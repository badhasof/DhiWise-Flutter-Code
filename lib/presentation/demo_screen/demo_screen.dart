import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/demo_bloc.dart';
import 'models/demo_model.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<DemoBloc>(
      create: (context) => DemoBloc(DemoState(
        demoModelObj: DemoModel(),
      ))
        ..add(DemoInitialEvent()),
      child: DemoScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemoBloc, DemoState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                        left: 16.h,
                        top: 50.h,
                        right: 16.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgIsolationModeGray10002,
                            height: 200.h,
                            width: 182.h,
                          ),
                          SizedBox(height: 52.h),
                          Text(
                            "msg_set_self_demo_time".tr,
                            style: theme.textTheme.headlineSmall,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "msg_how_much_time_would".tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.titleMediumGray600Medium
                                .copyWith(
                              height: 1.50,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildTimeSelectionSection(context),
                          SizedBox(height: 16.h),
                          _buildFeatureHighlightRow(context)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildStartDemoColumn(context),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTimeSelectionSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillPrimary.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              margin: EdgeInsets.zero,
              color: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5.h,
                ),
                borderRadius: BorderRadiusStyle.roundedBorder12,
              ),
              child: Container(
                height: 74.h,
                width: double.maxFinite,
                padding: EdgeInsets.all(14.h),
                decoration: AppDecoration.outlinePrimary14.copyWith(
                  borderRadius: BorderRadiusStyle.roundedBorder12,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "lbl_0".tr,
                                  style: CustomTextStyles.labelLargeGray600,
                                ),
                                Text(
                                  "lbl_45_minutes".tr,
                                  style: CustomTextStyles.labelLargeGray600,
                                )
                              ],
                            ),
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPlayProgress,
                            height: 6.h,
                            width: double.maxFinite,
                            radius: BorderRadius.circular(
                              3.h,
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 76.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.h,
                          vertical: 2.h,
                        ),
                        decoration: AppDecoration.outlinePrimary15.copyWith(
                          borderRadius: BorderRadiusStyle.circleBorder8,
                        ),
                        child: Text(
                          "lbl_30_mins".tr,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.titleSmallOnPrimary,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h)
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildFeatureHighlightRow(BuildContext context) {
    return Container(
      decoration: AppDecoration.outlineBlueGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      width: double.maxFinite,
      child: DottedBorder(
        color: appTheme.blueGray100,
        padding: EdgeInsets.only(
          left: 1.h,
          top: 1.h,
          right: 1.h,
          bottom: 1.h,
        ),
        strokeWidth: 1.h,
        radius: Radius.circular(12),
        borderType: BorderType.RRect,
        dashPattern: [3, 3],
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.h,
            vertical: 8.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgSignal,
                height: 20.h,
                width: 20.h,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 164.h,
                  margin: EdgeInsets.only(left: 8.h),
                  child: Text(
                    "msg_try_about_30_mins".tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.titleSmallOnPrimary_1.copyWith(
                      height: 1.43,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildStartDemoColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomElevatedButton(
            height: 48.h,
            text: "lbl_start_demo".tr,
            margin: EdgeInsets.only(bottom: 12.h),
            buttonStyle: CustomButtonStyles.fillDeepOrange,
          )
        ],
      ),
    );
  }
}
