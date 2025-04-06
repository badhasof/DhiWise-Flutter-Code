import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenueCatService {
  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // API keys
  static const String _iosApiKey = 'appl_cMlIZOukSOmYZWKJYEqGumIdNgu';
  // Android API key - to be added later
  static const String _androidApiKey = '';

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
      // Enable debug logs during development
      await Purchases.setLogLevel(LogLevel.debug);

      // Configure the SDK with appropriate API key
      PurchasesConfiguration configuration;
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_iosApiKey);
      } else {
        // We're focusing on iOS for now, but keeping the structure for Android
        debugPrint('Android not configured yet');
        return;
      }

      // Initialize the SDK
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('RevenueCat initialized successfully');
      
      // Set up listener for customer info updates to help with StoreKit issues
      if (Platform.isIOS) {
        Purchases.addCustomerInfoUpdateListener((info) {
          debugPrint('Customer info updated - checking entitlements');
          // This helps ensure all transactions are fully processed
        });
      }

      // Identify the current user
      await identifyUser();

      // Get initial customer info
      await refreshCustomerInfo();

    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
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

  // Fetch and cache offerings
  Future<Offerings?> fetchOfferings() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat not initialized');
      return null;
    }

    try {
      _offerings = await Purchases.getOfferings();
      debugPrint('Offerings fetched successfully');
      
      if (_offerings?.current != null) {
        debugPrint('Current offering: ${_offerings?.current?.identifier}');
        debugPrint('Available packages: ${_offerings?.current?.availablePackages.length}');
        
        for (var package in _offerings?.current?.availablePackages ?? []) {
          debugPrint('Package: ${package.identifier}, ${package.storeProduct.priceString}');
        }
      } else {
        debugPrint('No current offering available');
      }
      
      return _offerings;
    } on PlatformException catch (e) {
      debugPrint('Error fetching offerings: ${e.message}');
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
      return _customerInfo;
    } on PlatformException catch (e) {
      debugPrint('Error fetching customer info: ${e.message}');
      return null;
    }
  }

  // Check if user has active subscription
  bool hasActiveSubscription() {
    return _customerInfo?.entitlements.all.isNotEmpty ?? false;
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