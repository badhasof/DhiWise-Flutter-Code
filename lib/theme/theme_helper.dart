import 'package:flutter/material.dart';
import '../core/app_export.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = PrefUtils().getThemeData();

// A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

// A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: appTheme.gray50,
          side: BorderSide(
            color: colorScheme.primary,
            width: 1.h,
          ),
          shape: RoundedRectangleBorder(),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
          elevation: 0,
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

/// Class containing the supported text theme styles.
class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        bodyMedium: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 14.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 12.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 20.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 16.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: appTheme.gray700,
          fontSize: 14.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
        ),
      );
}

/// Class containing the supported color schemes.
class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light(
    primary: Color(0XFFEFEBEA),
    primaryContainer: Color(0XFF384949),
    secondaryContainer: Color(0XFFEBEBEB),
    errorContainer: Color(0XFF0DB0EE),
    onError: Color(0XFFFEDFC5),
    onPrimary: Color(0XFF37251F),
    onPrimaryContainer: Color(0XFFFFFFFF),
  );
}

/// Class containing custom colors for a lightCode theme.
class LightCodeColors {
  // Amber
  Color get amber300 => Color(0XFFFDD559);
  Color get amber30001 => Color(0XFFFFC75B);
  Color get amberA100 => Color(0XFFFFE177);
// Blue
  Color get blue300 => Color(0XFF60B7FE);
  Color get blue30001 => Color(0XFF69B4F0);
  Color get blue400 => Color(0XFF48A7E5);
  Color get blueA200 => Color(0XFF5186FF);
  Color get blueA400 => Color(0XFF3D74F4);
  Color get blueA700 => Color(0XFF1D5AEA);
// BlueGray
  Color get blueGray200 => Color(0XFFA7C7D3);
  Color get blueGray700 => Color(0XFF3E5959);
// DeepOrange
  Color get deepOrange100 => Color(0XFFFECBAA);
  Color get deepOrange200 => Color(0XFFFFBE9D);
  Color get deepOrange20001 => Color(0XFFFFAE85);
  Color get deepOrange300 => Color(0XFFF4924B);
  Color get deepOrange30001 => Color(0XFFFF9361);
  Color get deepOrange800 => Color(0XFFD84918);
  Color get deepOrangeA100 => Color(0XFFFF9E71);
  Color get deepOrangeA200 => Color(0XFFFF6F3E);
  Color get deepOrangeA400 => Color(0XFFFF4B00);
// Gray
  Color get gray100 => Color(0XFFF5F5F5);
  Color get gray10001 => Color(0XFFF3F2F2);
  Color get gray300 => Color(0XFFE0E0E0);
  Color get gray4003f => Color(0X3FBDBDBD);
  Color get gray50 => Color(0XFFFFF9F4);
  Color get gray500 => Color(0XFFAA9B96);
  Color get gray5001 => Color(0XFFFAFAFA);
  Color get gray5002 => Color(0XFFF1FBFF);
  Color get gray600 => Color(0XFF80706B);
  Color get gray700 => Color(0XFF63514B);
  Color get gray70001 => Color(0XFF7B513D);
  Color get gray70002 => Color(0XFF7C513D);
  Color get gray800 => Color(0XFF513D37);
// Indigo
  Color get indigoA700 => Color(0XFF213BF1);
// LightBlue
  Color get lightBlue100 => Color(0XFFB3E7FA);
  Color get lightBlue10001 => Color(0XFFB2E6FA);
  Color get lightBlue10002 => Color(0XFFA7D3F8);
  Color get lightBlue200 => Color(0XFF84CEEF);
  Color get lightBlue400 => Color(0XFF20BFFC);
  Color get lightBlue600 => Color(0XFF079FEB);
  Color get lightBlueA100 => Color(0XFF83D9FF);
  Color get lightBlueA200 => Color(0XFF3EBBF2);
  Color get lightBlueA20001 => Color(0XFF3DBAF2);
// LightGreen
  Color get lightGreen100 => Color(0XFFE4EAD3);
  Color get lightGreenA700 => Color(0XFF59CC03);
// Lime
  Color get lime900 => Color(0XFF954C35);
  Color get lime90001 => Color(0XFF7C3F2C);
// Orange
  Color get orange300 => Color(0XFFFFC14F);
  Color get orange400 => Color(0XFFFF9F22);
// Pink
  Color get pink300 => Color(0XFFEF6085);
  Color get pink30001 => Color(0XFFFA6E85);
  Color get pink400 => Color(0XFFE33F65);
  Color get pinkA100 => Color(0XFFFF84A7);
// Red
  Color get red300 => Color(0XFFF86A6A);
  Color get red400 => Color(0XFFC0694E);
  Color get red700 => Color(0XFFAE583E);
// Teal
  Color get teal300 => Color(0XFF3BAFAF);
  Color get teal30001 => Color(0XFF55D58F);
// Yellow
  Color get yellow700 => Color(0XFFFFBF31);
  Color get yellow900 => Color(0XFFFF8812);
  Color get yellow90001 => Color(0XFFFF7816);
}
