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
  
  // Update subscription status and type from customer info
  void _updateSubscriptionFromCustomerInfo(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[RevenueCatOfferingManager.entitlementId];
    final bool isActive = entitlement?.isActive ?? false;
    
    debugPrint('🔑 Entitlement status: ${isActive ? 'ACTIVE' : 'INACTIVE'}');
    
    // Determine subscription type
    SubscriptionType newType = SubscriptionType.none;
    
    if (isActive && entitlement != null) {
      // Check if this is a lifetime subscription
      final productId = entitlement.productIdentifier.toLowerCase();
      if (productId.contains('lifetime')) {
        newType = SubscriptionType.lifetime;
        debugPrint('💎 Detected LIFETIME subscription');
      } else {
        newType = SubscriptionType.monthly;
        debugPrint('📅 Detected MONTHLY subscription');
      }
    }
    
    // Update status if changed
    if (isActive != _isSubscribed) {
      debugPrint('📢 Subscription status changed to: ${isActive ? 'PREMIUM' : 'BASIC'}');
      _isSubscribed = isActive;
      _subscriptionStatusController.add(_isSubscribed);
    }
    
    // Update type if changed
    if (newType != _subscriptionType) {
      debugPrint('📢 Subscription type changed to: $newType');
      _subscriptionType = newType;
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
    
    final entitlement = customerInfo.entitlements.all[RevenueCatOfferingManager.entitlementId];
    if (entitlement != null) {
      debugPrint('   - Entitlement "${RevenueCatOfferingManager.entitlementId}":');
      debugPrint('     - Active: ${entitlement.isActive}');
      debugPrint('     - Product: ${entitlement.productIdentifier}');
      debugPrint('     - Will Renew: ${entitlement.willRenew}');
      if (entitlement.expirationDate != null) {
        debugPrint('     - Expires: ${entitlement.expirationDate}');
      }
    } else {
      debugPrint('   - Entitlement "${RevenueCatOfferingManager.entitlementId}" not found');
    }
    
    debugPrint('   - Active subscriptions: ${customerInfo.activeSubscriptions.join(', ')}');
    debugPrint('   - All purchased products: ${customerInfo.allPurchasedProductIdentifiers.join(', ')}');
  }
  
  // Check current subscription status (on-demand)
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
      final customerInfo = await Purchases.getCustomerInfo();
      final managementURL = customerInfo.managementURL;
      
      if (managementURL != null) {
        final Uri uri = Uri.parse(managementURL);
        debugPrint('Opening management URL: $managementURL');
        
        // Launch the URL in external browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        } else {
          debugPrint('Could not launch management URL: $managementURL');
          return false;
        }
      } else {
        debugPrint('No management URL available for this user');
        return false;
      }
    } on PlatformException catch (e) {
      debugPrint('Error opening subscription management: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error opening subscription management: $e');
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