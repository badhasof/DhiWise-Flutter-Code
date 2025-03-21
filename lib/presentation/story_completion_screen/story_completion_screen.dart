import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../../core/app_export.dart';
import '../new_stories_screen/new_stories_screen.dart';
import '../home_screen/home_screen.dart';

class StoryCompletionScreen extends StatefulWidget {
  const StoryCompletionScreen({Key? key}) : super(key: key);

  @override
  State<StoryCompletionScreen> createState() => _StoryCompletionScreenState();
}

class _StoryCompletionScreenState extends State<StoryCompletionScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    
    // More reliable way to ensure animation plays after screen is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This ensures we're not calling play() during build
      if (mounted) {
        // Add a brief delay to ensure the animation is visible
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _confettiController.play();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildBody(),
                ),
                _buildBottomBar(context),
              ],
            ),
          ),
          
          // Center aligned confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2, // straight down
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 25, // increased for more distance
              minBlastForce: 10, // increased for more distance
              gravity: 0.05, // reduced for slower falling
              particleDrag: 0.02, // reduced for less resistance
              colors: const [
                Color(0xFFFF6F3E), // Orange
                Color(0xFF1CAFFB), // Blue
                Color(0xFFFADA7F), // Gold
                Color(0xFF60C6BE), // Teal
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          // Trial time indicator
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
              decoration: BoxDecoration(
                color: Color(0xFFFF6F3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.h,
                    color: Color(0xFFFF6F3E),
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    "Trail time: 30:00",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF6F3E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.only(top: 118.h - 66.h, left: 16.h, right: 16.h, bottom: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildContentWrapper(),
        ],
      ),
    );
  }

  Widget _buildContentWrapper() {
    return Column(
      children: [
        // Illustration/badge
        Container(
          width: 160.h,
          height: 160.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFF9F4), // Match page background
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/completion_star.svg',
              width: 140.h,
              height: 140.h,
            ),
          ),
        ),
        SizedBox(height: 60.h),
        
        // Header text
        Text(
          "Story Completed!",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20.fSize,
            fontWeight: FontWeight.w900,
            color: Color(0xFF37251F),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        
        // Subtitle text
        Text(
          "Well done! You've completed this story.",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14.fSize,
            fontWeight: FontWeight.w500,
            color: Color(0xFF63514B),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // Second part of subtitle on its own line
        Text(
          "Ready for more adventures?",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14.fSize,
            fontWeight: FontWeight.w500,
            color: Color(0xFF63514B),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEFECEB),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTryAnotherButton(context),
            SizedBox(height: 12.h),
            _buildBackToHomeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTryAnotherButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: GestureDetector(
        onTap: () {
          // Navigate to the new stories screen, replacing the current screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NewStoriesScreen.builder(context),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFF6F3E),
            borderRadius: BorderRadius.circular(12.h),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD84918),
                offset: Offset(0, 3),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            child: Center(
              child: Text(
                "Try another challenge",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: GestureDetector(
        onTap: () {
          // Fix: Use Navigator.pushReplacement instead of pushAndRemoveUntil
          // This replaces the current screen while keeping the rest of the navigation stack intact
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen.builder(context),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: Color(0xFFEFECEB),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFEFECEB),
                offset: Offset(0, 3),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            child: Center(
              child: Text(
                "Back to Home",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6F3E),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 