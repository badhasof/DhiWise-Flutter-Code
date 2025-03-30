import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../domain/story/story_model.dart';
import '../models/home_six_item_model.dart';

// ignore_for_file: must_be_immutable
class HomeSixItemWidget extends StatelessWidget {
  HomeSixItemWidget(this.homeSixItemModelObj, {
    Key? key, 
    this.story, 
    this.onTap,
    this.onButtonTap,
  }) : super(
          key: key,
        );

  HomeSixItemModel homeSixItemModelObj;
  
  // Add Story object as an optional parameter
  final Story? story;
  
  // Add onTap callback for the widget body
  final VoidCallback? onTap;
  
  // Add onButtonTap callback for the Read Now button
  final VoidCallback? onButtonTap;
  
  // Get the difficulty indicator image based on the story level
  String _getDifficultyIndicatorImage() {
    if (story == null) {
      return ImageConstant.imgDifficultyBeginner;
    }
    
    switch (story!.level) {
      case 'Beginner':
        return ImageConstant.imgDifficultyBeginner;
      case 'Intermediate':
        return ImageConstant.imgDifficultyIntermediate;
      case 'Advanced':
        return ImageConstant.imgDifficultyAdvanced;
      default:
        return ImageConstant.imgDifficultyBeginner;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the labelfill from the model (which we set to story.subGenre in the parent)
    final String genre = homeSixItemModelObj.labelfill!;
    final String title = story?.titleEn ?? homeSixItemModelObj.hisnewbook!;
    final String buttonText = homeSixItemModelObj.label!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: AppDecoration.fillOnPrimaryContainer1.copyWith(
          borderRadius: BorderRadiusStyle.roundedBorder12,
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: story?.imagePath ?? ImageConstant.imgImage10,
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
                              genre,
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
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.titleSmallOnPrimaryBold,
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Use the difficulty indicator based on story level
                        CustomImageView(
                          imagePath: _getDifficultyIndicatorImage(),
                          height: 24.h,
                          width: 26.h,
                        ),
                        InkWell(
                          onTap: () {
                            // Prevent the tap from propagating to the parent
                            if (onButtonTap != null) {
                              onButtonTap!();
                            }
                          },
                          child: Container(
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
                                        buttonText,
                                        style: CustomTextStyles.titleSmallDeeporangeA200Bold,
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
