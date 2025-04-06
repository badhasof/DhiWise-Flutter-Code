import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class RevenueCatService {
  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // API keys
  static const String _iosApiKey = 'appl_cMlIZOukSOmYZWKJYEqGumIdNgu';
  // Android API key
  static const String _androidApiKey = 'goog_ByHJNQbxPIcheDuRuSLYYlktEsq';

  // Flag to track initialization
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Current offerings
  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  // Current customer info
  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  // Maximum retries for purchase operations
  static const int _maxPurchaseRetries = 3;

  // Initialize the RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RevenueCat already initialized');
      return;
    }

    try {
      debugPrint('⚙️ Initializing RevenueCat SDK...');
      final initStopwatch = Stopwatch()..start();
      
      // Enable debug logs during development
      await Purchases.setLogLevel(LogLevel.debug);

      // Configure the SDK with appropriate API key
      PurchasesConfiguration configuration;
      if (Platform.isIOS) {
        debugPrint('🍎 Configuring RevenueCat for iOS with API key: ${_iosApiKey.substring(0, 8)}...');
        configuration = PurchasesConfiguration(_iosApiKey);
      } else if (Platform.isAndroid) {
        debugPrint('🤖 Configuring RevenueCat for Android with API key: ${_androidApiKey.substring(0, 8)}...');
        configuration = PurchasesConfiguration(_androidApiKey);
      } else {
        debugPrint('⚠️ Unsupported platform for RevenueCat');
        return;
      }

      // Initialize the SDK with timeout
      await Purchases.configure(configuration).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('RevenueCat configuration timed out after 10 seconds');
        }
      );
      
      initStopwatch.stop();
      debugPrint('⏱️ RevenueCat configuration took ${initStopwatch.elapsedMilliseconds}ms');
      
      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
      
      // Set up listener for customer info updates to help with StoreKit issues
      if (Platform.isIOS) {
        Purchases.addCustomerInfoUpdateListener((info) {
          debugPrint('👤 Customer info updated - checking entitlements');
          // Log the entitlements for debugging
          info.entitlements.all.forEach((key, entitlement) {
            debugPrint('Entitlement: $key, isActive: ${entitlement.isActive}');
          });
        });
      }

      // Identify the current user
      await identifyUser();

      // Get initial customer info
      await refreshCustomerInfo();

    } on TimeoutException {
      debugPrint('⏱️ RevenueCat initialization timed out - network may be slow or unavailable');
    } catch (e) {
      debugPrint('❌ Error initializing RevenueCat: $e');
    }
  }

  // Identify the current user with RevenueCat
  Future<void> identifyUser() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat not initialized');
      return;
    }

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final String userId = currentUser.uid;
        debugPrint('Identifying user with RevenueCat: $userId');
        await Purchases.logIn(userId);
        debugPrint('User identified successfully with RevenueCat');
      } else {
        debugPrint('No logged-in user found for RevenueCat identification');
      }
    } catch (e) {
      debugPrint('Error identifying user with RevenueCat: $e');
    }
  }

  // Fetch available offerings from RevenueCat
  Future<Offerings?> fetchOfferings() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Initializing now before fetching offerings...');
      await initialize();
    }
    
    try {
      debugPrint('🔍 Fetching offerings from RevenueCat - START');
      final stopwatch = Stopwatch()..start();
      
      // Add timeout to the Purchases.getOfferings call
      final offerings = await Purchases.getOfferings().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏱️ TIMEOUT: RevenueCat offerings fetch took too long (15+ seconds)');
          throw TimeoutException('RevenueCat offerings fetch timed out after 15 seconds');
        }
      );
      
      stopwatch.stop();
      debugPrint('⏱️ RevenueCat offerings fetch took ${stopwatch.elapsedMilliseconds}ms');
      
      // Debug offerings
      if (offerings.current == null) {
        debugPrint('❌ No current offering found');
      } else {
        debugPrint('✅ Current offering found: ${offerings.current!.identifier}');
      }
      
      if (offerings.all.isEmpty) {
        debugPrint('❌ No offerings found in RevenueCat console');
      } else {
        debugPrint('✅ Found ${offerings.all.length} offerings: ${offerings.all.keys.join(', ')}');
      }
      
      return offerings;
    } on TimeoutException {
      debugPrint('❌ RevenueCat offerings fetch timed out - check network connection and RevenueCat API status');
      return null;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('❌ Error fetching offerings: ${e.message}, code: $errorCode');
      
      // More detailed error diagnostics
      if (errorCode == PurchasesErrorCode.networkError) {
        debugPrint('💡 Network error - check device connectivity and RevenueCat status page');
      } else if (errorCode == PurchasesErrorCode.configurationError) {
        debugPrint('💡 Configuration error - verify API keys and project settings');
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Unknown error fetching offerings: $e');
      return null;
    }
  }

  // Refresh customer info
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat not initialized');
      return null;
    }

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      debugPrint('Customer info fetched successfully');
      
      // Debug output for entitlements
      if (_customerInfo != null) {
        debugPrint('Available entitlements: ${_customerInfo!.entitlements.all.keys.join(', ')}');
        _customerInfo!.entitlements.all.forEach((key, entitlement) {
          debugPrint('Entitlement: $key, isActive: ${entitlement.isActive}, identifier: ${entitlement.identifier}');
          debugPrint('   productIdentifier: ${entitlement.productIdentifier}');
        });
      }
      
      return _customerInfo;
    } on PlatformException catch (e) {
      debugPrint('Error fetching customer info: ${e.message}');
      return null;
    }
  }

  // Check if user has active subscription
  bool hasActiveSubscription() {
    if (_customerInfo == null) return false;
    
    // Look for any active entitlement, primarily 'Premium'
    final hasEntitlement = _customerInfo!.entitlements.all.values.any((entitlement) => entitlement.isActive);
    debugPrint('hasActiveSubscription check: $hasEntitlement');
    return hasEntitlement;
  }

  // Purchase a package with retry logic for StoreKit issues
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) {
      debugPrint('RevenueCat not initialized');
      return false;
    }

    int retryCount = 0;
    while (retryCount < _maxPurchaseRetries) {
      try {
        debugPrint('Attempting purchase of ${package.identifier} (Attempt ${retryCount + 1})');
        
        // If this is a retry, try to refresh the offerings
        if (retryCount > 0) {
          debugPrint('Refreshing offerings before retry attempt...');
          await fetchOfferings();
          
          // Get fresh package reference
          final freshPackage = _offerings?.current?.availablePackages.firstWhere(
            (p) => p.identifier == package.identifier,
            orElse: () => package, // Fallback to original if not found
          );
          
          // Use the fresh package if found
          if (freshPackage != null && freshPackage != package) {
            debugPrint('Using fresh package reference for retry');
            package = freshPackage;
          }
        }
        
        final purchaseResult = await Purchases.purchasePackage(package);
        _customerInfo = purchaseResult;
        
        debugPrint('Purchase completed successfully');
        return _customerInfo?.entitlements.all.isNotEmpty ?? false;
        
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        
        // Handle specific purchase errors
        if (errorCode == PurchasesErrorCode.receiptAlreadyInUseError) {
          debugPrint('Receipt already in use - try restoring purchases');
          return await restorePurchases();
        } else if (errorCode == PurchasesErrorCode.invalidReceiptError || 
                 e.message?.contains('receipt is not valid') == true ||
                 e.message?.contains('missing in the receipt') == true) {
          
          debugPrint('Invalid receipt error detected - ${e.message}');
          
          // For receipt validation errors, wait and retry
          if (retryCount < _maxPurchaseRetries - 1) {
            retryCount++;
            debugPrint('Waiting before retry attempt ${retryCount + 1}...');
            await Future.delayed(Duration(seconds: 2 * retryCount)); // Progressive backoff
            continue;
          }
        } else if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          debugPrint('Purchase was cancelled by user');
          return false;
        } else {
          debugPrint('Error making purchase: ${e.message}');
        }
        
        return false;
      } catch (e) {
        debugPrint('Unexpected error during purchase: $e');
        return false;
      }
      
      retryCount++;
    }
    
    debugPrint('Purchase failed after $_maxPurchaseRetries attempts');
    return false;
  }

  // Restore purchases with retry logic
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat not initialized');
      return false;
    }

    int retryCount = 0;
    while (retryCount < _maxPurchaseRetries) {
      try {
        debugPrint('Attempting to restore purchases (Attempt ${retryCount + 1})');
        _customerInfo = await Purchases.restorePurchases();
        debugPrint('Purchases restored successfully');
        return _customerInfo?.entitlements.all.isNotEmpty ?? false;
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        
        // Handle specific restore errors
        if (errorCode == PurchasesErrorCode.invalidReceiptError || 
            e.message?.contains('receipt is not valid') == true) {
          
          debugPrint('Invalid receipt error during restore - ${e.message}');
          
          // For receipt validation errors, wait and retry
          if (retryCount < _maxPurchaseRetries - 1) {
            retryCount++;
            debugPrint('Waiting before retry attempt ${retryCount + 1}...');
            await Future.delayed(Duration(seconds: 2 * retryCount)); // Progressive backoff
            continue;
          }
        } else {
          debugPrint('Error restoring purchases: ${e.message}');
        }
        
        return false;
      } catch (e) {
        debugPrint('Unexpected error restoring purchases: $e');
        return false;
      }
      
      retryCount++;
    }
    
    debugPrint('Restore failed after $_maxPurchaseRetries attempts');
    return false;
  }
} 