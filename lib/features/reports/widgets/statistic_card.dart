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
    return Semantics(
      label: '$label: $count ($percentage)',
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20.sp, color: iconColor),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 1.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  percentage,
                  style: TextStyle(fontSize: 8.sp, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
