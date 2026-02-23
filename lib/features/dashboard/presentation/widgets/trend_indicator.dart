import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Trend Indicator Widget - Shows percentage change with arrow
class TrendIndicator extends StatelessWidget {
  final double percentChange;
  final bool isPositive;

  const TrendIndicator({
    required this.percentChange, required this.isPositive, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Semantics(
      label: isPositive
          ? 'ارتفاع بنسبة ${percentChange.abs().toStringAsFixed(1)}%'
          : 'انخفاض بنسبة ${percentChange.abs().toStringAsFixed(1)}%',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              '${percentChange.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
