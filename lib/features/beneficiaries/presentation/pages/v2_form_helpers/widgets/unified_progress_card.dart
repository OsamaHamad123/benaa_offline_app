import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///  Compact Progress Card - Simplified Single Line
///
/// Shows tab progress and field completion in a clean, compact way
class UnifiedProgressCard extends StatelessWidget {
  final int currentTab;
  final int totalTabs;
  final int completedFields;
  final int totalFields;
  final String currentTabTitle;

  const UnifiedProgressCard({
    super.key,
    required this.currentTab,
    required this.totalTabs,
    required this.completedFields,
    required this.totalFields,
    required this.currentTabTitle,
  });

  double get tabProgress => (currentTab + 1) / totalTabs;
  double get fieldsProgress =>
      totalFields > 0 ? completedFields / totalFields : 0.0;
  double get overallProgress => (tabProgress + fieldsProgress) / 2;

  Color _getProgressColor() {
    if (overallProgress >= 0.8) return Colors.green;
    if (overallProgress >= 0.5) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor();

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: progressColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Compact Progress Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    value: overallProgress,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab Title
                  Text(
                    currentTabTitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  
                  // Compact Stats
                  Row(
                    children: [
                      Icon(Icons.tab, size: 12.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        '${currentTab + 1}/$totalTabs',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.task_alt, size: 12.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        '$completedFields/$totalFields',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Icon
            Icon(
              overallProgress >= 0.8
                  ? Icons.check_circle_rounded
                  : overallProgress >= 0.5
                      ? Icons.schedule_rounded
                      : Icons.circle_outlined,
              color: progressColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}