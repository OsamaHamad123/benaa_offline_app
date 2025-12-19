import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/monitoring/performance_monitor.dart';
import '../../../../core/error/error_tracker.dart';
import '../../../../core/analytics/app_analytics.dart';

/// 📊 Monitoring Dashboard - Admin view للمراقبة الشاملة
class MonitoringDashboard extends ConsumerWidget {
  const MonitoringDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoring = ref.watch(appMonitoringProvider);
    final stats = ref.watch(monitoringStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Monitoring Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(monitoringStatsProvider),
            tooltip: 'Refresh Stats',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              monitoring.clearAll();
              ref.invalidate(monitoringStatsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Monitoring data cleared')),
              );
            },
            tooltip: 'Clear All Data',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(context, monitoring),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            _StatsCardsSection(stats: stats),
            SizedBox(height: 24.h),

            // Performance Section
            _PerformanceSection(),
            SizedBox(height: 24.h),

            // Errors Section
            _ErrorsSection(),
            SizedBox(height: 24.h),

            // Screen Analytics Section
            _ScreenAnalyticsSection(),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, AppMonitoring monitoring) {
    final report = monitoring.generateComprehensiveReport();

    // في Production: حفظ في ملف أو مشاركة
    // هنا نعرض في Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📄 Comprehensive Report'),
        content: SingleChildScrollView(
          child: SelectableText(
            report,
            style: TextStyle(fontFamily: 'monospace', fontSize: 12.sp),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Cards الإحصائيات
class _StatsCardsSection extends StatelessWidget {
  final MonitoringStats stats;

  const _StatsCardsSection({required this.stats});

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 4; // Desktop
    if (width > 800) return 2; // Tablet
    return 1; // Mobile
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 1.5; // Desktop - more square
    if (width > 800) return 2.2; // Tablet
    return 2.5; // Mobile - wider
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: _getChildAspectRatio(context),
          children: [
            _StatCard(
              icon: Icons.visibility,
              label: 'Screen Visits',
              value: '${stats.totalScreenVisits}',
              subtitle: '${stats.uniqueScreens} unique',
              color: Colors.blue,
            ),
            _StatCard(
              icon: Icons.speed,
              label: 'Operations',
              value: '${stats.totalOperations}',
              subtitle: stats.slowestOperation != null
                  ? 'Slowest: ${stats.slowestOperation!.value.average.inMilliseconds}ms'
                  : 'N/A',
              color: Colors.purple,
            ),
            _StatCard(
              icon: Icons.error_outline,
              label: 'Errors',
              value: '${stats.totalErrors}',
              subtitle: '${stats.criticalErrors} critical',
              color: stats.criticalErrors > 0 ? Colors.red : Colors.orange,
            ),
            _StatCard(
              icon: Icons.warning_amber,
              label: 'Performance Alerts',
              value: '${stats.performanceAlerts}',
              subtitle: 'Slow operations',
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.w : 16.w,
          vertical: isSmallScreen ? 12.h : 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 18.sp : 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11.sp : 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 20.sp : 28.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isSmallScreen ? 9.sp : 11.sp,
                color: Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Performance Section
class _PerformanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final slowOps = PerformanceMonitor.getSlowOperations(limit: 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚡ Slowest Operations',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (slowOps.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No operations recorded yet')),
            ),
          )
        else
          ...slowOps.map((entry) {
            final metric = entry.value;
            final isSmallScreen = MediaQuery.sizeOf(context).width < 600;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.w : 16.w,
                  vertical: isSmallScreen ? 4.h : 8.h,
                ),
                leading: CircleAvatar(
                  backgroundColor: _getColorForDuration(metric.average),
                  radius: isSmallScreen ? 18.r : 22.r,
                  child: FittedBox(
                    child: Text(
                      '${metric.average.inMilliseconds}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9.sp : 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Min: ${metric.min.inMilliseconds}ms • '
                    'Max: ${metric.max.inMilliseconds}ms • '
                    'Count: ${metric.count}',
                    style: TextStyle(fontSize: isSmallScreen ? 10.sp : 11.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: metric.errorCount > 0
                    ? Chip(
                        label: Text(
                          '${metric.errorCount}',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        backgroundColor: Colors.red[100],
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }

  Color _getColorForDuration(Duration duration) {
    if (duration.inMilliseconds < 100) return Colors.green;
    if (duration.inMilliseconds < 300) return Colors.orange;
    return Colors.red;
  }
}

/// Errors Section
class _ErrorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final errors = ErrorTracker.getAllErrors();
    final recentErrors = errors.reversed.take(10).toList();
    final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🐛 Recent Errors',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (recentErrors.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  'No errors recorded 🎉',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...recentErrors.map((error) {
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              color: error.severity == ErrorSeverity.critical
                  ? Colors.red[50]
                  : error.severity == ErrorSeverity.error
                      ? Colors.orange[50]
                      : null,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.w : 16.w,
                  vertical: isSmallScreen ? 8.h : 12.h,
                ),
                leading: Text(
                  error.severity.emoji,
                  style: TextStyle(fontSize: isSmallScreen ? 20.sp : 24.sp),
                ),
                title: Text(
                  error.context ?? 'Unknown Context',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      '${error.error}',
                      style: TextStyle(fontSize: isSmallScreen ? 10.sp : 11.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      error.timestamp.toString().substring(0, 19),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9.sp : 10.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: error.severity == ErrorSeverity.critical
                        ? Colors.red[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    error.severity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 8.sp : 9.sp,
                      fontWeight: FontWeight.bold,
                      color: error.severity == ErrorSeverity.critical
                          ? Colors.red[900]
                          : Colors.orange[900],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// Screen Analytics Section
class _ScreenAnalyticsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenStats = AppAnalytics.getScreenStats();
    final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📱 Screen Analytics',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (screenStats.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  'No screen visits recorded',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...screenStats.entries.map((entry) {
            final stat = entry.value;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.w : 16.w,
                  vertical: isSmallScreen ? 8.h : 12.h,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: isSmallScreen ? 18.r : 22.r,
                  child: FittedBox(
                    child: Text(
                      '${stat.visits}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10.sp : 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Avg: ${stat.averageDuration.inSeconds}s • Total: ${stat.totalDuration.inMinutes}m',
                    style: TextStyle(fontSize: isSmallScreen ? 10.sp : 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: isSmallScreen ? 20.sp : 24.sp,
                  color: Colors.grey,
                ),
              ),
            );
          }),
      ],
    );
  }
}
