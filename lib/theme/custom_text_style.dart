import 'package:flutter/material.dart';
import '../core/app_export.dart';

extension on TextStyle {}

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.
class CustomTextStyles {
  // Body text style
  static TextStyle get bodyMediumAmber30001 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.amber30001,
      );
  static TextStyle get bodyMediumBlue30001 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.blue30001,
      );
  static TextStyle get bodyMediumDeeporange30001 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.deepOrange30001,
      );
  static TextStyle get bodyMediumGray500 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray500,
      );
  static TextStyle get bodyMediumGray600 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray600,
      );
  static TextStyle get bodyMediumGray700 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray700,
      );
  static TextStyle get bodyMediumGray700_1 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray700,
      );
  static TextStyle get bodyMediumGray70002 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray70002,
      );
  static TextStyle get bodyMediumOnPrimary =>
      theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
      );
  static TextStyle get bodyMediumRed300 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.red300,
      );
  static TextStyle get bodyMediumTeal300 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.teal300,
      );
  static TextStyle get bodyMediumTeal30001 =>
      theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.teal30001,
      );
  
  // Label text style
  static TextStyle get labelLargeDeeporangeA200Bold =>
      theme.textTheme.labelLarge!.copyWith(
        color: appTheme.deepOrangeA200,
        fontWeight: FontWeight.w700,
      );
  static TextStyle get labelLargeDeeporangeA200_1 =>
      theme.textTheme.labelLarge!.copyWith(
        color: appTheme.deepOrangeA200,
      );
  static TextStyle get labelLargeGray600 =>
      theme.textTheme.labelLarge!.copyWith(
        color: appTheme.gray600,
      );
      
// Title text style
  static TextStyle get titleMediumAmber30001 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.amber30001,
      );
  static TextStyle get titleMediumBlue30001 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blue30001,
      );
  static TextStyle get titleMediumDeeporange30001 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.deepOrange30001,
      );
  static TextStyle get titleMediumDeeporangeA200 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.deepOrangeA200,
      );
  static TextStyle get titleMediumDeeporangeA200Black =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.deepOrangeA200,
        fontWeight: FontWeight.w900,
      );
  static TextStyle get titleMediumGray500 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray500,
      );
  static TextStyle get titleMediumGray500Medium =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray500,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get titleMediumGray600Medium =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray600,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get titleMediumGray70002 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray70002,
      );
  static TextStyle get titleMediumGray900 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray800,
      );
  static TextStyle get titleMediumOnPrimary =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get titleMediumOnPrimary_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
      );
  static TextStyle get titleMediumOnPrimaryExtraBold =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w800,
      );
  static TextStyle get titleMediumOnPrimarySemiBold_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimary.withValues(
          alpha: 0.5,
        ),
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleMediumRed300 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.red300,
      );
  static TextStyle get titleMediumRedA200 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.red300,
      );
  static TextStyle get titleMediumTeal300 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.teal300,
      );
  static TextStyle get titleMediumTeal30001 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.teal30001,
      );
  static TextStyle get titleMediumOnPrimaryContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get titleSmallBluegray400 =>
      theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blueGray200,
      );
  static TextStyle get titleSmallBold => theme.textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w700,
      );
  static TextStyle get titleSmallDeeporangeA200Bold =>
      theme.textTheme.titleSmall!.copyWith(
        color: appTheme.deepOrangeA200,
        fontWeight: FontWeight.w700,
      );
  static TextStyle get titleSmallOnPrimary =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleSmallOnPrimaryBold =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
      );
  static TextStyle get titleSmallOnPrimary_1 =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onPrimary,
      );
}
