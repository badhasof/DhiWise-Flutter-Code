import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'user_reading_service.dart';
import 'user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'subscription_status_manager.dart';
import 'revenuecat_offering_manager.dart';

class UserStatsManager {
  // Singleton pattern
  static final UserStatsManager _instance = UserStatsManager._internal();
  factory UserStatsManager() => _instance;
  UserStatsManager._internal();
  
  // Services
  final UserReadingService _userReadingService = UserReadingService();
  final UserService _userService = UserService();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream subscriptions for real-time updates
  StreamSubscription? _userStatsSubscription;
  StreamSubscription? _completedStoriesSubscription;
  
  // Real-time update callbacks
  List<Function()> _listeners = [];
  
  // Data storage
  int _completedStoriesCount = 0;
  List<Map<String, dynamic>> _recentCompletedStories = [];
  int _currentLevel = 1;
  int _storiesForNextLevel = 3;
  int _totalStoriesForCurrentLevel = 0;
  int _progressToNextLevel = 0;
  
  // Status flags
  bool _isDataLoaded = false;
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  
  // Premium status
  bool _isPremium = false;
  String _subscriptionType = "";
  bool _isPremiumChecked = false;
  
  // User profile data
  Map<String, dynamic>? _userData;
  bool _isUserDataLoaded = false;
  DateTime? _lastUserDataFetchTime;
  
  // Getters
  bool get isDataLoaded => _isDataLoaded;
  bool get isLoading => _isLoading;
  int get completedStoriesCount => _completedStoriesCount;
  List<Map<String, dynamic>> get recentCompletedStories => _recentCompletedStories;
  int get currentLevel => _currentLevel;
  int get storiesForNextLevel => _storiesForNextLevel;
  int get totalStoriesForCurrentLevel => _totalStoriesForCurrentLevel;
  int get progressToNextLevel => _progressToNextLevel;
  bool get isPremium => _isPremium;
  String get subscriptionType => _subscriptionType;
  bool get isPremiumChecked => _isPremiumChecked;
  Map<String, dynamic>? get userData => _userData;
  bool get isUserDataLoaded => _isUserDataLoaded;
  
  // Add a listener for real-time updates
  void addListener(Function() listener) {
    _listeners.add(listener);
  }
  
  // Remove a listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }
  
  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('❌ Error notifying listener: $e');
      }
    }
  }
  
  // Set up real-time listeners
  void setupRealTimeListeners() {
    // Cancel any existing subscriptions
    _cancelSubscriptions();
    
    // Only set up if user is logged in
    if (!_userService.isLoggedIn) return;
    
    final userId = _auth.currentUser!.uid;
    
    // Listen for changes to the user document (for stats and premium status)
    _userStatsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          // Update user data (general)
          _userData = data;
          _isUserDataLoaded = true;
          _lastUserDataFetchTime = DateTime.now();
          
          // Update stats
          if (data.containsKey('stats')) {
            final stats = data['stats'] as Map<String, dynamic>?;
            if (stats != null && stats.containsKey('totalStoriesCompleted')) {
              final totalStories = (stats['totalStoriesCompleted'] as num?)?.toInt() ?? 0;
              
              // Calculate level stats if the count changed
              if (totalStories != _completedStoriesCount) {
                _completedStoriesCount = totalStories;
                _calculateLevelStats(totalStories);
                _lastFetchTime = DateTime.now();
                _isDataLoaded = true;
              }
            }
          }
          
          // Notify listeners of changes
          _notifyListeners();
          
          debugPrint('🔄 Real-time update: User document changed');
        }
      }
    }, onError: (error) {
      debugPrint('❌ Error in user document listener: $error');
    });
    
    // Listen for changes to the completed stories collection
    _completedStoriesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('completedStories')
        .orderBy('completedAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.metadata.isFromCache) {
        // Update recent completed stories
        _recentCompletedStories = snapshot.docs
            .map((doc) => doc.data())
            .toList();
        
        // Notify listeners of changes
        _notifyListeners();
        
        debugPrint('🔄 Real-time update: Completed stories changed');
      }
    }, onError: (error) {
      debugPrint('❌ Error in completed stories listener: $error');
    });
    
    debugPrint('🔊 Set up real-time listeners for user stats');
  }
  
  // Cancel all subscriptions
  void _cancelSubscriptions() {
    _userStatsSubscription?.cancel();
    _completedStoriesSubscription?.cancel();
    _userStatsSubscription = null;
    _completedStoriesSubscription = null;
    
    debugPrint('🔇 Cancelled real-time listeners for user stats');
  }
  
  // Clean up resources
  void dispose() {
    _cancelSubscriptions();
    _listeners.clear();
  }
  
  // Initialize and fetch data
  Future<void> initialize() async {
    debugPrint('🚀 Initializing UserStatsManager');
    await fetchUserStats();
    await checkPremiumStatus();
    await fetchUserProfile();
  }
  
  // Fetch premium status
  Future<void> checkPremiumStatus() async {
    try {
      if (!_userService.isLoggedIn) {
        _isPremium = false;
        _isPremiumChecked = true;
        return;
      }

      debugPrint('🔍 UserStatsManager: Checking RevenueCat subscription status');
      
      // Check status directly from RevenueCat's SubscriptionStatusManager
      final bool isSubscribed = await SubscriptionStatusManager.instance.checkSubscriptionStatus();
      final subscriptionType = SubscriptionStatusManager.instance.subscriptionType;
      
      // Update local state
      _isPremium = isSubscribed;
      
      // Set subscription type based on the enum from SubscriptionStatusManager
      switch (subscriptionType) {
        case SubscriptionType.lifetime:
          _subscriptionType = 'Lifetime';
          break;
        case SubscriptionType.monthly:
          _subscriptionType = 'Monthly';
          break;
        case SubscriptionType.none:
          _subscriptionType = '';
          break;
      }
      
      debugPrint('✅ UserStatsManager: Subscription status: ${_isPremium ? 'PREMIUM' : 'FREE'}, Type: $_subscriptionType');
      debugPrint('✅ UserStatsManager: Using subscription type from SubscriptionStatusManager: $subscriptionType');
      _isPremiumChecked = true;
      
    } catch (e) {
      debugPrint('❌ UserStatsManager: Unexpected error checking premium status: $e');
      _isPremium = false;
      _subscriptionType = "";
      _isPremiumChecked = true;
    }
  }
  
  // This method is no longer needed since we're getting data directly from SubscriptionStatusManager
  // but keeping it for backward compatibility
  void _syncWithSubscriptionStatusManager() {
    // No implementation needed - we're now getting data from SubscriptionStatusManager directly
  }
  
  // Fetch user profile data
  Future<void> fetchUserProfile() async {
    if (!_userService.isLoggedIn) {
      return;
    }
    
    try {
      debugPrint('👤 UserStatsManager: Fetching user profile data');
      
      // Get user data
      final userData = await _userService.getUserData();
      
      _userData = userData;
      _isUserDataLoaded = true;
      _lastUserDataFetchTime = DateTime.now();
      
      debugPrint('✅ UserStatsManager: User profile data loaded');
    } catch (e) {
      debugPrint('❌ UserStatsManager: Error loading user profile: $e');
    }
  }
  
  // Fetch all user stats
  Future<void> fetchUserStats() async {
    // Don't fetch if not logged in or already fetching
    if (!_userService.isLoggedIn || _isLoading) {
      return;
    }
    
    _isLoading = true;
    
    try {
      debugPrint('📊 UserStatsManager: Fetching user stats');
      
      // Get the total number of completed stories
      final totalStories = await _userReadingService.getTotalCompletedStories();
      
      // Get the most recent completed stories (up to 5)
      final recentStories = await _userReadingService.getCompletedStories();
      final limitedRecentStories = recentStories.take(5).toList();
      
      // Calculate the user's level and progress
      _calculateLevelStats(totalStories);
      
      // Update stored data
      _completedStoriesCount = totalStories;
      _recentCompletedStories = limitedRecentStories;
      _isDataLoaded = true;
      _lastFetchTime = DateTime.now();
      
      debugPrint('✅ UserStatsManager: Loaded stats - $_completedStoriesCount stories, Level: $_currentLevel');
    } catch (e) {
      debugPrint('❌ UserStatsManager: Error loading user stats: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  // Calculate level stats based on completed stories
  void _calculateLevelStats(int completedStories) {
    int storiesRequired = 0;
    int level = 1;
    int storiesForThisLevel = 3; // Level 2 requires 3 stories
    
    // Start at level 1, requiring 0 stories
    while (completedStories >= storiesRequired + storiesForThisLevel) {
      // Move to the next level
      level++;
      storiesRequired += storiesForThisLevel;
      storiesForThisLevel++; // Each level requires one more story
    }
    
    // Calculate totals for the progress bar
    int storiesCompletedInCurrentLevel = completedStories - storiesRequired;
    int totalStoriesNeededForCurrentLevel = storiesForThisLevel;
    
    // Update state variables
    _currentLevel = level;
    _storiesForNextLevel = storiesForThisLevel; 
    _totalStoriesForCurrentLevel = storiesForThisLevel;
    _progressToNextLevel = storiesCompletedInCurrentLevel;
  }
  
  // Check if data is stale and needs refresh (older than 3 minutes)
  bool get isDataStale {
    if (!_isDataLoaded) return true;
    if (_lastFetchTime == null) return true;
    
    final now = DateTime.now();
    final diff = now.difference(_lastFetchTime!);
    
    // Consider data stale after 3 minutes
    return diff.inMinutes > 3;
  }
  
  // Check if user profile data is stale
  bool get isUserDataStale {
    if (!_isUserDataLoaded) return true;
    if (_lastUserDataFetchTime == null) return true;
    
    final now = DateTime.now();
    final diff = now.difference(_lastUserDataFetchTime!);
    
    // Extend cache time to 15 minutes for profile data
    // This reduces unnecessary refreshes when navigating back to profile page
    return diff.inMinutes > 15;
  }
  
  // Fetch if needed (if data is stale)
  Future<void> fetchIfNeeded() async {
    List<Future> futures = [];
    
    // Only fetch what's needed
    if (isDataStale) {
      futures.add(fetchUserStats());
    }
    
    if (!_isPremiumChecked) {
      futures.add(checkPremiumStatus());
    }
    
    if (isUserDataStale) {
      futures.add(fetchUserProfile());
    }
    
    // Wait for all needed fetches to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
  
  // Refresh all user data
  Future<void> refreshAll() async {
    await checkPremiumStatus();
    await fetchUserProfile();
    await fetchUserStats();
  }
  
  // Calculate the level for a specific story number
  int calculateLevelForStoryNumber(int storyNumber) {
    int storiesRequired = 0;
    int level = 1;
    int storiesForThisLevel = 3; // Level 2 requires 3 stories
    
    while (storyNumber > storiesRequired) {
      storiesRequired += storiesForThisLevel;
      if (storyNumber <= storiesRequired) {
        return level;
      }
      level++;
      storiesForThisLevel++;
    }
    
    return level;
  }
} 