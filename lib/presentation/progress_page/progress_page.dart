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
  ScrollController? _scrollController;
  
  // Completed stories count
  int _completedStoriesCount = 0;
  bool _isLoadingStats = true;
  List<Map<String, dynamic>> _recentCompletedStories = [];
  
  // Premium status
  bool _isPremium = false;
  bool _isCheckingPremium = true;
  String _subscriptionType = "";
  
  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _userReadingService = UserReadingService();
    _userService = UserService();
    _subscriptionService = SubscriptionService();
    _prefUtils = PrefUtils();
    _scrollController = ScrollController();
    
    // Check premium status
    _checkPremiumStatus();
    
    // Load user stats
    _loadUserStats();
  }
  
  Future<void> _checkPremiumStatus() async {
    setState(() {
      _isCheckingPremium = true;
    });
    
    try {
      // Check if user has premium access
      bool isPremium = await _userService.hasPremiumAccess();
      
      if (isPremium) {
        // Get subscription type
        var userData = await _userService.getUserData();
        if (userData != null && userData.containsKey('subscriptionType')) {
          setState(() {
            _subscriptionType = userData['subscriptionType'] ?? "";
          });
        }
      }
      
      setState(() {
        _isPremium = isPremium;
        _isCheckingPremium = false;
      });
      
      // Only initialize timer for non-premium users
      if (!_isPremium) {
        _initializeTimer();
      }
      
      debugPrint('Premium status: $_isPremium, Type: $_subscriptionType');
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      setState(() {
        _isCheckingPremium = false;
        _isPremium = false;
      });
      
      // Initialize timer on error (default to free tier behavior)
      _initializeTimer();
    }
  }
  
  Future<void> _initializeTimer() async {
    // Initialize the timer if it hasn't been started yet
    await _prefUtils.initializeTimerIfNeeded();
    
    // Get current remaining time
    _remainingSeconds = _prefUtils.calculateRemainingTime();
    if (mounted) setState(() {}); // Update UI with current time
    
    // Start the countdown timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Get the most up-to-date remaining time
          _remainingSeconds = _prefUtils.calculateRemainingTime();
          
          if (_remainingSeconds <= 0) {
            _timer?.cancel();
            // Handle timer expiration - navigate to feedback page
            _navigateToFeedbackIfNeeded();
          }
        });
      }
    });
  }
  
  Future<void> _loadUserStats() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });
      
      // Get the total number of completed stories
      final totalStories = await _userReadingService.getTotalCompletedStories();
      
      // Get the most recent completed stories (up to 5)
      final recentStories = await _userReadingService.getCompletedStories();
      final limitedRecentStories = recentStories.take(5).toList();
      
      setState(() {
        _completedStoriesCount = totalStories;
        _recentCompletedStories = limitedRecentStories;
        _isLoadingStats = false;
      });
      
      debugPrint('✅ Loaded user stats: $_completedStoriesCount completed stories');
    } catch (e) {
      debugPrint('❌ Error loading user stats: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }
  
  void _navigateToFeedbackIfNeeded() {
    // Don't navigate to feedback page if user is premium
    if (_isPremium) return;
    
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
    _timer?.cancel();
    super.dispose();
  }
  
  // Get the individual digits for the time display
  List<String> _getTimeDigits() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    
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
                      onRefresh: _loadUserStats,
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
                            SizedBox(height: 20.h),
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
          if (!_isPremium)
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
            )
          else
            // Show premium badge for premium users
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: Color(0xFF59CC03), // Green for premium
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isCheckingPremium ? "Checking status..." : "Premium Access",
                    style: CustomTextStyles.titleMediumOnPrimaryContainer,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16.h,
                            ),
                            SizedBox(width: 4.h),
                            Text(
                              _subscriptionType,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.fSize,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
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
                          "12",
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
                    _buildDayColumn("M", true),
                    _buildDayColumn("T", true, isActive: true),
                    _buildDayColumn("W", true),
                    _buildDayColumn("T", true),
                    _buildDayColumn("F", false, number: "8"),
                    _buildDayColumn("S", false, number: "9"),
                    _buildDayColumn("S", false, number: "10"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, bool isChecked, {bool isActive = false, String? number}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isActive ? appTheme.gray70001 : appTheme.gray70001.withOpacity(0.8),
            fontSize: 14.fSize,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 30.h,
          height: 30.h,
          decoration: BoxDecoration(
            gradient: isChecked && number == null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      appTheme.deepOrangeA200,
                      appTheme.deepOrangeA100,
                    ],
                  )
                : null,
            color: number != null 
                ? appTheme.gray70001.withOpacity(0.1) 
                : !isChecked
                    ? appTheme.gray50
                    : null,
            borderRadius: BorderRadius.circular(88.h),
            boxShadow: isChecked ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: Offset(0, 2),
                blurRadius: 16,
              ),
            ] : null,
          ),
          child: Center(
            child: number != null
                ? Text(
                    number,
                    style: TextStyle(
                      color: appTheme.gray70001,
                      fontSize: 14.fSize,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : isChecked
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.h,
                      )
                    : null,
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
                value: _isLoadingStats ? "Loading..." : "$_completedStoriesCount",
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: ImageConstant.imgTrophyIcon,
                iconBgColor: Color(0xFFE2FECD),
                title: "Current level",
                value: "Level 5",
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
                  _isLoadingStats && title == "Stories Read"
                      ? SizedBox(
                          height: 16.h,
                          width: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.h,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appTheme.deepOrangeA200,
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

  /// Section Widget
  Widget _buildNextLevelCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
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
                            "Level 6",
                            style: TextStyle(
                              color: appTheme.gray900,
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
                        "12/35 stories",
                        style: TextStyle(
                          color: appTheme.blueGray400,
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
                              width: 124.h,
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
          if (_isLoadingStats)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    appTheme.deepOrangeA200,
                  ),
                ),
              ),
            )
          else if (_recentCompletedStories.isEmpty)
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
              itemCount: _recentCompletedStories.length,
              separatorBuilder: (context, index) => Divider(
                color: appTheme.gray10001,
                height: 16.h,
              ),
              itemBuilder: (context, index) {
                final story = _recentCompletedStories[index];
                final title = story['titleEn'] ?? 'Unknown Story';
                final completedAt = story['completedAt'] as Timestamp?;
                final completedDate = completedAt != null 
                    ? completedAt.toDate()
                    : DateTime.now();
                
                // Format the date as "Mon, Jan 1"
                final formattedDate = '${_getDayName(completedDate.weekday)}, ${_getMonthName(completedDate.month)} ${completedDate.day}';
                
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
                        story['level'] ?? 'Beginner',
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
} 