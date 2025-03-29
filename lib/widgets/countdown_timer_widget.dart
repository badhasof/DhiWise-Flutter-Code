import 'package:flutter/material.dart';
import 'dart:async';
import '../core/app_export.dart';
import '../core/utils/pref_utils.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_image_view.dart';
import '../theme/custom_button_style.dart';
import '../services/user_service.dart';

class CountdownTimerWidget extends StatefulWidget {
  final bool hideIfPremium;
  
  const CountdownTimerWidget({
    Key? key,
    this.hideIfPremium = true,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 0; // Initialize to 0, will be updated in initState
  late PrefUtils _prefUtils;
  bool _hasNavigatedToFeedback = false;
  
  // Premium status
  bool _isPremium = false;
  bool _isCheckingPremium = true;
  final UserService _userService = UserService();
  
  @override
  void initState() {
    super.initState();
    _prefUtils = PrefUtils();
    
    if (widget.hideIfPremium) {
      _checkPremiumStatus();
    } else {
      _initializeTimer();
    }
  }
  
  Future<void> _checkPremiumStatus() async {
    setState(() {
      _isCheckingPremium = true;
    });
    
    try {
      // Check if user has premium access
      bool isPremium = await _userService.hasPremiumAccess();
      
      setState(() {
        _isPremium = isPremium;
        _isCheckingPremium = false;
      });
      
      // Only initialize the timer if NOT premium
      if (!_isPremium) {
        _initializeTimer();
      }
      
      debugPrint('CountdownTimer - Premium status: $_isPremium');
    } catch (e) {
      debugPrint('CountdownTimer - Error checking premium status: $e');
      setState(() {
        _isCheckingPremium = false;
        // Default to non-premium on error
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
  
  void _navigateToFeedbackIfNeeded() {
    // Don't navigate if premium
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
  
  // Format seconds to mm:ss
  String _formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // If checking premium status, show a loading indicator
    if (_isCheckingPremium) {
      return SizedBox(
        height: 22.h,
        width: 122.h,
        child: Center(
          child: SizedBox(
            width: 14.h,
            height: 14.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.h,
              valueColor: AlwaysStoppedAnimation<Color>(
                appTheme.deepOrangeA200,
              ),
            ),
          ),
        ),
      );
    }
    
    // If user is premium and we want to hide the widget, return an empty SizedBox
    if (_isPremium && widget.hideIfPremium) {
      return SizedBox.shrink();
    }
    
    // Otherwise show the countdown timer
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