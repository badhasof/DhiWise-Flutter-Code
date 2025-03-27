import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../core/utils/pref_utils.dart';
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
  
  @override
  void initState() {
    super.initState();
    _prefUtils = PrefUtils();
    _initializeTimer();
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
  
  void _navigateToFeedbackIfNeeded() {
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
                      child: Column(
                        children: [
                          _buildStreakCard(context),
                          SizedBox(height: 20.h),
                          _buildProgressCards(context),
                          SizedBox(height: 12.h),
                          _buildNextLevelCard(context),
                        ],
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
          // Trial time container
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
                value: "8",
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
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(66.h),
              ),
              child: Center(
                child: CustomImageView(
                  imagePath: icon,
                  height: 24.h,
                  width: 24.h,
                ),
              ),
            ),
            SizedBox(width: 14.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: appTheme.gray600,
                    fontSize: 14.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: appTheme.gray800,
                    fontSize: 18.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
} 