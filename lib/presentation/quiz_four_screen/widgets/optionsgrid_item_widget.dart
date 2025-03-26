import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/optionsgrid_item_model.dart';

// ignore_for_file: must_be_immutable
class OptionsgridItemWidget extends StatelessWidget {
  const OptionsgridItemWidget(
    this.optionsgridItemModelObj, {
    Key? key,
    this.onTapOption,
  }) : super(key: key);

  final OptionsgridItemModel optionsgridItemModelObj;
  final Function(OptionsgridItemModel)? onTapOption;

  BoxDecoration _getDecoration() {
    // Use option color as background when selected, light background when not selected
    return BoxDecoration(
      color: optionsgridItemModelObj.selected ? _getOptionColor() : Color.fromARGB(255, 236, 234, 231),
      borderRadius: BorderRadiusStyle.roundedBorder12,
    );
  }

  // Get the color for the option based on its ID
  Color _getOptionColor() {
    switch (optionsgridItemModelObj.id) {
      case "1": // MSA
        return Color.fromARGB(255, 55, 31, 44); // Dark brown
      case "2": // Egyptian
        return Color(0xFFFFC75B); // Amber/yellow
      case "3": // Jordanian
        return Color(0xFF3BAFAF); // Teal
      case "4": // Moroccan
        return Color(0xFFE53935); // Red
      case "5": // Yemeni
        return Color(0xFFF86A6A); // Red
      case "6": // Maghrebi
        return Color(0xFF55D58F); // Green
      case "7": // Levantine
        return Color(0xFF69B4F0); // Light blue
      case "8": // Gulf
        return Color(0xFF7C513D); // Brown
      default:
        return theme.colorScheme.primary;
    }
  }

  BoxDecoration _getInnerDecoration() {
    Color optionColor = _getOptionColor();
    
    if (optionsgridItemModelObj.selected) {
      // When selected: white background with colored border
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusStyle.roundedBorder12,
        border: Border.all(
          color: optionColor,
          width: 2.h,
        ),
      );
    } else {
      // When not selected: colored background with subtle white border
      return BoxDecoration(
        color: optionColor,
        borderRadius: BorderRadiusStyle.roundedBorder12,
        border: Border.all(
          color: Colors.white,
          width: 1.5.h,
        ),
      );
    }
  }
  TextStyle _getTextStyle(bool isArabic) {
    Color textColor = optionsgridItemModelObj.selected 
        ? _getOptionColor() // Use the option color when selected
        : Colors.white;
        
    if (optionsgridItemModelObj.selected) {
      return isArabic 
          ? theme.textTheme.bodyMedium!.copyWith(color: textColor)
          : theme.textTheme.titleMedium!.copyWith(color: textColor);
    }
    // White text when not selected
    return isArabic 
        ? theme.textTheme.bodyMedium!.copyWith(color: Colors.white)
        : theme.textTheme.titleMedium!.copyWith(color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapOption?.call(optionsgridItemModelObj);
      },
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: _getDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: _getInnerDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      optionsgridItemModelObj.msa!,
                      style: _getTextStyle(false).copyWith(fontSize: 18.fSize),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      optionsgridItemModelObj.tf!,
                      style: _getTextStyle(true).copyWith(fontSize: 22.fSize),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
