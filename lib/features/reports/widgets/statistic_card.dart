import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable card for displaying gender/category statistics
class StatisticCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final String percentage;
  final Color iconColor;
  final Color? backgroundColor;

  const StatisticCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.percentage,
    required this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.sp, color: iconColor),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 1.h),
            Text(
              count,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
