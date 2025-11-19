import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reports_providers.dart';

/// Dashboard Widget - عرض ملخص سريع لأهم الإحصائيات
class DashboardWidget extends ConsumerWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(summaryStatisticsProvider);
    final syncAsync = ref.watch(syncStatusReportProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'لوحة المعلومات',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
              ],
            ),
            SizedBox(height: 16.h),
            statsAsync.when(
              data: (stats) {
                return Column(
                  children: [
                    // أهم الإحصائيات في Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 2.5,
                      children: [
                        _QuickStatCard(
                          icon: Icons.people,
                          label: 'إجمالي المستفيدين',
                          value: '${stats.total}',
                          color: Colors.blue,
                          trend: _calculateTrend(stats.total, stats.total - 10),
                        ),
                        _QuickStatCard(
                          icon: Icons.child_care,
                          label: 'أيتام',
                          value: '${stats.orphans}',
                          color: Colors.orange,
                        ),
                        _QuickStatCard(
                          icon: Icons.attach_money,
                          label: 'فقراء',
                          value: '${stats.poor}',
                          color: Colors.green,
                        ),
                        _QuickStatCard(
                          icon: Icons.pending,
                          label: 'معلقين',
                          value: '${stats.pending}',
                          color: stats.pending > 0 ? Colors.red : Colors.grey,
                          urgent: stats.pending > 0,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // شريط التقدم للمزامنة
                    syncAsync.when(
                      data: (syncData) {
                        final synced = syncData
                            .firstWhere(
                              (s) => s.status == 'تمت المزامنة',
                              orElse: () => syncData.first,
                            )
                            .count;
                        final total = stats.total;
                        final percentage = total > 0
                            ? (synced / total * 100).toDouble()
                            : 0.0;

                        return _SyncProgressBar(
                          synced: synced,
                          total: total,
                          percentage: percentage,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                );
              },
              loading: () => SizedBox(
                height: 150.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: EdgeInsets.all(16.r),
                child: Text('خطأ في تحميل البيانات: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _calculateTrend(int current, int previous) {
    if (previous == 0) return null;
    return ((current - previous) / previous * 100);
  }
}

/// Quick Stat Card - بطاقة إحصائية سريعة
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double? trend;
  final bool urgent;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trend,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: urgent ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: urgent
            ? Border.all(color: color, width: 2)
            : Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (trend != null) ...[
                      SizedBox(width: 4.w),
                      _TrendIndicator(trend: trend!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trend Indicator - مؤشر الاتجاه
class _TrendIndicator extends StatelessWidget {
  final double trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isPositive = trend >= 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: isPositive ? Colors.green : Colors.red,
          size: 14.sp,
        ),
        Text(
          '${trend.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 10.sp,
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Sync Progress Bar - شريط تقدم المزامنة
class _SyncProgressBar extends StatelessWidget {
  final int synced;
  final int total;
  final double percentage;

  const _SyncProgressBar({
    required this.synced,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.withOpacity(0.1), Colors.teal.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sync, color: Colors.teal, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'حالة المزامنة',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
              Text(
                '$synced / $total',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8.h,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80
                    ? Colors.green
                    : percentage >= 50
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${percentage.toStringAsFixed(1)}% مكتمل',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
