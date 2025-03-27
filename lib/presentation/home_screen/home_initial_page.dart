import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../services/story_service.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_outlined_button.dart';
import '../new_stories_screen/new_stories_screen.dart';
import '../stories_overview_screen/stories_overview_screen.dart';
import 'bloc/home_bloc.dart';
import 'models/home_initial_model.dart';
import 'models/home_six_item_model.dart';
import 'widgets/home_six_item_widget.dart';
import '../story_screen/story_screen.dart';
import '../progress_page/progress_page.dart';
import '../settings_screen/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeInitialPage extends StatefulWidget {
  const HomeInitialPage({Key? key})
      : super(
          key: key,
        );

  @override
  HomeInitialPageState createState() => HomeInitialPageState();
  static Widget builder(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(HomeState(
        homeInitialModelObj: HomeInitialModel(),
      ))
        ..add(HomeInitialEvent()),
      child: HomeInitialPage(),
    );
  }
}

class HomeInitialPageState extends State<HomeInitialPage> {
  // Flag emoji container state
  bool _isFlagPressed = false;
  String _selectedFlag = "🇺🇸"; // Add variable to track selected flag
  
  // Story service instance
  final StoryService _storyService = StoryService();
  
  // List to store stories
  List<Story> _stories = [];
  List<Story> _displayedStories = []; // Stories filtered by fiction/non-fiction
  bool _isLoading = true;
  bool _isFictionSelected = false; // Non-fiction selected by default
  String _selectedSubGenre = "All Stories"; // Track selected sub-genre
  
  // List to store available sub-genres
  List<String> _availableSubGenres = ["All Stories"];
  
  // Variable to store user's name
  String _userName = "User";
  
  @override
  void initState() {
    super.initState();
    _loadStories();
    _loadUserData();
  }
  
  // Load user data from Firebase
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            // Get the first name only (split at first space)
            _userName = user.displayName!.split(' ')[0];
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  // Load stories from the service
  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
    });
    
    final stories = await _storyService.getStories();
    final filteredStories = await _storyService.getStoriesByCategory(_isFictionSelected);
    final subGenres = await _storyService.getAvailableSubGenres(_isFictionSelected);
    
    setState(() {
      _stories = stories;
      _displayedStories = filteredStories;
      _availableSubGenres = subGenres;
      _isLoading = false;
    });
  }
  
  // Update displayed stories based on fiction/non-fiction and sub-genre selection
  Future<void> _updateDisplayedStories() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get the sub-genres for the current fiction/non-fiction selection
    final subGenres = await _storyService.getAvailableSubGenres(_isFictionSelected);
    
    List<Story> filteredStories;
    
    if (_selectedSubGenre == "All Stories") {
      // Just filter by fiction/non-fiction
      filteredStories = await _storyService.getStoriesByCategory(_isFictionSelected);
    } else {
      // Filter by both fiction/non-fiction and sub-genre
      filteredStories = await _storyService.getFilteredStories(
        isFiction: _isFictionSelected,
        subGenre: _selectedSubGenre,
      );
    }
    
    // Debug print to verify the stories are filtered correctly
    print('Fiction selected: $_isFictionSelected');
    print('Sub-genre selected: $_selectedSubGenre');
    print('Number of stories: ${filteredStories.length}');
    print('Available sub-genres: $_availableSubGenres');
    
    setState(() {
      _availableSubGenres = subGenres;
      _displayedStories = filteredStories;
      _isLoading = false;
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
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainContentStack(context),
            _buildStoriesSection(context),
            SizedBox(height: 20.h),
            Container(
              height: 8.h,
              width: 374.h,
              decoration: BoxDecoration(
                color: appTheme.deepOrange50,
              ),
            ),
            SizedBox(height: 22.h),
            Padding(
              padding: EdgeInsets.only(left: 16.h),
              child: Text(
                "My Stories",
                style: theme.textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 44.h),
            CustomImageView(
              imagePath: ImageConstant.imgIsolationModeGray10002,
              height: 200.h,
              width: 182.h,
              alignment: Alignment.center,
            ),
            SizedBox(height: 52.h),
            _buildHeaderSection(context),
            SizedBox(height: 18.h)
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildMainContentStack(BuildContext context) {
    // Get the status bar height
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return SizedBox(
      height: 298.h + statusBarHeight, // Add status bar height to the stack height
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.maxFinite,
              height: 346.h, // Increased height to extend background to tabs
              decoration: AppDecoration.gradientRedToOrange,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgEllipse34,
                    height: 200.h,
                    width: 184.h,
                    alignment: Alignment.topRight,
                  ),
                  SizedBox(height: 96.h)
                ],
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight, // Position the content below the status bar
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgEllipse36,
                    height: 262.h,
                    width: 144.h,
                    alignment: Alignment.bottomLeft,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.maxFinite,
                          margin: EdgeInsets.only(
                            left: 10.h,
                            right: 16.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 34.h,
                                  width: 38.h,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CustomImageView(
                                        imagePath: ImageConstant.imgLinguaBeginner,
                                        height: 34.h,
                                        width: 38.h,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen.builder(context),
                                    ),
                                  );
                                },
                                child: CustomImageView(
                                  imagePath:
                                      ImageConstant.imgSettingsDeepOrangeA200,
                                  height: 18.h,
                                  width: 72.h,
                                  margin: EdgeInsets.only(
                                    left: 6.h,
                                    bottom: 6.h,
                                  ),
                                ),
                              ),
                              Spacer(),
                              CustomElevatedButton(
                                height: 28.h,
                                width: 56.h,
                                text: "12",
                                leftIcon: Container(
                                  margin: EdgeInsets.only(right: 4.h),
                                  child: CustomImageView(
                                    imagePath: ImageConstant.imgFire,
                                    height: 20.h,
                                    width: 20.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                buttonStyle: CustomButtonStyles.outlineBlack,
                                buttonTextStyle:
                                    CustomTextStyles.titleSmallDeeporangeA200Bold,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8.h),
                                child: PopupMenuButton<String>(
                                  offset: Offset(0, 0),
                                  position: PopupMenuPosition.over,
                                  constraints: BoxConstraints(
                                    maxWidth: 50.h,
                                    minWidth: 50.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.h),
                                  ),
                                  color: Color(0xFFF9F9F9),
                                  elevation: 8,
                                  child: Container(
                                    height: 28.h,
                                    width: 50.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28.h),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _selectedFlag,
                                      style: TextStyle(
                                        fontSize: 28.h,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      height: 24.h,
                                      padding: EdgeInsets.zero,
                                      value: "🇺🇸",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "🇺🇸",
                                                style: TextStyle(
                                                  fontSize: 24.h,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      height: 24.h,
                                      padding: EdgeInsets.zero,
                                      value: "🇪🇬",
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "🇪🇬",
                                              style: TextStyle(
                                                fontSize: 24.h,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      height: 24.h,
                                      padding: EdgeInsets.zero,
                                      value: "🇯🇴",
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "🇯🇴",
                                              style: TextStyle(
                                                fontSize: 24.h,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      height: 24.h,
                                      padding: EdgeInsets.zero,
                                      value: "🇲🇦",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.h)),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                "🇲🇦",
                                                style: TextStyle(
                                                  fontSize: 24.h,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedFlag = value;
                                    });
                                    print("${value} flag selected!");
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen.builder(context),
                                    ),
                                  );
                                },
                                child: CustomImageView(
                                  imagePath: ImageConstant.imgSearch,
                                  height: 20.h,
                                  width: 22.h,
                                  margin: EdgeInsets.only(
                                    left: 8.h,
                                    bottom: 6.h,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.only(left: 16.h),
                          child: Text(
                            "Hi $_userName",
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.h),
                          child: Text(
                            "Welcome back",
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressPage.builder(context),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.h,
                              vertical: 14.h,
                            ),
                            decoration: AppDecoration.outlineBlack.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            width: double.maxFinite,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconButton(
                                  height: 52.h,
                                  width: 52.h,
                                  padding: EdgeInsets.all(4.h),
                                  decoration: IconButtonStyleHelper.fillDeepOrange,
                                  child: CustomImageView(
                                    imagePath: ImageConstant.imgTropy,
                                  ),
                                ),
                                SizedBox(width: 14.h),
                                Expanded(
                                  child: Column(
                                    spacing: 4,
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Container(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Complete 3 stories today".tr,
                                                style: CustomTextStyles
                                                    .titleMediumGray900,
                                              ),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgArrowRight,
                                              height: 16.h,
                                              width: 18.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "2/3 Completed".tr,
                                        style:
                                            CustomTextStyles.titleSmallBluegray400,
                                      ),
                                      Container(
                                        width: double.maxFinite,
                                        decoration:
                                            AppDecoration.fillGray30001.copyWith(
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder4,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 10.h,
                                              width: 124.h,
                                              decoration: BoxDecoration(
                                                color: appTheme.lightGreenA700,
                                                borderRadius: BorderRadius.circular(
                                                  5.h,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          decoration: AppDecoration.fillOnPrimaryContainer1,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(top: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isFictionSelected = true;
                                      print("Fiction selected: $_isFictionSelected");
                                    });
                                    _updateDisplayedStories();
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    padding: EdgeInsets.only(
                                      top: 12.h,
                                      bottom: 10.h,
                                    ),
                                    decoration: _isFictionSelected
                                        ? AppDecoration.outlineDeeporangeA200
                                        : BoxDecoration(
                                            color: appTheme.gray50,
                                            border: Border(
                                              top: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              bottom: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              left: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              right: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Fiction",
                                          style: _isFictionSelected
                                              ? CustomTextStyles.titleMediumDeeporangeA200Black
                                              : CustomTextStyles.titleMediumGray600Medium,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isFictionSelected = false;
                                      print("Non-Fiction selected: ${!_isFictionSelected}");
                                    });
                                    _updateDisplayedStories();
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    padding: EdgeInsets.only(
                                      top: 12.h,
                                      bottom: 10.h,
                                    ),
                                    decoration: !_isFictionSelected
                                        ? AppDecoration.outlineDeeporangeA200
                                        : BoxDecoration(
                                            color: appTheme.gray50,
                                            border: Border(
                                              top: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              bottom: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              left: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                              right: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Non-Fiction",
                                          style: !_isFictionSelected
                                              ? CustomTextStyles.titleMediumDeeporangeA200Black
                                              : CustomTextStyles.titleMediumGray600Medium,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildStoriesSection(BuildContext context) {
    // Get the first 3 stories or fewer if there are less than 3
    final displayStories = _isLoading ? [] : _displayedStories.take(3).toList();
    
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 14.h, right: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scrollable row for sub-genres
          Container(
            height: 40.h,
            width: double.maxFinite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Generate sub-genre tabs dynamically
                  ..._availableSubGenres.map((subGenre) {
                    final isSelected = subGenre == _selectedSubGenre;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubGenre = subGenre;
                        });
                        _updateDisplayedStories(); // Update stories when sub-genre is selected
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 18.h),
                        padding: EdgeInsets.only(
                          top: 4.h,
                          bottom: 2.h,
                        ),
                        decoration: isSelected 
                          ? AppDecoration.outlineDeeporangeA2001  // Selected style with orange underline
                          : null,  // No decoration when not selected
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subGenre,
                              style: isSelected
                                ? theme.textTheme.titleLarge
                                : CustomTextStyles.titleMediumOnPrimarySemiBold_1,
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Show loading indicator when loading
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          // Display stories from JSON
          else if (displayStories.isNotEmpty)
            ...displayStories.map((story) {
              return Column(
                children: [
                  HomeSixItemWidget(
                    HomeSixItemModel(
                      labelfill: story.subGenre,
                      hisnewbook: story.titleEn,
                      label: "Read Now"
                    ),
                    story: story,
                    onTap: () => _navigateToStoryOverview(story),
                    onButtonTap: () => _navigateToStoryScreen(story),
                  ),
                  SizedBox(height: 12.h),
                ],
              );
            }).toList()
          // Fallback to empty state if no stories match the filter
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  "No stories found for this category",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.maxFinite,
            child: Divider(
              endIndent: 16.h,
            ),
          ),
          Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(right: 16.h, top: 12.h),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewStoriesScreen.builder(context),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "See All".tr,
                        style: CustomTextStyles.titleSmallOnPrimaryBold,
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgArrowRight,
                        height: 16.h,
                        width: 18.h,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 22.h),
      child: Column(
        spacing: 6,
        children: [
          Text(
            "Exciting features coming soon".tr,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "Stay tuned! New features are on their way to help you master the language",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall!.copyWith(
              height: 1.43,
            ),
          )
        ],
      ),
    );
  }
}
