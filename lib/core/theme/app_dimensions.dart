import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

/// 📐 App Dimensions - Centralized spacing, padding, and sizing
///
/// ✨ Benefits:
/// - Consistent spacing across the app
/// - Easy to maintain and update
/// - Responsive by default (uses flutter_screenutil)
/// - Type-safe dimension values
///
/// Usage:
/// ```dart
/// Container(
///   padding: AppDimensions.paddingMD,
///   margin: EdgeInsets.all(AppDimensions.md),
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: AppDimensions.fontLG),
///   ),
/// )
/// ```
class AppDimensions {
  AppDimensions._(); // Private constructor to prevent instantiation

  // ==================== Spacing Values ====================

  /// 4.0 - Extra small spacing
  static double get xs => 4.w;

  /// 8.0 - Small spacing
  static double get sm => 8.w;

  /// 12.0 - Medium-small spacing
  static double get md12 => 12.w;

  /// 16.0 - Medium spacing (default)
  static double get md => 16.w;

  /// 20.0 - Medium-large spacing
  static double get md20 => 20.w;

  /// 24.0 - Large spacing
  static double get lg => 24.w;

  /// 32.0 - Extra large spacing
  static double get xl => 32.w;

  /// 48.0 - Double extra large spacing
  static double get xxl => 48.w;

  // ==================== Padding ====================

  static EdgeInsets get paddingXS => EdgeInsets.all(xs);
  static EdgeInsets get paddingSM => EdgeInsets.all(sm);
  static EdgeInsets get paddingMD => EdgeInsets.all(md);
  static EdgeInsets get paddingLG => EdgeInsets.all(lg);
  static EdgeInsets get paddingXL => EdgeInsets.all(xl);

  static EdgeInsets get paddingHorizontalXS =>
      EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get paddingHorizontalSM =>
      EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get paddingHorizontalMD =>
      EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get paddingHorizontalLG =>
      EdgeInsets.symmetric(horizontal: lg);

  static EdgeInsets get paddingVerticalXS => EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get paddingVerticalSM => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get paddingVerticalMD => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get paddingVerticalLG => EdgeInsets.symmetric(vertical: lg);

  // ==================== Font Sizes ====================

  /// 10.sp - Extra small font
  static double get fontXS => 10.sp;

  /// 12.sp - Small font
  static double get fontSM => 12.sp;

  /// 13.sp - Medium-small font
  static double get fontMD13 => 13.sp;

  /// 14.sp - Medium font (default)
  static double get fontMD => 14.sp;

  /// 15.sp - Medium-large font
  static double get fontMD15 => 15.sp;

  /// 16.sp - Large font
  static double get fontLG => 16.sp;

  /// 18.sp - Extra large font
  static double get fontXL => 18.sp;

  /// 20.sp - Double extra large font
  static double get fontXXL => 20.sp;

  /// 24.sp - Triple extra large font
  static double get fontXXXL => 24.sp;

  /// 28.sp - Huge font
  static double get fontHuge => 28.sp;

  // ==================== Border Radius ====================

  /// 4.r - Small radius
  static double get radiusSM => 4.r;

  /// 8.r - Medium radius
  static double get radiusMD => 8.r;

  /// 12.r - Large radius (default)
  static double get radiusLG => 12.r;

  /// 16.r - Extra large radius
  static double get radiusXL => 16.r;

  /// 20.r - Double extra large radius
  static double get radiusXXL => 20.r;

  /// Circular border radius - small
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);

  /// Circular border radius - medium
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);

  /// Circular border radius - large (default)
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);

  /// Circular border radius - extra large
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);

  /// Circular border radius - double extra large
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);

  // ==================== Icon Sizes ====================

  /// 14.sp - Extra small icon
  static double get iconXS => 14.sp;

  /// 16.sp - Small icon
  static double get iconSM => 16.sp;

  /// 20.sp - Medium icon
  static double get iconMD => 20.sp;

  /// 24.sp - Large icon (default)
  static double get iconLG => 24.sp;

  /// 28.sp - Extra large icon
  static double get iconXL => 28.sp;

  /// 32.sp - Double extra large icon
  static double get iconXXL => 32.sp;

  /// 40.sp - Huge icon
  static double get iconHuge => 40.sp;

  // ==================== Component Sizes ====================

  /// Button height - small
  static double get buttonHeightSM => 36.h;

  /// Button height - medium
  static double get buttonHeightMD => 44.h;

  /// Button height - large
  static double get buttonHeightLG => 52.h;

  /// Input field height
  static double get inputHeight => 48.h;

  /// Card elevation
  static double get cardElevation => 2.0;

  /// Card elevation - hover
  static double get cardElevationHover => 4.0;

  // ==================== Dialog/Modal Sizes ====================

  /// Dialog max width (for tablets and larger)
  static double get dialogMaxWidth => 600.w;

  /// Dialog max height percentage (90% of screen)
  static double get dialogMaxHeightPercent => 0.9;

  /// Bottom sheet max height percentage (95% of screen)
  static double get bottomSheetMaxHeightPercent => 0.95;

  /// Modal barrier opacity
  static double get modalBarrierOpacity => 0.5;

  // ==================== List/Grid Spacing ====================

  /// List item vertical padding
  static double get listItemVerticalPadding => 12.h;

  /// List item horizontal padding
  static double get listItemHorizontalPadding => md;

  /// Grid spacing
  static double get gridSpacing => md;

  /// Grid cross-axis spacing
  static double get gridCrossAxisSpacing => sm;

  /// Grid main-axis spacing
  static double get gridMainAxisSpacing => sm;

  // ==================== Avatar Sizes ====================

  /// Avatar radius - small
  static double get avatarRadiusSM => 16.r;

  /// Avatar radius - medium
  static double get avatarRadiusMD => 24.r;

  /// Avatar radius - large
  static double get avatarRadiusLG => 32.r;

  /// Avatar radius - extra large
  static double get avatarRadiusXL => 48.r;

  /// Avatar size - small
  static double get avatarSM => 60.w;

  /// Avatar size - medium
  static double get avatarMD => 80.w;

  /// Avatar size - large
  static double get avatarLG => 100.w;

  /// Avatar size - extra large
  static double get avatarXL => 120.w;

  /// Round radius (50% circle)
  static double get radiusRound => 999.r;

  // ==================== Divider ====================

  /// Divider thickness
  static double get dividerThickness => 1.0;

  /// Divider height (including padding)
  static double get dividerHeight => 16.h;

  // ==================== AppBar ====================

  /// AppBar height
  static double get appBarHeight => 56.h;

  /// AppBar elevation
  static double get appBarElevation => 0.0;

  // ==================== Tab ====================

  /// Tab height
  static double get tabHeight => 46.h;

  /// Tab indicator weight
  static double get tabIndicatorWeight => 2.0;

  // ==================== Chips ====================

  /// Chip height
  static double get chipHeight => 32.h;

  /// Chip padding horizontal
  static double get chipPaddingHorizontal => md12;

  // ==================== Screen Percentage Helpers ====================

  /// Get screen width percentage (0-100)
  static double screenWidthPercent(double percent) =>
      ScreenUtil().screenWidth * (percent / 100);

  /// Get screen height percentage (0-100)
  static double screenHeightPercent(double percent) =>
      ScreenUtil().screenHeight * (percent / 100);
}
