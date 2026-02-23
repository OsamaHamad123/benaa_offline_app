import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_colors.dart';
import '../utils/dashboard_colors.dart'; // ✅ Dashboard Colors
import '../providers/dashboard_providers.dart';

/// Daily Performance Section - مؤشر الأداء اليومي
class DailyPerformanceSection extends ConsumerWidget {
  const DailyPerformanceSection({super.key});

  // Daily target for visits (can be made configurable)
  static const int dailyTarget = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(dailyPerformanceProvider);

    return performanceAsync.when(
      data: (data) {
        final visitsToday = data.visitsToday;
        final newBeneficiariesToday = data.newBeneficiariesToday;
        final avgVisitsPerDay = data.avgVisitsPerDay;

        final percentage = (visitsToday / dailyTarget).clamp(0.0, 1.0);
        final isTargetMet = visitsToday >= dailyTarget;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isTargetMet ? AppColors.success.withOpacity(0.3) : AppColors.info.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isTargetMet
                    ? [
                        AppColors.success.withOpacity(0.05),
                        AppColors.successLight.withOpacity(0.05),
                      ]
                    : [
                        AppColors.info.withOpacity(0.05),
                        AppColors.infoLight.withOpacity(0.05),
                      ],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color:
                                  isTargetMet ? AppColors.success.withOpacity(0.15) : AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              isTargetMet ? Icons.check_circle : Icons.trending_up,
                              color: isTargetMet ? AppColors.success : AppColors.info,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الأداء اليومي',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                isTargetMet ? 'تم تحقيق الهدف! 🎉' : 'في التقدم',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isTargetMet ? AppColors.successDark : AppColors.textSecondary,
                                  fontWeight: isTargetMet ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Circular Progress Indicator
                  SizedBox(
                    height: 160.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        SizedBox(
                          width: 140.w,
                          height: 140.w,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12.w,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.divider.withOpacity(0.15),
                            ),
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: 140.w,
                          height: 140.w,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0, end: percentage),
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12.w,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isTargetMet ? AppColors.success : AppColors.info,
                                ),
                              );
                            },
                          ),
                        ),
                        // Center Text - allow scaling down when space is tight
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$visitsToday',
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isTargetMet ? AppColors.success : AppColors.info,
                                ),
                              ),
                              Text(
                                'من $dailyTarget',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'زيارة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Additional Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.person_add,
                          label: 'مستفيدين جدد',
                          value: '$newBeneficiariesToday',
                          color: DashboardColors.widows,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.show_chart,
                          label: 'المتوسط (7 أيام)',
                          value: avgVisitsPerDay.toStringAsFixed(1),
                          color: DashboardColors.warning,
                        ),
                      ),
                    ],
                  ),

                  if (visitsToday < dailyTarget) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: AppColors.warningDark,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'باقي ${dailyTarget - visitsToday} زيارة لتحقيق الهدف اليومي',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => _buildSkeletonLoader(),
      error: (error, stack) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text('خطأ: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.border.withOpacity(0.2), width: 2),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Provide a compact skeleton when vertical space is limited to avoid overflow
            final compact = constraints.maxHeight > 0 && constraints.maxHeight < 260;

            final double iconSize = compact ? 32.w : 40.w;
            final double headerBarHeight = compact ? 14.h : 20.h;
            final double circleSize = compact ? 80.w : 140.w;
            final double statBoxHeight = compact ? 44.h : 60.h;
            final double spacing = compact ? 12.h : 20.h;

            // Cap sizes based on available vertical space to avoid overflow
            final availableH = constraints.maxHeight > 0 ? constraints.maxHeight : double.infinity;
            final effectiveCircleSize = math.min(circleSize, availableH * 0.45);
            final effectiveHeaderBarHeight = math.min(
              headerBarHeight,
              availableH * 0.08,
            );
            final effectiveStatBoxHeight = math.min(
              statBoxHeight,
              availableH * 0.18,
            );

            return Container(
              padding: EdgeInsets.all(compact ? 12.w : 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: effectiveHeaderBarHeight,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  Container(
                    width: effectiveCircleSize,
                    height: effectiveCircleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                  ),
                  SizedBox(height: spacing),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: effectiveStatBoxHeight,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: effectiveStatBoxHeight,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Stat Item Widget for Additional Stats
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
