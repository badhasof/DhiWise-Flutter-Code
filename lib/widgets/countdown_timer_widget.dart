import 'package:flutter/material.dart';
import 'dart:async';
import '../core/app_export.dart';
import '../core/utils/pref_utils.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_image_view.dart';
import '../theme/custom_button_style.dart';

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({Key? key}) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
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
  
  // Format seconds to mm:ss
  String _formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      height: 22.h,
      width: 122.h,
      text: "Trial time ${_formatTime()}".tr,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 4.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgClock,
          height: 16.h,
          width: 16.h,
          fit: BoxFit.contain,
        ),
      ),
      buttonStyle: CustomButtonStyles.fillDeepOrangeA,
      buttonTextStyle: CustomTextStyles.labelLargeDeeporangeA200_1,
    );
  }
} 