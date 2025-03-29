import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../domain/story/story_model.dart';

class UserReadingService {
  // Singleton pattern
  static final UserReadingService _instance = UserReadingService._internal();
  factory UserReadingService() => _instance;
  UserReadingService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  // Record a completed story
  Future<void> recordCompletedStory(String storyId, {Story? storyDetails}) async {
    if (!isLoggedIn) return;
    
    try {
      final userId = currentUser!.uid;
      final now = DateTime.now();
      
      // Create a reference to the user's completed stories subcollection
      final userRef = _firestore.collection('users').doc(userId);
      
      // Add the story to the user's completed stories array
      await userRef.update({
        'stats.totalStoriesCompleted': FieldValue.increment(1),
        'stats.lastCompletedAt': FieldValue.serverTimestamp(),
      });
      
      // Add to the completedStories subcollection for detailed history
      await userRef.collection('completedStories').doc(storyId).set({
        'storyId': storyId,
        'completedAt': FieldValue.serverTimestamp(),
        'titleEn': storyDetails?.titleEn ?? '',
        'titleAr': storyDetails?.titleAr ?? '',
        'dialect': storyDetails?.dialect ?? '',
        'level': storyDetails?.level ?? '',
        'genre': storyDetails?.genre ?? '',
      });
      
      debugPrint('Story completion recorded successfully');
    } catch (e) {
      debugPrint('Error recording story completion: $e');
    }
  }
  
  // Get the total number of completed stories
  Future<int> getTotalCompletedStories() async {
    if (!isLoggedIn) return 0;
    
    try {
      final userId = currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return 0;
      
      final data = userDoc.data();
      if (data == null) return 0;
      
      // Check if stats field exists
      if (!data.containsKey('stats')) return 0;
      
      // Get the total completed stories count
      final stats = data['stats'] as Map<String, dynamic>?;
      if (stats == null) return 0;
      
      return (stats['totalStoriesCompleted'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('Error getting total completed stories: $e');
      return 0;
    }
  }
  
  // Get all completed stories with details
  Future<List<Map<String, dynamic>>> getCompletedStories() async {
    if (!isLoggedIn) return [];
    
    try {
      final userId = currentUser!.uid;
      final completedStoriesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedStories')
          .orderBy('completedAt', descending: true)
          .get();
      
      return completedStoriesSnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('Error getting completed stories: $e');
      return [];
    }
  }
  
  // Initialize user reading stats if needed
  Future<void> initializeReadingStatsIfNeeded() async {
    if (!isLoggedIn) return;
    
    try {
      final userId = currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return;
      
      final data = userDoc.data();
      if (data == null) return;
      
      // Check if stats field exists
      if (!data.containsKey('stats')) {
        // Initialize stats field
        await _firestore.collection('users').doc(userId).update({
          'stats': {
            'totalStoriesCompleted': 0,
            'lastCompletedAt': null,
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing reading stats: $e');
    }
  }
} 