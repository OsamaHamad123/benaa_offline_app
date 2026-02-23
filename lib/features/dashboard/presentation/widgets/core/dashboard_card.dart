import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/app_colors.dart';

/// Dashboard Card - بطاقة موحدة للداشبورد
///
/// استخدام:
/// ```dart
/// DashboardCard(
///   accentColor: Colors.blue,
///   child: Text('محتوى'),
/// )
/// ```
class DashboardCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;

  const DashboardCard({
    required this.child, super.key,
    this.accentColor,
    this.onTap,
    this.padding,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? AppColors.primary;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16.r);

    return Card(
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: BorderSide(
          color: effectiveColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor.withOpacity(0.03),
                effectiveColor.withOpacity(0.01),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: effectiveBorderRadius,
          ),
          padding: padding ?? EdgeInsets.all(16.w),
          child: child,
        ),
      ),
    );
  }
}

/// Stat Dashboard Card - بطاقة إحصائيات موحدة
class StatDashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StatDashboardCard({
    required this.label, required this.value, required this.icon, required this.color, super.key,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      accentColor: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
