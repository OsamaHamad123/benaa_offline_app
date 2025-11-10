import 'package:flutter/material.dart';

/// Responsive utilities for adaptive layouts
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ⚡ Performance: Cache للقيم المحسوبة
  static final Map<int, bool> _isMobileCache = {};
  static final Map<int, bool> _isTabletCache = {};
  static final Map<int, bool> _isDesktopCache = {};

  /// Check if the screen is mobile size
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toInt();
    return _isMobileCache.putIfAbsent(width, () => width < mobileBreakpoint);
  }

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toInt();
    return _isTabletCache.putIfAbsent(
      width,
      () => width >= mobileBreakpoint && width < desktopBreakpoint,
    );
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toInt();
    return _isDesktopCache.putIfAbsent(width, () => width >= desktopBreakpoint);
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get cross axis count for grid based on screen size
  static int getCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(
      getResponsiveValue(context, mobile: 12.0, tablet: 16.0, desktop: 24.0),
    );
  }

  /// Get spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }

  /// Get font size scale based on screen size
  static double getFontScale(BuildContext context) {
    return getResponsiveValue(context, mobile: 1.0, tablet: 1.1, desktop: 1.2);
  }

  /// ⚡ Performance: احصل على كل القيم المحسوبة مرة واحدة
  static ResponsiveValues getValues(BuildContext context) {
    return ResponsiveValues(context);
  }
}

/// ⚡ Class لتخزين القيم المحسوبة مرة واحدة
class ResponsiveValues {
  final EdgeInsets padding;
  final double spacing;
  final double spacing15;
  final double fontScale;

  ResponsiveValues(BuildContext context)
    : padding = EdgeInsets.all(
        ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 24.0,
        ),
      ),
      spacing = ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 12.0,
        tablet: 16.0,
        desktop: 20.0,
      ),
      spacing15 =
          ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ) *
          1.5,
      fontScale = ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 1.0,
        tablet: 1.1,
        desktop: 1.2,
      );
}

/// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils.desktopBreakpoint &&
            desktop != null) {
          return desktop!(context, constraints);
        } else if (constraints.maxWidth >= ResponsiveUtils.mobileBreakpoint &&
            tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}
