import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../services/story_service.dart';
import '../story_screen/story_screen.dart';
import '../../widgets/countdown_timer_widget.dart';

class StoryData {
  final String title;
  final String arabicTitle;
  final String description;
  final String imagePath;
  final String level;
  final String duration;
  final bool isFavorite;

  StoryData({
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.imagePath,
    required this.level,
    required this.duration,
    this.isFavorite = false,
  });
}

class StoriesOverviewScreen extends StatefulWidget {
  final StoryData storyData;

  const StoriesOverviewScreen({
    Key? key,
    required this.storyData,
  }) : super(key: key);

  @override
  State<StoriesOverviewScreen> createState() => _StoriesOverviewScreenState();
}

class _StoriesOverviewScreenState extends State<StoriesOverviewScreen> {
  bool isFavorite = false;
  // Story service instance
  final StoryService _storyService = StoryService();
  // Story object
  Story? _story;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.storyData.isFavorite;
    _loadStory();
  }
  
  // Load the story from the service
  Future<void> _loadStory() async {
    // Try to find a story with a matching title
    final stories = await _storyService.getStories();
    final matchingStory = stories.where((s) => 
      s.titleEn.toLowerCase() == widget.storyData.title.toLowerCase() ||
      s.titleAr.toLowerCase() == widget.storyData.arabicTitle.toLowerCase()
    ).toList();
    
    if (matchingStory.isNotEmpty) {
      setState(() {
        _story = matchingStory.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoryImage(),
                      SizedBox(height: 16.h),
                      _buildTagsAndTitles(),
                      SizedBox(height: 16.h),
                      _buildDescriptionSection(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.h, 0, 16.h, 16.h),
              child: _buildReadNowButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Column(
      children: [
        // Status bar content (time, battery, etc.)
        // Trail time indicator
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: 4.h),
            child: CountdownTimerWidget(hideIfPremium: true),
          ),
        ),
        // Navigation bar with back button, title, and favorite button
        Container(
          padding: EdgeInsets.fromLTRB(16.h, 4.h, 16.h, 12.h),
          decoration: BoxDecoration(
            color: Color(0xFFFFF9F4),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFEFECEB),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFFAB9C97),
                  size: 24.h,
                ),
              ),
              Text(
                "Overview",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF37251F),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Color(0xFFFF4C4B),
                  size: 24.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.h),
      child: Image.asset(
        _story?.imagePath ?? widget.storyData.imagePath,
        width: double.infinity,
        height: 200.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTagsAndTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level and duration tags
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
              decoration: BoxDecoration(
                color: Color(0xFF1CAFFB),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                widget.storyData.level,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12.fSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
              decoration: BoxDecoration(
                color: Color(0xFFFFEBE5),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.h,
                    color: appTheme.deepOrangeA200,
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    widget.storyData.duration,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                      color: appTheme.deepOrangeA200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Story title (English)
        Text(
          widget.storyData.title,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 24.fSize,
            fontWeight: FontWeight.w800,
            color: Color(0xFF37251F),
            height: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Story title (Arabic)
        Text(
          widget.storyData.arabicTitle,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18.fSize,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37251F),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dashed line separator
        Container(
          width: double.infinity,
          height: 1,
          child: CustomPaint(
            painter: DashedLinePainter(color: Color(0xFFDBD3D1)),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Story description
        Text(
          widget.storyData.description,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16.fSize,
            fontWeight: FontWeight.w500,
            color: Color(0xFF513E37),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReadNowButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFD84918),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_story != null) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => StoryScreen(story: _story!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Story content not available yet'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            decoration: BoxDecoration(
              color: appTheme.deepOrangeA200,
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Read now",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.h),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  
  DashedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
      
    double dashWidth = 3;
    double dashSpace = 3;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 