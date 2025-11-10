import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../theme/app_colors.dart';

/// Pending Sync Alert Card
class PendingSyncAlert extends ConsumerWidget {
  const PendingSyncAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<int>(
      future: database.countPendingSync(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data!;

        return Card(
          elevation: 0,
          color: Colors.orange[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange[200]!, width: 1),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              'بيانات بحاجة للمزامنة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
            subtitle: Text(
              'لديك $count مستفيد بحاجة للمزامنة مع الخادم',
              style: TextStyle(color: Colors.orange[700]),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Trigger sync
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('مزامنة'),
            ),
          ),
        );
      },
    );
  }
}

/// Last Sync Status Card
class LastSyncStatus extends StatelessWidget {
  const LastSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get real sync data from provider
    final lastSyncTime = '3 ساعات';
    final syncedCount = 42;
    final isSuccess = true;

    return Card(
      elevation: 0,
      color: isSuccess ? Colors.green[50] : Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSuccess ? Colors.green[200]! : Colors.red[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isSuccess ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          isSuccess ? 'آخر مزامنة ناجحة' : 'فشلت آخر مزامنة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSuccess ? Colors.green[900] : Colors.red[900],
          ),
        ),
        subtitle: Text(
          'منذ $lastSyncTime - $syncedCount سجل',
          style: TextStyle(
            color: isSuccess ? Colors.green[700] : Colors.red[700],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isSuccess ? Colors.green[700] : Colors.red[700],
        ),
        onTap: () {
          // TODO: Navigate to sync details
        },
      ),
    );
  }
}

/// Data Quality Score Card
class DataQualityScore extends ConsumerWidget {
  const DataQualityScore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<int>(
      future: database.countBeneficiaries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final total = snapshot.data!;
        // TODO: حساب البيانات الناقصة من قاعدة البيانات
        final completeData = (total * 0.85).round();
        final score = (completeData / total * 100).round();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جودة البيانات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForScore(score),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$score%',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForScore(score),
                                ),
                          ),
                          Text(
                            _getStatusText(score),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$completeData من $total سجل مكتمل',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Show incomplete data
                  },
                  icon: const Icon(Icons.list_rounded),
                  label: const Text('عرض البيانات الناقصة'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.info),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getStatusText(int score) {
    if (score >= 90) return 'ممتاز';
    if (score >= 70) return 'جيد';
    return 'يحتاج تحسين';
  }
}

/// Connection Status Bar
class ConnectionStatusBar extends StatelessWidget {
  final bool isOnline;

  const ConnectionStatusBar({super.key, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green[50] : Colors.orange[50],
        border: Border(
          bottom: BorderSide(
            color: isOnline ? Colors.green[200]! : Colors.orange[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOnline
                  ? 'متصل بالإنترنت - المزامنة متاحة'
                  : 'وضع عدم الاتصال - البيانات محلية فقط',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isOnline ? Colors.green[900] : Colors.orange[900],
              ),
            ),
          ),
          if (!isOnline)
            Icon(Icons.cloud_off_rounded, size: 18, color: Colors.orange[700]),
        ],
      ),
    );
  }
}

/// Performance Metrics Card
class PerformanceMetricsCard extends StatelessWidget {
  const PerformanceMetricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get real data from activity logger
    final todayCount = 12;
    final avgDaily = 8.5;
    final monthCount = 245;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'كفاءة العمل',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'إضافات اليوم',
                    value: '$todayCount',
                    trend: '+20%',
                    trendUp: true,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'متوسط يومي',
                    value: '$avgDaily',
                    trend: 'مستقر',
                    trendUp: null,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'هذا الشهر',
                    value: '$monthCount',
                    trend: '+15%',
                    trendUp: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool? trendUp;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: trendUp == null
                ? Colors.grey[200]
                : trendUp!
                ? Colors.green[50]
                : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trendUp != null)
                Icon(
                  trendUp! ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: trendUp! ? Colors.green : Colors.red,
                ),
              const SizedBox(width: 2),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: trendUp == null
                      ? Colors.grey[600]
                      : trendUp!
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
