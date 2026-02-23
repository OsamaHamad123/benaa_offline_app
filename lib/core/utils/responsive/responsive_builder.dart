import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

/// 🎨 بناء ويدجيتات متجاوبة بناءً على حجم الشاشة
///
/// مثال:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context, _) => SingleColumnForm(),
///   tablet: (context, _) => TwoColumnForm(),
///   desktop: (context, _) => ThreeColumnFormWithSidebar(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    required this.mobile, super.key,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return (desktop ?? tablet ?? mobile)(context, constraints);
        } else if (constraints.maxWidth >= AppBreakpoints.mobile) {
          return (tablet ?? mobile)(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// 📱 بناء ويدجت واحد مع تخصيصات بناءً على حجم الشاشة
///
/// مثال:
/// ```dart
/// ResponsiveValue<int>(
///   mobile: 1,
///   tablet: 2,
///   desktop: 3,
///   builder: (context, columns) {
///     return GridView.count(crossAxisCount: columns);
///   },
/// )
/// ```
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    required this.mobile, required this.builder, super.key,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final value = AppBreakpoints.responsive<T>(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    return builder(context, value);
  }
}

/// 📐 SliverGrid متجاوب
///
/// مثال:
/// ```dart
/// ResponsiveSliverGrid(
///   children: items.map((item) => ItemCard(item)).toList(),
/// )
/// ```
class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final double? mobileColumns;
  final double? tabletColumns;
  final double? desktopColumns;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveSliverGrid({
    required this.children, super.key,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.responsive<int>(
      context: context,
      mobile: (mobileColumns ?? 1).toInt(),
      tablet: (tabletColumns ?? 2).toInt(),
      desktop: (desktopColumns ?? 3).toInt(),
    );

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      delegate: SliverChildListDelegate(children),
    );
  }
}

/// 📱 Grid متجاوب (غير Sliver)
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? mobileColumns;
  final double? tabletColumns;
  final double? desktopColumns;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry padding;

  const ResponsiveGrid({
    required this.children, super.key,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.responsive<int>(
      context: context,
      mobile: (mobileColumns ?? 1).toInt(),
      tablet: (tabletColumns ?? 2).toInt(),
      desktop: (desktopColumns ?? 3).toInt(),
    );

    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        children: children,
      ),
    );
  }
}
