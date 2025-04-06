import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// These are the Viewport values of your Figma Design.
// These are used in the code as a reference to create your UI Responsively.
const num FIGMA_DESIGN_WIDTH = 375;
const num FIGMA_DESIGN_HEIGHT = 749;
const num FIGMA_DESIGN_STATUS_BAR = 0;

/// Custom extension using different method names to avoid conflicts
extension ResponsiveExtension on num {
  // Get height based on screen height
  double get h => ScreenUtil().setHeight(this.toDouble());
  
  // Get width based on screen width
  double get w => ScreenUtil().setWidth(this.toDouble());
  
  // Get font size based on screen width
  double get fSize => ScreenUtil().setSp(this.toDouble());
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(this.toStringAsFixed(fractionDigits));
  }

  double isNonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}

enum DeviceType { mobile, tablet, desktop }

// For backward compatibility with existing code
class SizeUtils {
  /// Device's BoxConstraints
  static late BoxConstraints boxConstraints;

  /// Device's Orientation
  static late Orientation orientation;

  /// Type of Device
  ///
  /// This can either be mobile or tablet
  static late DeviceType deviceType;

  /// Device's Height
  static double get height => ScreenUtil().screenHeight;

  /// Device's Width
  static double get width => ScreenUtil().screenWidth;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    deviceType = DeviceType.mobile;
  }
}

// Keeping the Sizer class for backward compatibility
typedef ResponsiveBuild = Widget Function(
    BuildContext context, Orientation orientation, DeviceType deviceType);

class Sizer extends StatelessWidget {
  const Sizer({Key? key, required this.builder}) : super(key: key);

  /// Builds the widget whenever the orientation changes.
  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeUtils.setScreenSize(constraints, orientation);
        return builder(context, orientation, SizeUtils.deviceType);
      });
    });
  }
}
