import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Enhanced Section Header with Animation
///
/// Section header that shows completion status with visual feedback
class AnimatedSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isComplete;
  final VoidCallback? onTap;

  const AnimatedSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.isComplete = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: isComplete
              ? LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isComplete ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isComplete ? Colors.green : theme.colorScheme.outline,
            width: isComplete ? 2 : 1,
          ),
          boxShadow: isComplete
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isComplete
                    ? Colors.green.withOpacity(0.2)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isComplete
                    ? Colors.green
                    : theme.colorScheme.onPrimaryContainer,
                size: 20.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isComplete
                      ? Colors.green.shade800
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Checkmark
            if (isComplete)
              AnimatedScale(
                scale: isComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🎨 Enhanced Section Card with Animation
///
/// Complete section card that wraps content with animated header
class AnimatedSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isComplete;
  final List<Widget> children;
  final EdgeInsets? padding;
  final Color? color;

  const AnimatedSectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.isComplete = false,
    required this.children,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 0,
      color: color ?? theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isComplete
              ? Colors.green.withOpacity(0.3)
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Header
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green.withOpacity(0.2)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color:
                        isComplete ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isComplete
                          ? Colors.green.shade800
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Checkmark
                if (isComplete)
                  AnimatedScale(
                    scale: isComplete ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 📊 Completion Progress Card
///
/// Shows overall form completion percentage
class CompletionProgressCard extends StatelessWidget {
  final int completedFields;
  final int totalFields;
  final String? subtitle;

  const CompletionProgressCard({
    super.key,
    required this.completedFields,
    required this.totalFields,
    this.subtitle,
  });

  double get percentage => (completedFields / totalFields * 100).clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اكتمال النموذج',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Percentage
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getPercentageColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _getPercentageColor(), width: 2),
                  ),
                  child: Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _getPercentageColor(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8.h,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPercentageColor(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '$completedFields / $totalFields',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor() {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
