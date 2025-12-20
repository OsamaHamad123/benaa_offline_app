import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 Form Progress Indicator
///
/// يعرض مؤشر تقدم في AppBar يوضح عدد الحقول المكتملة
class FormProgressIndicator extends StatelessWidget {
  final int totalRequiredFields;
  final int filledFields;
  final Color? progressColor;
  final Color? backgroundColor;

  const FormProgressIndicator({
    super.key,
    required this.totalRequiredFields,
    required this.filledFields,
    this.progressColor,
    this.backgroundColor,
  });

  double get progress {
    if (totalRequiredFields == 0) return 0.0;
    return (filledFields / totalRequiredFields).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? Colors.white;
    final effectiveBackgroundColor =
        backgroundColor ?? Colors.white.withOpacity(0.3);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress text FIRST (before progress bar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$filledFields من $totalRequiredFields',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% مكتمل',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: effectiveBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

/// 💾 Auto-Save Indicator
///
/// يعرض مؤشر حفظ تلقائي subtle في AppBar
class AutoSaveIndicator extends StatelessWidget {
  final DateTime? lastSaved;
  final bool isSaving;

  const AutoSaveIndicator({super.key, this.lastSaved, this.isSaving = false});

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    }
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSaving) {
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12.w,
              height: 12.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'جاري الحفظ...',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (lastSaved != null) {
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, size: 14.sp, color: Colors.green),
            SizedBox(width: 4.w),
            Text(
              _formatTime(lastSaved!),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
