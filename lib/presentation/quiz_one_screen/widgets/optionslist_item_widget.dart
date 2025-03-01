import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_one_bloc.dart';

// ignore_for_file: must_be_immutable
class OptionslistItemWidget extends StatelessWidget {
  const OptionslistItemWidget(
    this.optionslistItemModelObj, {
    Key? key,
    this.onTapOption,
  }) : super(key: key);

  final OptionslistItemModel optionslistItemModelObj;
  final Function(OptionslistItemModel)? onTapOption;

  @override
  Widget build(BuildContext context) {
    print("Building item: ${optionslistItemModelObj.id}, selected: ${optionslistItemModelObj.selected}"); // Debug print
    return GestureDetector(
      onTap: () {
        onTapOption?.call(optionslistItemModelObj);
      },
      child: Container(
        width: double.maxFinite,
        decoration: optionslistItemModelObj.selected
            ? AppDecoration.fillDeepOrangeA.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder12,
              )
            : AppDecoration.fillPrimary.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder12,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.h,
                vertical: 6.h,
              ),
              decoration: optionslistItemModelObj.selected
                  ? AppDecoration.outlineDeepOrangeA.copyWith(
                      borderRadius: BorderRadiusStyle.roundedBorder12,
                    )
                  : AppDecoration.outlinePrimary1.copyWith(
                      borderRadius: BorderRadiusStyle.roundedBorder12,
                    ),
              width: double.maxFinite,
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: optionslistItemModelObj.image!,
                    height: 36.h,
                    width: 36.h,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12.h,
                        bottom: 4.h,
                      ),
                      child: Text(
                        optionslistItemModelObj.optionOne!,
                        style: optionslistItemModelObj.selected
                            ? CustomTextStyles.titleMediumDeeporangeA200
                            : CustomTextStyles.titleMediumOnPrimary_1,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 4.h)
          ],
        ),
      ),
    );
  }
}
