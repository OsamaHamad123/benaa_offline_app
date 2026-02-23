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
    required this.total, required this.active, required this.paused, required this.ended, super.key,
    this.totalAmount,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePercentage = total > 0 ? (active / total * 100).toInt() : 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, isMobile ? 4.h : 8.h, 16.w, 4.h),
      padding: EdgeInsets.all(isMobile ? 10.w : 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.4),
            theme.colorScheme.secondaryContainer.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12.r : 16.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                size: isMobile ? 18.sp : 24.sp,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'إحصائيات الكفالات',
                  style: (isMobile ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8.h : 12.h),

          // Stats Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: تحديد عدد الأعمدة حسب العرض
              final crossAxisCount = constraints.maxWidth < 600
                  ? 2 // Mobile: عمودين
                  : constraints.maxWidth < 900
                      ? 4 // Tablet: 4 أعمدة
                      : 4; // Desktop: 4 أعمدة

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: isMobile ? 4.w : 8.w,
                crossAxisSpacing: isMobile ? 4.w : 8.w,
                childAspectRatio: crossAxisCount == 2 ? 1.4 : 1.0,
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
              );
            },
          ),

          // Financial Summary (if available)
          if (totalAmount != null) ...[
            SizedBox(height: isMobile ? 10.h : 16.h),
            Container(
              padding: EdgeInsets.all(isMobile ? 10.w : 16.w),
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
                          valueColor: const AlwaysStoppedAnimation<Color>(
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
