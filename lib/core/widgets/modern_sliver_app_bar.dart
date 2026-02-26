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
    final effectiveExpandedHeight = expandedHeight ?? (isTablet ? 120.h : 100.h);

    return SliverAppBar(
      expandedHeight: effectiveExpandedHeight,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isTablet ? 24.w : 20.w,
          right: 8.w,
          bottom: 16.h,
        ),

        title: Row(
          children: [
            SizedBox(width: 4.w), // مسافة من البداية
            // أيقونة مع خلفية
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),

            SizedBox(width: 12.w),

            // العنوان مع Flexible لمنع overflow
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 20.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              SizedBox(width: 8.w), // مسافة من النهاية
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
    this.iconSize = 24,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget iconButton = Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onPressed,
          child: Ink(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              icon,
              size: iconSize.sp,
              color: Colors.white,
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
