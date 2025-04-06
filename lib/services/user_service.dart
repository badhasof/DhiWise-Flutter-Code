import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'subscription_status_manager.dart';

// Demo status enum values
enum DemoStatus {
  NA,       // Demo has not been started
  STARTED,  // Demo has been started but not completed
  DONE      // Demo has been completed
}

// Extension for string conversion
extension DemoStatusExtension on DemoStatus {
  String get value {
    switch (this) {
      case DemoStatus.NA:
        return 'N/A';
      case DemoStatus.STARTED:
        return 'started';
      case DemoStatus.DONE:
        return 'Done';
    }
  }
  
  static DemoStatus fromString(String? value) {
    if (value == null) return DemoStatus.NA;
    
    switch (value) {
      case 'started':
        return DemoStatus.STARTED;
      case 'Done':
        return DemoStatus.DONE;
      default:
        return DemoStatus.NA;
    }
  }
}

class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Subscription service
  final SubscriptionStatusManager _subscriptionStatusManager = SubscriptionStatusManager();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  // Check if user has premium access (DEPRECATED - Use SubscriptionStatusManager)
  @Deprecated('Use SubscriptionStatusManager.instance.isSubscribed instead')
  Future<bool> hasPremiumAccess() async {
    // This method now always returns false or throws an error
    // as it relies on the legacy Firestore subscription check.
    debugPrint('⚠️ WARNING: UserService.hasPremiumAccess() is deprecated. Use SubscriptionStatusManager.instance.isSubscribed.');
    // Return false to avoid potential issues where this might still be called.
    return false;
    /* 
    if (!isLoggedIn) return false;
    
    try {
      // Old logic - relies on legacy service and Firestore
      return await _subscriptionService.checkSubscriptionStatus(); 
    } catch (e) {
      debugPrint('Error checking premium access: $e');
      return false;
    }
    */
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
  
  // Get the current demo status for the user
  Future<DemoStatus> getDemoStatus() async {
    if (!isLoggedIn) return DemoStatus.NA;
    
    try {
      final userData = await getUserData();
      if (userData == null) return DemoStatus.NA;
      
      // Get the demo status string from user data
      final demoStatusString = userData['demo'] as String?;
      return DemoStatusExtension.fromString(demoStatusString);
    } catch (e) {
      debugPrint('Error getting demo status: $e');
      return DemoStatus.NA;
    }
  }
  
  // Set the demo status for the user
  Future<void> setDemoStatus(DemoStatus status) async {
    if (!isLoggedIn) return;
    
    try {
      await updateUserData({
        'demo': status.value,
      });
      debugPrint('Demo status updated to: ${status.value}');
    } catch (e) {
      debugPrint('Error updating demo status: $e');
    }
  }
  
  // Initialize user data in Firestore if it doesn't exist
  Future<void> initializeUserDataIfNeeded() async {
    if (!isLoggedIn) {
      debugPrint('⚠️ Cannot initialize user data: No user is logged in');
      return;
    }
    
    try {
      final userId = currentUser!.uid;
      debugPrint('🔍 Checking if user data exists for UID: $userId');
      
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        debugPrint('📝 Creating new user document in Firestore');
        // Initialize basic user data - REMOVE isPremium
        await _firestore.collection('users').doc(userId).set({
          'email': currentUser!.email,
          'displayName': currentUser!.displayName,
          'photoURL': currentUser!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'demo': DemoStatus.NA.value, // Initialize with N/A
          'stats': {
            'totalStoriesCompleted': 0,
            'lastCompletedAt': null,
          }
        });
        debugPrint('✅ User document created successfully (with demo status N/A)');
      } else {
        debugPrint('🔍 User document already exists, checking for demo field');
        // Check if demo field exists and initialize if needed
        final data = doc.data();
        if (data != null && !data.containsKey('demo')) {
          debugPrint('📊 Adding demo field to existing user document');
          await _firestore.collection('users').doc(userId).update({
            'demo': DemoStatus.NA.value,
          });
          debugPrint('✅ Added demo field to user document');
        } else {
          debugPrint('✅ User document already has demo field');
        }
        
        // Check if stats field exists and initialize if needed
        if (data != null && !data.containsKey('stats')) {
          debugPrint('📊 Adding stats field to existing user document');
          await _firestore.collection('users').doc(userId).update({
            'stats': {
              'totalStoriesCompleted': 0,
              'lastCompletedAt': null,
            }
          });
          debugPrint('✅ Added stats field to user document');
        } else {
          debugPrint('✅ User document already has stats field');
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing user data: $e');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
} 