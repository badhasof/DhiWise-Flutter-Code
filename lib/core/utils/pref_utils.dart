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

  // ----- STREAK TRACKING METHODS -----
  
  // Get the current streak count
  int getStreakCount() {
    return _sharedPreferences!.getInt('streakCount') ?? 0;
  }
  
  // Set the streak count
  Future<void> setStreakCount(int count) {
    return _sharedPreferences!.setInt('streakCount', count);
  }
  
  // Get the last login date
  DateTime? getLastLoginDate() {
    final lastLoginMillis = _sharedPreferences!.getInt('lastLoginDate');
    if (lastLoginMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastLoginMillis);
  }
  
  // Set the last login date
  Future<void> setLastLoginDate(DateTime date) {
    return _sharedPreferences!.setInt('lastLoginDate', date.millisecondsSinceEpoch);
  }
  
  // Get days of the week when user logged in (this week)
  List<int> getLoginDaysOfWeek() {
    final List<String> daysList = _sharedPreferences!.getStringList('loginDaysOfWeek') ?? [];
    return daysList.map((day) => int.parse(day)).toList();
  }
  
  // Set days of the week when user logged in
  Future<void> setLoginDaysOfWeek(List<int> days) {
    final List<String> daysList = days.map((day) => day.toString()).toList();
    return _sharedPreferences!.setStringList('loginDaysOfWeek', daysList);
  }
  
  // Add today to login days and update streak
  Future<void> recordTodayLogin() async {
    final now = DateTime.now();
    final today = now.weekday; // 1-7 (Monday-Sunday)
    
    // Get existing data
    final lastLoginDate = getLastLoginDate();
    final loginDays = getLoginDaysOfWeek();
    var streakCount = getStreakCount();
    
    // If this is the first time logging in
    if (lastLoginDate == null) {
      await setStreakCount(1);
      await setLoginDaysOfWeek([today]);
      await setLastLoginDate(now);
      return;
    }
    
    // Check if we need to reset the week
    final lastLoginDateTime = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    final todayDateTime = DateTime(now.year, now.month, now.day);
    final difference = todayDateTime.difference(lastLoginDateTime).inDays;
    
    // Already logged in today, nothing to do
    if (difference == 0) {
      return;
    }
    
    // If it's a new week (last login was more than 7 days ago or in a different week)
    bool isNewWeek = difference > 7 || 
                     lastLoginDate.weekday > today || 
                     (lastLoginDate.year != now.year || 
                     lastLoginDate.month != now.month ||
                     (lastLoginDate.day - lastLoginDate.weekday) != (now.day - now.weekday));
    
    if (isNewWeek) {
      // Reset login days for new week
      loginDays.clear();
    }
    
    // If logged in yesterday, increment streak
    if (difference == 1) {
      streakCount++;
    } 
    // If missed a day or more, reset streak
    else if (difference > 1) {
      streakCount = 1;
    }
    
    // Add today to login days if not already present
    if (!loginDays.contains(today)) {
      loginDays.add(today);
    }
    
    // Save all updates
    await setStreakCount(streakCount);
    await setLoginDaysOfWeek(loginDays);
    await setLastLoginDate(now);
  }
}
