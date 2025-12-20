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
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.fontSize,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor.withOpacity(0.2),
                effectiveColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: effectiveColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize ?? 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
