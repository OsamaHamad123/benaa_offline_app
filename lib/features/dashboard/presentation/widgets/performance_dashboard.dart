import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/performance/performance_suite.dart';
import '../../../../core/performance/widget_performance_analyzer.dart';
import '../../../../core/performance/state_optimizer.dart';
import '../../../../core/database/query_optimizer.dart';

/// 🚀 Performance Dashboard - واجهة شاملة للأداء
class PerformanceDashboard extends ConsumerStatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  ConsumerState<PerformanceDashboard> createState() =>
      _PerformanceDashboardState();
}

class _PerformanceDashboardState extends ConsumerState<PerformanceDashboard> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePerformanceSuite();
  }

  Future<void> _initializePerformanceSuite() async {
    try {
      // تهيئة آمنة مع تأخير
      await Future.delayed(const Duration(milliseconds: 100));
      PerformanceSuite().initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('🚀 Performance Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Error initializing performance suite',
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                _error!,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitialized = false;
                  });
                  _initializePerformanceSuite();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('🚀 Performance Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final summary = ref.watch(performanceSummaryProvider);
    final recommendations = ref.watch(performanceRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(performanceSummaryProvider);
              ref.invalidate(performanceRecommendationsProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              ref.read(performanceSuiteProvider).clearAll();
              ref.invalidate(performanceSummaryProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Performance data cleared')),
              );
            },
            tooltip: 'Clear All',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(context, ref),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Grade Card
            _GradeCard(summary: summary),
            SizedBox(height: 20.h),

            // Quick Stats
            _QuickStatsSection(summary: summary),
            SizedBox(height: 24.h),

            // Recommendations
            if (recommendations.isNotEmpty) ...[
              _RecommendationsSection(recommendations: recommendations),
              SizedBox(height: 24.h),
            ],

            // Detailed Metrics Tabs
            _DetailedMetricsTabs(),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, WidgetRef ref) {
    final suite = ref.read(performanceSuiteProvider);
    final report = suite.generateComprehensiveReport();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📄 Performance Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              report,
              style: TextStyle(fontFamily: 'monospace', fontSize: 11.sp),
            ),
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

/// بطاقة التقييم العام
class _GradeCard extends StatelessWidget {
  final PerformanceSummary summary;

  const _GradeCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final grade = summary.overallGrade;
    final color = _getGradeColor(grade);

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Icon(_getGradeIcon(grade), size: 60.sp, color: color),
            SizedBox(height: 12.h),
            Text(
              'Overall Performance',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 4.h),
            Text(
              grade.name.toUpperCase(),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(PerformanceGrade grade) {
    switch (grade) {
      case PerformanceGrade.excellent:
        return Colors.green;
      case PerformanceGrade.good:
        return Colors.blue;
      case PerformanceGrade.fair:
        return Colors.orange;
      case PerformanceGrade.poor:
        return Colors.red;
    }
  }

  IconData _getGradeIcon(PerformanceGrade grade) {
    switch (grade) {
      case PerformanceGrade.excellent:
        return Icons.emoji_events;
      case PerformanceGrade.good:
        return Icons.thumb_up;
      case PerformanceGrade.fair:
        return Icons.warning_amber;
      case PerformanceGrade.poor:
        return Icons.error_outline;
    }
  }
}

/// قسم الإحصائيات السريعة
class _QuickStatsSection extends StatelessWidget {
  final PerformanceSummary summary;

  const _QuickStatsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isSmall ? 2 : 4,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: isSmall ? 1.2 : 1.5,
          children: [
            _MetricCard(
              icon: Icons.speed,
              label: 'FPS',
              value: summary.averageFPS.toStringAsFixed(1),
              color: summary.averageFPS >= 55 ? Colors.green : Colors.orange,
            ),
            _MetricCard(
              icon: Icons.widgets,
              label: 'Widgets',
              value: '${summary.totalWidgetsTracked}',
              color: Colors.blue,
            ),
            _MetricCard(
              icon: Icons.storage,
              label: 'Cache Hit',
              value: '${summary.cacheHitRate.toStringAsFixed(0)}%',
              color: Colors.purple,
            ),
            _MetricCard(
              icon: Icons.warning_amber,
              label: 'State Waste',
              value: '${summary.stateWasteRate.toStringAsFixed(0)}%',
              color: summary.stateWasteRate < 10 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}

/// بطاقة Metric
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// قسم التوصيات
class _RecommendationsSection extends StatelessWidget {
  final List<PerformanceRecommendation> recommendations;

  const _RecommendationsSection({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Recommendations',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...recommendations.map(
          (rec) => _RecommendationCard(recommendation: rec),
        ),
      ],
    );
  }
}

/// بطاقة توصية
class _RecommendationCard extends StatelessWidget {
  final PerformanceRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(recommendation.severity);

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeverityIcon(recommendation.severity),
                  color: color,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    recommendation.category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(recommendation.message, style: TextStyle(fontSize: 12.sp)),
            SizedBox(height: 4.h),
            Text(
              '💡 ${recommendation.suggestion}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(RecommendationSeverity severity) {
    switch (severity) {
      case RecommendationSeverity.high:
        return Colors.red;
      case RecommendationSeverity.medium:
        return Colors.orange;
      case RecommendationSeverity.low:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon(RecommendationSeverity severity) {
    switch (severity) {
      case RecommendationSeverity.high:
        return Icons.error;
      case RecommendationSeverity.medium:
        return Icons.warning;
      case RecommendationSeverity.low:
        return Icons.info;
    }
  }
}

/// Tabs للـ Metrics التفصيلية
class _DetailedMetricsTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Widgets'),
              Tab(text: 'States'),
              Tab(text: 'Queries'),
            ],
          ),
          SizedBox(
            height: 400.h,
            child: TabBarView(
              children: [
                _WidgetMetricsTab(),
                _StateMetricsTab(),
                _QueryMetricsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab الـ Widget Metrics
class _WidgetMetricsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = WidgetPerformanceAnalyzer.getMostRebuiltWidgets(limit: 20);

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final entry = widgets[index];
        final metrics = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  metrics.isPerformant ? Colors.green : Colors.orange,
              child: Text(
                '${metrics.buildCount}',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
            title: Text(entry.key, style: TextStyle(fontSize: 12.sp)),
            subtitle: Text(
              'Avg: ${metrics.averageBuildDuration?.inMilliseconds ?? 0}ms',
              style: TextStyle(fontSize: 10.sp),
            ),
          ),
        );
      },
    );
  }
}

/// Tab الـ State Metrics
class _StateMetricsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final states = StateOptimizer.getMostUpdatedStates(limit: 20);

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: states.length,
      itemBuilder: (context, index) {
        final entry = states[index];
        final metrics = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  metrics.wasteRate < 10 ? Colors.green : Colors.red,
              child: Text(
                '${metrics.updateCount}',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
            title: Text(entry.key, style: TextStyle(fontSize: 12.sp)),
            subtitle: Text(
              'Waste: ${metrics.wasteRate.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 10.sp),
            ),
          ),
        );
      },
    );
  }
}

/// Tab الـ Query Metrics
class _QueryMetricsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final queries = QueryOptimizer.getSlowestQueries(limit: 20);

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        final entry = queries[index];
        final stats = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: stats.averageDuration.inMilliseconds < 50
                  ? Colors.green
                  : Colors.orange,
              child: Text(
                '${stats.averageDuration.inMilliseconds}',
                style: TextStyle(fontSize: 9.sp),
              ),
            ),
            title: Text(
              entry.key.replaceFirst('Query: ', ''),
              style: TextStyle(fontSize: 12.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Executions: ${stats.executionCount}',
              style: TextStyle(fontSize: 10.sp),
            ),
          ),
        );
      },
    );
  }
}
