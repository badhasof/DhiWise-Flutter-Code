import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_service.dart';

class RevenueCatOfferingManager {
  // Singleton pattern
  static final RevenueCatOfferingManager _instance = RevenueCatOfferingManager._internal();
  factory RevenueCatOfferingManager() => _instance;
  RevenueCatOfferingManager._internal();

  // RevenueCat service instance
  final _revenueCatService = RevenueCatService();
  
  // Current offerings cache
  Offerings? _currentOfferings;
  
  // Entitlement ID for your subscription
  static const String entitlementId = 'Lifetime Access';
  
  // Fetch and display offerings
  Future<Offerings?> fetchAndDisplayOfferings() async {
    try {
      // Fetch offerings from RevenueCat
      _currentOfferings = await _revenueCatService.fetchOfferings();
      
      if (_currentOfferings == null) {
        debugPrint('No offerings available');
        return null;
      }
      
      // Log current offering information
      debugPrint('Current Offering: ${_currentOfferings!.current}');
      
      if (_currentOfferings!.current != null && 
          _currentOfferings!.current!.availablePackages.isNotEmpty) {
        
        debugPrint('Available Packages:');
        for (var package in _currentOfferings!.current!.availablePackages) {
          debugPrint('  - ${package.identifier}: ${package.storeProduct.title}');
          debugPrint('    Price: ${package.storeProduct.priceString}');
          debugPrint('    Description: ${package.storeProduct.description}');
        }
        
        // Check for and log any metadata in the offering
        if (_currentOfferings!.current!.metadata.isNotEmpty) {
          debugPrint('Offering Metadata:');
          _currentOfferings!.current!.metadata.forEach((key, value) {
            debugPrint('  - $key: $value');
          });
        }
      } else {
        debugPrint('No packages available in the current offering');
      }
      
      return _currentOfferings;
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }
  
  // Get monthly subscription package if available
  Package? getMonthlyPackage() {
    if (_currentOfferings?.current == null) return null;
    
    // Try to find a package with "monthly" in the identifier
    return _currentOfferings!.current!.availablePackages.firstWhere(
      (package) => package.identifier.toLowerCase().contains('monthly'),
      orElse: () => _currentOfferings!.current!.availablePackages.first,
    );
  }
  
  // Get lifetime access package if available
  Package? getLifetimePackage() {
    if (_currentOfferings?.current == null) return null;
    
    // Try to find a package with "lifetime" in the identifier
    try {
      return _currentOfferings!.current!.availablePackages.firstWhere(
        (package) => package.identifier.toLowerCase().contains('lifetime'),
      );
    } catch (e) {
      // Return null if no lifetime package is found
      return null;
    }
  }
  
  // Implementation of Task 3.1: Purchase Flow
  Future<PurchaseResult> purchasePackage(Package package, [bool? isLifetime]) async {
    try {
      // Check if this is a lifetime purchase if not explicitly provided
      final bool isLifetimePurchase = isLifetime ?? package.identifier.toLowerCase().contains('lifetime');
      debugPrint('🛒 Purchasing package: ${package.identifier} (${isLifetimePurchase ? 'LIFETIME' : 'SUBSCRIPTION'})');
      
      // Check current entitlement status
      final CustomerInfo currentInfo = await Purchases.getCustomerInfo();
      final bool hasActiveSubscription = currentInfo.entitlements.all[entitlementId]?.isActive ?? false;
      
      if (hasActiveSubscription && isLifetimePurchase) {
        debugPrint('⚠️ User already has an active subscription and is purchasing lifetime access');
        // We'll proceed with the purchase and RevenueCat will handle the subscription management
      }
      
      // Perform the purchase
      CustomerInfo? customerInfo;
      
      // Add retry logic for StoreKit receipt validation errors
      int retryCount = 0;
      bool purchaseSuccessful = false;
      
      while (retryCount < 3 && !purchaseSuccessful) {
        try {
          if (retryCount > 0) {
            debugPrint('🔄 StoreKit receipt retry attempt ${retryCount}');
            await Future.delayed(Duration(seconds: 1 * retryCount)); // Progressive backoff
          }
          
          customerInfo = await Purchases.purchasePackage(package);
          purchaseSuccessful = true;
        } on PlatformException catch (e) {
          final errorCode = PurchasesErrorHelper.getErrorCode(e);
          
          // Only retry for receipt validation errors
          if ((errorCode == PurchasesErrorCode.invalidReceiptError || 
              e.message?.contains('receipt is not valid') == true ||
              e.message?.contains('missing in the receipt') == true) && 
              retryCount < 2) {
            debugPrint('⚠️ Receipt validation error, retrying: ${e.message}');
            retryCount++;
            continue;
          }
          
          // For other errors, or if we've used all our retries, rethrow
          rethrow;
        }
      }
      
      // If we're here and customerInfo is still null after retries, throw an error
      if (customerInfo == null) {
        throw Exception('Failed to complete purchase after multiple attempts');
      }
      
      // Check if the specific entitlement is active
      if (customerInfo.entitlements.all[entitlementId]?.isActive == true) {
        debugPrint('✅ Purchase successful! Entitlement active.');
        
        // If this was a lifetime purchase and user had existing subscription, log additional info
        if (isLifetimePurchase) {
          debugPrint('🎉 Lifetime purchase successful. RevenueCat will manage any existing subscriptions.');
          
          // Check for changes in active subscription products
          final Set<String> previousProducts = Set.from(currentInfo.activeSubscriptions);
          final Set<String> currentProducts = Set.from(customerInfo.activeSubscriptions);
          
          debugPrint('📋 Previous active products: ${previousProducts.join(', ')}');
          debugPrint('📋 Current active products: ${currentProducts.join(', ')}');
        }
        
        // Log entitlement details
        final entitlement = customerInfo.entitlements.all[entitlementId];
        if (entitlement != null) {
          debugPrint('📝 Entitlement details:');
          debugPrint('   - Product ID: ${entitlement.productIdentifier}');
          debugPrint('   - Will renew: ${entitlement.willRenew}');
          if (entitlement.expirationDate != null) {
            debugPrint('   - Expires: ${entitlement.expirationDate}');
          } else {
            debugPrint('   - No expiration date (could be lifetime)');
          }
        }
        
        // Return result with success
        return PurchaseResult(
          success: true,
          customerInfo: customerInfo,
          message: isLifetimePurchase 
            ? 'Lifetime access purchased successfully! You now have permanent premium access.'
            : 'Subscription purchased successfully! You now have premium access.',
        );
      } else {
        debugPrint('⚠️ Purchase completed, but entitlement is not active.');
        
        // Perform additional validation and refresh
        await Future.delayed(Duration(seconds: 1));
        final refreshedInfo = await Purchases.getCustomerInfo();
        
        // Check again after refresh
        if (refreshedInfo.entitlements.all[entitlementId]?.isActive == true) {
          debugPrint('✅ Entitlement became active after refresh!');
          return PurchaseResult(
            success: true,
            customerInfo: refreshedInfo,
            message: isLifetimePurchase 
              ? 'Lifetime access purchased successfully! You now have permanent premium access.'
              : 'Subscription purchased successfully! You now have premium access.',
          );
        }
        
        // Return result indicating successful purchase but no active entitlement
        return PurchaseResult(
          success: false,
          customerInfo: customerInfo,
          message: 'Purchase processed, but subscription is not active. Please contact support.',
        );
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage;
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        errorMessage = 'Purchase cancelled.';
        debugPrint('❌ ' + errorMessage);
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        errorMessage = 'Payment is pending. Access will be granted once payment is completed.';
        debugPrint('⏳ ' + errorMessage);
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        errorMessage = 'Product already purchased. Please restore your purchases.';
        debugPrint('🔄 ' + errorMessage);
        
        // Try to restore purchases automatically
        try {
          debugPrint('🔄 Attempting automatic restore...');
          return await restorePurchases();
        } catch (_) {
          // If auto-restore fails, return original error
        }
      } else if (errorCode == PurchasesErrorCode.invalidReceiptError || 
                e.message?.contains('receipt is not valid') == true ||
                e.message?.contains('missing in the receipt') == true) {
        errorMessage = 'There was an issue validating your purchase. Please try restoring your purchases.';
        debugPrint('❌ Receipt validation error: ${e.message}');
      } else {
        errorMessage = 'Error purchasing package: ${e.message}';
        debugPrint('❌ ' + errorMessage);
      }
      
      return PurchaseResult(
        success: false,
        errorCode: errorCode,
        message: errorMessage,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error purchasing package: $e');
      return PurchaseResult(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }
  
  // Implementation of Task 3.2: Restore Purchases Flow
  Future<PurchaseResult> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      
      // Check if the specific entitlement is active
      if (customerInfo.entitlements.all[entitlementId]?.isActive == true) {
        debugPrint('Purchases restored successfully! Entitlement active.');
        // Return result with success
        return PurchaseResult(
          success: true,
          customerInfo: customerInfo,
          message: 'Purchases restored successfully! Your premium access has been activated.',
        );
      } else {
        debugPrint('Restore successful, but no active entitlement found.');
        // Return result indicating successful restoration but no active entitlement
        return PurchaseResult(
          success: false,
          customerInfo: customerInfo,
          message: 'No active subscriptions found to restore.',
        );
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage = 'Error restoring purchases: ${e.message}';
      debugPrint(errorMessage);
      
      return PurchaseResult(
        success: false,
        errorCode: errorCode,
        message: errorMessage,
      );
    } catch (e) {
      debugPrint('Unexpected error restoring purchases: $e');
      return PurchaseResult(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }
  
  // Check if user has active subscription
  Future<bool> checkSubscriptionStatus() async {
    await _revenueCatService.refreshCustomerInfo();
    CustomerInfo? customerInfo = _revenueCatService.customerInfo;
    return customerInfo?.entitlements.all[entitlementId]?.isActive ?? false;
  }
}

// Class to represent purchase/restore result
class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final PurchasesErrorCode? errorCode;
  final String message;
  
  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.errorCode,
    required this.message,
  });
} 