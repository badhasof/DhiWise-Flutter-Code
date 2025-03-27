import 'dart:convert';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: must_be_immutable
class PrefUtils {
  PrefUtils() {
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  static SharedPreferences? _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  ///will clear all the data stored in preference
  void clearPreferencesData() async {
    _sharedPreferences!.clear();
  }

  Future<void> setThemeData(String value) {
    return _sharedPreferences!.setString('themeData', value);
  }

  String getThemeData() {
    try {
      return _sharedPreferences!.getString('themeData')!;
    } catch (e) {
      return 'primary';
    }
  }

  // Method to store demo time in minutes
  Future<void> setDemoTime(int minutes) {
    return _sharedPreferences!.setInt('demoTimeMinutes', minutes);
  }
  
  // Method to retrieve stored demo time
  int getDemoTime() {
    try {
      return _sharedPreferences!.getInt('demoTimeMinutes') ?? 15; // Default to 15 minutes
    } catch (e) {
      return 15; // Default to 15 minutes if there's an error
    }
  }
  
  // Save the start time of the timer
  Future<void> saveTimerStartTime() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _sharedPreferences!.setInt('timerStartTime', now);
  }
  
  // Get the start time of the timer
  int getTimerStartTime() {
    return _sharedPreferences!.getInt('timerStartTime') ?? 0;
  }
  
  // Save the remaining seconds
  Future<void> saveRemainingSeconds(int seconds) {
    return _sharedPreferences!.setInt('remainingSeconds', seconds);
  }
  
  // Get remaining seconds
  int getRemainingSeconds() {
    return _sharedPreferences!.getInt('remainingSeconds') ?? (getDemoTime() * 60);
  }
  
  // Initialize timer on first launch
  Future<void> initializeTimerIfNeeded() async {
    if (!_sharedPreferences!.containsKey('timerStartTime')) {
      await resetTimer();
    }
  }
  
  // Calculate current remaining time based on elapsed time
  int calculateRemainingTime() {
    // Get the stored values
    int startTime = getTimerStartTime();
    int initialRemainingSeconds = getRemainingSeconds();
    
    // If timer hasn't been initialized, return the default demo time
    if (startTime == 0) {
      return getDemoTime() * 60;
    }
    
    // Calculate elapsed time since the timer was started
    int elapsedMillis = DateTime.now().millisecondsSinceEpoch - startTime;
    int elapsedSeconds = elapsedMillis ~/ 1000;
    
    // Calculate remaining seconds
    int remaining = initialRemainingSeconds - elapsedSeconds;
    
    // Ensure we don't go below zero
    return remaining > 0 ? remaining : 0;
  }
  
  // Check if the timer has expired
  bool hasTimerExpired() {
    return calculateRemainingTime() <= 0;
  }
  
  // Reset the timer using the currently selected demo time
  Future<void> resetTimer() async {
    // Get the selected demo time in minutes
    int demoTimeMinutes = getDemoTime();
    // Set start time to current time
    await saveTimerStartTime();
    // Set initial remaining seconds to full demo time
    await saveRemainingSeconds(demoTimeMinutes * 60);
  }
}
