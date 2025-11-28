import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/animated_counter.dart';

/// Gender Stat Card - كارد إحصائيات الجنس (ذكور/إناث)
class GenderStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final MaterialColor color;

  const GenderStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Semantics(
      label: '$label: $count من $total (${percentage.toStringAsFixed(1)}%)',
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade50, color.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.shade200, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.shade700, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedCounter(
              value: count,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
