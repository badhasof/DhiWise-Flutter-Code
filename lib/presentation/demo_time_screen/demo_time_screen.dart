import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'bloc/demo_time_bloc.dart';
import 'bloc/demo_time_state.dart';
import 'bloc/demo_time_event.dart';
import 'models/demo_time_model.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DemoTimeScreen extends StatefulWidget {
  const DemoTimeScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<DemoTimeBloc>(
      create: (context) => DemoTimeBloc(DemoTimeState(
        demoTimeModelObj: DemoTimeModel(),
      ))..add(DemoTimeInitialEvent()),
      child: const DemoTimeScreen(),
    );
  }

  @override
  State<DemoTimeScreen> createState() => _DemoTimeScreenState();
}

class _DemoTimeScreenState extends State<DemoTimeScreen> {
  double _sliderValue = 0.67; // Initial slider value for 30 minutes (30/45)

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemoTimeBloc, DemoTimeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0xFFFFF9F4),
          appBar: AppBar(
            backgroundColor: Color(0xFFFFF9F4),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: appTheme.gray900),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth - 32.h; // Accounting for horizontal padding
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            SvgPicture.asset(
              'assets/images/hourglass.svg',
              width: imageWidth,
              height: imageWidth * 0.7,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h), // 16px gap before header
            _buildHeader(),
            SizedBox(height: 16.h), // 16px gap before slider
            _buildSliderSection(),
            SizedBox(height: 16.h), // 16px gap before tip section
            _buildTipSection(),
            SizedBox(height: 116.h), // 116px gap before button
            _buildBottomSection(context),
            SizedBox(height: 24.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Set self-demo time",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24.fSize,
            color: appTheme.gray900,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "How much time would you like\nto explore the app?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 16.fSize,
            color: appTheme.gray700,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection() {
    return Container(
      padding: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFEFECEB), // Light gray outer container
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(
            color: Color(0xFFEFECEB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Time indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "0",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.fSize,
                    color: Color(0xFF80706B),
                  ),
                ),
                Text(
                  "45 Minutes",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.fSize,
                    color: Color(0xFF80706B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            
            // Slider with progress
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background track
                Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFEFECEB),
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                ),
                
                // Active track
                Container(
                  height: 6.h,
                  width: _sliderValue * MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Color(0xFF1CAFFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.h),
                      bottomLeft: Radius.circular(8.h),
                      topRight: _sliderValue == 1.0 ? Radius.circular(8.h) : Radius.zero,
                      bottomRight: _sliderValue == 1.0 ? Radius.circular(8.h) : Radius.zero,
                    ),
                  ),
                ),
                
                // Draggable thumb/nob
                Positioned(
                  top: -6.5.h,
                  left: _sliderValue * (MediaQuery.of(context).size.width * 0.85 - 19.h),
                  child: Container(
                    height: 19.h,
                    width: 19.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.h),
                      border: Border.all(
                        color: Color(0xFF1CAFFB),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                
                // Tooltip
                Positioned(
                  top: -30.h,
                  left: 185.5.h * _sliderValue,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.h),
                      border: Border.all(
                        color: Color(0xFFEFECEB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "${(_sliderValue * 45).round()} mins",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.fSize,
                        color: Color(0xFF37251F),
                      ),
                    ),
                  ),
                ),
                
                // Transparent slider for interaction
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                    trackShape: RectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                        int minutes = (value * 45).round();
                        context.read<DemoTimeBloc>().add(UpdateMinutesEvent(minutes: minutes));
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: DottedBorder(
        color: Color(0xFFDBD3D1),
        strokeWidth: 1,
        dashPattern: [3, 3],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.h),
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.h,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: Color(0xFFFF6F3E), // Orange icon
                  size: 16.h,
                ),
              ),
              SizedBox(width: 8.h),
              Expanded(
                child: Text(
                  "Try about 30 mins to know best about our features!",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.fSize,
                    color: Color(0xFF37251F), // Dark text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
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
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
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
            "Start demo",
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