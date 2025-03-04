import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/home_six_item_model.dart';

// ignore_for_file: must_be_immutable
class HomeSixItemWidget extends StatelessWidget {
  HomeSixItemWidget(this.homeSixItemModelObj, {Key? key})
      : super(
          key: key,
        );

  HomeSixItemModel homeSixItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: AppDecoration.fillOnPrimaryContainer1.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Row(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgImage10,
            height: 94.h,
            width: 94.h,
            radius: BorderRadius.circular(
              8.h,
            ),
            margin: EdgeInsets.only(right: 9.h),
          ),
          Expanded(
            child: Column(
              spacing: 8,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.h,
                            vertical: 2.h,
                          ),
                          decoration: AppDecoration.fillDeepOrange50.copyWith(
                            borderRadius: BorderRadiusStyle.circleBorder8,
                          ),
                          child: Text(
                            homeSixItemModelObj.labelfill!,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.labelLargeDeeporangeA200_1,
                          ),
                        ),
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgContrast,
                        height: 14.h,
                        width: 18.h,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Text(
                    homeSixItemModelObj.hisnewbook!,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.titleSmallOnPrimaryBold,
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgFrame1686560216,
                        height: 24.h,
                        width: 26.h,
                      ),
                      Container(
                        width: 88.h,
                        decoration: AppDecoration.fillPrimary.copyWith(
                          borderRadius: BorderRadiusStyle.roundedBorder12,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              decoration: AppDecoration.outlinePrimary15.copyWith(
                                borderRadius: BorderRadiusStyle.roundedBorder12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    homeSixItemModelObj.label!,
                                    style: CustomTextStyles.titleSmallDeeporangeA200Bold,
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
          )
        ],
      ),
    );
  }
}
