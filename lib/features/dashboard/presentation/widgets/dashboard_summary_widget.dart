import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/providers.dart';

/// Dashboard Summary Widget - عرض ملخص سريع لأهم الإحصائيات
/// Enhanced version with real-time data from database
class DashboardSummaryWidget extends ConsumerWidget {
  const DashboardSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        // Get counts
        final total = await db.beneficiariesDao.countBeneficiaries();
        final orphans = await db.beneficiariesDao.countBeneficiariesByCategory(
          1,
        );
        final poor = await db.beneficiariesDao.countBeneficiariesByCategory(3);
        final pending = await db.beneficiariesDao.countPendingSync();

        // Calculate sync percentage
        final synced = total - pending;
        final syncPercentage = total > 0 ? (synced / total * 100) : 0.0;

        return {
          'total': total,
          'orphans': orphans,
          'poor': poor,
          'pending': pending,
          'synced': synced,
          'syncPercentage': syncPercentage,
          'totalTrend': null,
        };
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              height: 200.h,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = snapshot.data!;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.assessment, size: 20.sp, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 16.h),
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
                      value: '${stats['total'] ?? 0}',
                      color: Colors.blue,
                      trend: stats['totalTrend'],
                    ),
                    _QuickStatCard(
                      icon: Icons.child_care,
                      label: 'أيتام',
                      value: '${stats['orphans'] ?? 0}',
                      color: Colors.orange,
                    ),
                    _QuickStatCard(
                      icon: Icons.attach_money,
                      label: 'فقراء',
                      value: '${stats['poor'] ?? 0}',
                      color: Colors.green,
                    ),
                    _QuickStatCard(
                      icon: Icons.pending,
                      label: 'بانتظار المزامنة',
                      value: '${stats['pending'] ?? 0}',
                      color: (stats['pending'] ?? 0) > 0
                          ? Colors.red
                          : Colors.grey,
                      urgent: (stats['pending'] ?? 0) > 0,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // شريط التقدم للمزامنة
                _SyncProgressBar(
                  synced: stats['synced'] ?? 0,
                  total: stats['total'] ?? 0,
                  percentage: stats['syncPercentage']?.toDouble() ?? 0.0,
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 12.r : 10.r),
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
            child: Icon(icon, color: color, size: isTablet ? 22.sp : 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isTablet ? 10.sp : 9.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                            fontSize: isTablet ? 20.sp : 18.sp,
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
              value: total > 0 ? percentage / 100 : 0,
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
