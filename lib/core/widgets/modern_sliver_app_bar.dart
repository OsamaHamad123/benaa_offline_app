import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 Modern Sliver AppBar - مكون موحد قابل لإعادة الاستخدام
///
/// يوفر:
/// - تصميم موحد لجميع الصفحات الرئيسية
/// - دعم كامل للثيم الديناميكي
/// - تحسينات الأداء (RepaintBoundary، Caching)
/// - Responsive للتابلت والموبايل
/// - Padding محسّن
class ModernSliverAppBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget>? actions;
  final double? expandedHeight;
  final bool isTablet;

  const ModernSliverAppBar({
    required this.title,
    required this.icon,
    super.key,
    this.actions,
    this.expandedHeight,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    // Phase 5: reduced height for a lighter, more comfortable AppBar
    final effectiveExpandedHeight = expandedHeight ?? (isTablet ? 110.h : 88.h);

    return SliverAppBar(
      expandedHeight: effectiveExpandedHeight,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.primary,
      foregroundColor: onPrimary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isTablet ? 24.w : 20.w,
          right: 10.w,
          bottom: 16.h,
        ),

        title: Row(
          children: [
            SizedBox(width: 2.w), // مسافة من البداية
            // أيقونة مع خلفية
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: onPrimary, size: 16.sp),
            ),

            SizedBox(width: 10.w),

            // العنوان مع Flexible لمنع overflow
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 20.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // الخلفية مع التدرج اللوني
        background: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      actions: actions != null
          ? [
              ...actions!,
              SizedBox(width: 10.w), // مسافة من النهاية
            ]
          : null,
    );
  }
}

/// 🎯 Modern Action Button - زر action موحد
///
/// يوفر padding محسّن وتجربة مستخدم أفضل مع دعم badge
class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double iconSize;
  final int? badge;

  const ModernActionButton({
    required this.icon,
    required this.tooltip,
    super.key,
    this.onPressed,
    this.iconSize = 17,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget iconButton = Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onPressed,
          child: Ink(
            // Phase 5: increased touch target (closer to 48dp WCAG recommendation)
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isDark ? onPrimary.withValues(alpha: 0.14) : onPrimary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: onPrimary,
            ),
          ),
        ),
      ),
    );

    // إضافة badge إذا كان موجود
    if (badge != null && badge! > 0) {
      return Badge(
        label: Text(badge! > 99 ? '99+' : '$badge'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        child: iconButton,
      );
    }

    return iconButton;
  }
}
