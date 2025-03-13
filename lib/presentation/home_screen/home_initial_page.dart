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
    Navigator.push(
      context,
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
                              CustomImageView(
                                imagePath:
                                    ImageConstant.imgSettingsDeepOrangeA200,
                                height: 18.h,
                                width: 72.h,
                                margin: EdgeInsets.only(
                                  left: 6.h,
                                  bottom: 6.h,
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
                              CustomImageView(
                                imagePath: ImageConstant.imgSearch,
                                height: 20.h,
                                width: 22.h,
                                margin: EdgeInsets.only(
                                  left: 8.h,
                                  bottom: 6.h,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.only(left: 16.h),
                          child: Text(
                            "Hi Evelyn",
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
                        Container(
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
                                    SizedBox(
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
                        SizedBox(height: 20.h),
                        Container(
                          decoration: AppDecoration.fillOnPrimaryContainer1,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(top: 8.h), // Added margin to position tabs at the bottom of background
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomOutlinedButton(
                                  height: 48.h,
                                  text: "Fiction",
                                  buttonStyle: CustomButtonStyles.outlinePrimary1,
                                  buttonTextStyle:
                                      CustomTextStyles.titleMediumGray600Medium,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.only(
                                    top: 12.h,
                                    bottom: 10.h,
                                  ),
                                  decoration: AppDecoration.outlineDeeporangeA200,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Non-Fiction",
                                        style: CustomTextStyles
                                            .titleMediumDeeporangeA200Black,
                                      )
                                    ],
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
    final displayStories = _stories.take(3).toList();
    
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 14.h, right: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 4.h,
                    bottom: 2.h,
                  ),
                  decoration: AppDecoration.outlineDeeporangeA2001,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "All Stories",
                        style: theme.textTheme.titleLarge,
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 18.h,
                    ),
                    child: Text(
                      "Fantasy",
                      style: CustomTextStyles.titleMediumOnPrimarySemiBold_1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.h),
                  child: Text(
                    "Horror",
                    style: CustomTextStyles.titleMediumOnPrimarySemiBold_1,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Display stories from JSON
          if (displayStories.isNotEmpty)
            ...displayStories.map((story) {
              return Column(
                children: [
                  HomeSixItemWidget(
                    HomeSixItemModel(
                      labelfill: story.genre,
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
          else
            // Fallback to hardcoded stories if JSON loading fails
            Column(
              children: [
                HomeSixItemWidget(
                  HomeSixItemModel(
                    labelfill: "Fantasy",
                    hisnewbook: "Learn Arabic Through Stories",
                    label: "Read Now"
                  ),
                ),
                SizedBox(height: 12.h),
                HomeSixItemWidget(
                  HomeSixItemModel(
                    labelfill: "Conversation",
                    hisnewbook: "Daily Arabic Conversations",
                    label: "Practice"
                  ),
                ),
                SizedBox(height: 12.h),
                HomeSixItemWidget(
                  HomeSixItemModel(
                    labelfill: "Quizzes",
                    hisnewbook: "Test Your Knowledge",
                    label: "Take Quiz"
                  ),
                ),
              ],
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
