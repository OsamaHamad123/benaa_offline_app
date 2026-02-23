import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable list item for displaying report details with progress bar
class DetailListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progressValue;
  final Color? progressColor;
  final Color? indicatorColor;
  final double? indicatorWidth;
  final double? indicatorHeight;

  const DetailListItem({
    required this.title, required this.subtitle, required this.progressValue, super.key,
    this.progressColor,
    this.indicatorColor,
    this.indicatorWidth,
    this.indicatorHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Color indicator (optional)
            if (indicatorColor != null)
              Container(
                width: indicatorWidth ?? 6.w,
                height: indicatorHeight ?? 32.h,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            if (indicatorColor != null) SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail list item with full-width progress bar (for governorate/age reports)
class DetailListItemWithProgress extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progressValue;
  final Color? progressColor;
  final Color? indicatorColor;
  final double? indicatorSize;

  const DetailListItemWithProgress({
    required this.title, required this.subtitle, required this.progressValue, super.key,
    this.progressColor,
    this.indicatorColor,
    this.indicatorSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title with optional color indicator
                Row(
                  children: [
                    if (indicatorColor != null) ...[
                      Container(
                        width: indicatorSize ?? 12,
                        height: indicatorSize ?? 12,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[200],
              color: progressColor,
            ),
          ],
        ),
      ),
    );
  }
}
