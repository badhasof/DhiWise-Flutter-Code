import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/dialectoptionsgrid_item_model.dart';

// ignore_for_file: must_be_immutable
class DialectoptionsgridItemWidget extends StatelessWidget {
  DialectoptionsgridItemWidget(this.dialectoptionsgridItemModelObj, {Key? key})
      : super(
          key: key,
        );

  DialectoptionsgridItemModel dialectoptionsgridItemModelObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
                  dialectoptionsgridItemModelObj.option!,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  dialectoptionsgridItemModelObj.tf!,
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
