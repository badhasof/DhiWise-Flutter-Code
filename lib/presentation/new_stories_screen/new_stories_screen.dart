import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_export.dart';
import '../home_screen/widgets/home_six_item_widget.dart';
import '../home_screen/models/home_six_item_model.dart';
import '../stories_overview_screen/stories_overview_screen.dart';
import 'bloc/new_stories_bloc.dart';
import 'models/new_stories_model.dart';

class NewStoriesScreen extends StatelessWidget {
  const NewStoriesScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<NewStoriesBloc>(
      create: (context) => NewStoriesBloc(NewStoriesState(
        newStoriesModelObj: NewStoriesModel(),
      ))..add(NewStoriesInitialEvent()),
      child: NewStoriesScreen(),
    );
  }

  void _navigateToStoryOverview(BuildContext context) {
    final storyData = StoryData(
      title: "Schiphol Airport: A Gateway of Wonders",
      arabicTitle: "مطار سخيبول: بوابة العجائب",
      description: "Amsterdam's Schiphol Airport is renowned as one of Europe's busiest and most efficient hubs, seamlessly connecting millions of travelers to destinations across the globe each year. Its state-of-the-art facilities, innovative design, and commitment to exceptional service make it a standout in the world of modern aviation.",
      imagePath: ImageConstant.imgImage10, // Using an existing image as placeholder
      level: "Beginner",
      duration: "25 min",
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoriesOverviewScreen(storyData: storyData),
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
    return Builder(
      builder: (context) => Column(
        children: [
          InkWell(
            onTap: () => _navigateToStoryOverview(context),
            child: HomeSixItemWidget(
              HomeSixItemModel(
                labelfill: "Fantasy",
                hisnewbook: "Schiphol Airport: A Gateway of Wonders",
                label: "Read now",
              ),
            ),
          ),
          SizedBox(height: 12.h),
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Horror",
              hisnewbook: "Go to school",
              label: "Read now",
            ),
          ),
          SizedBox(height: 12.h),
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Adventure",
              hisnewbook: 'His new book "Kashfal Mufradat"',
              label: "Read now",
            ),
          ),
          SizedBox(height: 12.h),
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Fantasy",
              hisnewbook: 'His new book "Kashfal Mufradat"',
              label: "Read now",
            ),
          ),
          SizedBox(height: 12.h),
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Fantasy",
              hisnewbook: 'His new book "Kashfal Mufradat"',
              label: "Read now",
            ),
          ),
        ],
      ),
    );
  }
}
