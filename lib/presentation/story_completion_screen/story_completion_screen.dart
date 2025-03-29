import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../../core/app_export.dart';
import '../new_stories_completion_screen/new_stories_completion_screen.dart';
import '../home_screen/home_screen.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../services/user_reading_service.dart';
import '../../domain/story/story_model.dart';

class StoryCompletionScreen extends StatefulWidget {
  final String? storyId;
  final Story? storyDetails;
  
  const StoryCompletionScreen({
    Key? key, 
    this.storyId,
    this.storyDetails,
  }) : super(key: key);

  @override
  State<StoryCompletionScreen> createState() => _StoryCompletionScreenState();
}

class _StoryCompletionScreenState extends State<StoryCompletionScreen> {
  late ConfettiController _confettiController;
  final _userReadingService = UserReadingService();
  bool _isRecordingCompletion = false;

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
            
            // Record story completion
            _recordStoryCompletion();
          }
        });
      }
    });
  }

  // Record that the user completed this story
  Future<void> _recordStoryCompletion() async {
    if (_isRecordingCompletion || widget.storyId == null) return;
    
    setState(() {
      _isRecordingCompletion = true;
    });
    
    try {
      await _userReadingService.recordCompletedStory(
        widget.storyId!,
        storyDetails: widget.storyDetails,
      );
      debugPrint('✅ Successfully recorded story completion for ID: ${widget.storyId}');
    } catch (e) {
      debugPrint('❌ Error recording story completion: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingCompletion = false;
        });
      }
    }
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
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          // Trial time indicator
          CountdownTimerWidget(hideIfPremium: true),
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
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 16.h, right: 16.h, top: 16.h, bottom: 36.h),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
                  // Navigate to the new stories completion screen, replacing the current screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => NewStoriesCompletionScreen.builder(context),
                    ),
                  );
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
                  "Try another challenge",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(bottom: 4.h),
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0), // Light gray outer frame
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: Color(0xFFEFECEB),
                  width: 1.5,
                ),
              ),
              child: TextButton(
                onPressed: () {
                  // Fix: Use Navigator.pushReplacement instead of pushAndRemoveUntil
                  // This replaces the current screen while keeping the rest of the navigation stack intact
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen.builder(context),
                    ),
                  );
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
                  "Back to Home",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Color(0xFFFF6F3E),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
} 