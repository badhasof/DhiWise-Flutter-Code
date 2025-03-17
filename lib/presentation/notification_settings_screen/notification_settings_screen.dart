import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../theme/custom_button_style.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return NotificationSettingsScreen();
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildNotificationSettings(context),
                      SizedBox(height: 24.h),
                      _buildRestoreDefaultButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: appTheme.gray600,
                  size: 20.h,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      color: appTheme.gray900,
                      fontSize: 18.fSize,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.h), // Balance the back button
            ],
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildNotificationSettings(BuildContext context) {
    return Container(
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
          _buildNotificationItem(
            context,
            title: "Reminders",
            isFirst: true,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.remindersSettingsScreen);
            },
          ),
          _buildNotificationItem(
            context,
            title: "Friends",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.friendsSettingsScreen);
            },
          ),
          _buildNotificationItem(
            context,
            title: "Leaderboards",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.leaderboardsSettingsScreen);
            },
          ),
          _buildNotificationItem(
            context,
            title: "Announcements",
            isLast: true,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.announcementsSettingsScreen);
            },
          ),
        ],
      ),
    );
  }

  /// Common Widget
  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    VoidCallback? onTap,
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
              Icon(
                Icons.arrow_forward_ios,
                color: appTheme.gray600,
                size: 16.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRestoreDefaultButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Reset all notification settings to default
      },
      child: Text(
        "Restore default",
        style: TextStyle(
          color: appTheme.deepOrangeA200,
          fontSize: 16.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
} 