import 'package:flutter/material.dart';
import '../core/app_export.dart';

class AppDecoration {
  // Fill decorations
  static BoxDecoration get fillAmber => BoxDecoration(
        color: appTheme.amber30001,
      );
  static BoxDecoration get fillBlue => BoxDecoration(
        color: appTheme.blue30001,
      );
  static BoxDecoration get fillDeepOrange => BoxDecoration(
        color: appTheme.deepOrange30001,
      );
  static BoxDecoration get fillDeepOrangeA => BoxDecoration(
        color: appTheme.deepOrangeA100,
      );
  static BoxDecoration get fillGray => BoxDecoration(
        color: appTheme.gray50,
      );
  static BoxDecoration get fillGray70002 => BoxDecoration(
        color: appTheme.gray70002,
      );
  static BoxDecoration get fillLightGreenA => BoxDecoration(
        color: appTheme.lightGreenA700,
      );
  static BoxDecoration get fillOnPrimary => BoxDecoration(
        color: theme.colorScheme.onPrimary,
      );
  static BoxDecoration get fillPrimary => BoxDecoration(
        color: theme.colorScheme.primary,
      );
  static BoxDecoration get fillRed => BoxDecoration(
        color: appTheme.red300,
      );
  static BoxDecoration get fillTeal => BoxDecoration(
        color: appTheme.teal300,
      );
  static BoxDecoration get fillTeal30001 => BoxDecoration(
        color: appTheme.teal30001,
      );
// Outline decorations
  static BoxDecoration get outlineAmber => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.amber30001,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineBlue => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.blue30001,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineDeepOrange => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.deepOrange30001,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineDeepOrangeA => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.deepOrangeA100,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineGray => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.gray70002,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineOnPrimary => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: theme.colorScheme.onPrimary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineOnPrimaryContainer => BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(
          color: theme.colorScheme.onPrimaryContainer,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary => BoxDecoration(
        color: appTheme.gray50,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.h,
          ),
        ),
      );
  static BoxDecoration get outlinePrimary1 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary10 => BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary11 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.h,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.gray4003f,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              4,
            ),
          )
        ],
      );
  static BoxDecoration get outlinePrimary12 => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.h,
          ),
        ),
      );
  static BoxDecoration get outlinePrimary2 => BoxDecoration(
        color: appTheme.amber30001,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary3 => BoxDecoration(
        color: appTheme.blue30001,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary4 => BoxDecoration(
        color: appTheme.gray70001,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary5 => BoxDecoration(
        color: appTheme.teal300,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary6 => BoxDecoration(
        color: appTheme.deepOrange30001,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary7 => BoxDecoration(
        color: appTheme.red300,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary8 => BoxDecoration(
        color: appTheme.teal30001,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlinePrimary9 => BoxDecoration(
        color: appTheme.gray70002,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineRed => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.red300,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineTeal => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.teal300,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineTeal30001 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.teal30001,
          width: 1.5.h,
        ),
      );
}

class BorderRadiusStyle {
  // Circle borders
  static BorderRadius get circleBorder102 => BorderRadius.circular(
        102.h,
      );
  static BorderRadius get circleBorder8 => BorderRadius.circular(
        8.h,
      );
// Rounded borders
  static BorderRadius get roundedBorder12 => BorderRadius.circular(
        12.h,
      );
}
