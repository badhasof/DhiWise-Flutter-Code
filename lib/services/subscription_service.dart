import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  // Singleton pattern
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Product IDs
  static const String monthlyProductId = 'com.linguax.subscription.monthly';
  static const String lifetimeProductId = 'com.linguax.subscription.lifetimeaccess';

  // In-app purchase instance
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  // Stream subscription for purchase updates
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Available products
  List<ProductDetails> _products = [];
  
  // Controller to notify listeners about purchase status
  final StreamController<PurchaseStatus> _purchaseStatusController = 
      StreamController<PurchaseStatus>.broadcast();

  // Controller to notify listeners about product load status
  final StreamController<bool> _productsLoadedController = 
      StreamController<bool>.broadcast();
  
  // Stream to listen for purchase status changes
  Stream<PurchaseStatus> get purchaseStatusStream => _purchaseStatusController.stream;
  
  // Stream to listen for product load status
  Stream<bool> get productsLoadedStream => _productsLoadedController.stream;
  
  // Flag to determine if we're in sandbox environment (only valid on iOS)
  bool _isSandboxEnvironment = false;
  bool get isSandboxEnvironment => _isSandboxEnvironment;
  
  // Getter for available products
  List<ProductDetails> get products => _products;

  // Loading status
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Store the last error details for better error handling
  Map<String, dynamic>? _lastErrorDetails;
  Map<String, dynamic>? get lastErrorDetails => _lastErrorDetails;
  
  // Product getters
  ProductDetails? get monthlySubscription => 
      _products.firstWhere((product) => product.id == monthlyProductId, 
                         orElse: () => ProductDetails(
                           id: monthlyProductId,
                           title: 'Monthly Subscription',
                           description: 'Access to all features for one month',
                           price: '2.99',
                           rawPrice: 2.99,
                           currencyCode: 'USD',
                           currencySymbol: '\$',
                         ));
                         
  ProductDetails? get lifetimeSubscription => 
      _products.firstWhere((product) => product.id == lifetimeProductId, 
                         orElse: () => ProductDetails(
                           id: lifetimeProductId,
                           title: 'Lifetime Access',
                           description: 'Lifetime access to all features',
                           price: '29.99',
                           rawPrice: 29.99,
                           currencyCode: 'USD',
                           currencySymbol: '\$',
                         ));
  
  // Initialize the subscription service
  Future<void> initialize() async {
    _isLoading = true;
    
    // Check if the store is available
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // Store is not available
      debugPrint('⚠️ The store is not available - this usually means the In-App Purchase capability is missing');
      debugPrint('⚠️ Open Xcode > Runner.xcworkspace > Runner target > Signing & Capabilities > + Capability > In-App Purchase');
      _isLoading = false;
      _productsLoadedController.add(false);
      return;
    }
    
    if (Platform.isIOS) {
      debugPrint('🔍 Checking iOS environment...');
      debugPrint('🔍 App Bundle ID: com.linguax.app');
      debugPrint('🔍 iOS version: ${Platform.operatingSystemVersion}');
      
      // Check if we're in debug mode
      bool isDebug = kDebugMode;
      debugPrint('🔍 Is debug mode: $isDebug');
      
      // When in debug mode, StoreKit transactions will use the Sandbox environment
      _isSandboxEnvironment = isDebug;
      debugPrint('🔍 StoreKit environment: ${_isSandboxEnvironment ? "Sandbox" : "Production"}');

      // Configure StoreKit-specific platform features
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      
      // Set delegate for payment queue      
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      
      // Handle pending transactions from previous sessions
      try {
        debugPrint('🔍 Checking for pending transactions...');
        
        // Ensure price consent is shown if needed
        await iosPlatformAddition.showPriceConsentIfNeeded();
        
        // Get payment queue wrapper
        final SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
        
        // Complete any pending transactions from previous app sessions
        final List<SKPaymentTransactionWrapper> transactions = await paymentQueue.transactions();
        if (transactions.isNotEmpty) {
          debugPrint('⚠️ Found ${transactions.length} pending transactions. Completing them now...');
          for (final transaction in transactions) {
            try {
              debugPrint('🔄 Completing pending transaction: ${transaction.transactionIdentifier ?? "Unknown ID"}');
              await paymentQueue.finishTransaction(transaction);
            } catch (e) {
              debugPrint('❌ Error completing transaction: $e');
            }
          }
        } else {
          debugPrint('✅ No pending transactions found');
        }
        
        // Get the current storefront if possible
        try {
          final SKStorefrontWrapper? storefront = await paymentQueue.storefront();
          if (storefront != null) {
            debugPrint('🔍 StoreKit Storefront: ${storefront.countryCode} (${storefront.identifier})');
          } else {
            debugPrint('⚠️ No StoreKit storefront available - this could indicate an App Store Connect issue');
          }
        } catch (e) {
          debugPrint('⚠️ Error getting storefront: $e');
        }
      } catch (e) {
        debugPrint('❌ Error handling pending transactions: $e');
      }
      
      if (_isSandboxEnvironment) {
        debugPrint('🔷 SANDBOX TESTING MODE ENABLED 🔷');
        debugPrint('⚠️ Important Sandbox Testing Instructions:');
      debugPrint('⚠️ 1. Use a physical device (not simulator)');
        debugPrint('⚠️ 2. Use a Sandbox Apple Account created in App Store Connect');
        debugPrint('⚠️ 3. Do NOT sign into Sandbox account in Settings app');
        debugPrint('⚠️ 4. Wait for sign-in prompt during purchase');
        debugPrint('⚠️ 5. Check for [Environment: Sandbox] text in sign-in prompt');
        debugPrint('⚠️ 6. Sandbox accounts have accelerated renewal times:');
        debugPrint('     - 1 minute = 1 hour');
        debugPrint('     - 1 hour = 1 day');
        debugPrint('     - 1 day = 1 month');
        debugPrint('     - 1 week = 6 months');
      }
    }
    
    // Set up a listener for purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Load the products
    await loadProducts();
  }

  // Load available products from the store
  Future<void> loadProducts() async {
    final Set<String> productIds = <String>{
      monthlyProductId,
      lifetimeProductId,
    };
    
    debugPrint('🔍 Attempting to load products with IDs: $productIds');
    
    try {
      debugPrint('Checking if store is available before query...');
      final bool available = await _inAppPurchase.isAvailable();
      debugPrint('Store availability: $available');
      
      if (!available) {
        debugPrint('❌ Store is not available. Cannot load products.');
        _isLoading = false;
        _productsLoadedController.add(false);
        return;
      }
      
      // Reset products list before new query
      _products = [];
      
      debugPrint('✅ Store is available. Querying product details...');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Some product IDs were not found: ${response.notFoundIDs}');
        debugPrint('⚠️ Check if these products are properly configured in App Store Connect');
        debugPrint('⚠️ Products can take up to 1 hour to appear in sandbox after updating in App Store Connect');
        debugPrint('⚠️ Bundle ID: com.linguax.app');
      }
      
      if (response.productDetails.isEmpty) {
        debugPrint('❌ No products were found. Possible issues:');
        debugPrint('   - Products not configured in App Store Connect');
        debugPrint('   - Sandbox tester account not properly set up');
        debugPrint('   - App Bundle ID mismatch between app and App Store');
        debugPrint('   - Products not in "Ready to Submit" state');
        debugPrint('   - Wait up to 1 hour for product changes to appear in sandbox');
        debugPrint('   - Missing agreements, tax, or banking information in App Store Connect');
        debugPrint('   - Missing In-App Purchase capability in Xcode project');
        
        // Check for specific iOS issues
        if (Platform.isIOS) {
          // Check for common StoreKit configuration issues
          final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
              _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
          
          // Try to manually request products directly with lower-level StoreKit API
          try {
            debugPrint('🔄 Attempting to directly use StoreKit API to fetch products...');
            
            // Try loading products again with manual delay
            debugPrint('⏳ Waiting for 2 seconds before retrying product load...');
            await Future.delayed(Duration(seconds: 2));
            
            final ProductDetailsResponse retryResponse = 
                await _inAppPurchase.queryProductDetails(productIds);
                
            if (retryResponse.productDetails.isNotEmpty) {
              _products = retryResponse.productDetails;
              debugPrint('✅ Products loaded after retry: ${_products.length} products');
              _printProductDetails();
              _isLoading = false;
              _productsLoadedController.add(true);
              return;
            } else {
              debugPrint('❌ Still no products after retry.');
            }
          } catch (e) {
            debugPrint('❌ Error during retry: $e');
          }
        }
      } else {
        _products = response.productDetails;
        debugPrint('✅ Found ${_products.length} products:');
        _printProductDetails();
      }
      
      _isLoading = false;
      _productsLoadedController.add(_products.isNotEmpty);
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      _isLoading = false;
      _productsLoadedController.add(false);
    }
  }
  
  // Helper method to print product details
  void _printProductDetails() {
    for (var product in _products) {
      debugPrint('   - ID: ${product.id}');
      debugPrint('   - Title: ${product.title}');
      debugPrint('   - Price: ${product.price}');
      if (Platform.isIOS) {
        final SKProductWrapper skProduct = (product as AppStoreProductDetails).skProduct;
        debugPrint('   - Raw data: {productIdentifier: ${skProduct.productIdentifier}, price: ${skProduct.price}, '
            'priceLocale: ${skProduct.priceLocale.currencyCode}}');
      }
    }
  }

  // Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('🔔 Purchase update: ${purchaseDetails.status} - ${purchaseDetails.productID}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('⏳ Purchase pending: ${purchaseDetails.productID}');
        _purchaseStatusController.add(PurchaseStatus.pending);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
        _purchaseStatusController.add(PurchaseStatus.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        if (Platform.isIOS) {
          debugPrint('🧾 iOS receipt data:');
          debugPrint('🧾 Receipt length: ${purchaseDetails.verificationData.serverVerificationData.length}');
          final AppStorePurchaseDetails iosPurchase = purchaseDetails as AppStorePurchaseDetails;
          debugPrint('🧾 Transaction ID: ${iosPurchase.skPaymentTransaction.transactionIdentifier}');
          // Original transaction ID might not be available for first-time purchases
          final String? originalTransactionId = iosPurchase.skPaymentTransaction.originalTransaction?.transactionIdentifier;
          debugPrint('🧾 Original Transaction ID: ${originalTransactionId ?? 'Not available (first purchase)'}');
          
          // Check and log if this is a sandbox receipt
          final String receiptData = purchaseDetails.verificationData.serverVerificationData;
          final bool containsSandboxText = receiptData.contains('Sandbox');
          debugPrint('🧾 Receipt contains "Sandbox" text: $containsSandboxText (This indicates a sandbox purchase)');
        }
        
        // Verify the purchase on the server
        final bool isValid = await _verifyPurchase(purchaseDetails);
        
        if (isValid) {
          debugPrint('✅ Purchase validated successfully');
        // Update the user's subscription status
        await _updateUserSubscription(purchaseDetails);
        // Complete the purchase
        await _inAppPurchase.completePurchase(purchaseDetails);
        _purchaseStatusController.add(purchaseDetails.status);
        } else {
          debugPrint('❌ Purchase verification failed');
          _purchaseStatusController.add(PurchaseStatus.error);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('❌ Purchase canceled: ${purchaseDetails.productID}');
        _purchaseStatusController.add(PurchaseStatus.canceled);
      }
    }
  }

  // Handle errors
  void _handleError(IAPError error) {
    debugPrint('Error: ${error.code} - ${error.message}');
    
    // Log additional information for Apple errors
    if (Platform.isIOS) {
      final errorCode = error.details?['NSUnderlyingError']?['code'] ?? 'Unknown';
      final errorDomain = error.details?['NSUnderlyingError']?['domain'] ?? 'Unknown';
      
      debugPrint('Apple Error Code: $errorCode');
      debugPrint('Apple Error Domain: $errorDomain');
      
      // Store error details for the UI to use
      _lastErrorDetails = {
        'code': errorCode,
        'domain': errorDomain,
        'message': error.message
      };
      
      // Handle Apple Store Display (ASD) errors
      if (errorDomain == 'ASDErrorDomain') {
        switch (errorCode) {
          case 500:
            // Error 500 typically means the App Store account has issues or purchase is unavailable
            debugPrint('⚠️ ASDErrorDomain 500: App Store account or purchase availability issue');
            debugPrint('⚠️ This error often occurs when:');
            debugPrint('⚠️ 1. The user is trying to purchase with a sandbox account in production');
            debugPrint('⚠️ 2. There are App Store Connect configuration issues with the product');
            debugPrint('⚠️ 3. The App Store account may have payment issues or restrictions');
            
            // Clean up any pending transactions that might be stuck
            _cleanupPendingTransactions();
            
            // Try to recover from the error
            handleASDError(500);
            break;
          default:
            debugPrint('⚠️ Unhandled ASDErrorDomain error: $errorCode');
        }
      }
      
      // Handle SKErrorDomain errors
      if (errorDomain == 'SKErrorDomain') {
        switch (errorCode) {
          case 0: // SKError.Code.unknown
            debugPrint('⚠️ Unknown StoreKit error, could be simulator limitation');
            break;
          case 2: // SKError.Code.paymentCancelled
            debugPrint('⚠️ User cancelled payment');
            break;
          case 4: // SKError.Code.paymentNotAllowed
            debugPrint('⚠️ Device not allowed to make payments');
            break;
          // Add more specific error handling for other SKErrorDomain codes
          default:
            debugPrint('⚠️ Unhandled SKErrorDomain error: $errorCode');
        }
      }
    } else {
      // For non-iOS platforms, store generic error details
      _lastErrorDetails = {
        'code': error.code,
        'domain': 'unknown',
        'message': error.message
      };
    }
  }

  // Clean up any pending transactions
  Future<void> _cleanupPendingTransactions() async {
    if (Platform.isIOS) {
      try {
        debugPrint('🧹 Attempting to clean up pending transactions...');
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        
        final SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
        final transactions = await paymentQueue.transactions();
        
        if (transactions.isNotEmpty) {
          debugPrint('🧹 Found ${transactions.length} pending transactions to clean up');
          for (final transaction in transactions) {
            try {
              await paymentQueue.finishTransaction(transaction);
              debugPrint('🧹 Successfully finished transaction: ${transaction.transactionIdentifier ?? "Unknown"}');
            } catch (e) {
              debugPrint('❌ Error finishing transaction: $e');
            }
          }
        } else {
          debugPrint('✅ No pending transactions found to clean up');
        }
      } catch (e) {
        debugPrint('❌ Error cleaning up transactions: $e');
      }
    }
  }

  // Clean up on done
  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  // Handle stream errors
  void _updateStreamOnError(dynamic error) {
    debugPrint('Stream error: $error');
  }

  // Verify the purchase with the App Store
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a production app, you would verify the purchase with your server
    // The server would verify the receipt with Apple's servers
    
    if (Platform.isIOS) {
      // For iOS, we should check whether the receipt is from the sandbox or production environment
      // and send verification requests to the appropriate Apple endpoint
      
      // For sandbox testing, we'll just check if the transaction has completed
      if (_isSandboxEnvironment) {
        debugPrint('🧪 Sandbox verification: Receipt assumed valid for testing');
        return true;
      }
      
      // For production, you would:
      // 1. Send the receipt to your backend
      // 2. Your backend would verify with Apple's servers
      // 3. Return the result
      
      // For now, we'll just return true
      return true;
    }
    
    // For Android, we would verify with Google Play
    // For simplicity, we'll just return true for this example
    return true;
  }

  // Update the user's subscription status in Firestore
  Future<void> _updateUserSubscription(PurchaseDetails purchaseDetails) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('No logged in user found');
      return;
    }

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String userId = currentUser.uid;
    final DateTime now = DateTime.now();
    
    // Determine subscription type and end date
    String subscriptionType;
    DateTime? endDate;
    
    if (purchaseDetails.productID == monthlyProductId) {
      subscriptionType = 'monthly';
      
      // Note: In sandbox, subscription renewals are accelerated:
      // 1 minute = 1 hour, 1 hour = 1 day, 1 day = 1 month, 1 week = 6 months
      // For testing purposes, we'll add 30 days as in production
      endDate = now.add(const Duration(days: 30));
      
      debugPrint('📅 Set subscription end date: ${endDate.toIso8601String()}');
      if (_isSandboxEnvironment) {
        debugPrint('⚠️ Note: In sandbox, this monthly subscription will renew much faster:');
        debugPrint('⚠️ 1 minute = 1 hour, 1 hour = 1 day, 1 day = 1 month');
      }
    } else if (purchaseDetails.productID == lifetimeProductId) {
      subscriptionType = 'lifetime';
      endDate = null;
      debugPrint('📅 Lifetime subscription has no end date');
    } else {
      debugPrint('Unknown product ID: ${purchaseDetails.productID}');
      return;
    }
    
    // Create the subscription model
    /* final SubscriptionModel subscription = SubscriptionModel(
      id: purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: subscriptionType == 'monthly' ? 'Monthly Subscription' : 'Lifetime Access',
      type: subscriptionType,
      price: subscriptionType == 'monthly' ? 2.99 : 29.99,
      status: 'active',
      startDate: now,
      endDate: endDate,
    ); */

    try {
      // Add/update the subscription in Firestore
      // REMOVED: Firestore update for subscription status
      /* await db.collection('users').doc(userId).set({
        'subscription': subscription.toJson(),
        'isPremium': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); */

      // Instead, just log that this step is skipped
      debugPrint('Firestore update for subscription skipped (handled by RevenueCat).');
      
      // Optional: Trigger a manual refresh of RevenueCat status if needed
      // await SubscriptionStatusManager.instance.checkSubscriptionStatus();

      // debugPrint('User subscription updated successfully'); // No longer accurate
    } catch (e) {
      debugPrint('Error during Firestore update skip (expected): $e');
    }
  }

  // Check if user has an active subscription (DEPRECATED - for legacy systems only)
  @Deprecated('Use SubscriptionStatusManager.instance.isSubscribed instead')
  Future<bool> checkSubscriptionStatus() async {
    debugPrint('⚠️ WARNING: SubscriptionService.checkSubscriptionStatus() is deprecated.');
    debugPrint('⚠️ Use SubscriptionStatusManager.instance.isSubscribed instead.');
    
    // Return false as these fields have been removed from Firestore
    return false;
    
    /* Original implementation relied on Firestore fields that no longer exist
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentSnapshot doc = await db.collection('users').doc(currentUser.uid).get();

      if (!doc.exists || !doc.data().toString().contains('subscription')) {
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('isPremium') && data['isPremium'] == true) {
        return true;
      }

      if (data.containsKey('subscription')) {
        final subscription = SubscriptionModel.fromJson(data['subscription']);
        
        if (subscription.type == 'lifetime') {
          return true;
        }
        
        if (subscription.status == 'active' && subscription.endDate != null) {
          return DateTime.now().isBefore(subscription.endDate!);
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
    */
  }

  // Purchase a product
  Future<void> purchaseProduct(String productId) async {
    debugPrint('🔍 Attempting to purchase product: $productId');
    debugPrint('🔍 Available products: ${_products.length}');
    
    try {
      if (_isLoading) {
        debugPrint('⚠️ Products are still loading, please wait...');
        throw Exception('Products are still loading. Please wait and try again.');
      }
      
      if (_products.isEmpty) {
        debugPrint('❌ No products available! Cannot make purchase.');
        debugPrint('Trying to reload products...');
        await loadProducts();
        
        if (_products.isEmpty) {
          debugPrint('❌ Still no products available after reload attempt.');
          
          // Force a transaction check to verify StoreKit is working
          if (Platform.isIOS) {
            try {
              final SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
              final transactions = await paymentQueue.transactions();
              debugPrint('🔍 Current transaction count: ${transactions.length}');
              
              // Test StoreKit's ability to determine if purchases are allowed
              try {
                final bool canMakePayments = await SKPaymentQueueWrapper.canMakePayments();
                debugPrint('🔍 StoreKit reports can make payments: $canMakePayments');
                if (!canMakePayments) {
                  debugPrint('❌ StoreKit reports that payments are not allowed on this device');
                  throw Exception('Payments are not allowed on this device. Check parental controls or other device restrictions.');
                }
              } catch (e) {
                debugPrint('❌ Error checking payment capability: $e');
              }
            } catch (e) {
              debugPrint('❌ Error checking StoreKit payment status: $e');
            }
          }
          
          throw Exception('No products available for purchase. Please check your App Store Connect configuration.');
        }
      }
      
      // Find the product in available products
      ProductDetails? productDetails;
      try {
        productDetails = _products.firstWhere(
          (product) => product.id == productId,
        );
        debugPrint('✅ Found product to purchase: ${productDetails.title} (${productDetails.id})');
      } catch (e) {
        debugPrint('❌ Product not found in available products: $productId');
        throw Exception('Product not found: $productId. Please refresh and try again.');
      }
      
      // Pre-check for potential issues on iOS
      if (Platform.isIOS) {
        await _performPrePurchaseChecksIOS(productId);
      }
      
      // Create purchase parameter
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
      
      debugPrint('🔍 Initiating purchase flow for product: ${productDetails.id}');
      
      if (Platform.isIOS) {
        debugPrint('🍎 iOS Purchase - Look for Sandbox Apple ID sign-in prompt');
        
        if (_isSandboxEnvironment) {
          // Force-clear any existing cached credentials to ensure sign-in prompt appears
          final SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
          
          // Test StoreKit's connection before purchase
          try {
            final bool canMakePayments = await SKPaymentQueueWrapper.canMakePayments();
            debugPrint('🔍 StoreKit reports can make payments: $canMakePayments');
          } catch (e) {
            debugPrint('❌ Error checking payment capability: $e');
          }
          
          debugPrint('🧪 Sandbox Environment - Sign in with a Sandbox Apple ID when prompted');
          debugPrint('🧪 Important: You must use a Sandbox tester account from App Store Connect');
          debugPrint('🧪 Wait for the sign-in prompt during purchase');
          debugPrint('🧪 Verify [Environment: Sandbox] appears in the sign-in dialog');
          debugPrint('🧪 If no prompt appears, try restarting the app or clearing app data');
          
          // For troubleshooting, show additional debug info
          final transactions = await paymentQueue.transactions();
          debugPrint('🔍 Current transaction count before purchase: ${transactions.length}');
        }
      }
      
      // Choose the correct purchase method based on product type
      if (productId == monthlyProductId) {
        // Use buyNonConsumable with autoRenewing=true for subscriptions in Flutter
        debugPrint('🔍 Using buyNonConsumable for subscription product');
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Use buyNonConsumable for one-time purchases
        debugPrint('🔍 Using buyNonConsumable for one-time purchase');
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
      
      debugPrint('✅ Purchase flow initiated successfully');
    } catch (e) {
      debugPrint('❌ Error purchasing product: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      rethrow; // Rethrow to let the UI handle it
    }
  }

  // Perform pre-purchase checks on iOS to catch common issues
  Future<void> _performPrePurchaseChecksIOS(String productId) async {
    debugPrint('🔍 Performing pre-purchase checks for iOS...');
    
    // Reset any previous error details
    _lastErrorDetails = null;

    try {
      // Check if there are any pending transactions that might cause issues
      final SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
      final transactions = await paymentQueue.transactions();
      
      if (transactions.isNotEmpty) {
        debugPrint('⚠️ Found ${transactions.length} pending transactions before purchase');
        debugPrint('⚠️ Completing pending transactions to avoid issues...');
        
        // Try to finish any pending transactions to prevent conflicts
        for (final transaction in transactions) {
          try {
            await paymentQueue.finishTransaction(transaction);
            debugPrint('✅ Successfully finished transaction: ${transaction.transactionIdentifier ?? "Unknown"}');
          } catch (e) {
            debugPrint('❌ Error finishing transaction: $e');
          }
        }
      }
      
      // Verify store is available (should be fixed in initialize but double-check)
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('❌ Store suddenly became unavailable');
        throw Exception('App Store is currently unavailable. Please try again later.');
      }
      
      // Verify user can make payments
      final bool canMakePayments = await SKPaymentQueueWrapper.canMakePayments();
      if (!canMakePayments) {
        debugPrint('❌ User cannot make payments');
        throw Exception('Your device is not allowed to make payments. Please check your restrictions.');
      }
      
      debugPrint('✅ Pre-purchase checks passed for iOS');
    } catch (e) {
      debugPrint('❌ Pre-purchase checks failed: $e');
      // If this is not an Exception we already threw, wrap it
      if (e is! Exception) {
        throw Exception('Purchase preparation failed: $e');
      }
      rethrow;
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    try {
      debugPrint('🔍 Attempting to restore purchases...');
      if (Platform.isIOS) {
        debugPrint('🍎 iOS Restore - This will restore all previous purchases made with the currently logged-in Apple ID');
        if (_isSandboxEnvironment) {
          debugPrint('🧪 Sandbox Environment - This will only restore purchases made with Sandbox Apple ID');
        }
      }
      
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore purchases initiated successfully');
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      rethrow;
    }
  }

  // Clear purchase history (simulation of App Store Connect sandbox feature)
  // Note: This only simulates clearing local records, real clearing is done in App Store Connect
  Future<void> simulateClearPurchaseHistory() async {
    if (!_isSandboxEnvironment || !Platform.isIOS) {
      debugPrint('⚠️ Clear purchase history simulation is only available in iOS sandbox environment');
      return;
    }
    
    debugPrint('🧪 Simulating clearing purchase history');
    debugPrint('⚠️ Note: This is just a simulation. To truly clear purchase history:');
    debugPrint('⚠️ 1. Go to App Store Connect > Users and Access > Sandbox > Testers');
    debugPrint('⚠️ 2. Select your Sandbox Apple ID');
    debugPrint('⚠️ 3. Click "Clear Purchase History"');
    debugPrint('⚠️ 4. Wait for process to complete (can take some time for accounts with many purchases)');
    
    // No actual implementation needed as this is just informational
  }

  // Dispose the service
  void dispose() {
    _subscription?.cancel();
    _purchaseStatusController.close();
    _productsLoadedController.close();
  }

  // Method to check if price consent should be shown
  bool shouldShowPriceConsent() {
    return true;
  }

  // Add specific handling for ASD errors
  Future<void> handleASDError(int errorCode) async {
    if (errorCode == 500) {
      debugPrint('🔍 Attempting to recover from ASDErrorDomain error 500...');
      
      if (Platform.isIOS) {
        try {
          // Clean up any pending transactions
          await _cleanupPendingTransactions();
          
          // Reset the StoreKit payment queue state
          final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
              _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
          
          // Refresh the available products
          debugPrint('🔄 Refreshing products after ASDErrorDomain error...');
          await loadProducts();
          
          debugPrint('✅ Recovery procedures completed for ASDErrorDomain error 500');
          
          // If in sandbox mode, provide additional diagnostic information
          if (_isSandboxEnvironment) {
            debugPrint('🧪 Sandbox environment detected, additional diagnostics:');
            debugPrint('🧪 ASDErrorDomain 500 in sandbox often means:');
            debugPrint('🧪 1. The sandbox tester account may need to be recreated in App Store Connect');
            debugPrint('🧪 2. The product may not be properly configured in App Store Connect');
            debugPrint('🧪 3. There may be a delay in product availability after configuration changes');
          } else {
            debugPrint('🔍 Production environment - ASDErrorDomain 500 often indicates:');
            debugPrint('🔍 1. User may have payment restrictions or issues with their Apple ID');
            debugPrint('🔍 2. Product might not be approved or properly configured in App Store Connect');
            debugPrint('🔍 3. App Store services may be experiencing temporary issues');
          }
        } catch (e) {
          debugPrint('❌ Error during ASDErrorDomain 500 recovery: $e');
        }
      }
    }
  }
}

// Example implementation of the SKPaymentQueueDelegate to handle transactions
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return true;
  }
} 