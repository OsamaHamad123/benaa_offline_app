import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dashboard Spacing - نظام مسافات موحد للداشبورد
class DashboardSpacing {
  // Prevent instantiation
  DashboardSpacing._();

  // Vertical Spacing
  static double get tiny => 4.h;
  static double get small => 8.h;
  static double get medium => 16.h;
  static double get large => 24.h;
  static double get xLarge => 32.h;
  static double get xxLarge => 48.h;

  // Horizontal Spacing
  static double get tinyH => 4.w;
  static double get smallH => 8.w;
  static double get mediumH => 16.w;
  static double get largeH => 24.w;
  static double get xLargeH => 32.w;

  // Padding
  static double get paddingTiny => 4.w;
  static double get paddingSmall => 8.w;
  static double get paddingMedium => 16.w;
  static double get paddingLarge => 24.w;
  static double get paddingXLarge => 32.w;

  // Border Radius
  static double get radiusSmall => 8.r;
  static double get radiusMedium => 12.r;
  static double get radiusLarge => 16.r;
  static double get radiusXLarge => 20.r;
  static double get radiusCircular => 999.r;
}
