import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/dashboard_providers.dart';

/// Dashboard Summary Widget - عرض ملخص سريع لأهم الإحصائيات
/// Enhanced version with real-time data from database
class DashboardSummaryWidget extends ConsumerWidget {
  final String contextLabel;
  final VoidCallback? onSyncNow;

  const DashboardSummaryWidget({
    required this.contextLabel,
    this.onSyncNow,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final isCompact = MediaQuery.sizeOf(context).width < 380;

    return summaryAsync.when(
      data: (stats) => Card(
        // Phase 5: reduced elevation for a lighter, more premium feel
        elevation: 1,
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
                    size: isCompact ? 21.sp : 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'لوحة المعلومات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 17.sp : null,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      contextLabel,
                      style: TextStyle(fontSize: isCompact ? 9.sp : 10.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.assessment, size: isCompact ? 18.sp : 20.sp, color: Colors.grey),
                ],
              ),
              SizedBox(height: 16.h),
              // أهم الإحصائيات في Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: isCompact ? 10.h : 12.h,
                crossAxisSpacing: isCompact ? 10.w : 12.w,
                // Phase 5: increased aspect ratio slightly for shorter, less dominating cards
                childAspectRatio: isCompact ? 2.5 : 2.7,
                children: [
                  _QuickStatCard(
                    icon: Icons.people,
                    label: 'إجمالي المستفيدين',
                    value: '${stats.total}',
                    color: Colors.blue,
                    deltaLabel: stats.total > 0 ? '+${(stats.syncPercentage / 10).toStringAsFixed(1)}%' : '0%',
                    isCompact: isCompact,
                  ),
                  _QuickStatCard(
                    icon: Icons.child_care,
                    label: 'أيتام',
                    value: '${stats.orphans}',
                    color: Colors.orange,
                    deltaLabel: stats.total > 0 ? '${((stats.orphans / stats.total) * 100).toStringAsFixed(1)}%' : '0%',
                    isCompact: isCompact,
                  ),
                  _QuickStatCard(
                    icon: Icons.attach_money,
                    label: 'فقراء',
                    value: '${stats.poor}',
                    color: Colors.green,
                    deltaLabel: stats.total > 0 ? '${((stats.poor / stats.total) * 100).toStringAsFixed(1)}%' : '0%',
                    isCompact: isCompact,
                  ),
                  _QuickStatCard(
                    icon: Icons.pending,
                    label: 'بانتظار المزامنة',
                    value: '${stats.pending}',
                    color: stats.pending > 0 ? Colors.red : Colors.grey,
                    urgent: stats.pending > 0,
                    deltaLabel: stats.pending == 0 ? 'ممتاز' : '${stats.pending} عنصر',
                    isCompact: isCompact,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // شريط التقدم للمزامنة
              _SyncProgressBar(
                synced: stats.synced,
                total: stats.total,
                percentage: stats.syncPercentage,
                onSyncNow: onSyncNow,
                isCompact: isCompact,
              ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        // Phase 5: consistent reduced elevation
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          height: 200.h,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 24.w, height: 24.w, color: Colors.grey.shade300),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(height: 14.h, color: Colors.grey.shade300),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      4,
                      (_) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text('خطأ: ${error.toString()}'),
        ),
      ),
    );
  }
}

/// Quick Stat Card - بطاقة إحصائية سريعة
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool urgent;
  final String? deltaLabel;
  final bool isCompact;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.urgent = false,
    this.deltaLabel,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Use ScreenUtil instead of MediaQuery for better performance
    final isTablet = 1.sw > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 12.r : (isCompact ? 8.r : 10.r)),
      decoration: BoxDecoration(
        color: urgent ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: urgent ? Border.all(color: color, width: 2) : Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 7.r : 8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: isTablet ? 22.sp : (isCompact ? 18.sp : 20.sp)),
          ),
          SizedBox(width: isCompact ? 8.w : 10.w),
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
                        fontSize: isTablet ? 10.sp : (isCompact ? 8.sp : 9.sp),
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
                            fontSize: isTablet ? 20.sp : (isCompact ? 16.sp : 18.sp),
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (deltaLabel != null) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          deltaLabel!,
                          style: TextStyle(
                            fontSize: isCompact ? 7.sp : 8.sp,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
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

/// Sync Progress Bar - شريط تقدم المزامنة
class _SyncProgressBar extends StatelessWidget {
  final int synced;
  final int total;
  final double percentage;
  final VoidCallback? onSyncNow;
  final bool isCompact;

  const _SyncProgressBar({
    required this.synced,
    required this.total,
    required this.percentage,
    this.onSyncNow,
    this.isCompact = false,
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
                      fontSize: isCompact ? 11.sp : 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
              Text(
                '$synced / $total',
                style: TextStyle(
                  fontSize: isCompact ? 11.sp : 12.sp,
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
            style: TextStyle(fontSize: isCompact ? 9.sp : 10.sp, color: Colors.grey[600]),
          ),
          if (onSyncNow != null && percentage < 100) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSyncNow,
                style: TextButton.styleFrom(
                  minimumSize: Size(44.w, 34.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  foregroundColor: Colors.teal,
                  backgroundColor: Colors.teal.withOpacity(0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: Icon(Icons.sync_rounded, size: isCompact ? 16.sp : 18.sp),
                label: Text(
                  'مزامنة الآن',
                  style: TextStyle(fontSize: isCompact ? 11.sp : 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
