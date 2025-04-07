import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'subscription_status_manager.dart';
import 'user_feedback_service.dart';

/// Status of the subscription flow
enum SubscriptionFlowStatus {
  NOT_SHOWN,   // Subscription screen hasn't been shown
  SHOWN,       // Subscription screen has been shown but user didn't subscribe
  COMPLETED    // User has subscribed
}

/// Extension for string conversion
extension SubscriptionFlowStatusExtension on SubscriptionFlowStatus {
  String get value {
    switch (this) {
      case SubscriptionFlowStatus.NOT_SHOWN:
        return 'not_shown';
      case SubscriptionFlowStatus.SHOWN:
        return 'shown';
      case SubscriptionFlowStatus.COMPLETED:
        return 'completed';
    }
  }
  
  static SubscriptionFlowStatus fromString(String? value) {
    if (value == null) return SubscriptionFlowStatus.NOT_SHOWN;
    
    switch (value) {
      case 'shown':
        return SubscriptionFlowStatus.SHOWN;
      case 'completed':
        return SubscriptionFlowStatus.COMPLETED;
      default:
        return SubscriptionFlowStatus.NOT_SHOWN;
    }
  }
}

/// A service to manage the subscription flow after feedback completion
class SubscriptionFlowService {
  // Singleton pattern
  static final SubscriptionFlowService _instance = SubscriptionFlowService._internal();
  factory SubscriptionFlowService() => _instance;
  SubscriptionFlowService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  // Dependencies
  final _subscriptionStatusManager = SubscriptionStatusManager.instance;
  final _feedbackService = UserFeedbackService();
  
  // Get the current subscription flow status for the user
  Future<SubscriptionFlowStatus> getSubscriptionFlowStatus() async {
    if (!isLoggedIn) return SubscriptionFlowStatus.NOT_SHOWN;
    
    try {
      final userData = await getUserData();
      if (userData == null) return SubscriptionFlowStatus.NOT_SHOWN;
      
      // Get the subscription flow status string from user data
      final subscriptionFlowData = userData['subscriptionFlow'] as Map<String, dynamic>?;
      if (subscriptionFlowData == null) return SubscriptionFlowStatus.NOT_SHOWN;
      
      final statusString = subscriptionFlowData['status'] as String?;
      return SubscriptionFlowStatusExtension.fromString(statusString);
    } catch (e) {
      debugPrint('Error getting subscription flow status: $e');
      return SubscriptionFlowStatus.NOT_SHOWN;
    }
  }
  
  // Set the subscription flow status for the user
  Future<void> setSubscriptionFlowStatus(SubscriptionFlowStatus status) async {
    if (!isLoggedIn) return;
    
    try {
      await updateUserData({
        'subscriptionFlow': {
          'status': status.value,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      });
      debugPrint('Subscription flow status updated to: ${status.value}');
    } catch (e) {
      debugPrint('Error updating subscription flow status: $e');
    }
  }
  
  // Mark subscription flow as shown
  Future<void> markAsShown() async {
    await setSubscriptionFlowStatus(SubscriptionFlowStatus.SHOWN);
  }
  
  // Mark subscription flow as completed
  Future<void> markAsCompleted() async {
    await setSubscriptionFlowStatus(SubscriptionFlowStatus.COMPLETED);
  }
  
  // Check if subscription screen should be shown on app start
  Future<bool> shouldShowSubscription() async {
    if (!isLoggedIn) {
      debugPrint('⚠️ Cannot check subscription flow: No user is logged in');
      return false;
    }
    
    try {
      // First, ensure the user has completed feedback
      final feedbackStatus = await _feedbackService.getFeedbackStatus();
      debugPrint('📊 shouldShowSubscription: Feedback status = ${feedbackStatus.value}');
      
      if (feedbackStatus != FeedbackStatus.COMPLETED) {
        debugPrint('📊 Not showing subscription screen: Feedback status is ${feedbackStatus.value}, not COMPLETED');
        return false;
      }
      
      // Check if they already have premium
      final hasPremium = await _subscriptionStatusManager.checkSubscriptionStatus();
      debugPrint('📊 shouldShowSubscription: User has premium = $hasPremium');
      
      if (hasPremium) {
        debugPrint('📊 Not showing subscription screen: User already has premium');
        // If they're premium, make sure we mark the flow as completed
        await markAsCompleted();
        return false;
      }
      
      // Check the current subscription flow status
      final subscriptionFlowStatus = await getSubscriptionFlowStatus();
      debugPrint('📊 shouldShowSubscription: Current subscription flow status = ${subscriptionFlowStatus.value}');
      
      // Decision logic:
      // 1. If status is NOT_SHOWN, subscription screen should be shown
      // 2. If status is SHOWN, subscription has been seen but not completed, so don't show again on startup
      // 3. If status is COMPLETED, user has already subscribed, don't show
      
      final shouldShow = subscriptionFlowStatus == SubscriptionFlowStatus.NOT_SHOWN;
      debugPrint('📊 Subscription flow decision: ${shouldShow ? "SHOW" : "DONT SHOW"} subscription screen');
      
      return shouldShow;
    } catch (e) {
      debugPrint('❌ Error in shouldShowSubscription: $e');
      // Log stack trace for debugging
      debugPrint('Stack trace: ${StackTrace.current}');
      return false;
    }
  }
  
  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (!isLoggedIn) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!doc.exists) return null;
      
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (!isLoggedIn) return;
    
    try {
      await _firestore.collection('users').doc(currentUser!.uid).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }
  
  // Initialize subscription flow data if needed
  Future<void> initializeSubscriptionFlowDataIfNeeded() async {
    if (!isLoggedIn) {
      debugPrint('⚠️ Cannot initialize subscription flow data: No user is logged in');
      return;
    }
    
    try {
      final userId = currentUser!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        // This should be handled by UserService.initializeUserDataIfNeeded()
        debugPrint('⚠️ User document does not exist. This should be handled by UserService.');
        return;
      }
      
      final data = doc.data();
      if (data != null && !data.containsKey('subscriptionFlow')) {
        debugPrint('📊 Adding subscriptionFlow field to user document');
        await _firestore.collection('users').doc(userId).update({
          'subscriptionFlow': {
            'status': SubscriptionFlowStatus.NOT_SHOWN.value,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }
        });
        debugPrint('✅ Added subscriptionFlow field to user document');
      } else {
        debugPrint('✅ User document already has subscriptionFlow field');
      }
    } catch (e) {
      debugPrint('❌ Error initializing subscription flow data: $e');
    }
  }
  
  // Debug method to directly check subscription flow data in Firestore
  Future<void> debugCheckSubscriptionFlowData() async {
    if (!isLoggedIn) {
      debugPrint('▶️ DEBUG: Not logged in, cannot check subscription flow data');
      return;
    }
    
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!doc.exists) {
        debugPrint('▶️ DEBUG: User document does not exist in Firestore');
        return;
      }
      
      final data = doc.data();
      if (data == null) {
        debugPrint('▶️ DEBUG: User document exists but data is null');
        return;
      }
      
      if (!data.containsKey('subscriptionFlow')) {
        debugPrint('▶️ DEBUG: User document does not contain subscriptionFlow field');
        return;
      }
      
      final subscriptionFlowData = data['subscriptionFlow'] as Map<String, dynamic>?;
      if (subscriptionFlowData == null) {
        debugPrint('▶️ DEBUG: SubscriptionFlow field exists but is null');
        return;
      }
      
      debugPrint('▶️ DEBUG: SubscriptionFlow data found:');
      debugPrint('  Status: ${subscriptionFlowData['status']}');
      debugPrint('  CreatedAt: ${subscriptionFlowData['createdAt']}');
      debugPrint('  UpdatedAt: ${subscriptionFlowData['updatedAt']}');
    } catch (e) {
      debugPrint('▶️ DEBUG: Error checking subscription flow data: $e');
    }
  }
} 