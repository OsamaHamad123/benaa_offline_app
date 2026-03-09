import 'package:benaa_offline_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section Title Widget with Icon - Reusable across dashboard
///
/// استخدام:
/// ```dart
/// SectionTitle(title: 'الإحصائيات', icon: Icons.bar_chart)
/// ```
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final double? fontSize;
  final Widget? trailing;

  const SectionTitle({
    required this.title,
    required this.icon,
    super.key,
    this.color,
    this.fontSize,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min, // ✅ Fix: Prevent unconstrained width
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 17.sp, color: effectiveColor),
        ),
        SizedBox(width: 10.w),
        Flexible(
          // ✅ Changed from Expanded to Flexible
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize ?? 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.w),
          trailing!,
        ],
      ],
    );
  }
}
