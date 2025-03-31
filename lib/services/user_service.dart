import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'subscription_service.dart';

class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Subscription service
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  // Check if user has premium access
  Future<bool> hasPremiumAccess() async {
    if (!isLoggedIn) return false;
    
    try {
      return await _subscriptionService.checkSubscriptionStatus();
    } catch (e) {
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
      // Error silently handled
    }
  }
  
  // Initialize user data in Firestore if it doesn't exist
  Future<void> initializeUserDataIfNeeded() async {
    if (!isLoggedIn) {
      return;
    }
    
    try {
      final userId = currentUser!.uid;
      
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        // Initialize basic user data
        await _firestore.collection('users').doc(userId).set({
          'email': currentUser!.email,
          'displayName': currentUser!.displayName,
          'photoURL': currentUser!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'isPremium': false,
          'stats': {
            'totalStoriesCompleted': 0,
            'lastCompletedAt': null,
          }
        });
      } else {
        // Check if stats field exists and initialize if needed
        final data = doc.data();
        if (data != null && !data.containsKey('stats')) {
          await _firestore.collection('users').doc(userId).update({
            'stats': {
              'totalStoriesCompleted': 0,
              'lastCompletedAt': null,
            }
          });
        }
      }
    } catch (e) {
      // Error silently handled
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Error silently handled
    }
  }
} 