import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/options_item_model.dart';

// ignore_for_file: must_be_immutable
class OptionsItemWidget extends StatelessWidget {
  OptionsItemWidget(this.optionsItemModelObj, {Key? key})
      : super(
          key: key,
        );

  OptionsItemModel optionsItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164.h,
      decoration: AppDecoration.fillPrimary.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: AppDecoration.outlinePrimary10.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder12,
            ),
            child: Column(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  optionsItemModelObj.option!,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  optionsItemModelObj.tf!,
                  style: theme.textTheme.bodyMedium,
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
