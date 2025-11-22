import 'package:flutter/material.dart';

/// 📱 App Breakpoints - Device detection and responsive values
///
/// ✨ Benefits:
/// - Centralized breakpoint management
/// - Easy device type detection
/// - Responsive value selection
/// - Consistent across the app
///
/// Usage:
/// ```dart
/// // Device detection
/// if (AppBreakpoints.isMobile(context)) {
///   return MobileLayout();
/// } else {
///   return TabletLayout();
/// }
///
/// // Responsive values
/// final columns = AppBreakpoints.value(
///   context: context,
///   mobile: 1,
///   tablet: 2,
///   desktop: 3,
/// );
/// ```
class AppBreakpoints {
  AppBreakpoints._(); // Private constructor

  // ==================== Breakpoint Values ====================

  /// Mobile breakpoint (< 600px)
  static const double mobile = 600.0;

  /// Tablet breakpoint (>= 600px && < 1200px)
  static const double tablet = 1200.0;

  /// Desktop breakpoint (>= 1200px)
  static const double desktop = 1200.0;

  // ==================== Device Type Detection ====================

  /// Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if device is tablet (600 <= width < 1200)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Check if device is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Check if device is mobile or tablet (width < 1200)
  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  /// Check if device is tablet or desktop (width >= 600)
  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile;

  /// Check if orientation is landscape
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if orientation is portrait
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // ==================== Responsive Value Selection ====================

  /// Get responsive value based on device type
  ///
  /// If desktop/tablet values are not provided, falls back to mobile value
  ///
  /// Example:
  /// ```dart
  /// final padding = AppBreakpoints.value(
  ///   context: context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get columns count based on device type
  ///
  /// Example:
  /// ```dart
  /// final columns = AppBreakpoints.columns(
  ///   context: context,
  ///   mobile: 1,
  ///   tablet: 2,
  ///   desktop: 3,
  /// );
  /// ```
  static int columns({
    required BuildContext context,
    required int mobile,
    int? tablet,
    int? desktop,
  }) {
    return value<int>(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive aspect ratio
  static double aspectRatio({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value<double>(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // ==================== Common Responsive Patterns ====================

  /// Get dialog max width
  /// - Mobile: full width
  /// - Tablet/Desktop: 600px
  static double dialogMaxWidth(BuildContext context) {
    return isMobile(context) ? double.infinity : 600.0;
  }

  /// Get grid columns for lists
  /// - Mobile: 1 column
  /// - Tablet: 2 columns
  /// - Desktop: 3 columns
  static int gridColumns(BuildContext context) {
    return columns(context: context, mobile: 1, tablet: 2, desktop: 3);
  }

  /// Get card columns for dashboard
  /// - Mobile: 1 column
  /// - Tablet: 2 columns
  /// - Desktop: 4 columns
  static int cardColumns(BuildContext context) {
    return columns(context: context, mobile: 1, tablet: 2, desktop: 4);
  }

  /// Get side panel width
  /// - Mobile: full width
  /// - Tablet: 320px
  /// - Desktop: 400px
  static double sidePanelWidth(BuildContext context) {
    return value<double>(
      context: context,
      mobile: MediaQuery.of(context).size.width,
      tablet: 320.0,
      desktop: 400.0,
    );
  }

  /// Get form max width
  /// - Mobile: full width
  /// - Tablet/Desktop: 800px
  static double formMaxWidth(BuildContext context) {
    return isMobile(context) ? double.infinity : 800.0;
  }

  // ==================== Screen Size Info ====================

  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get device pixel ratio
  static double devicePixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  /// Get text scale factor
  static double textScaleFactor(BuildContext context) =>
      MediaQuery.of(context).textScaleFactor;

  // ==================== Utility Methods ====================

  /// Execute different code based on device type
  ///
  /// Example:
  /// ```dart
  /// AppBreakpoints.when(
  ///   context: context,
  ///   mobile: () => print('Mobile'),
  ///   tablet: () => print('Tablet'),
  ///   desktop: () => print('Desktop'),
  /// );
  /// ```
  static void when({
    required BuildContext context,
    required VoidCallback mobile,
    VoidCallback? tablet,
    VoidCallback? desktop,
  }) {
    if (isDesktop(context)) {
      (desktop ?? tablet ?? mobile)();
    } else if (isTablet(context)) {
      (tablet ?? mobile)();
    } else {
      mobile();
    }
  }

  /// Get device type name as string
  static String deviceType(BuildContext context) {
    if (isDesktop(context)) return 'Desktop';
    if (isTablet(context)) return 'Tablet';
    return 'Mobile';
  }
}

/// Extension for easy responsive access
extension ResponsiveContext on BuildContext {
  /// Check if mobile
  bool get isMobile => AppBreakpoints.isMobile(this);

  /// Check if tablet
  bool get isTablet => AppBreakpoints.isTablet(this);

  /// Check if desktop
  bool get isDesktop => AppBreakpoints.isDesktop(this);

  /// Check if landscape
  bool get isLandscape => AppBreakpoints.isLandscape(this);

  /// Check if portrait
  bool get isPortrait => AppBreakpoints.isPortrait(this);

  /// Get screen width
  double get screenWidth => AppBreakpoints.screenWidth(this);

  /// Get screen height
  double get screenHeight => AppBreakpoints.screenHeight(this);

  /// Get responsive value
  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) =>
      AppBreakpoints.value<T>(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
