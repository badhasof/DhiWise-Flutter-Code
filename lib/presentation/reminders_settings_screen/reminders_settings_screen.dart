import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../theme/custom_button_style.dart';

class RemindersSettingsScreen extends StatefulWidget {
  const RemindersSettingsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return RemindersSettingsScreen();
  }

  @override
  State<RemindersSettingsScreen> createState() => _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState extends State<RemindersSettingsScreen> {
  bool _mobileEnabled = true;
  bool _emailEnabled = false;
  String _reminderTime = "4:00 PM";

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
                      _buildReminderSettings(context),
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
                    "Reminders",
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
  Widget _buildReminderSettings(BuildContext context) {
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
          _buildReminderItem(
            context,
            title: "Practice reminder",
            isFirst: true,
            trailing: Row(
              children: [
                _buildNotificationToggle(
                  context,
                  isEnabled: _mobileEnabled,
                  icon: Icons.phone_android,
                  onChanged: (value) {
                    setState(() {
                      _mobileEnabled = value;
                    });
                  },
                ),
                SizedBox(width: 8.h),
                _buildNotificationToggle(
                  context,
                  isEnabled: _emailEnabled,
                  icon: Icons.email_outlined,
                  onChanged: (value) {
                    setState(() {
                      _emailEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          _buildReminderItem(
            context,
            title: "Reminder time",
            isLast: true,
            trailing: Row(
              children: [
                Text(
                  _reminderTime,
                  style: TextStyle(
                    color: appTheme.gray600,
                    fontSize: 16.fSize,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8.h),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: appTheme.gray600,
                  size: 24.h,
                ),
              ],
            ),
            onTap: () {
              _showTimePicker(context);
            },
          ),
        ],
      ),
    );
  }

  /// Common Widget
  Widget _buildReminderItem(
    BuildContext context, {
    required String title,
    Widget? trailing,
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
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  /// Common Widget
  Widget _buildNotificationToggle(
    BuildContext context, {
    required bool isEnabled,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        width: 40.h,
        height: 40.h,
        decoration: BoxDecoration(
          color: isEnabled ? appTheme.deepOrangeA200.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: isEnabled ? appTheme.deepOrangeA200 : appTheme.gray100,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? appTheme.deepOrangeA200 : appTheme.gray600,
          size: 20.h,
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRestoreDefaultButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          _mobileEnabled = true;
          _emailEnabled = false;
          _reminderTime = "4:00 PM";
        });
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

  void _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 16, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = "${picked.hourOfPeriod}:${picked.minute.toString().padLeft(2, '0')} ${picked.period == DayPeriod.am ? 'AM' : 'PM'}";
      });
    }
  }
} 