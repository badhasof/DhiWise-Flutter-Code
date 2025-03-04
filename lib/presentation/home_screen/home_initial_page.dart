import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_outlined_button.dart';
import 'bloc/home_bloc.dart';
import 'models/home_initial_model.dart';
import 'models/home_six_item_model.dart';
import 'widgets/home_six_item_widget.dart';

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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainContentStack(context),
            SizedBox(height: 18.h),
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
    return SizedBox(
      height: 298.h,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.maxFinite,
              decoration: AppDecoration.gradientRedToOrange,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 152.h,
                    width: 184.h,
                    decoration: AppDecoration.stack21,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.imgEllipse34,
                          height: 152.h,
                          width: double.maxFinite,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 96.h)
                ],
              ),
            ),
          ),
          Container(
            height: 296.h,
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
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildStoriesSection(BuildContext context) {
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
          // Fantasy - Learn Arabic Through Stories
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Fantasy",
              hisnewbook: "Learn Arabic Through Stories",
              label: "Read Now"
            ),
          ),
          SizedBox(height: 12.h),
          // Conversation - Daily Arabic Conversations
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Conversation",
              hisnewbook: "Daily Arabic Conversations",
              label: "Practice"
            ),
          ),
          SizedBox(height: 12.h),
          // Quizzes - Test Your Knowledge
          HomeSixItemWidget(
            HomeSixItemModel(
              labelfill: "Quizzes",
              hisnewbook: "Test Your Knowledge",
              label: "Take Quiz"
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
