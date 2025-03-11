import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_button.dart';

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

  @override
  void initState() {
    super.initState();
    isFavorite = widget.storyData.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLevelAndDuration(),
                          SizedBox(height: 16.h),
                          _buildTitles(),
                          SizedBox(height: 24.h),
                          _buildDescription(),
                          SizedBox(height: 24.h),
                          _buildReadNowButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Overview",
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
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

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        image: DecorationImage(
          image: AssetImage(widget.storyData.imagePath),
          fit: BoxFit.cover,
        ),
      ),
      margin: EdgeInsets.all(16.h),
    );
  }

  Widget _buildLevelAndDuration() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20.h),
          ),
          child: Text(
            widget.storyData.level,
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
                widget.storyData.duration,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appTheme.deepOrangeA200,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.storyData.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.storyData.arabicTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Arabic',
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.storyData.description,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildReadNowButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          // Handle read now action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.deepOrangeA200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Read now",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
    );
  }
} 