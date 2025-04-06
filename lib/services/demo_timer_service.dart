import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../core/utils/pref_utils.dart';
import 'subscription_status_manager.dart';
import 'user_service.dart';

/// A global service to monitor the demo timer across the entire app
class DemoTimerService {
  // Singleton pattern
  static final DemoTimerService _instance = DemoTimerService._internal();
  factory DemoTimerService() => _instance;
  DemoTimerService._internal();

  static DemoTimerService get instance => _instance;

  // Timer and state
  Timer? _timer;
  int _remainingSeconds = 0;
  PrefUtils? _prefUtils;
  bool _hasNavigatedToFeedback = false;
  bool _isPremium = false;

  // Subscription manager for premium status
  late SubscriptionStatusManager _subscriptionManager;
  late UserService _userService;
  StreamSubscription? _subscriptionStatusSubscription;

  // Initialize the service
  Future<void> initialize() async {
    _prefUtils = PrefUtils();
    await _prefUtils!.init(); // Ensure SharedPreferences is loaded
    _subscriptionManager = SubscriptionStatusManager.instance;
    _userService = UserService();
    
    // Get initial subscription status and listen for changes
    await _checkSubscriptionStatus();
    _subscriptionStatusSubscription = _subscriptionManager.subscriptionStatusStream.listen(_onSubscriptionStatusChanged);
    
    debugPrint('✅ Demo Timer Service initialized');
  }

  Future<void> _checkSubscriptionStatus() async {
    // Check current subscription status
    _isPremium = await _subscriptionManager.checkSubscriptionStatus();
    
    // Only initialize timer if not premium
    if (!_isPremium) {
      _initializeTimer();
    } else if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
  
  void _onSubscriptionStatusChanged(bool isSubscribed) {
    _isPremium = isSubscribed;
    
    // Cancel timer if user became premium
    if (_isPremium && _timer != null) {
      _timer!.cancel();
      _timer = null;
      _hasNavigatedToFeedback = false;
    } 
    // Start timer if user lost premium status
    else if (!_isPremium && _timer == null) {
      _initializeTimer();
    }
  }
  
  Future<void> _initializeTimer() async {
    // Don't initialize if already premium
    if (_isPremium) return;
    
    // Initialize PrefUtils if needed
    if (_prefUtils == null) {
      _prefUtils = PrefUtils();
      await _prefUtils!.init();
    }
    
    // Ensure the timer is initialized locally if needed
    await _prefUtils!.initializeTimerIfNeeded();
    
    // Get current remaining time
    _remainingSeconds = _prefUtils!.calculateRemainingTime();
    debugPrint('[DemoTimerService] Timer initializing with ${_remainingSeconds} seconds remaining (${_remainingSeconds/60} minutes)');

    // Safeguard: If remaining seconds is 0 or less immediately, 
    // something is wrong (likely PrefUtils not initialized or default timer issue)
    // Don't start the timer or set status to STARTED.
    if (_remainingSeconds <= 0) {
      debugPrint('❌ ERROR: Initial remaining demo time is $_remainingSeconds seconds. Preventing timer start.');
      // Optionally, reset the timer here if this indicates a corrupted state
      // await _prefUtils.resetTimer(); 
      return; // Prevent timer start and status update
    }
    
    // Set demo status to STARTED in Firestore only if timer initialization is valid
    await _updateDemoStatus(DemoStatus.STARTED);
    
    // Cancel any existing timer
    _timer?.cancel();
    
    // Start the countdown timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Get the most up-to-date remaining time
      _remainingSeconds = _prefUtils!.calculateRemainingTime();
      
      // Log every 60 seconds for debugging
      if (timer.tick % 60 == 0) {
        debugPrint('[DemoTimerService] Timer running: ${_remainingSeconds} seconds remaining');
      }
      
      if (_remainingSeconds <= 0) {
        // Safeguard: Ensure the timer actually ran for at least one tick 
        // before marking as DONE. This prevents immediate marking if 
        // calculateRemainingTime somehow returns 0 on the very first check.
        if (timer.tick > 1) { 
          _timer?.cancel();
          
          // Set demo status to DONE in Firestore when timer expires
          _updateDemoStatusWithRetry(DemoStatus.DONE).then((_) {
            // After status is updated, handle timer expiration - navigate to feedback page
            _navigateToFeedbackIfNeeded();
          }).catchError((error) {
            debugPrint('❌ ERROR: Failed to update demo status after retry: $error');
            // Still try to navigate to feedback page even if status update fails
            _navigateToFeedbackIfNeeded();
          });
        } else {
          // Log if timer immediately expired, indicating a potential setup issue
          debugPrint('⚠️ WARNING: Demo timer evaluated to <= 0 on tick ${timer.tick}. Not marking as DONE yet.');
          // We don't cancel the timer here, let it run another tick to see if calculation stabilizes
        }
      }
    });
  }
  
  // Updated method with retry capability for ensuring critical status updates succeed
  Future<void> _updateDemoStatusWithRetry(DemoStatus status) async {
    if (!_userService.isLoggedIn) return;
    
    try {
      // Try to update status
      await _updateDemoStatus(status);
      
      // Verify update was successful (for critical states like DONE)
      if (status == DemoStatus.DONE) {
        // Double check status was updated
        final currentStatus = await _userService.getDemoStatus();
        if (currentStatus != status) {
          debugPrint('⚠️ WARNING: Demo status verification failed. Retrying update...');
          // Try one more time
          await _updateDemoStatus(status);
        }
      }
    } catch (e) {
      debugPrint('❌ ERROR updating demo status: $e. Will retry...');
      // Wait briefly and retry once on error
      await Future.delayed(Duration(milliseconds: 500));
      await _updateDemoStatus(status);
    }
  }
  
  Future<void> _updateDemoStatus(DemoStatus status) async {
    if (!_userService.isLoggedIn) return;
    
    try {
      await _userService.setDemoStatus(status);
      debugPrint('Demo status updated to ${status.value}');
    } catch (e) {
      debugPrint('Error updating demo status: $e');
    }
  }
  
  void _navigateToFeedbackIfNeeded() {
    // Don't navigate if premium
    if (_isPremium) {
      debugPrint('[DemoTimerService] User is premium, skipping feedback navigation.');
      return;
    }
    
    if (!_hasNavigatedToFeedback) {
      debugPrint('[DemoTimerService] Attempting to navigate to FeedbackScreen...');
      _hasNavigatedToFeedback = true;
      // Delay navigation slightly to prevent multiple navigations
      Future.delayed(Duration(milliseconds: 500), () {
        final currentContext = NavigatorService.navigatorKey.currentContext;
        if (currentContext != null) {
          debugPrint('[DemoTimerService] Context found. Navigating to ${AppRoutes.feedbackScreen}');
          Navigator.of(currentContext).pushNamedAndRemoveUntil(
            AppRoutes.feedbackScreen,
            (route) => false,
          );
          debugPrint('[DemoTimerService] Navigation command issued.');
        } else {
          debugPrint('❌ [DemoTimerService] ERROR: Navigator context is null. Cannot navigate.');
        }
      });
    } else {
      debugPrint('[DemoTimerService] Already navigated to feedback, skipping.');
    }
  }
  
  // Check if timer is expired
  bool isTimerExpired() {
    if (_isPremium) return false;
    if (_prefUtils == null) return false; // Avoid null error
    return _prefUtils!.hasTimerExpired();
  }
  
  // Check if a timer was ever created - now also checks Firestore
  Future<bool> wasTimerCreated() async {
    // Check if timer was set in local preferences
    if (_prefUtils == null) return false; // Avoid null error
    bool localTimerCreated = _prefUtils!.getTimerStartTime() > 0;
    
    // Also check Firestore if the user is logged in
    if (_userService.isLoggedIn) {
      DemoStatus status = await _userService.getDemoStatus();
      // If status is STARTED or DONE, a timer was created
      return localTimerCreated || status == DemoStatus.STARTED || status == DemoStatus.DONE;
    }
    
    return localTimerCreated;
  }
  
  // Check if the demo is marked as done in Firestore
  Future<bool> isDemoMarkedAsDone() async {
    if (!_userService.isLoggedIn) return false;
    
    DemoStatus status = await _userService.getDemoStatus();
    return status == DemoStatus.DONE;
  }
  
  // Reset navigation flag (call when returning from feedback screen)
  void resetNavigationFlag() {
    _hasNavigatedToFeedback = false;
  }
  
  // Get remaining seconds
  int getRemainingSeconds() {
    return _remainingSeconds;
  }
  
  // Refresh and get the latest remaining time
  int refreshRemainingTime() {
    try {
      // Initialize PrefUtils if it hasn't been initialized yet
      if (_prefUtils == null) {
        _prefUtils = PrefUtils();
        // Don't wait for init() to complete, but start the initialization
        _prefUtils!.init().then((_) {
          debugPrint('✅ PrefUtils initialized during refreshRemainingTime call');
        });
        return 0; // Return default value while initializing
      }
      
      _remainingSeconds = _prefUtils!.calculateRemainingTime();
      return _remainingSeconds;
    } catch (e) {
      print('Error in refreshRemainingTime: $e');
      // Return a default value to prevent late initialization errors
      return 0;
    }
  }
  
  // Dispose the service
  void dispose() {
    _timer?.cancel();
    _subscriptionStatusSubscription?.cancel();
  }
  
  // Force update the demo status (can be called externally)
  Future<void> forceUpdateDemoStatus(DemoStatus status) async {
    // Check current status first to avoid unnecessary updates
    if (!_userService.isLoggedIn) return;
    
    try {
      DemoStatus currentStatus = await _userService.getDemoStatus();
      if (currentStatus == status) {
        // Status is already set to the requested value, don't update
        debugPrint('Demo status already set to ${status.value}, skipping update');
        return;
      }
      
      // Only update if the status is different
      await _updateDemoStatus(status);
    } catch (e) {
      debugPrint('Error checking current demo status: $e');
      // Continue with update on error
      await _updateDemoStatus(status);
    }
  }
  
  // Restart the timer with the newly selected demo time
  Future<void> restartTimer() async {
    debugPrint('[DemoTimerService] Manually restarting timer with the new demo time...');
    
    // Cancel any existing timer
    _timer?.cancel();
    _timer = null;
    
    // Reinitialize timer (will pick up the new time from PrefUtils)
    await _initializeTimer();
    
    // Log the new remaining time
    debugPrint('[DemoTimerService] Timer restarted with ${_remainingSeconds} seconds remaining');
  }
} 