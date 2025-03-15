import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';

class StoryScreen extends StatefulWidget {
  final Story story;

  const StoryScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  // Current playback position
  double _currentPosition = 0.0;
  // Playback speed
  double _playbackSpeed = 1.0;
  // Is playing
  bool _isPlaying = false;
  // Highlighted word in Arabic
  String? _highlightedArabicWord;
  // Highlighted word in English
  String? _highlightedEnglishWord;

  @override
  void initState() {
    super.initState();
    // Hide the bottom navigation bar when this screen is shown
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    // Restore the bottom navigation bar when this screen is closed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndLevel(),
                      SizedBox(height: 24.h),
                      _buildStoryContent(),
                    ],
                  ),
                ),
              ),
            ),
            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Story details",
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  // Show options menu
                },
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
            decoration: BoxDecoration(
              color: appTheme.deepOrangeA200.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.h,
                  color: appTheme.deepOrangeA200,
                ),
                SizedBox(width: 4.h),
                Text(
                  "Trial time: 30:00",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.deepOrangeA200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.story.titleEn,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Text(
                widget.story.level,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: appTheme.deepOrangeA200.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.h,
                    color: appTheme.deepOrangeA200,
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    "3 min",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appTheme.deepOrangeA200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoryContent() {
    return Column(
      children: [
        // Arabic content
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Right-to-left for Arabic
            children: _buildHighlightedText(
              widget.story.contentAr,
              TextDirection.rtl,
              isArabic: true,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Language toggle indicator
        Center(
          child: Container(
            width: 24.h,
            height: 24.h,
            decoration: BoxDecoration(
              color: appTheme.deepOrangeA200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.translate,
              color: Colors.white,
              size: 16.h,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // English content
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildHighlightedText(
              widget.story.contentEn,
              TextDirection.ltr,
              isArabic: false,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHighlightedText(String content, TextDirection direction, {required bool isArabic}) {
    // Split content into paragraphs
    final paragraphs = content.split('\n');
    
    return paragraphs.map((paragraph) {
      // Split paragraph into words
      final words = paragraph.split(' ');
      
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Directionality(
          textDirection: direction,
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontFamily: isArabic ? 'Arabic' : null,
              ),
              children: words.map((word) {
                final isHighlighted = isArabic 
                    ? word.contains(_highlightedArabicWord ?? '')
                    : word.contains(_highlightedEnglishWord ?? '');
                
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    color: isHighlighted 
                        ? appTheme.deepOrangeA200 
                        : Colors.black,
                    backgroundColor: isHighlighted 
                        ? appTheme.deepOrangeA200.withOpacity(0.1)
                        : null,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        if (isArabic) {
                          _highlightedArabicWord = word;
                          // TODO: Find corresponding English word
                        } else {
                          _highlightedEnglishWord = word;
                          // TODO: Find corresponding Arabic word
                        }
                      });
                    },
                );
              }).toList(),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.h),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.h),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
            ),
            child: Slider(
              value: _currentPosition,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
              },
            ),
          ),
          // Time and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current time
              Text(
                "3:00",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              // Play button
              Container(
                width: 56.h,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.blue, // Reverted back to original blue color
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, // Reverted back to original white color
                    size: 32.h,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
              ),
              // Playback speed
              DropdownButton<double>(
                value: _playbackSpeed,
                icon: Icon(Icons.arrow_drop_down),
                underline: SizedBox(),
                items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  return DropdownMenuItem<double>(
                    value: speed,
                    child: Text(
                      "${speed}x",
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playbackSpeed = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
} 