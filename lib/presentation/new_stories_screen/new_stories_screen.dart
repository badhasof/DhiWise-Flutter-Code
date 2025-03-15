import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../services/story_service.dart';
import '../home_screen/widgets/home_six_item_widget.dart';
import '../home_screen/models/home_six_item_model.dart';
import '../stories_overview_screen/stories_overview_screen.dart';
import '../story_screen/story_screen.dart';
import 'bloc/new_stories_bloc.dart';
import 'models/new_stories_model.dart';

class NewStoriesScreen extends StatefulWidget {
  const NewStoriesScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<NewStoriesBloc>(
      create: (context) => NewStoriesBloc(NewStoriesState(
        newStoriesModelObj: NewStoriesModel(),
      ))..add(NewStoriesInitialEvent()),
      child: NewStoriesScreen(),
    );
  }

  @override
  State<NewStoriesScreen> createState() => _NewStoriesScreenState();
}

class _NewStoriesScreenState extends State<NewStoriesScreen> {
  // Story service instance
  final StoryService _storyService = StoryService();
  
  // List to store stories
  List<Story> _stories = [];
  
  @override
  void initState() {
    super.initState();
    _loadStories();
  }
  
  // Load stories from the service
  Future<void> _loadStories() async {
    final stories = await _storyService.getStories();
    setState(() {
      _stories = stories;
    });
  }
  
  // Navigate to story overview screen
  void _navigateToStoryOverview(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoriesOverviewScreen(storyData: story.toStoryData()),
      ),
    );
  }
  
  // Navigate to story screen
  void _navigateToStoryScreen(Story story) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => StoryScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewStoriesBloc, NewStoriesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "All Stories",
              style: theme.textTheme.titleLarge,
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    _buildTrialTimeWidget(),
                    SizedBox(height: 24.h),
                    _buildStoryList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrialTimeWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
      decoration: BoxDecoration(
        color: appTheme.deepOrangeA200,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          Text(
            "Trial time",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          _buildTimeDigit("2"),
          _buildTimeDigit("9"),
          Text(
            ":",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          _buildTimeDigit("5"),
          _buildTimeDigit("9"),
        ],
      ),
    );
  }

  Widget _buildTimeDigit(String digit) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.h),
      ),
      child: Text(
        digit,
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStoryList() {
    if (_stories.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: _stories.map((story) {
        return Column(
          children: [
            HomeSixItemWidget(
              HomeSixItemModel(
                labelfill: story.genre,
                hisnewbook: story.titleEn,
                label: "Read Now",
              ),
              story: story,
              onTap: () => _navigateToStoryOverview(story),
              onButtonTap: () => _navigateToStoryScreen(story),
            ),
            SizedBox(height: 12.h),
          ],
        );
      }).toList(),
    );
  }
}
