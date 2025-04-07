import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/demo_timer_service.dart';
import '../../services/subscription_status_manager.dart';
import '../../services/user_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return FeedbackScreen();
  }

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _answer1Controller = TextEditingController();
  TextEditingController _answer2Controller = TextEditingController();
  TextEditingController _answer3Controller = TextEditingController();
  bool _isTimerExpired = false;
  bool _isDemoDone = false;
  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    debugPrint('[FeedbackScreen] initState called.'); // Log initState
    super.initState();
    // Reset the navigation flag in the demo timer service
    // This prevents duplicate navigations if the timer expires while on this screen
    DemoTimerService.instance.resetNavigationFlag();
    
    // Check if timer is actually expired and if user is premium
    _checkDemoStatus();
  }
  
  Future<void> _checkDemoStatus() async {
    debugPrint('[FeedbackScreen] _checkDemoStatus started.'); // Log start
    // Check if demo timer is finished in Firebase
    _isDemoDone = await DemoTimerService.instance.isDemoMarkedAsDone();
    debugPrint('[FeedbackScreen] isDemoDone: $_isDemoDone');
    
    // Check if demo timer is expired locally
    _isTimerExpired = await DemoTimerService.instance.isTimerExpired();
    debugPrint('[FeedbackScreen] isTimerExpired: $_isTimerExpired');
    
    // Ensure demo status is updated to DONE if timer is expired but status isn't marked as done
    if (_isTimerExpired && !_isDemoDone) {
      debugPrint('[FeedbackScreen] Timer expired but status not marked as DONE. Forcing update...');
      await DemoTimerService.instance.forceUpdateDemoStatus(DemoStatus.DONE);
      _isDemoDone = true;
      debugPrint('[FeedbackScreen] Status updated to DONE');
    }
    
    // Check if user has premium access
    _isPremium = await SubscriptionStatusManager.instance.checkSubscriptionStatus();
    debugPrint('[FeedbackScreen] isPremium: $_isPremium');
    
    // Mark as no longer loading
    if (mounted) {
      debugPrint('[FeedbackScreen] Setting state: _isLoading = false');
      setState(() {
        _isLoading = false;
      });
    }
    
    // If demo isn't marked as done in Firebase or user has premium, redirect to home
    if (!_isDemoDone || _isPremium) {
      debugPrint('[FeedbackScreen] Condition met for redirection. Redirecting to Home...');
      // Short delay to allow screen to initialize
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          debugPrint('[FeedbackScreen] Executing navigation to Home.');
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.homeScreen,
            (route) => false,
          );
        }
      });
    } else {
      debugPrint('[FeedbackScreen] Conditions not met for redirection. Staying on FeedbackScreen.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    _answer3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[FeedbackScreen] build called. isLoading: $_isLoading, isDemoDone: $_isDemoDone, isPremium: $_isPremium'); // Log build
    // If still loading or demo isn't done or user is premium, show loading indicator
    if (_isLoading || !_isDemoDone || _isPremium) {
      debugPrint('[FeedbackScreen] Building loading indicator.');
      return Scaffold(
        backgroundColor: Color(0xFFFFF9F4),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6F3E),
          ),
        ),
      );
    }
  
    debugPrint('[FeedbackScreen] Building main content.');
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.h),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildTextField("Name", _nameController),
              SizedBox(height: 16.h),
              _buildTextField("Email address", _emailController),
              SizedBox(height: 32.h),
              _buildQuestionField(
                1,
                "What was the most valuable or enjoyable feature you discovered?",
                _answer1Controller,
              ),
              SizedBox(height: 24.h),
              _buildQuestionField(
                2,
                "From the self demo, what didn't you like or enjoy? Please share any complaints you may have.",
                _answer2Controller,
              ),
              SizedBox(height: 24.h),
              _buildQuestionField(
                3,
                "As a valuable user and customer, what would you love to see in an app like this? Don't hold back.",
                _answer3Controller,
              ),
              SizedBox(height: 32.h),
              _buildSubmitButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "No Sugarcoating!",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 28.fSize,
            color: Color(0xFF37251F),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Tell us what sucked and what didn't.",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18.fSize,
            color: Color(0xFFFF6F3E),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Container(
          width: 60.h,
          height: 3.h,
          decoration: BoxDecoration(
            color: Color(0xFFEFECEB),
            borderRadius: BorderRadius.circular(2.h),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: Color(0xFFEFECEB),
          width: 1.h,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          border: InputBorder.none,
          labelStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16.fSize,
            color: Color(0xFF80706B),
          ),
        ),
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16.fSize,
          color: Color(0xFF37251F),
        ),
      ),
    );
  }

  Widget _buildQuestionField(int number, String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.h,
              height: 32.h,
              decoration: BoxDecoration(
                color: Color(0xFFFF6F3E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.fSize,
                  color: Color(0xFF37251F),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(
              color: Color(0xFFEFECEB),
              width: 1.h,
            ),
          ),
          height: 100.h,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "",
              contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16.fSize,
              color: Color(0xFF37251F),
            ),
            maxLines: null,
            expands: true,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFD84918), // Deep orange outer frame
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFF6F3E), // Inner orange content wrapper
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: TextButton(
          onPressed: () async {
            // Double-check demo status before submitting
            bool isDemoDone = await DemoTimerService.instance.isDemoMarkedAsDone();
            if (!isDemoDone) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.homeScreen,
                (route) => false,
              );
              return;
            }
            
            // Submit feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Feedback submitted. Thank you!')),
            );
            
            // Check if user already has premium access
            final bool isPremium = await SubscriptionStatusManager.instance.checkSubscriptionStatus();
            
            // Navigate to subscription/pricing screen only if user doesn't have premium
            Future.delayed(Duration(milliseconds: 1500), () {
              if (!isPremium) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.subscriptionScreen,
                  arguments: {'fromFeedback': true} // Pass data to identify this navigation path
                );
              } else {
                // User already has premium, navigate to home screen instead
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homeScreen,
                  (route) => false,
                );
              }
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.h),
            ),
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            "Send feedback",
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 16.fSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 