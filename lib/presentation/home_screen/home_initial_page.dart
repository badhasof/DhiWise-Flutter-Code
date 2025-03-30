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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/pref_utils.dart';
import '../../services/user_reading_service.dart';

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
  String _currentDialect = "msa"; // Track the current dialect
  
  // Shared Preferences key for dialect
  static const String _dialectPrefsKey = 'selectedDialect';
  static const String _flagPrefsKey = 'selectedFlag';
  
  // Streak counter
  int _streakCount = 0;
  late PrefUtils _prefUtils;
  
  // User level
  int _userLevel = 1;
  int _completedStoriesCount = 0;
  int _storiesNeededForNextLevel = 3;
  int _storiesCompletedInCurrentLevel = 0;
  
  // Map flags to dialects
  final Map<String, String> _flagToDialect = {
    "🇺🇸": "msa",     // MSA (Modern Standard Arabic) with US flag
    "🇪🇬": "egyptian", // Egyptian dialect
    "🇯🇴": "jordanian", // Jordanian dialect
    "🇲🇦": "moroccan"  // Moroccan dialect
  };
  
  // Map dialects to flags (reverse mapping)
  late final Map<String, String> _dialectToFlag = {
    "msa": "🇺🇸",
    "egyptian": "🇪🇬",
    "jordanian": "🇯🇴",
    "moroccan": "🇲🇦"
  };
  
  // Map dialects to display names
  final Map<String, String> _dialectToDisplayName = {
    "msa": "MSA",
    "egyptian": "Egyptian",
    "jordanian": "Jordanian",
    "moroccan": "Moroccan"
  };
  
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
    _prefUtils = PrefUtils();
    _loadStreakCount();
    _loadUserLevel();
    _loadSavedDialect().then((_) {
      _loadStories();
    });
    _loadUserData();
    
    // Set the initial dialect in the story service
    _storyService.setDialect(_currentDialect);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh streak count when returning to this page
    _loadStreakCount();
    _loadUserLevel();
  }
  
  // Load streak count from preferences
  Future<void> _loadStreakCount() async {
    await _prefUtils.init();
    setState(() {
      _streakCount = _prefUtils.getStreakCount();
    });
  }
  
  // Load user level based on completed stories
  Future<void> _loadUserLevel() async {
    try {
      // Get total completed stories
      final userReadingService = UserReadingService();
      final completedStories = await userReadingService.getTotalCompletedStories();
      
      // Calculate level and stories needed for next level
      final levelData = _calculateLevelAndProgress(completedStories);
      
      setState(() {
        _completedStoriesCount = completedStories;
        _userLevel = levelData['level'] ?? 1;
        _storiesNeededForNextLevel = levelData['storiesForNextLevel'] ?? 3;
        _storiesCompletedInCurrentLevel = levelData['storiesCompletedInCurrentLevel'] ?? 0;
      });
    } catch (e) {
      print('Error loading user level: $e');
    }
  }
  
  // Calculate detailed level information including progress
  Map<String, int> _calculateLevelAndProgress(int completedStories) {
    int storiesRequired = 0;
    int level = 1;
    int storiesForThisLevel = 3; // Level 2 requires 3 stories
    
    // Start at level 1, requiring 0 stories
    while (completedStories >= storiesRequired + storiesForThisLevel) {
      // Move to the next level
      level++;
      storiesRequired += storiesForThisLevel;
      storiesForThisLevel++; // Each level requires one more story
    }
    
    // Calculate progress within current level
    int storiesCompletedInCurrentLevel = completedStories - storiesRequired;
    
    return {
      'level': level,
      'storiesForNextLevel': storiesForThisLevel,
      'storiesCompletedInCurrentLevel': storiesCompletedInCurrentLevel,
      'totalStoriesRequired': storiesRequired
    };
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
  
  // Load saved dialect preference from SharedPreferences
  Future<void> _loadSavedDialect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDialect = prefs.getString(_dialectPrefsKey);
      final savedFlag = prefs.getString(_flagPrefsKey);
      
      if (savedDialect != null && _dialectToFlag.containsKey(savedDialect)) {
        setState(() {
          _currentDialect = savedDialect;
          _selectedFlag = savedFlag ?? _dialectToFlag[savedDialect]!;
        });
        
        // Set the dialect in the story service
        _storyService.setDialect(_currentDialect);
        print('Loaded saved dialect: $_currentDialect with flag: $_selectedFlag');
      }
    } catch (e) {
      print('Error loading saved dialect: $e');
    }
  }
  
  // Save dialect preference to SharedPreferences
  Future<void> _saveDialectPreference(String dialect, String flag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dialectPrefsKey, dialect);
      await prefs.setString(_flagPrefsKey, flag);
      print('Saved dialect preference: $dialect with flag: $flag');
    } catch (e) {
      print('Error saving dialect preference: $e');
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
    print('Current dialect: $_currentDialect');
    
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

  // Switch dialect based on flag selection
  Future<void> _switchDialect(String flag) async {
    // Get the dialect for the selected flag
    final newDialect = _flagToDialect[flag] ?? "msa";
    
    print('Flag selected: $flag');
    print('Current dialect: $_currentDialect');
    print('New dialect: $newDialect');
    
    // If dialect hasn't changed, do nothing
    if (newDialect == _currentDialect) {
      print('Dialect unchanged, not reloading stories');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _selectedFlag = flag;
      _currentDialect = newDialect;
    });
    
    // Save the new dialect preference
    await _saveDialectPreference(newDialect, flag);
    
    // Clear the cache for the new dialect to force reloading from JSON files
    _storyService.clearCacheForDialect(newDialect);
    
    // Update the dialect in the story service
    _storyService.setDialect(newDialect);
    print('Set dialect in story service to: $newDialect');
    
    // Reload stories with the new dialect
    await _loadStories();
    print('Stories reloaded for dialect: $newDialect');
    print('Displayed stories count: ${_displayedStories.length}');
    
    // Show a snackbar to indicate the dialect change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${_dialectToDisplayName[newDialect] ?? newDialect} dialect'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Get the level badge image path based on user level
  String _getLevelBadgeImage() {
    // For now use the beginner badge for all levels
    // In a real implementation, you would have different badge images for different levels
    return ImageConstant.imgLinguaBeginner;
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
                                        imagePath: _getLevelBadgeImage(),
                                        height: 34.h,
                                        width: 38.h,
                                      ),
                                      // Level indicator
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          height: 16.h,
                                          width: 16.h,
                                          decoration: BoxDecoration(
                                            color: appTheme.deepOrangeA200,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.h,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$_userLevel",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.fSize,
                                                fontFamily: 'Be Vietnam Pro',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
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
                                text: "$_streakCount",
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProgressPage.builder(context),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8.h),
                                child: PopupMenuButton<String>(
                                  offset: Offset(0, 0),
                                  position: PopupMenuPosition.over,
                                  constraints: BoxConstraints(
                                    maxWidth: 60.h,
                                    minWidth: 60.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.h),
                                  ),
                                  color: Color(0xFFF9F9F9),
                                  elevation: 8,
                                  tooltip: 'Current dialect: ${_dialectToDisplayName[_currentDialect] ?? _currentDialect}',
                                  child: Container(
                                    height: 28.h,
                                    width: 60.h,
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.h),
                                          child: Text(
                                            _selectedFlag,
                                            style: TextStyle(
                                              fontSize: 28.h,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 8.h),
                                          child: Text(
                                            "▾",
                                            style: TextStyle(
                                              fontSize: 16.h,
                                              fontWeight: FontWeight.bold,
                                              height: 0.8,
                                              color: appTheme.gray600,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    _switchDialect(value);
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
                                                "Complete ${_storiesNeededForNextLevel - _storiesCompletedInCurrentLevel} more to Level ${_userLevel + 1}".tr,
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
                                        "${_storiesCompletedInCurrentLevel}/${_storiesNeededForNextLevel} Completed".tr,
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
                                              width: (_storiesCompletedInCurrentLevel / _storiesNeededForNextLevel) * MediaQuery.of(context).size.width * 0.58,
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
