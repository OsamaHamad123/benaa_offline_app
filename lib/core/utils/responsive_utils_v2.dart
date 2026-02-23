import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📐 Responsive Utility - Using flutter_screenutil
///
/// This utility provides consistent responsive sizing across the entire app.
/// Benefits:
/// - ✅ Automatic scaling for different screen sizes
/// - ✅ Works on Mobile, Tablet, Desktop, Web
/// - ✅ Maintains design proportions
/// - ✅ Easy to use with .w, .h, .sp extensions
///
/// Usage Examples:
/// ```dart
/// // Width & Height
/// Container(
///   width: 100.w,    // Responsive width
///   height: 50.h,    // Responsive height
///   padding: EdgeInsets.all(16.r), // Responsive padding
/// )
///
/// // Font Size
/// Text('Hello', style: TextStyle(fontSize: 16.sp))
///
/// // Spacing
/// SizedBox(height: ResponsiveUtils.verticalSpace)
/// SizedBox(width: ResponsiveUtils.horizontalSpace)
/// ```

class ResponsiveUtils {
  // Design dimensions (iPhone 13 Pro as reference)
  static const double _designWidth = 390;
  static const double _designHeight = 844;

  /// Initialize ScreenUtil (Call once in main.dart)
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(_designWidth, _designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  // ==================== Device Type Detection ====================

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  static bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;

  // ==================== Responsive Dimensions ====================

  /// Get responsive width (0.0 - 1.0 represents percentage)
  static double width(BuildContext context, double percentage) => MediaQuery.of(context).size.width * percentage;

  /// Get responsive height (0.0 - 1.0 represents percentage)
  static double height(BuildContext context, double percentage) => MediaQuery.of(context).size.height * percentage;

  /// Screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  /// Screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // ==================== Standard Spacing ====================

  /// Extra small spacing (4.0)
  static double get xSmallSpace => 4.h;

  /// Small spacing (8.0)
  static double get smallSpace => 8.h;

  /// Medium spacing (16.0)
  static double get mediumSpace => 16.h;

  /// Large spacing (24.0)
  static double get largeSpace => 24.h;

  /// Extra large spacing (32.0)
  static double get xLargeSpace => 32.h;

  /// Vertical spacing widget
  static Widget get verticalSpace => SizedBox(height: mediumSpace);

  /// Horizontal spacing widget
  static Widget get horizontalSpace => SizedBox(width: mediumSpace);

  /// Custom vertical spacing
  static Widget verticalSpacing(double height) => SizedBox(height: height.h);

  /// Custom horizontal spacing
  static Widget horizontalSpacing(double width) => SizedBox(width: width.w);

  // ==================== Responsive Padding ====================

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.all(32.r);
    } else if (isTablet(context)) {
      return EdgeInsets.all(24.r);
    } else {
      return EdgeInsets.all(16.r);
    }
  }

  /// Get horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(horizontal: 32.w);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 24.w);
    } else {
      return EdgeInsets.symmetric(horizontal: 16.w);
    }
  }

  /// Get vertical padding
  static EdgeInsets getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(vertical: 32.h);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(vertical: 24.h);
    } else {
      return EdgeInsets.symmetric(vertical: 16.h);
    }
  }

  // ==================== Responsive Font Sizes ====================

  /// Extra small font (10sp)
  static double get xSmallFont => 10.sp;

  /// Small font (12sp)
  static double get smallFont => 12.sp;

  /// Body font (14sp)
  static double get bodyFont => 14.sp;

  /// Medium font (16sp)
  static double get mediumFont => 16.sp;

  /// Large font (18sp)
  static double get largeFont => 18.sp;

  /// Title font (20sp)
  static double get titleFont => 20.sp;

  /// Heading font (24sp)
  static double get headingFont => 24.sp;

  /// Display font (32sp)
  static double get displayFont => 32.sp;

  // ==================== Responsive Spacing for Context ====================

  /// Get spacing value based on device type
  static double getResponsiveSpacing(BuildContext context) {
    if (isDesktop(context)) return 32.h;
    if (isTablet(context)) return 24.h;
    return 16.h;
  }

  /// Get card spacing
  static double getCardSpacing(BuildContext context) {
    if (isDesktop(context)) return 24.h;
    if (isTablet(context)) return 16.h;
    return 12.h;
  }

  /// Get icon size
  static double getIconSize(BuildContext context) {
    if (isDesktop(context)) return 32.r;
    if (isTablet(context)) return 28.r;
    return 24.r;
  }

  // ==================== Grid Columns ====================

  /// Get number of grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Get cross axis count for grid (alias for getGridColumns)
  static int getCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Get responsive value based on screen size (generic helper)
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

  /// Get ResponsiveValues object for caching (backward compatibility)
  static ResponsiveValues getValues(BuildContext context) {
    return ResponsiveValues(context);
  }

  /// Get grid spacing
  static double getGridSpacing(BuildContext context) {
    if (isDesktop(context)) return 24.r;
    if (isTablet(context)) return 16.r;
    return 12.r;
  }

  /// Get list spacing - مسافة أصغر للقوائم
  static double getListSpacing(BuildContext context) {
    if (isDesktop(context)) return 12.r;
    if (isTablet(context)) return 8.r;
    return 6.r;
  }

  /// Get compact list spacing - مسافة مدمجة جداً
  static double getCompactListSpacing(BuildContext context) {
    if (isDesktop(context)) return 8.r;
    if (isTablet(context)) return 6.r;
    return 4.r;
  }

  // ==================== Card & Container Sizes ====================

  /// Get card width for lists
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return screenWidth * 0.3;
    if (isTablet(context)) return screenWidth * 0.45;
    return screenWidth * 0.9;
  }

  /// Get dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 600.w;
    if (isTablet(context)) return screenWidth * 0.7;
    return screenWidth * 0.9;
  }

  // ==================== Border Radius ====================

  /// Small border radius (4.0)
  static double get smallRadius => 4.r;

  /// Medium border radius (8.0)
  static double get mediumRadius => 8.r;

  /// Large border radius (12.0)
  static double get largeRadius => 12.r;

  /// Extra large border radius (16.0)
  static double get xLargeRadius => 16.r;

  /// Circular border radius (100.0)
  static double get circularRadius => 100.r;

  // ==================== Safe Area ====================

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      bottom: MediaQuery.of(context).padding.bottom,
    );
  }

  // ==================== Responsive Layout Builder ====================

  /// Build different layouts based on screen size
  static Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }

  // ==================== Max Width Container ====================

  /// Wrap content with max width for desktop
  static Widget maxWidthContainer({
    required Widget child,
    double maxWidth = 1200,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.w),
        child: child,
      ),
    );
  }
}

/// 📦 Responsive Values Cache Class
///
/// Caches commonly used responsive values for better performance
class ResponsiveValues {
  final BuildContext context;

  late final EdgeInsets padding;
  late final double spacing;
  late final double spacing15;
  late final double fontScale;
  late final double fontSize;
  late final int crossAxisCount;
  late final bool isTablet;
  late final bool isMobile;
  late final bool isDesktop;

  ResponsiveValues(this.context) {
    isTablet = ResponsiveUtils.isTablet(context);
    isMobile = ResponsiveUtils.isMobile(context);
    isDesktop = ResponsiveUtils.isDesktop(context);
    padding = ResponsiveUtils.getResponsivePadding(context);
    spacing = ResponsiveUtils.getResponsiveSpacing(context);
    spacing15 = isMobile ? 12.0 : 15.0;
    fontScale = isMobile ? 1.0 : 1.1;
    fontSize = ResponsiveUtils.bodyFont;
    crossAxisCount = ResponsiveUtils.getGridColumns(context);
  }
}

// ==================== Responsive Form Layout ====================

/// 📱 Form Layout متجاوب للموبايل والتابلت
///
/// - موبايل: عمود واحد (Column)
/// - تابلت+: عمودين (2-column Row)
class ResponsiveFormLayout extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveFormLayout({
    required this.children, super.key,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      // موبايل: عمود واحد
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, spacing),
      );
    }

    // تابلت+: عمودين
    return _buildTwoColumns();
  }

  Widget _buildTwoColumns() {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (var i = 0; i < children.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(children[i]);
      } else {
        rightColumn.add(children[i]);
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _addSpacing(leftColumn, spacing),
            ),
          ),
          SizedBox(width: spacing * 2),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _addSpacing(rightColumn, spacing),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double space) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(SizedBox(height: space));
      }
    }
    return result;
  }
}
