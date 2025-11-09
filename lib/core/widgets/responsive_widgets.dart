import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Responsive Card Widget with adaptive padding
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        );

    return Card(
      color: color,
      elevation: elevation,
      shape: shape,
      child: Padding(padding: responsivePadding, child: child),
    );
  }
}

/// Responsive GridView with adaptive columns
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return GridView.count(
      shrinkWrap: shrinkWrap,
      physics: physics,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

/// Responsive Container with adaptive padding and margin
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMargin = margin;

    return Container(
      padding: responsivePadding,
      margin: responsiveMargin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Responsive Text with adaptive font size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool useScale;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.useScale = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final scale = useScale ? ResponsiveUtils.getFontScale(context) : 1.0;

    return Text(
      text,
      style: baseStyle.copyWith(
        fontSize: baseStyle.fontSize != null
            ? baseStyle.fontSize! * scale
            : null,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive SizedBox with adaptive spacing
class ResponsiveSizedBox extends StatelessWidget {
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.child,
  });

  const ResponsiveSizedBox.height({
    super.key,
    double? mobile,
    double? tablet,
    double? desktop,
  }) : mobileHeight = mobile,
       tabletHeight = tablet,
       desktopHeight = desktop,
       mobileWidth = null,
       tabletWidth = null,
       desktopWidth = null,
       child = null;

  const ResponsiveSizedBox.width({
    super.key,
    double? mobile,
    double? tablet,
    double? desktop,
  }) : mobileWidth = mobile,
       tabletWidth = tablet,
       desktopWidth = desktop,
       mobileHeight = null,
       tabletHeight = null,
       desktopHeight = null,
       child = null;

  @override
  Widget build(BuildContext context) {
    final height = mobileHeight != null
        ? ResponsiveUtils.getResponsiveValue(
            context,
            mobile: mobileHeight!,
            tablet: tabletHeight ?? mobileHeight!,
            desktop: desktopHeight ?? tabletHeight ?? mobileHeight!,
          )
        : null;

    final width = mobileWidth != null
        ? ResponsiveUtils.getResponsiveValue(
            context,
            mobile: mobileWidth!,
            tablet: tabletWidth ?? mobileWidth!,
            desktop: desktopWidth ?? tabletWidth ?? mobileWidth!,
          )
        : null;

    return SizedBox(height: height, width: width, child: child);
  }
}

/// Responsive Padding Widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsivePadding({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      child: child,
    );
  }
}
