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
  static BoxDecoration get fillDeepOrange50 => BoxDecoration(
        color: appTheme.deepOrange50,
      );
  static BoxDecoration get fillDeepOrangeA => BoxDecoration(
        color: appTheme.deepOrangeA100,
      );
  static BoxDecoration get fillGray => BoxDecoration(
        color: appTheme.gray50,
      );
  static BoxDecoration get fillGray30001 => BoxDecoration(
        color: appTheme.gray300,
      );
  static BoxDecoration get fillGray5001 => BoxDecoration(
        color: appTheme.gray5001,
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
  static BoxDecoration get fillOnPrimaryContainer1 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
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
  
  // Gradient decorations
  static BoxDecoration get gradientRedToOrange => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [appTheme.red300, appTheme.orange300],
        ),
      );
      
// Outline decorations
  static BoxDecoration get outlineAmber => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.amber30001,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineBlack => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        boxShadow: [
          BoxShadow(
            color: appTheme.gray700.withOpacity(0.08),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              4,
            ),
          )
        ],
      );
  static BoxDecoration get outlineBlue => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.blue30001,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineBlueGray => BoxDecoration();
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
  static BoxDecoration get outlineDeeporangeA100 => BoxDecoration(
        color: appTheme.deepOrange100,
        border: Border.all(
          color: appTheme.deepOrangeA100,
          width: 1.5.h,
        ),
      );
  static BoxDecoration get outlineDeeporangeA200 => BoxDecoration(
        color: appTheme.gray50,
        border: Border(
          bottom: BorderSide(
            color: appTheme.deepOrangeA200,
            width: 2.h,
          ),
        ),
      );
  static BoxDecoration get outlineDeeporangeA2001 => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: appTheme.deepOrangeA200,
            width: 2.h,
          ),
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
  static BoxDecoration get outlinePrimary14 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5.h,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      );
  static BoxDecoration get outlinePrimary15 => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.h,
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
  
  // Stack decorations
  static BoxDecoration get stack21 => BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.imageNotFound,
          ),
          fit: BoxFit.fill,
        ),
      );
}

class BorderRadiusStyle {
  // Circle borders
  static BorderRadius get circleBorder102 => BorderRadius.circular(
        102.h,
      );
  static BorderRadius get circleBorder16 => BorderRadius.circular(
        16.h,
      );
  static BorderRadius get circleBorder54 => BorderRadius.circular(
        54.h,
      );
  static BorderRadius get circleBorder8 => BorderRadius.circular(
        8.h,
      );
// Rounded borders
  static BorderRadius get roundedBorder12 => BorderRadius.circular(
        12.h,
      );
  static BorderRadius get roundedBorder4 => BorderRadius.circular(
        4.h,
      );
}
