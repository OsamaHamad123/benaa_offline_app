import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🏆 Tab Completion Badge
///
/// Shows completion status for each tab with:
/// - Progress percentage badge
/// - Checkmark icon for completed tabs (>= 80%)
/// - Color-coded states (green/orange/blue)
class TabCompletionBadge extends StatelessWidget {
  final double progress;
  final bool showCheckmark;
  final int completedFields;
  final int totalFields;

  const TabCompletionBadge({
    super.key,
    required this.progress,
    this.showCheckmark = true,
    required this.completedFields,
    required this.totalFields,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final isComplete = percentage >= 80;
    final color = _getColorForProgress(percentage);

    return Semantics(
      label: 'تم إكمال $completedFields من $totalFields حقل, $percentage%',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Bar
          SizedBox(
            width: 45.w,
            height: 4.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),

          SizedBox(width: 6.w),

          // Completion Badge
          if (isComplete && showCheckmark)
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 10.sp),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForProgress(int percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50); // Green
    if (percentage >= 50) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF2196F3); // Blue
  }
}

/// 📊 Enhanced Tab with Badge
///
/// Custom tab widget that includes:
/// - Icon
/// - Label
/// - Completion badge with progress
/// - Field count (completed/total)
class EnhancedTabWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double progress;
  final int completedFields;
  final int totalFields;
  final bool isActive;

  const EnhancedTabWithBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.progress,
    required this.completedFields,
    required this.totalFields,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final color =
        isActive ? Theme.of(context).primaryColor : Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with completion indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 22.sp, color: color),

              // Checkmark badge for completed tabs
              if (percentage >= 80)
                Positioned(
                  right: -4.w,
                  top: -4.h,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 10.sp),
                  ),
                ),
            ],
          ),

          SizedBox(height: 4.h),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),

          SizedBox(height: 4.h),

          // Progress Badge
          TabCompletionBadge(
            progress: progress,
            completedFields: completedFields,
            totalFields: totalFields,
          ),

          SizedBox(height: 2.h),

          // Field count
          Text(
            '$completedFields/$totalFields',
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 Tab Completion Calculator
///
/// Calculates completion statistics for each tab
class TabCompletionStats {
  final int completedFields;
  final int totalFields;
  final double progress;

  const TabCompletionStats({
    required this.completedFields,
    required this.totalFields,
    required this.progress,
  });

  int get percentage => (progress * 100).round();
  bool get isComplete => percentage >= 80;

  Color get color {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 50) return const Color(0xFFFF9800);
    return const Color(0xFF2196F3);
  }
}
