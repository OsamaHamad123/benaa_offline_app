import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'stat_card.dart';

/// 📊 Stats Dashboard Widget - لوحة الإحصائيات
class StatsDashboardWidget extends StatelessWidget {
  final int total;
  final int active;
  final int paused;
  final int ended;
  final double? totalAmount;
  final String? currency;

  const StatsDashboardWidget({
    super.key,
    required this.total,
    required this.active,
    required this.paused,
    required this.ended,
    this.totalAmount,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePercentage = total > 0 ? (active / total * 100).toInt() : 0;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.5),
            theme.colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: theme.colorScheme.primary,
                size: 28.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'إحصائيات الكفالات',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Stats Cards Grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.85,
            children: [
              StatCard(
                icon: Icons.handshake_rounded,
                label: 'إجمالي',
                value: '$total',
                color: theme.colorScheme.primary,
              ),
              StatCard(
                icon: Icons.check_circle_rounded,
                label: 'نشطة',
                value: '$active',
                color: Colors.green,
              ),
              StatCard(
                icon: Icons.pause_circle_rounded,
                label: 'موقوفة',
                value: '$paused',
                color: Colors.orange,
              ),
              StatCard(
                icon: Icons.cancel_rounded,
                label: 'منتهية',
                value: '$ended',
                color: theme.colorScheme.error,
              ),
            ],
          ),

          // Financial Summary (if available)
          if (totalAmount != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        color: theme.colorScheme.tertiary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'إجمالي المبالغ الشهرية',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${totalAmount!.toStringAsFixed(0)} ${currency ?? "IQD"}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'نسبة النشطة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '$activePercentage%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: activePercentage / 100,
                          minHeight: 8.h,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
