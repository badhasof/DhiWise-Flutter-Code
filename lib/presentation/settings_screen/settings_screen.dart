import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../theme/custom_button_style.dart';
import '../notification_settings_screen/notification_settings_screen.dart';
import '../sign_in_screen/sign_in_screen.dart';
import 'bloc/settings_bloc.dart';
import 'models/settings_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(SettingsState(
        settingsModelObj: SettingsModel(),
      ))
        ..add(SettingsInitialEvent()),
      child: SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        children: [
                          _buildAccountSection(context),
                          SizedBox(height: 24.h),
                          _buildSubscriptionSection(context),
                          SizedBox(height: 24.h),
                          _buildSupportSection(context),
                          SizedBox(height: 24.h),
                          _buildSignOutButton(context),
                          SizedBox(height: 24.h),
                          _buildFooterLinks(context),
                          SizedBox(height: 12.h),
                          Text(
                            "VERSION 1.0",
                            style: TextStyle(
                              color: appTheme.gray600,
                              fontSize: 12.fSize,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTopBar(BuildContext context) {
    return Column(
      children: [
        // Trial time banner
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 6.h),
            decoration: BoxDecoration(
              color: appTheme.deepOrangeA200.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgClock,
                  height: 20.h,
                  width: 20.h,
                  color: appTheme.deepOrangeA200,
                ),
                SizedBox(width: 4.h),
                Text(
                  "Trial time: 30:00",
                  style: TextStyle(
                    color: appTheme.deepOrangeA200,
                    fontSize: 12.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Settings header
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: appTheme.gray100,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 50.h),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: appTheme.gray900,
                        fontSize: 18.fSize,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: appTheme.deepOrangeA200,
                    fontSize: 16.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            "Account",
            style: TextStyle(
              color: appTheme.gray600,
              fontSize: 18.fSize,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: appTheme.gray100,
            borderRadius: BorderRadius.circular(12.h),
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 4),
            ),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: ImageConstant.imgSettingsIcon,
                title: "Preferences",
                onTap: () {},
                isFirst: true,
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgUserIcon,
                title: "Profile",
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgNotificationIcon,
                title: "Notifications",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgTeacherIcon,
                title: "LinguaX For Schools",
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgLinkIcon,
                title: "Social Accounts",
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgLockIcon,
                title: "Privacy Settings",
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildSubscriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            "Subscription",
            style: TextStyle(
              color: appTheme.gray600,
              fontSize: 18.fSize,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: appTheme.gray100,
            borderRadius: BorderRadius.circular(12.h),
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 4),
            ),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: ImageConstant.imgChooseAPlanIcon,
                title: "Choose a plan",
                onTap: () {},
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: appTheme.deepOrangeA200,
            borderRadius: BorderRadius.circular(12.h),
            border: Border(
              bottom: BorderSide(color: Color(0xFFD84918), width: 4),
            ),
          ),
          child: CustomElevatedButton(
            height: 48.h,
            text: "Restore subscription",
            buttonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(appTheme.deepOrangeA200),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
              ),
            ),
            buttonTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16.fSize,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            "Support",
            style: TextStyle(
              color: appTheme.gray600,
              fontSize: 18.fSize,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: appTheme.gray100,
            borderRadius: BorderRadius.circular(12.h),
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 4),
            ),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: ImageConstant.imgHelpIcon,
                title: "Help Center",
                onTap: () {},
                isFirst: true,
              ),
              _buildSettingItem(
                context,
                icon: ImageConstant.imgFeedbackIcon,
                title: "Feedback",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.feedbackScreen);
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 4),
        ),
      ),
      child: TextButton(
        onPressed: () => _signOut(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign out",
              style: TextStyle(
                color: appTheme.deepOrangeA200,
                fontSize: 16.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.h),
            CustomImageView(
              imagePath: ImageConstant.imgSignOutIcon,
              height: 24.h,
              width: 24.h,
              color: appTheme.deepOrangeA200,
            ),
          ],
        ),
      ),
    );
  }

  // Sign out method
  void _signOut(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Center(
            child: CircularProgressIndicator(
              color: appTheme.deepOrangeA200,
            ),
          );
        },
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully signed out"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Use NavigatorService to reset navigation and go to onboarding screen
      await Future.delayed(Duration(milliseconds: 500));
      
      // Reset navigation stack and go to onboarding screen
      NavigatorService.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.onboardimgScreen, 
        (route) => false
      );
    } catch (e) {
      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign out: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Section Widget
  Widget _buildFooterLinks(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "TERMS",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.h),
            child: Text(
              "•",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "PRIVACY POLICY",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.h),
            child: Text(
              "•",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "ACKNOWLEDGMENTS",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10.fSize,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Common Widget
  Widget _buildSettingItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
    bool isFirst = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(12.h) : Radius.zero,
          topRight: isFirst ? Radius.circular(12.h) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(12.h) : Radius.zero,
          bottomRight: isLast ? Radius.circular(12.h) : Radius.zero,
        ),
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: appTheme.gray100,
                  width: 1,
                ),
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 24.h,
                height: 24.h,
                child: CustomImageView(
                  imagePath: icon,
                  color: appTheme.gray600,
                ),
              ),
              SizedBox(width: 16.h),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: appTheme.gray900,
                    fontSize: 16.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              CustomImageView(
                imagePath: ImageConstant.imgArrowRightIcon,
                height: 20.h,
                width: 20.h,
                color: appTheme.gray600,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 