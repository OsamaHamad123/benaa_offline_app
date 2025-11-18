import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'trend_indicator.dart';

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

    // Hero tag for animations
    final heroTag = 'stat-card-$title';

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: color.withOpacity(0.2), width: 1),
          ),
          child: InkWell(
            onTap: onTap != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onTap!();
                  }
                : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.05), color.withOpacity(0.1)],
                ),
              ),
              padding: EdgeInsets.all(12.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(icon, color: color, size: 20.sp),
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
                      const Spacer(),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
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
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: color,
                              fontWeight: FontWeight.w500,
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
      mobile: 1.2,
      tablet: 1.3,
      desktop: 1.4,
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
          color: Colors.blue,
          onTap: onBeneficiariesTap,
        ),
        StatCard(
          title: 'المستفيدون النشطون',
          value: '$activeBeneficiaries',
          icon: Icons.person_add,
          color: Colors.green,
          subtitle: 'آخر 30 يوم',
        ),
        StatCard(
          title: 'بانتظار المزامنة',
          value: '$pendingSync',
          icon: Icons.sync_problem,
          color: pendingSync > 0 ? Colors.orange : Colors.grey,
          onTap: onPendingSyncTap,
        ),
        StatCard(
          title: 'الزيارات اليوم',
          value: '$completedVisitsToday',
          icon: Icons.check_circle,
          color: Colors.purple,
        ),
      ],
    );
  }
}
