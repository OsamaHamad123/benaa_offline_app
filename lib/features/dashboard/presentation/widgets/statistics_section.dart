import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/micro_interactions.dart';
import 'trend_indicator.dart';
import '../../../../theme/app_colors.dart';
import '../utils/dashboard_colors.dart'; // ✅ Dashboard Colors
import '../utils/dashboard_text_styles.dart'; // ✅ Dashboard Text Styles
import '../utils/dashboard_haptics.dart'; // ✅ Dashboard Haptics
import '../utils/dashboard_spacing.dart'; // ✅ Dashboard Spacing
import '../../../../core/utils/haptic_patterns.dart';

/// Stat Card Widget - Reusable statistics card with Trend Indicator
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final double? trendPercentage; // Trend percentage (optional)
  final int? previousValue; // Previous value for comparison

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.trendPercentage,
    this.previousValue,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate trend if previous value is provided
    double? calculatedTrend;
    if (previousValue != null && previousValue! > 0) {
      final currentVal = int.tryParse(value) ?? 0;
      calculatedTrend = ((currentVal - previousValue!) / previousValue!) * 100;
    }
    final trend = trendPercentage ?? calculatedTrend;

    return Semantics(
      label:
          '$title: $value${subtitle != null ? ', $subtitle' : ''}${trend != null ? ', تغير بنسبة ${trend.toStringAsFixed(1)}%' : ''}',
      hint: onTap != null ? 'اضغط لعرض التفاصيل' : null,
      button: onTap != null,
      enabled: onTap != null,
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.06), color.withOpacity(0.12)],
            ),
          ),
          child: MicroInteractions.bounceButton(
            onTap: onTap != null
                ? () {
                    HapticPatterns.selection();
                    onTap!();
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Very tight vertical constraints occur in some test environments
                  // and on very small tiles. Render a compact horizontal layout
                  // when the available height is too small to fit the full card.
                  // Treat very small heights or very narrow widths as "compact" cases.
                  if (constraints.maxHeight < 110 || constraints.maxWidth < 80) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(icon, color: color, size: 18.sp),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Value (scale down if needed)
                              Flexible(
                                fit: FlexFit.loose,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: DashboardTextStyles.statValue.copyWith(
                                      fontSize: 20.sp,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: DashboardSpacing.tiny),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  title,
                                  style: DashboardTextStyles.statLabel.copyWith(
                                    fontSize: 10.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trend != null)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: TrendIndicator(
                              percentChange: trend,
                              isPositive: trend >= 0,
                            ),
                          )
                        else if (onTap != null)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12.sp,
                              color: color,
                            ),
                          ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(icon, color: color, size: 22.sp),
                          ),
                          // Trend Indicator or Arrow
                          if (trend != null)
                            TrendIndicator(
                              percentChange: trend,
                              isPositive: trend >= 0,
                            )
                          else if (onTap != null)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12.sp,
                              color: color,
                            ),
                        ],
                      ),
                      // Use fixed small spacing instead of Spacer() to avoid overflow
                      SizedBox(height: DashboardSpacing.tiny),
                      // Use FittedBox to scale the numeric value down in very tight constraints
                      Flexible(
                        fit: FlexFit.loose,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: DashboardTextStyles.statValue.copyWith(
                              color: color,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: DashboardSpacing.tiny),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          title,
                          style: DashboardTextStyles.statLabel.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: DashboardSpacing.tiny),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            subtitle!,
                            style: DashboardTextStyles.badge.copyWith(
                              fontSize: 10.sp,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Statistics Grid - Grid layout for stat cards
class StatisticsGrid extends ConsumerWidget {
  final int totalBeneficiaries;
  final int activeBeneficiaries;
  final int pendingSync;
  final int completedVisitsToday;
  final VoidCallback? onBeneficiariesTap;
  final VoidCallback? onPendingSyncTap;

  const StatisticsGrid({
    super.key,
    required this.totalBeneficiaries,
    required this.activeBeneficiaries,
    required this.pendingSync,
    required this.completedVisitsToday,
    this.onBeneficiariesTap,
    this.onPendingSyncTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ResponsiveUtils for perfect responsive layout
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    final childAspectRatio = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 1.15,
      tablet: 1.45,
      desktop: 1.5,
    );

    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        StatCard(
          title: 'إجمالي المستفيدين',
          value: '$totalBeneficiaries',
          icon: Icons.people,
          color: DashboardColors.totalBeneficiaries,
          onTap: onBeneficiariesTap,
        ),
        StatCard(
          title: 'المستفيدون النشطون',
          value: '$activeBeneficiaries',
          icon: Icons.person_add,
          color: AppColors.success,
          subtitle: 'آخر 30 يوم',
        ),
        StatCard(
          title: 'بانتظار المزامنة',
          value: '$pendingSync',
          icon: Icons.sync_problem,
          color: pendingSync > 0 ? DashboardColors.warning : AppColors.textHint,
          onTap: onPendingSyncTap,
        ),
        StatCard(
          title: 'الزيارات اليوم',
          value: '$completedVisitsToday',
          icon: Icons.check_circle,
          color: DashboardColors.widows,
        ),
      ],
    );
  }
}
