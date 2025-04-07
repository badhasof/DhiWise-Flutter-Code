import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'revenuecat_service.dart';
import 'revenuecat_offering_manager.dart';
import 'package:flutter/material.dart';

/// Subscription type to distinguish between different subscription plans
enum SubscriptionType {
  none,
  monthly,
  lifetime
}

/// A singleton class to manage subscription status throughout the app
class SubscriptionStatusManager {
  // Singleton pattern
  static final SubscriptionStatusManager _instance = SubscriptionStatusManager._internal();
  factory SubscriptionStatusManager() => _instance;
  SubscriptionStatusManager._internal();
  
  // Static getter for the instance
  static SubscriptionStatusManager get instance => _instance;

  // Subscription status stream controller
  final _subscriptionStatusController = StreamController<bool>.broadcast();
  
  // Subscription type stream controller
  final _subscriptionTypeController = StreamController<SubscriptionType>.broadcast();
  
  // Current subscription status
  bool _isSubscribed = false;
  
  // Current subscription type
  SubscriptionType _subscriptionType = SubscriptionType.none;
  
  // Access to the subscription status stream
  Stream<bool> get subscriptionStatusStream => _subscriptionStatusController.stream;
  
  // Access to the subscription type stream
  Stream<SubscriptionType> get subscriptionTypeStream => _subscriptionTypeController.stream;
  
  // Current subscription status
  bool get isSubscribed => _isSubscribed;
  
  // Current subscription type
  SubscriptionType get subscriptionType => _subscriptionType;
  
  // Convenience getters for subscription type checks
  bool get isLifetime => _subscriptionType == SubscriptionType.lifetime;
  bool get isMonthly => _subscriptionType == SubscriptionType.monthly;

  // Initialize the subscription status manager
  Future<void> initialize() async {
    try {
      // Set up Firebase Auth listener for user changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          // User logged in, identify with RevenueCat
          _identifyUser(user.uid);
        }
      });
      
      // Check initial subscription status
      await checkSubscriptionStatus();
      
      // Set up listener for real-time subscription status updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        debugPrint('💰 RevenueCat customer info updated');
        _logCustomerInfo(customerInfo);
        
        // Check the entitlement status
        _updateSubscriptionFromCustomerInfo(customerInfo);
      });
      
      debugPrint('✅ SubscriptionStatusManager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing SubscriptionStatusManager: $e');
    }
  }
  
  // Update subscription status from RevenueCat customer info
  void _updateSubscriptionFromCustomerInfo(CustomerInfo customerInfo) {
    // Check for active entitlements and active subscriptions
    bool isActive = false;
    bool hasActiveMonthly = false;
    bool hasActiveLifetime = false;
    SubscriptionType newType = SubscriptionType.none;
    
    // Log all active subscriptions for diagnosis
    final activeSubscriptions = customerInfo.activeSubscriptions;
    debugPrint('📊 Active subscriptions: ${activeSubscriptions.join(', ')}');
    
    // Check if we have active subscriptions that indicate specific types
    final bool hasMonthlySubscriptionProduct = activeSubscriptions.any(
      (subId) => subId.toLowerCase().contains('monthly') || 
                 subId.toLowerCase().contains('month')
    );
    
    final bool hasLifetimeSubscriptionProduct = activeSubscriptions.any(
      (subId) => subId.toLowerCase().contains('lifetime') || 
                 subId.toLowerCase().contains('life')
    );
    
    // First check if the premium entitlement is active
    final premiumEntitlement = customerInfo.entitlements.all["Premium"];
    if (premiumEntitlement != null && premiumEntitlement.isActive) {
      isActive = true;
      debugPrint('🔍 Found active Premium entitlement');
      debugPrint('   - Product ID: ${premiumEntitlement.productIdentifier}');
      debugPrint('   - Expires: ${premiumEntitlement.expirationDate ?? 'No expiration'}');
      debugPrint('   - Will Renew: ${premiumEntitlement.willRenew}');
      
      // Determine if it's monthly or lifetime based on product ID and expiration
      if (premiumEntitlement.productIdentifier.toLowerCase().contains('lifetime') ||
          premiumEntitlement.expirationDate == null) {
        hasActiveLifetime = true;
        debugPrint('💎 Premium access appears to be LIFETIME');
      } else {
        hasActiveMonthly = true;
        debugPrint('📅 Premium access appears to be MONTHLY');
      }
    }
    
    // Now determine the subscription type based on what's active
    // Priority: 
    // 1. If product ID clearly indicates a type, use that
    // 2. Otherwise use the entitlement that's active
    
    if (hasActiveMonthly && hasActiveLifetime) {
      // Prioritize lifetime if both are showing as active
      newType = SubscriptionType.lifetime;
      debugPrint('🔄 Both monthly and lifetime active - prioritizing LIFETIME');
    } else if (hasActiveLifetime) {
      newType = SubscriptionType.lifetime;
      debugPrint('💎 Setting subscription type to LIFETIME');
    } else if (hasActiveMonthly) {
      newType = SubscriptionType.monthly;
      debugPrint('📅 Setting subscription type to MONTHLY');
    }
    
    // Handle the case where the entitlements don't match the products
    if (hasMonthlySubscriptionProduct && !isActive) {
      debugPrint('⚠️ User has monthly subscription product but no active entitlements');
      // Assume they should have monthly access
      isActive = true;
      newType = SubscriptionType.monthly;
      debugPrint('🔄 Correcting status: Setting to MONTHLY based on subscription product');
    } else if (hasLifetimeSubscriptionProduct && !isActive) {
      debugPrint('⚠️ User has lifetime subscription product but no active entitlements');
      // Assume they should have lifetime access
      isActive = true;
      newType = SubscriptionType.lifetime;
      debugPrint('🔄 Correcting status: Setting to LIFETIME based on subscription product');
    }
    
    // Fallback for any other unhandled cases
    if (!isActive) {
      debugPrint('❌ No active entitlements or subscription products found');
      newType = SubscriptionType.none;
    }
    
    debugPrint('🔑 Final status determination:');
    debugPrint('   - Subscription active: ${isActive ? 'YES' : 'NO'}');
    debugPrint('   - Monthly entitlement active: ${hasActiveMonthly ? 'YES' : 'NO'}');
    debugPrint('   - Lifetime entitlement active: ${hasActiveLifetime ? 'YES' : 'NO'}');
    debugPrint('   - Has monthly product: ${hasMonthlySubscriptionProduct ? 'YES' : 'NO'}');
    debugPrint('   - Has lifetime product: ${hasLifetimeSubscriptionProduct ? 'YES' : 'NO'}');
    debugPrint('   - Final subscription type: $newType');
    
    // Update status if changed
    if (_isSubscribed != isActive || _subscriptionType != newType) {
      debugPrint('🔄 Updating subscription status to ${isActive ? 'ACTIVE' : 'INACTIVE'}, type: $newType');
      _isSubscribed = isActive;
      _subscriptionType = newType;
      
      // Notify listeners
      _subscriptionStatusController.add(_isSubscribed);
      _subscriptionTypeController.add(_subscriptionType);
    }
  }
  
  // Identify the current user with RevenueCat
  Future<void> _identifyUser(String userId) async {
    try {
      debugPrint('🔍 Identifying user with RevenueCat: $userId');
      final logInResult = await Purchases.logIn(userId);
      final customerInfo = logInResult.customerInfo;
      debugPrint('✅ User identified successfully with RevenueCat');
      _logCustomerInfo(customerInfo);
      
      // Update subscription based on the fetched customer info
      _updateSubscriptionFromCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('❌ Error identifying user with RevenueCat: $e');
    }
  }
  
  // Log detailed customer info for debugging
  void _logCustomerInfo(CustomerInfo customerInfo) {
    debugPrint('👤 RevenueCat Customer Info:');
    debugPrint('   - Original App User ID: ${customerInfo.originalAppUserId}');
    debugPrint('   - EntitlementIDs: ${customerInfo.entitlements.all.keys.join(', ')}');
    
    // Log all entitlements, not just a specific one
    customerInfo.entitlements.all.forEach((key, entitlement) {
      debugPrint('   - Entitlement "$key":');
      debugPrint('     - Active: ${entitlement.isActive}');
      debugPrint('     - Product ID: ${entitlement.productIdentifier}');
      debugPrint('     - Expires: ${entitlement.expirationDate ?? 'No expiration'}');
      debugPrint('     - Will Renew: ${entitlement.willRenew}');
    });
    
    // Also log all active and non-active subscriptions
    debugPrint('   - Active Subscriptions: ${customerInfo.activeSubscriptions.join(', ')}');
    debugPrint('   - All Purchased Products: ${customerInfo.allPurchasedProductIdentifiers.join(', ')}');
  }
  
  // Check subscription status using appropriate service
  Future<bool> checkSubscriptionStatus() async {
    try {
      debugPrint('🔍 Checking current subscription status directly from RevenueCat...');
      // Force refresh from RevenueCat to ensure we have latest status
      final customerInfo = await Purchases.getCustomerInfo();
      _logCustomerInfo(customerInfo);
      
      // Update subscription status and type
      _updateSubscriptionFromCustomerInfo(customerInfo);
      
      return _isSubscribed;
    } on PlatformException catch (e) {
      debugPrint('❌ Error checking subscription status: ${e.message}');
      return _isSubscribed; // Return current status on error
    } catch (e) {
      debugPrint('❌ Unexpected error checking subscription status: $e');
      return _isSubscribed; // Return current status on error
    }
  }
  
  // Get subscription type string for display
  String getSubscriptionTypeString() {
    switch (_subscriptionType) {
      case SubscriptionType.lifetime:
        return 'Lifetime Access';
      case SubscriptionType.monthly:
        return 'Monthly Subscription';
      case SubscriptionType.none:
        return 'No Subscription';
    }
  }
  
  // Implementation of Task 4.2: Open subscription management URL
  Future<bool> openSubscriptionManagement() async {
    try {
      debugPrint('🔍 Fetching customer info for management URL...');
      final customerInfo = await Purchases.getCustomerInfo();
      final String? managementUrlString = customerInfo.managementURL;
      
      if (managementUrlString != null) {
        debugPrint('Found management URL string: $managementUrlString');
        final Uri managementUri = Uri.parse(managementUrlString);
        
        if (await canLaunchUrl(managementUri)) {
          await launchUrl(managementUri);
          return true;
        } else {
         debugPrint('❌ Could not launch management URL: $managementUri');
         // Optionally show an error message to the user here
         return false;
        }
      } else {
        debugPrint('⚠️ No management URL available for this user (may not have subscriptions or platform issue).');
        // Optionally inform the user
        return false;
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Error fetching customer info for management URL: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error opening subscription management: $e');
      return false;
    }
  }
  
  // Method to restore purchases
  Future<bool> restorePurchases() async {
    try {
      debugPrint('Attempting to restore purchases...');
      final customerInfo = await Purchases.restorePurchases();
      
      // Update subscription status and type
      _updateSubscriptionFromCustomerInfo(customerInfo);
      
      debugPrint('Purchases restored. Active status: $_isSubscribed, Type: $_subscriptionType');
      return true;
    } on PlatformException catch (e) {
      debugPrint('Error restoring purchases: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error restoring purchases: $e');
      return false;
    }
  }
  
  // Dispose of resources
  void dispose() {
    _subscriptionStatusController.close();
    _subscriptionTypeController.close();
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }
  
  // Reference to the listener function for removal
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    // Empty implementation, just needed for the reference
  }
  
  // Method to update subscription type manually (for synchronization with other managers)
  void updateSubscriptionType(SubscriptionType type) {
    if (_subscriptionType != type) {
      debugPrint('🔄 Manually updating subscription type: $type');
      _subscriptionType = type;
      _isSubscribed = type != SubscriptionType.none;
      
      // Notify listeners
      _subscriptionTypeController.add(_subscriptionType);
      _subscriptionStatusController.add(_isSubscribed);
      
      debugPrint('📢 Subscription type manually updated to: $type');
    }
  }
  
  // Check if user already has a subscription before showing the subscription screen
  Future<bool> shouldShowSubscriptionScreen(BuildContext context) async {
    try {
      debugPrint('🔍 Checking premium status before showing subscription screen...');
      
      // Force refresh from RevenueCat to ensure we have the latest status
      final customerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionFromCustomerInfo(customerInfo);
      
      // If user already has premium, show a message and return false
      if (_isSubscribed) {
        debugPrint('✅ User already has premium status, no need to show subscription screen');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You already have ${_subscriptionType == SubscriptionType.lifetime ? 'lifetime' : 'premium'} access!',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
      
      // User doesn't have premium, show subscription screen
      debugPrint('⚠️ User does not have premium, should show subscription screen');
      return true;
    } catch (e) {
      debugPrint('❌ Error checking subscription status: $e');
      // On error, proceed with showing the subscription screen
      return true;
    }
  }
} 