import 'package:flutter/material.dart';
import 'dart:async';
import '../core/app_export.dart';
import '../core/utils/pref_utils.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_image_view.dart';
import '../theme/custom_button_style.dart';
import '../services/user_service.dart';
import '../services/user_stats_manager.dart';
import '../services/subscription_status_manager.dart';
import '../services/demo_timer_service.dart';

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
  int _remainingSeconds = 0;
  late PrefUtils _prefUtils;
  
  // Subscription manager for premium status
  late SubscriptionStatusManager _subscriptionManager;
  bool _isPremium = false;
  StreamSubscription? _subscriptionStatusSubscription;
  
  @override
  void initState() {
    super.initState();
    _prefUtils = PrefUtils();
    _subscriptionManager = SubscriptionStatusManager.instance;
    
    // Get initial subscription status and listen for changes
    _checkSubscriptionStatus();
    _subscriptionStatusSubscription = _subscriptionManager.subscriptionStatusStream.listen(_onSubscriptionStatusChanged);
    
    // Initialize UI updates
    _startUIUpdates();
  }
  
  Future<void> _checkSubscriptionStatus() async {
    // Check current subscription status
    _isPremium = await _subscriptionManager.checkSubscriptionStatus();
    
    if (mounted) {
      setState(() {});
    }
  }
  
  void _onSubscriptionStatusChanged(bool isSubscribed) {
    if (mounted) {
      setState(() {
        _isPremium = isSubscribed;
      });
    }
  }
  
  void _startUIUpdates() {
    // Start a timer to update the UI with the latest remaining time
    _remainingSeconds = DemoTimerService.instance.refreshRemainingTime();
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds = DemoTimerService.instance.refreshRemainingTime();
          
          // If timer has reached zero, ensure status is updated to DONE
          if (_remainingSeconds <= 0) {
            // Check if timer has actually expired (not just zero due to calculation error)
            if (DemoTimerService.instance.isTimerExpired()) {
              // Update status to DONE if timer has expired
              DemoTimerService.instance.forceUpdateDemoStatus(DemoStatus.DONE);
            }
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _subscriptionStatusSubscription?.cancel();
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
    // If user is premium and we want to hide the widget, return an empty SizedBox
    if (_isPremium && widget.hideIfPremium) {
      return SizedBox.shrink();
    }
    
    // Otherwise show the countdown timer (original UI design)
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