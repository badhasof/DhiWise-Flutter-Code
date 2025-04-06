import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../core/utils/pref_utils.dart';
import '../../services/user_reading_service.dart';
import '../../services/user_service.dart';
import '../../services/subscription_service.dart';
import '../../services/user_stats_manager.dart';
import '../../services/subscription_status_manager.dart';
import '../../services/demo_timer_service.dart';
import 'bloc/progress_bloc.dart';
import 'models/progress_model.dart'; // ignore_for_file: must_be_immutable

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<ProgressBloc>(
      create: (context) => ProgressBloc(ProgressState(
        progressModelObj: ProgressModel(),
      ))
        ..add(ProgressInitialEvent()),
      child: ProgressPage(),
    );
  }

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Timer? _timer;
  int _remainingSeconds = 0; // Initialize to 0, will be updated in initState
  late PrefUtils _prefUtils;
  bool _hasNavigatedToFeedback = false;
  
  // Services and controllers
  late UserReadingService _userReadingService;
  late UserService _userService;
  late SubscriptionService _subscriptionService;
  late UserStatsManager _statsManager;
  ScrollController? _scrollController;
  
  // Completed stories count
  int _completedStoriesCount = 0;
  bool _isLoadingStats = false;
  bool _hasLoadedStatsOnce = false;
  List<Map<String, dynamic>> _recentCompletedStories = [];
  
  // Level calculation variables
  int _currentLevel = 1;
  int _storiesForNextLevel = 3;
  int _totalStoriesForCurrentLevel = 0;
  int _progressToNextLevel = 0;
  
  // Premium status
  bool _isPremium = false;
  bool _isCheckingPremium = true;
  String _subscriptionType = "";
  
  // For UI refresh control
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _userReadingService = UserReadingService();
    _userService = UserService();
    _subscriptionService = SubscriptionService();
    _prefUtils = PrefUtils();
    _statsManager = UserStatsManager();
    _scrollController = ScrollController();
    
    // Record today's login for streak tracking
    _prefUtils.recordTodayLogin();
    
    // Initialize timer if needed
    if (!_statsManager.isPremiumChecked) {
      // If premium status hasn't been checked yet, check it
      _checkPremiumStatus();
    } else if (!_statsManager.isPremium) {
      // If already checked and not premium, initialize timer
      _initializeTimer();
    }
    
    // Refresh stats if needed
    _refreshStatsIfNeeded();
    
    // Set up real-time listeners for automatic UI updates
    _setupRealTimeListeners();
  }
  
  Future<void> _checkPremiumStatus() async {
    try {
      // Check if user has premium access (using the stats manager)
      if (!_statsManager.isPremiumChecked) {
        await _statsManager.checkPremiumStatus();
      }
      
      if (mounted) {
        setState(() {});
      }
      
      // Only initialize timer for non-premium users
      if (!_statsManager.isPremium) {
        _initializeTimer();
      }
      
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      
      // Initialize timer on error (default to free tier behavior)
      _initializeTimer();
    }
  }
  
  Future<void> _initializeTimer() async {
    try {
      // Get the DemoTimerService instance instead of initializing own timer
      _remainingSeconds = DemoTimerService.instance.refreshRemainingTime();
      if (mounted) setState(() {}); // Update UI with current time
      
      // Start the countdown timer that uses the central DemoTimerService
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            // Get the most up-to-date remaining time from the DemoTimerService
            _remainingSeconds = DemoTimerService.instance.refreshRemainingTime();
            
            if (_remainingSeconds <= 0) {
              _timer?.cancel();
              
              // Ensure status is set to DONE when timer expires
              DemoTimerService.instance.forceUpdateDemoStatus(DemoStatus.DONE);
              
              // Handle timer expiration - navigate to feedback page
              _navigateToFeedbackIfNeeded();
            }
          });
        }
      });
    } catch (e) {
      print('Error initializing timer: $e');
      // Set a default value
      _remainingSeconds = 0;
      if (mounted) setState(() {});
    }
  }
  
  Future<void> _loadUserStats() async {
    try {
      // Only set loading state if we've already loaded stats once 
      // This prevents UI flicker on initial load
      if (_hasLoadedStatsOnce) {
        setState(() {
          _isLoadingStats = true;
        });
      }
      
      // Get the total number of completed stories
      final totalStories = await _userReadingService.getTotalCompletedStories();
      
      // Get the most recent completed stories (up to 5)
      final recentStories = await _userReadingService.getCompletedStories();
      final limitedRecentStories = recentStories.take(5).toList();
      
      // Calculate the user's level and progress
      _calculateLevelStats(totalStories);
      
      // Only update UI after all data is loaded
      if (mounted) {
        setState(() {
          _completedStoriesCount = totalStories;
          _recentCompletedStories = limitedRecentStories;
          _isLoadingStats = false;
          _hasLoadedStatsOnce = true;
        });
      }
      
      debugPrint('✅ Loaded user stats: $_completedStoriesCount completed stories, Level: $_currentLevel');
    } catch (e) {
      debugPrint('❌ Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
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
  
  // Get total stories needed to reach a specific level
  int _getTotalStoriesForLevel(int targetLevel) {
    int totalStories = 0;
    int storiesIncrement = 3; // Start with 3 stories for level 2
    
    for (int level = 2; level <= targetLevel; level++) {
      totalStories += storiesIncrement;
      storiesIncrement++; // Each level requires one more story
    }
    
    return totalStories;
  }
  
  // Refresh stats if they're stale or not loaded yet
  Future<void> _refreshStatsIfNeeded() async {
    if (_statsManager.isDataStale) {
      await _statsManager.fetchUserStats();
      if (mounted) setState(() {});
    }
  }
  
  // Set up real-time listeners
  void _setupRealTimeListeners() {
    // Set up the real-time Firebase listeners
    _statsManager.setupRealTimeListeners();
    
    // Register a setState callback to update the UI when data changes
    _statsManager.addListener(() {
      if (mounted) {
        setState(() {
          // UI will be updated with the latest data from the statsManager
          debugPrint('🔄 ProgressPage: Updating UI with real-time data');
        });
      }
    });
  }
  
  // Handle manual refresh by user
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // This will trigger manual refresh, but any future changes will be caught by listeners
      await _statsManager.refreshAll();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
    
    return;
  }
  
  void _navigateToFeedbackIfNeeded() {
    // Don't navigate to feedback page if user is premium
    if (_statsManager.isPremium) return;
    
    if (!_hasNavigatedToFeedback && mounted) {
      _hasNavigatedToFeedback = true;
      // Delay navigation slightly to prevent multiple navigations
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.feedbackScreen,
          (route) => false,
        );
      });
    }
  }
  
  @override
  void dispose() {
    // Clean up the real-time listeners
    _statsManager.removeListener(() {
      if (mounted) setState(() {});
    });
    _timer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }
  
  // Get the individual digits for the time display
  List<String> _getTimeDigits() {
    // Ensure remaining seconds is not negative
    int seconds = _remainingSeconds > 0 ? _remainingSeconds : 0;
    
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    
    return [
      minutesStr[0],
      minutesStr[1],
      secondsStr[0],
      secondsStr[1],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
                        child: Column(
                          children: [
                            _buildStreakCard(context),
                            SizedBox(height: 20.h),
                            _buildProgressCards(context),
                            SizedBox(height: 12.h),
                            _buildNextLevelCard(context),
                            SizedBox(height: 12.h),
                            _buildRecentCompletedStories(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTopBar(BuildContext context) {
    // Get the time digits for the display
    List<String> timeDigits = _getTimeDigits();
    
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          // Progress title centered
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: AppDecoration.outlinePrimary12,
            child: Center(
              child: Text(
                "Progress",
                style: CustomTextStyles.titleMediumOnPrimaryExtraBold,
              ),
            ),
          ),
          
          // Only show trial time container for non-premium users
          if (_statsManager.isPremiumChecked && !_statsManager.isPremium)
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: appTheme.deepOrangeA200,
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trial time",
                    style: CustomTextStyles.titleMediumOnPrimaryContainer,
                  ),
                  Row(
                    children: [
                      _buildTimeBox(timeDigits[0]),
                      _buildTimeBox(timeDigits[1]),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.h),
                        child: Text(
                          ":",
                          style: CustomTextStyles.titleMediumOnPrimaryContainer,
                        ),
                      ),
                      _buildTimeBox(timeDigits[2]),
                      _buildTimeBox(timeDigits[3]),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String number) {
    return Container(
      width: 24.h,
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6.h),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.fSize,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildStreakCard(BuildContext context) {
    // Get streak data
    final streakCount = _prefUtils.getStreakCount();
    final loginDays = _prefUtils.getLoginDaysOfWeek();
    final today = DateTime.now().weekday;
    
    // Calculate day numbers for the current week (Monday to Sunday)
    // First, get the date of Monday of this week
    final now = DateTime.now();
    final mondayDate = now.subtract(Duration(days: now.weekday - 1));
    
    // Create a map of day numbers for the full week
    Map<int, String> dayNumbers = {};
    for (int i = 1; i <= 7; i++) {
      final date = mondayDate.add(Duration(days: i - 1));
      dayNumbers[i] = date.day.toString();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.h),
      child: Stack(
        children: [
          // Background with gradient and blurred circles
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // No blur for the main container
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE3CC),
                      Color(0xFFFFD2AD),
                    ],
                    stops: [0.28, 1.0],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // White ellipse (top right)
                    Positioned(
                      right: -66.h,
                      top: -66.h,
                      child: Container(
                        width: 200.h,
                        height: 200.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    // Orange ellipse (middle right)
                    Positioned(
                      right: -40.h,
                      top: -40.h,
                      child: Container(
                        width: 164.h,
                        height: 164.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF6F3E).withOpacity(0.6),
                        ),
                      ),
                    ),
                    // Yellow ellipse (top right)
                    Positioned(
                      right: -70.h,
                      top: -70.h,
                      child: Container(
                        width: 120.h,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFCA6C).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Apply blur to the background only
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // Large white ellipse with stroke (bottom left) - moved to foreground
          Positioned(
            left: -120.h,
            top: 81.h,
            child: Container(
              width: 280.h,
              height: 280.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 48.h,
                ),
              ),
            ),
          ),
          
          // Foreground content that should not be blurred
          Container(
            padding: EdgeInsets.all(20.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$streakCount",
                          style: TextStyle(
                            color: appTheme.deepOrangeA200,
                            fontSize: 56.fSize,
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.36,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.08),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "day streak !",
                          style: TextStyle(
                            color: appTheme.gray70001,
                            fontSize: 18.fSize,
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgFireIcon,
                      height: 100.h,
                      width: 100.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: 36.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Monday (weekday 1)
                    _buildDayColumn(
                      "M", 
                      loginDays.contains(1), 
                      isActive: today == 1,
                      weekday: 1,
                      today: today,
                      dayNumber: dayNumbers[1]
                    ),
                    // Tuesday (weekday 2)
                    _buildDayColumn(
                      "T", 
                      loginDays.contains(2), 
                      isActive: today == 2,
                      weekday: 2,
                      today: today,
                      dayNumber: dayNumbers[2]
                    ),
                    // Wednesday (weekday 3)
                    _buildDayColumn(
                      "W", 
                      loginDays.contains(3), 
                      isActive: today == 3,
                      weekday: 3,
                      today: today,
                      dayNumber: dayNumbers[3]
                    ),
                    // Thursday (weekday 4)
                    _buildDayColumn(
                      "T", 
                      loginDays.contains(4), 
                      isActive: today == 4,
                      weekday: 4,
                      today: today,
                      dayNumber: dayNumbers[4]
                    ),
                    // Friday (weekday 5)
                    _buildDayColumn(
                      "F", 
                      loginDays.contains(5), 
                      isActive: today == 5,
                      weekday: 5,
                      today: today,
                      dayNumber: dayNumbers[5]
                    ),
                    // Saturday (weekday 6)
                    _buildDayColumn(
                      "S", 
                      loginDays.contains(6), 
                      isActive: today == 6,
                      weekday: 6,
                      today: today,
                      dayNumber: dayNumbers[6]
                    ),
                    // Sunday (weekday 7)
                    _buildDayColumn(
                      "S", 
                      loginDays.contains(7), 
                      isActive: today == 7,
                      weekday: 7,
                      today: today,
                      dayNumber: dayNumbers[7]
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, bool isChecked, {
    bool isActive = false,
    required int weekday,
    required int today,
    String? dayNumber,
  }) {
    bool isPastDay = weekday < today;
    bool isFutureDay = weekday > today;
    
    Color dotColor = Colors.transparent;
    Color textColor = appTheme.gray600;
    
    if (isActive) {
      // Today
      dotColor = appTheme.deepOrangeA200;
      textColor = appTheme.deepOrangeA200;
    } else if (isChecked) {
      // Past day with login
      dotColor = appTheme.deepOrangeA200;
    } else if (isPastDay) {
      // Past day without login
      dotColor = Colors.white;
    } 
    
    return Column(
      children: [
        Container(
          width: 8.h,
          height: 8.h,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 30.h,
          height: 30.h,
          decoration: BoxDecoration(
            color: isActive 
                ? appTheme.deepOrangeA200 
                : Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: isActive 
                    ? Colors.white 
                    : isPastDay
                        ? appTheme.gray600 
                        : appTheme.gray800,
                fontSize: 14.fSize,
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          dayNumber ?? "",
          style: TextStyle(
            color: textColor,
            fontSize: 12.fSize,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildProgressCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: ImageConstant.imgDartIcon,
                iconBgColor: Color(0xFFCDEDFE),
                title: "Stories Read",
                value: _statsManager.isDataLoaded 
                    ? "${_statsManager.completedStoriesCount}" 
                    : "—",
                isLoading: !_statsManager.isDataLoaded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String icon,
    required Color iconBgColor,
    required String title,
    required String value,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.gray10001,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(
            color: appTheme.gray10001,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.h,
              height: 48.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Center(
                child: CustomImageView(
                  imagePath: icon,
                  height: 24.h,
                  width: 24.h,
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: appTheme.gray70001,
                      fontSize: 14.fSize,
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  isLoading
                      ? Container(
                          height: 20.h,
                          width: 30.h,
                          color: Colors.transparent,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: appTheme.gray800.withOpacity(0.5),
                              fontSize: 20.fSize,
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            color: appTheme.gray800,
                            fontSize: 20.fSize,
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLevelCard(BuildContext context) {
    // Calculate progress percentage for the progress bar
    double progressPercentage = !_statsManager.isDataLoaded
        ? 0.0 
        : _statsManager.progressToNextLevel / _statsManager.totalStoriesForCurrentLevel;
    
    // Calculate the progress bar width (max 100%)
    double progressWidth = MediaQuery.of(context).size.width - 112.h;
    double filledWidth = progressWidth * progressPercentage;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.gray10001,
          width: 1,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(
            color: appTheme.gray10001,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: appTheme.deepOrange50,
                    borderRadius: BorderRadius.circular(289.h),
                  ),
                  child: Center(
                    child: CustomImageView(
                      imagePath: ImageConstant.imgTrophyIcon,
                      height: 24.h,
                      width: 24.h,
                    ),
                  ),
                ),
                SizedBox(width: 14.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            !_statsManager.isDataLoaded 
                                ? "Level —" 
                                : "Level ${_statsManager.currentLevel}",
                            style: TextStyle(
                              color: !_statsManager.isDataLoaded 
                                  ? appTheme.gray900.withOpacity(0.5) 
                                  : appTheme.gray900,
                              fontSize: 16.fSize,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgArrowRightOrange,
                            height: 20.h,
                            width: 20.h,
                            color: appTheme.deepOrangeA200,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        !_statsManager.isDataLoaded
                            ? "—/— stories" 
                            : "${_statsManager.progressToNextLevel}/${_statsManager.totalStoriesForCurrentLevel} stories",
                        style: TextStyle(
                          color: !_statsManager.isDataLoaded 
                              ? appTheme.blueGray400.withOpacity(0.5) 
                              : appTheme.blueGray400,
                          fontSize: 14.fSize,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: appTheme.gray30001,
                          borderRadius: BorderRadius.circular(100.h),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: !_statsManager.isDataLoaded ? 0 : filledWidth,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Color(0xFF59CC03),
                                borderRadius: BorderRadius.circular(12.h),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCompletedStories(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.gray10001,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recently Completed Stories",
            style: TextStyle(
              color: appTheme.gray800,
              fontSize: 16.fSize,
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          if (!_statsManager.isDataLoaded || _isRefreshing)
            // Show placeholder items while loading
            Column(
              children: List.generate(3, (index) => 
                Column(
                  children: [
                    _buildPlaceholderStoryItem(),
                    if (index < 2) 
                      Divider(
                        color: appTheme.gray10001,
                        height: 16.h,
                      ),
                  ],
                )
              ),
            )
          else if (_statsManager.recentCompletedStories.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  "You haven't completed any stories yet.\nStart reading to see your progress!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme.gray600,
                    fontSize: 14.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _statsManager.recentCompletedStories.length,
              separatorBuilder: (context, index) => Divider(
                color: appTheme.gray10001,
                height: 16.h,
              ),
              itemBuilder: (context, index) {
                final story = _statsManager.recentCompletedStories[index];
                final title = story['titleEn'] ?? 'Unknown Story';
                final completedAt = story['completedAt'] as Timestamp?;
                final completedDate = completedAt != null 
                    ? completedAt.toDate()
                    : DateTime.now();
                
                // Format the date as "Mon, Jan 1"
                final formattedDate = '${_getDayName(completedDate.weekday)}, ${_getMonthName(completedDate.month)} ${completedDate.day}';
                
                // Calculate which story number this was in the user's progression
                // This helps us display the proper level tag
                int storyNumber = _statsManager.completedStoriesCount - index;
                if (storyNumber < 1) storyNumber = 1;
                
                // Calculate the level this story was completed at
                int storyLevel = _statsManager.calculateLevelForStoryNumber(storyNumber);
                String levelDisplay = story['level'] ?? "Level $storyLevel";
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFCDEDFE),
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.book,
                          color: appTheme.deepOrangeA200,
                          size: 20.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: appTheme.gray800,
                              fontSize: 14.fSize,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: appTheme.gray600,
                              fontSize: 12.fSize,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: appTheme.deepOrangeA200.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.h),
                      ),
                      child: Text(
                        levelDisplay,
                        style: TextStyle(
                          color: appTheme.deepOrangeA200,
                          fontSize: 10.fSize,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
  
  // Helper method to build a placeholder story item while loading
  Widget _buildPlaceholderStoryItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.h,
          height: 40.h,
          decoration: BoxDecoration(
            color: Color(0xFFCDEDFE).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Center(
            child: Icon(
              Icons.book,
              color: appTheme.deepOrangeA200.withOpacity(0.5),
              size: 20.h,
            ),
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150.h,
                height: 14.h,
                decoration: BoxDecoration(
                  color: appTheme.gray50,
                  borderRadius: BorderRadius.circular(4.h),
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 80.h,
                height: 10.h,
                decoration: BoxDecoration(
                  color: appTheme.gray50,
                  borderRadius: BorderRadius.circular(4.h),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
          decoration: BoxDecoration(
            color: appTheme.deepOrangeA200.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.h),
          ),
          child: Container(
            width: 36.h,
            height: 10.h,
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(4.h),
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper method to get the day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
  
  // Helper method to get the month name
  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  // Milestone Card Widget
  Widget _buildMilestoneCard(BuildContext context) {
    // Calculate stories needed for next level
    final int storiesForNextLevel = _statsManager.storiesForNextLevel;
    final int storiesLeft = storiesForNextLevel - _statsManager.progressToNextLevel;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: appTheme.deepOrangeA200,
                    size: 24.h,
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    "Next Milestone",
                    style: CustomTextStyles.titleMediumGray900,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Level ${_statsManager.currentLevel + 1}",
                  style: CustomTextStyles.titleMediumGray900.copyWith(
                    color: appTheme.deepOrangeA200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  storiesLeft > 0 
                    ? "Complete $storiesLeft more ${storiesLeft == 1 ? 'story' : 'stories'} to reach Level ${_statsManager.currentLevel + 1}"
                    : "You've reached Level ${_statsManager.currentLevel + 1}!",
                  style: CustomTextStyles.bodyMediumGray700,
                ),
                SizedBox(height: 12.h),
                CustomElevatedButton(
                  text: storiesLeft > 0 ? "Keep Reading" : "Congratulations!",
                  margin: EdgeInsets.zero,
                  height: 40.h,
                  buttonStyle: CustomButtonStyles.fillDeepOrangeA,
                  onPressed: storiesLeft > 0 ? () {
                    Navigator.pushNamed(context, AppRoutes.homeScreen);
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format seconds into hours:minutes:seconds format
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  // Statistics Card Widget
  Widget _buildStatisticsCard(BuildContext context) {
    // Get streak from preferences
    final streak = _prefUtils.getStreakCount();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: appTheme.deepOrangeA200,
                    size: 24.h,
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    "Statistics",
                    style: CustomTextStyles.titleMediumGray900,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    color: appTheme.gray50,
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${_statsManager.completedStoriesCount}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: appTheme.deepOrangeA200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Stories",
                        style: CustomTextStyles.bodyMediumGray600,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    color: appTheme.gray50,
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$streak",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: appTheme.deepOrangeA200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Day Streak",
                        style: CustomTextStyles.bodyMediumGray600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    color: appTheme.gray50,
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${_statsManager.currentLevel}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: appTheme.deepOrangeA200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Level",
                        style: CustomTextStyles.bodyMediumGray600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Subscription Status Card Widget
  Widget _buildSubscriptionStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _statsManager.isPremium 
                      ? Icons.star 
                      : Icons.star_border,
                    color: appTheme.deepOrangeA200,
                    size: 24.h,
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    "Subscription",
                    style: CustomTextStyles.titleMediumGray900,
                  ),
                ],
              ),
              CustomElevatedButton(
                height: 32.h,
                width: 100.h,
                text: _statsManager.isPremium ? "Manage" : "Upgrade",
                margin: EdgeInsets.zero,
                buttonStyle: CustomButtonStyles.fillDeepOrangeA,
                buttonTextStyle: CustomTextStyles.titleMediumOnPrimary,
                onPressed: () async {
                  if (_statsManager.isPremium) {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(
                          color: appTheme.deepOrangeA200,
                        ),
                      ),
                    );
                    
                    // Try to open subscription management
                    final success = await SubscriptionStatusManager.instance.openSubscriptionManagement();
                    
                    // Hide loading dialog
                    Navigator.of(context, rootNavigator: true).pop();
                    
                    if (!success && context.mounted) {
                      // Show error message if failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open subscription management. Please try again later.'))
                      );
                    }
                  } else {
                    // Check if user already has premium before showing subscription screen
                    bool shouldShow = await SubscriptionStatusManager.instance.shouldShowSubscriptionScreen(context);
                    
                    // Only navigate if needed
                    if (shouldShow && context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.subscriptionScreen);
                    }
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              children: [
                Icon(
                  _statsManager.isPremium 
                    ? Icons.check_circle 
                    : Icons.access_time,
                  color: _statsManager.isPremium 
                    ? Colors.green 
                    : appTheme.deepOrangeA200,
                  size: 24.h,
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statsManager.isPremium 
                          ? "Premium Access" 
                          : "Free Trial",
                        style: CustomTextStyles.titleMediumGray900.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _statsManager.isPremium 
                          ? _statsManager.subscriptionType.isNotEmpty
                            ? "${_statsManager.subscriptionType} Plan" 
                            : "Premium Plan"
                          : _remainingSeconds > 0 
                            ? "${_formatTime(_remainingSeconds)} remaining" 
                            : "Trial expired",
                        style: CustomTextStyles.bodyMediumGray600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 