import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 Enhanced Progress Indicator with Percentage
///
/// Displays current tab progress with:
/// - Circular progress indicator
/// - Percentage text
/// - Smooth animations
class EnhancedProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? progressColor;
  final Color? backgroundColor;

  const EnhancedProgressIndicator({
    required this.currentStep, required this.totalSteps, super.key,
    this.progressColor,
    this.backgroundColor,
  });

  double get progress => (currentStep + 1) / totalSteps;
  int get percentage => (progress * 100).toInt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.primaryColor;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Progress
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 3.w,
                  valueColor: AlwaysStoppedAnimation(effectiveBackgroundColor),
                ),
                // Progress circle
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: Tween(begin: 0, end: progress),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3.w,
                      valueColor: AlwaysStoppedAnimation(
                        effectiveProgressColor,
                      ),
                    );
                  },
                ),
                // Percentage text
                TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: IntTween(begin: 0, end: percentage),
                  builder: (context, value, child) {
                    return Text(
                      '$value%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: effectiveProgressColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Progress text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'التقدم',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: IntTween(begin: 0, end: currentStep + 1),
                builder: (context, value, child) {
                  return Text(
                    'الخطوة $value من $totalSteps',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
