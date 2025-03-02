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
                "lbl_my_stories".tr,
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
                                    Card(
                                      clipBehavior: Clip.antiAlias,
                                      elevation: 0,
                                      margin: EdgeInsets.only(left: 4.h),
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusStyle.circleBorder16,
                                      ),
                                      child: Container(
                                        height: 32.h,
                                        padding: EdgeInsets.all(6.h),
                                        decoration: AppDecoration
                                            .fillOnPrimaryContainer1
                                            .copyWith(
                                          borderRadius:
                                              BorderRadiusStyle.circleBorder16,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath26,
                                              height: 2.h,
                                              width: 5.h,
                                              alignment: Alignment.topLeft,
                                              margin:
                                                  EdgeInsets.only(left: 4.h),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath26,
                                              height: 3.h,
                                              width: 6.h,
                                              alignment: Alignment.topLeft,
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath30,
                                              height: 4.h,
                                              width: 8.h,
                                              alignment: Alignment.topCenter,
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath26,
                                              height: 2.h,
                                              width: 6.h,
                                              alignment: Alignment.topLeft,
                                              margin: EdgeInsets.only(top: 4.h),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath30,
                                              height: 2.h,
                                              width: 5.h,
                                              alignment: Alignment.topRight,
                                              margin: EdgeInsets.only(top: 2.h),
                                            ),
                                            CustomImageView(
                                              imagePath: ImageConstant
                                                  .imgCheckmarkDeepOrangeA200,
                                              height: 6.h,
                                              width: 12.h,
                                              alignment: Alignment.centerLeft,
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath38,
                                              height: 3.h,
                                              width: 6.h,
                                              alignment: Alignment.bottomRight,
                                              margin:
                                                  EdgeInsets.only(bottom: 2.h),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath38,
                                              height: 2.h,
                                              width: 5.h,
                                              alignment: Alignment.bottomRight,
                                              margin:
                                                  EdgeInsets.only(right: 4.h),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath38,
                                              height: 3.h,
                                              width: 6.h,
                                              alignment: Alignment.bottomRight,
                                              margin:
                                                  EdgeInsets.only(bottom: 6.h),
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath44,
                                              height: 4.h,
                                              width: 8.h,
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgTelevision,
                                              height: 6.h,
                                              width: 12.h,
                                              alignment: Alignment.centerRight,
                                            ),
                                            CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgPath44,
                                              height: 2.h,
                                              width: 5.h,
                                              alignment: Alignment.bottomLeft,
                                              margin:
                                                  EdgeInsets.only(bottom: 2.h),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 28.h,
                                        margin: EdgeInsets.only(right: 2.h),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CustomImageView(
                                              imagePath: ImageConstant.imgEdit,
                                              height: 28.h,
                                              width: double.maxFinite,
                                            ),
                                            RotationTransition(
                                              turns: AlwaysStoppedAnimation(
                                                -(37 / 360),
                                              ),
                                              child: Text(
                                                "lbl_beta".tr,
                                                style:
                                                    theme.textTheme.labelSmall,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
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
                              text: "lbl_12".tr,
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
                          "lbl_hi_evelyn".tr,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.h),
                        child: Text(
                          "lbl_welcome_back".tr,
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
                                            "msg_complete_3_stories".tr,
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
                                    "lbl_2_3_completed".tr,
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
                                text: "lbl_fiction".tr,
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
                                      "lbl_non_fiction".tr,
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
      margin: EdgeInsets.only(left: 14.h),
      child: Column(
        spacing: 12,
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
                        "lbl_all_stories2".tr,
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
                      bottom: 6.h,
                    ),
                    child: Text(
                      "lbl_fantasy".tr,
                      style: CustomTextStyles.titleMediumOnPrimarySemiBold_1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.h),
                  child: Text(
                    "lbl_horror".tr,
                    style: CustomTextStyles.titleMediumOnPrimarySemiBold_1,
                  ),
                )
              ],
            ),
          ),
          BlocSelector<HomeBloc, HomeState, HomeInitialModel?>(
            selector: (state) => state.homeInitialModelObj,
            builder: (context, homeInitialModelObj) {
              return ListView.separated(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 12.h,
                  );
                },
                itemCount: homeInitialModelObj?.homeSixItemList.length ?? 0,
                itemBuilder: (context, index) {
                  HomeSixItemModel model =
                      homeInitialModelObj?.homeSixItemList[index] ??
                          HomeSixItemModel();
                  return HomeSixItemWidget(
                    model,
                  );
                },
              );
            },
          ),
          SizedBox(
            width: double.maxFinite,
            child: Divider(
              endIndent: 16.h,
            ),
          ),
          Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(right: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "lbl_see_all".tr,
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
            "msg_exciting_features".tr,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "msg_stay_tuned_new".tr,
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
