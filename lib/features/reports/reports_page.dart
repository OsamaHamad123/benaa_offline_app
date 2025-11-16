import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widgets/common_widgets.dart';
import 'providers/reports_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات')),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Summary Statistics
          const _SummaryStatistics(),
          SizedBox(height: 24.h),

          // Report Categories
          Text(
            'تقارير مفصلة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          _ReportCard(
            title: 'تقرير حسب المحافظة',
            description: 'توزيع المستفيدين على المحافظات',
            icon: Icons.location_on,
            color: Colors.blue,
            onTap: () => _showGovernorateReport(context),
          ),
          _ReportCard(
            title: 'تقرير حسب الفئة',
            description: 'توزيع المستفيدين حسب الفئات',
            icon: Icons.category,
            color: Colors.green,
            onTap: () => _showCategoryReport(context),
          ),
          _ReportCard(
            title: 'تقرير حسب الجنس',
            description: 'توزيع المستفيدين حسب الجنس',
            icon: Icons.wc,
            color: Colors.purple,
            onTap: () => _showGenderReport(context),
          ),
          _ReportCard(
            title: 'تقرير الأعمار',
            description: 'توزيع المستفيدين حسب الفئات العمرية',
            icon: Icons.cake,
            color: Colors.orange,
            onTap: () => _showAgeReport(context),
          ),
          _ReportCard(
            title: 'تقرير المزامنة',
            description: 'حالة مزامنة البيانات',
            icon: Icons.sync,
            color: Colors.teal,
            onTap: () => _showSyncReport(context),
          ),
        ],
      ),
    );
  }

  void _showGovernorateReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _GovernorateReportSheet(),
    );
  }

  void _showCategoryReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CategoryReportSheet(),
    );
  }

  void _showGenderReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _GenderReportSheet(),
    );
  }

  void _showAgeReport(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تقرير الأعمار قيد التطوير')));
  }

  void _showSyncReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _SyncReportSheet(),
    );
  }
}

class _SummaryStatistics extends ConsumerWidget {
  const _SummaryStatistics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(summaryStatisticsProvider);

    return statsAsync.when(
      data: (stats) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ملخص الإحصائيات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _StatRow(label: 'إجمالي المستفيدين', value: '${stats['total']}'),
              const SizedBox(height: 12),
              _StatRow(label: 'الأيتام', value: '${stats['orphans']}'),
              const SizedBox(height: 12),
              _StatRow(label: 'الفقراء', value: '${stats['poor']}'),
              const SizedBox(height: 12),
              _StatRow(
                label: 'بانتظار المزامنة',
                value: '${stats['pending']}',
                valueColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text('خطأ: $error')),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _GovernorateReportSheet extends ConsumerWidget {
  const _GovernorateReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تقرير حسب المحافظة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportAsync = ref.watch(governorateReportProvider);
                    final total =
                        ref.watch(summaryStatisticsProvider).value?['total'] ??
                        0;

                    return reportAsync.when(
                      data: (governorateCounts) {
                        final sortedEntries = governorateCounts.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: sortedEntries.length,
                          itemBuilder: (context, index) {
                            final entry = sortedEntries[index];
                            final percentage = total == 0
                                ? 0.0
                                : (entry.value / total) * 100;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('خطأ: $error')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryReportSheet extends ConsumerWidget {
  const _CategoryReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تقرير حسب الفئة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportAsync = ref.watch(categoryReportProvider);

                    return reportAsync.when(
                      data: (categoryCounts) {
                        final categories = categoryCounts.entries.map((e) {
                          final color = switch (e.key) {
                            'أيتام' => Colors.purple,
                            'فقراء' => Colors.green,
                            'أرامل' => Colors.orange,
                            'معاقين' => Colors.blue,
                            _ => Colors.grey,
                          };
                          return {
                            'name': e.key,
                            'count': e.value,
                            'color': color,
                          };
                        }).toList();

                        final total = categoryCounts.values.fold(
                          0,
                          (sum, count) => sum + count,
                        );

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final count = category['count'] as int;
                            final percentage = total == 0
                                ? 0.0
                                : (count / total) * 100;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: category['color'] as Color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['name'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '$count (${percentage.toStringAsFixed(1)}%)',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('خطأ: $error')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GenderReportSheet extends ConsumerWidget {
  const _GenderReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'تقرير حسب الجنس',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportAsync = ref.watch(genderReportProvider);
                    final totalAsync = ref.watch(summaryStatisticsProvider);

                    return reportAsync.when(
                      data: (genderCounts) {
                        final total = totalAsync.value?['total'] ?? 0;
                        final males = genderCounts['ذكور'] ?? 0;
                        final females = genderCounts['إناث'] ?? 0;

                        return Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: Colors.blue[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.male,
                                              size: 48,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'ذكور',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$males',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Text(
                                              total == 0
                                                  ? '0%'
                                                  : '${((males / total) * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Card(
                                      color: Colors.pink[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.female,
                                              size: 48,
                                              color: Colors.pink,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'إناث',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$females',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.pink,
                                              ),
                                            ),
                                            Text(
                                              total == 0
                                                  ? '0%'
                                                  : '${((females / total) * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('خطأ: $error')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SyncReportSheet extends ConsumerWidget {
  const _SyncReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تقرير المزامنة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportAsync = ref.watch(syncStatusReportProvider);

                    return reportAsync.when(
                      data: (syncCounts) {
                        final synced = syncCounts['تمت المزامنة'] ?? 0;
                        final pending = syncCounts['بانتظار المزامنة'] ?? 0;
                        final failed = syncCounts['فشلت المزامنة'] ?? 0;

                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            InfoCard(
                              icon: Icons.check_circle,
                              title: 'تمت المزامنة',
                              value: synced.toString(),
                              color: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            InfoCard(
                              icon: Icons.sync,
                              title: 'بانتظار المزامنة',
                              value: pending.toString(),
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            InfoCard(
                              icon: Icons.error,
                              title: 'فشلت المزامنة',
                              value: failed.toString(),
                              color: Colors.red,
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('خطأ: $error')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
