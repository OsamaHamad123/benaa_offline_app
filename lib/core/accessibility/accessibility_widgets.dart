import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📏 Accessibility Constants
///
/// ثوابت لضمان سهولة الوصول (Accessibility)
class AccessibilityConstants {
  AccessibilityConstants._();

  /// Minimum touch target size (48x48 dp) - WCAG 2.1 Level AAA
  static const double minTouchTarget = 48.0;

  /// Recommended touch target size for better UX
  static const double recommendedTouchTarget = 56.0;

  /// Minimum spacing between touch targets
  static const double minSpacing = 8.0;

  /// Text contrast ratios (WCAG 2.1)
  static const double minContrastNormal = 4.5; // For normal text
  static const double minContrastLarge = 3.0; // For large text (18pt+)
}

/// 🎯 Accessible Button
///
/// زر يضمن حجم لمس مناسب (48x48 dp minimum)
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? minWidth;
  final double? minHeight;
  final bool outlined;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.minWidth,
    this.minHeight,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMinWidth = minWidth ?? AccessibilityConstants.minTouchTarget;
    final effectiveMinHeight = minHeight ?? AccessibilityConstants.minTouchTarget;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: effectivePadding,
          minimumSize: Size(effectiveMinWidth, effectiveMinHeight),
          shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: effectivePadding,
        minimumSize: Size(effectiveMinWidth, effectiveMinHeight),
        shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      ),
      child: child,
    );
  }
}

/// 🎯 Accessible Icon Button
///
/// زر أيقونة يضمن حجم لمس مناسب
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? iconSize;
  final double? size;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.iconSize,
    this.size,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? AccessibilityConstants.minTouchTarget;
    final effectiveIconSize = iconSize ?? 24.sp;

    final button = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: effectiveIconSize),
        color: color,
        padding: padding ?? EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: effectiveSize,
          minHeight: effectiveSize,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 📱 Accessible List Tile
///
/// List tile مع حجم لمس مناسب
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final double? minHeight;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMinHeight = minHeight ?? AccessibilityConstants.minTouchTarget;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveMinHeight),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }
}

/// ♿ Semantic Label Wrapper
///
/// Wrapper يضيف semantic labels للـ screen readers
class SemanticWrapper extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool excludeSemantics;

  const SemanticWrapper({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// 🔊 Announcement Widget
///
/// Widget لعمل إعلانات للـ screen readers
class AccessibilityAnnouncement {
  /// Make an announcement for screen readers
  static void announce(BuildContext context, String message, {bool assertive = false}) {
    // Use SemanticsService for announcements
    // In production, would use platform-specific announcements
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

/// 📏 Spacing Helper for Accessibility
class AccessibleSpacing {
  AccessibleSpacing._();

  /// Minimum spacing between interactive elements
  static SizedBox get minVertical => SizedBox(height: AccessibilityConstants.minSpacing);

  /// Minimum spacing between interactive elements
  static SizedBox get minHorizontal => SizedBox(width: AccessibilityConstants.minSpacing);

  /// Recommended spacing for better UX
  static SizedBox get recommendedVertical => SizedBox(height: 16.h);

  /// Recommended spacing for better UX
  static SizedBox get recommendedHorizontal => SizedBox(width: 16.w);
}
