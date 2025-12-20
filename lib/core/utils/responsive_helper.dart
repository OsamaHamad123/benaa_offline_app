import 'package:flutter/material.dart';

/// 📱 Responsive Helper - مساعد للـ Responsive Design
///
/// يوفر breakpoints موحدة وutilities للتعامل مع responsive design
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Is Mobile (< 600px)
  bool get isMobile => screenWidth < 600;

  /// Is Tablet (600px - 900px)
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Is Desktop (>= 900px)
  bool get isDesktop => screenWidth >= 900;

  /// Is Landscape
  bool get isLandscape => screenWidth > screenHeight;

  /// Is Portrait
  bool get isPortrait => screenHeight > screenWidth;

  /// Adaptive Value - يختار قيمة حسب حجم الشاشة
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Adaptive Padding
  EdgeInsets padding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final p = value(
      mobile: mobile ?? 16.0,
      tablet: tablet ?? 24.0,
      desktop: desktop ?? 32.0,
    );
    return EdgeInsets.all(p);
  }

  /// Adaptive Horizontal Padding
  EdgeInsets horizontalPadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final p = value(
      mobile: mobile ?? 16.0,
      tablet: tablet ?? 24.0,
      desktop: desktop ?? 32.0,
    );
    return EdgeInsets.symmetric(horizontal: p);
  }

  /// Adaptive Vertical Padding
  EdgeInsets verticalPadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final p = value(
      mobile: mobile ?? 16.0,
      tablet: tablet ?? 24.0,
      desktop: desktop ?? 32.0,
    );
    return EdgeInsets.symmetric(vertical: p);
  }

  /// Max Content Width - لتحسين القراءة على الشاشات الكبيرة
  double get maxContentWidth {
    return value(
      mobile: double.infinity,
      tablet: 700.0,
      desktop: 1200.0,
    );
  }

  /// Grid Columns Count
  int gridColumns({int? mobile, int? tablet, int? desktop}) {
    return value(
      mobile: mobile ?? 1,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
    );
  }

  /// Font Size Multiplier
  double get fontSizeMultiplier {
    return value(
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.15,
    );
  }

  /// Icon Size
  double iconSize({double? mobile, double? tablet, double? desktop}) {
    return value(
      mobile: mobile ?? 24.0,
      tablet: tablet ?? 28.0,
      desktop: desktop ?? 32.0,
    );
  }

  /// Spacing
  double spacing({double? mobile, double? tablet, double? desktop}) {
    return value(
      mobile: mobile ?? 8.0,
      tablet: tablet ?? 12.0,
      desktop: desktop ?? 16.0,
    );
  }
}

/// Extension on BuildContext للوصول السريع
extension ResponsiveExtension on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}

/// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper helper) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveHelper(context));
  }
}

/// Responsive Layout - يختار layout حسب حجم الشاشة
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    if (responsive.isDesktop && desktop != null) return desktop!;
    if (responsive.isTablet && tablet != null) return tablet!;
    return mobile;
  }
}

/// Responsive Grid - شبكة تتكيف تلقائياً
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing,
    this.runSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final columns = responsive.gridColumns(
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    return Padding(
      padding: padding ?? responsive.padding(),
      child: GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: runSpacing ?? responsive.spacing(),
        crossAxisSpacing: spacing ?? responsive.spacing(),
        children: children,
      ),
    );
  }
}

/// Responsive Container - حاوية بـ max width تلقائي
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? responsive.maxContentWidth,
        ),
        child: Padding(
          padding: padding ?? responsive.padding(),
          child: child,
        ),
      ),
    );
  }
}
