import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/optionsgrid_item_model.dart';

// ignore_for_file: must_be_immutable
class OptionsgridItemWidget extends StatelessWidget {
  OptionsgridItemWidget(this.optionsgridItemModelObj, {Key? key})
      : super(
          key: key,
        );

  OptionsgridItemModel optionsgridItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillOnPrimary.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: AppDecoration.outlineOnPrimary.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder12,
            ),
            child: Column(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  optionsgridItemModelObj.msa!,
                  style: CustomTextStyles.titleMediumOnPrimary_1,
                ),
                Text(
                  optionsgridItemModelObj.tf!,
                  style: CustomTextStyles.bodyMediumOnPrimary,
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
