import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../services/story_service.dart';
import '../home_screen/widgets/home_six_item_widget.dart';
import '../home_screen/models/home_six_item_model.dart';
import '../stories_overview_screen/stories_overview_screen.dart';
import '../story_screen/story_screen.dart';
import '../home_screen/home_screen.dart';
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
    _loadStories(true); // Initially load fiction stories
  }
  
  // Load stories based on fiction or non-fiction
  Future<void> _loadStories(bool isFiction) async {
    final stories = await _storyService.getStoriesByCategory(isFiction);
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                    _buildCategoryTabs(context, state),
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

  Widget _buildCategoryTabs(BuildContext context, NewStoriesState state) {
    final isFictionSelected = state.newStoriesModelObj?.isFictionSelected ?? true;

    return Container(
      decoration: BoxDecoration(
        color: appTheme.gray100,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              "Fiction",
              isSelected: isFictionSelected,
              onTap: () {
                context.read<NewStoriesBloc>().add(
                  ToggleStoryTypeEvent(isFiction: true),
                );
                _loadStories(true);
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              "Non-Fiction",
              isSelected: !isFictionSelected,
              onTap: () {
                context.read<NewStoriesBloc>().add(
                  ToggleStoryTypeEvent(isFiction: false),
                );
                _loadStories(false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String title, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.deepOrangeA200 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                labelfill: story.subGenre.isNotEmpty ? story.subGenre : story.genre,
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
