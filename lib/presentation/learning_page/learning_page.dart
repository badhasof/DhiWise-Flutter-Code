import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/learning_bloc.dart';
import 'models/learning_model.dart'; // ignore_for_file: must_be_immutable

class LearningPage extends StatelessWidget {
  const LearningPage({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<LearningBloc>(
      create: (context) => LearningBloc(LearningState(
        learningModelObj: LearningModel(),
      ))
        ..add(LearningInitialEvent()),
      child: LearningPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningBloc, LearningState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  _buildTopBar(context),
                  Spacer(
                    flex: 56,
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgIsolationModeGray10002,
                    height: 200.h,
                    width: 182.h,
                  ),
                  SizedBox(height: 52.h),
                  _buildHeader(context),
                  Spacer(
                    flex: 43,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            decoration: AppDecoration.fillGray,
            child: Column(
              children: [
                CustomElevatedButton(
                  height: 22.h,
                  width: 122.h,
                  text: "Trial time 30:00".tr,
                  leftIcon: Container(
                    margin: EdgeInsets.only(right: 4.h),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgClock,
                      height: 16.h,
                      width: 16.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  buttonStyle: CustomButtonStyles.fillDeepOrangeA,
                  buttonTextStyle: CustomTextStyles.labelLargeDeeporangeA200_1,
                )
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: AppDecoration.outlinePrimary12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Learning",
                  style: CustomTextStyles.titleMediumOnPrimaryExtraBold,
                ),
                SizedBox(height: 4.h)
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 22.h),
      child: Column(
        spacing: 6,
        children: [
          Text(
            "Exciting features coming soon",
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