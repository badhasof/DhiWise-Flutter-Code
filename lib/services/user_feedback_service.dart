import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Feedback status enum values
enum FeedbackStatus {
  NOT_PROMPTED,  // User has not been prompted for feedback yet
  PROMPTED,      // User has been prompted but not completed feedback
  COMPLETED      // User has completed feedback
}

// Extension for string conversion
extension FeedbackStatusExtension on FeedbackStatus {
  String get value {
    switch (this) {
      case FeedbackStatus.NOT_PROMPTED:
        return 'not_prompted';
      case FeedbackStatus.PROMPTED:
        return 'prompted';
      case FeedbackStatus.COMPLETED:
        return 'completed';
    }
  }
  
  static FeedbackStatus fromString(String? value) {
    if (value == null) return FeedbackStatus.NOT_PROMPTED;
    
    switch (value) {
      case 'prompted':
        return FeedbackStatus.PROMPTED;
      case 'completed':
        return FeedbackStatus.COMPLETED;
      default:
        return FeedbackStatus.NOT_PROMPTED;
    }
  }
}

class UserFeedbackService {
  // Singleton pattern
  static final UserFeedbackService _instance = UserFeedbackService._internal();
  factory UserFeedbackService() => _instance;
  UserFeedbackService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  // Get the current feedback status for the user
  Future<FeedbackStatus> getFeedbackStatus() async {
    if (!isLoggedIn) return FeedbackStatus.NOT_PROMPTED;
    
    try {
      final userData = await getUserData();
      if (userData == null) return FeedbackStatus.NOT_PROMPTED;
      
      // Get the feedback status string from user data
      final feedbackData = userData['feedback'] as Map<String, dynamic>?;
      if (feedbackData == null) return FeedbackStatus.NOT_PROMPTED;
      
      final feedbackStatusString = feedbackData['status'] as String?;
      return FeedbackStatusExtension.fromString(feedbackStatusString);
    } catch (e) {
      debugPrint('Error getting feedback status: $e');
      return FeedbackStatus.NOT_PROMPTED;
    }
  }
  
  // Set the feedback status for the user
  Future<void> setFeedbackStatus(FeedbackStatus status) async {
    if (!isLoggedIn) return;
    
    try {
      await updateUserData({
        'feedback': {
          'status': status.value,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      });
      debugPrint('Feedback status updated to: ${status.value}');
    } catch (e) {
      debugPrint('Error updating feedback status: $e');
    }
  }
  
  // Check if feedback can be prompted based on user activity
  Future<bool> canPromptForFeedback() async {
    if (!isLoggedIn) return false;
    
    try {
      final status = await getFeedbackStatus();
      
      // Only prompt if user has not been prompted or completed feedback yet
      return status == FeedbackStatus.NOT_PROMPTED;
    } catch (e) {
      debugPrint('Error checking if can prompt for feedback: $e');
      return false;
    }
  }
  
  // Method to call when user completes an important action that could trigger feedback
  // For example, after completing a story or reaching a certain number of sessions
  Future<void> promptForFeedbackIfEligible() async {
    if (!isLoggedIn) return;
    
    try {
      final canPrompt = await canPromptForFeedback();
      
      if (canPrompt) {
        // Mark the user as prompted so feedback screen will show on next app start
        await markAsPrompted();
        debugPrint('User marked for feedback - will show on next app start');
      }
    } catch (e) {
      debugPrint('Error prompting for feedback: $e');
    }
  }
  
  // Mark user as prompted for feedback
  Future<void> markAsPrompted() async {
    await setFeedbackStatus(FeedbackStatus.PROMPTED);
  }
  
  // Mark feedback as completed
  Future<void> markAsCompleted() async {
    await setFeedbackStatus(FeedbackStatus.COMPLETED);
  }
  
  // Check if feedback should be shown to the user
  Future<bool> shouldShowFeedback() async {
    if (!isLoggedIn) {
      debugPrint('shouldShowFeedback: Not logged in, returning false');
      return false;
    }
    
    try {
      final status = await getFeedbackStatus();
      debugPrint('shouldShowFeedback: Current feedback status = ${status.value}');
      
      final shouldShow = status == FeedbackStatus.PROMPTED;
      debugPrint('shouldShowFeedback: Should show feedback = $shouldShow');
      
      return shouldShow;
    } catch (e) {
      debugPrint('shouldShowFeedback: Error checking status: $e');
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
  
  // Initialize feedback data if needed
  Future<void> initializeFeedbackDataIfNeeded() async {
    if (!isLoggedIn) {
      debugPrint('⚠️ Cannot initialize feedback data: No user is logged in');
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
      if (data != null && !data.containsKey('feedback')) {
        debugPrint('📊 Adding feedback field to user document');
        await _firestore.collection('users').doc(userId).update({
          'feedback': {
            'status': FeedbackStatus.NOT_PROMPTED.value,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }
        });
        debugPrint('✅ Added feedback field to user document');
      } else {
        debugPrint('✅ User document already has feedback field');
      }
    } catch (e) {
      debugPrint('❌ Error initializing feedback data: $e');
    }
  }
  
  // Debug method to directly check feedback data in Firestore
  Future<void> debugCheckFeedbackData() async {
    if (!isLoggedIn) {
      debugPrint('▶️ DEBUG: Not logged in, cannot check feedback data');
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
      
      if (!data.containsKey('feedback')) {
        debugPrint('▶️ DEBUG: User document does not contain feedback field');
        return;
      }
      
      final feedbackData = data['feedback'] as Map<String, dynamic>?;
      if (feedbackData == null) {
        debugPrint('▶️ DEBUG: Feedback field exists but is null');
        return;
      }
      
      debugPrint('▶️ DEBUG: Feedback data found:');
      debugPrint('  Status: ${feedbackData['status']}');
      debugPrint('  CreatedAt: ${feedbackData['createdAt']}');
      debugPrint('  UpdatedAt: ${feedbackData['updatedAt']}');
    } catch (e) {
      debugPrint('▶️ DEBUG: Error checking feedback data: $e');
    }
  }
} 