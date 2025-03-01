import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';

// ignore_for_file: must_be_immutable
class OptionslistItemWidget extends StatelessWidget {
  OptionslistItemWidget(this.optionslistItemModelObj, {Key? key})
      : super(
          key: key,
        );

  OptionslistItemModel optionslistItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillDeepOrangeA.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.h,
              vertical: 10.h,
            ),
            decoration: AppDecoration.outlineDeepOrangeA.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder12,
            ),
            width: double.maxFinite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    optionslistItemModelObj.time!,
                    style: CustomTextStyles.titleMediumOnPrimary_1,
                  ),
                ),
                Text(
                  optionslistItemModelObj.quickdailypract!,
                  style: CustomTextStyles.bodyMediumGray600,
                )
              ],
            ),
          ),
          SizedBox(height: 4.h)
        ],
      ),
    );
  }
}
