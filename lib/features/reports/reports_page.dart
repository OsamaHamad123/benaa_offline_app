import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/common_widgets.dart';
import 'providers/reports_providers.dart';
import 'domain/entities/report_data.dart';
import 'widgets/governorate_bar_chart.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/gender_donut_chart.dart';
import 'widgets/age_bar_chart.dart';
import 'widgets/report_modal_sheet.dart';
import 'widgets/statistic_card.dart';
import 'widgets/detail_list_item.dart';
import 'widgets/chart_section.dart';
import 'widgets/export_buttons.dart';
import 'helpers/percentage_helper.dart';
import 'services/pdf_export_service.dart';
import 'services/excel_export_service.dart';
import '../../core/constants/report_styles.dart';
import '../../core/constants/category_colors.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/shimmer_loading.dart';

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
            gradient: ReportStyles.governorateGradient,
            onTap: () => _showGovernorateReport(context),
          ),
          _ReportCard(
            title: 'تقرير حسب الفئة',
            description: 'توزيع المستفيدين حسب الفئات',
            icon: Icons.category,
            color: Colors.green,
            gradient: ReportStyles.categoryGradient,
            onTap: () => _showCategoryReport(context),
          ),
          _ReportCard(
            title: 'تقرير حسب الجنس',
            description: 'توزيع المستفيدين حسب الجنس',
            icon: Icons.wc,
            color: Colors.purple,
            gradient: ReportStyles.genderGradient,
            onTap: () => _showGenderReport(context),
          ),
          _ReportCard(
            title: 'تقرير الأعمار',
            description: 'توزيع المستفيدين حسب الفئات العمرية',
            icon: Icons.cake,
            color: Colors.orange,
            gradient: ReportStyles.ageGradient,
            onTap: () => _showAgeReport(context),
          ),
          _ReportCard(
            title: 'تقرير المزامنة',
            description: 'حالة مزامنة البيانات',
            icon: Icons.sync,
            color: Colors.teal,
            gradient: ReportStyles.syncGradient,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AgeReportSheet(),
    );
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
              _StatRow(label: 'إجمالي المستفيدين', value: '${stats.total}'),
              const SizedBox(height: 12),
              _StatRow(label: 'الأيتام', value: '${stats.orphans}'),
              const SizedBox(height: 12),
              _StatRow(label: 'الفقراء', value: '${stats.poor}'),
              const SizedBox(height: 12),
              _StatRow(
                label: 'بانتظار المزامنة',
                value: '${stats.pending}',
                valueColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
      loading: () => const SkeletonCard(height: 200),
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
    // Extract numeric value from string
    final numericValue = int.tryParse(value) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        AnimatedCounter(
          value: numericValue,
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
  final LinearGradient? gradient;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ReportStyles.cardMargin),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: ReportStyles.cardBorderRadius,
        boxShadow: ReportStyles.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ReportStyles.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(ReportStyles.cardPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: ReportStyles.cardIconSize,
                  ),
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
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
        final reportAsync = ref.watch(governorateReportProvider);
        final total = ref.watch(summaryStatisticsProvider).value?.total ?? 0;

        return CompactReportModalSheet(
          title: 'تقرير حسب المحافظة',
          child: reportAsync.when(
            data: (governorateCounts) {
              final sortedCounts = List.from(governorateCounts)
                ..sort((a, b) => b.count.compareTo(a.count));

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Chart Section - Using reusable ChartSection widget
                  ChartSection(
                    title: 'التوزيع حسب المحافظة',
                    chart: GovernorateBarChart(
                      data: sortedCounts
                          .take(10)
                          .toList()
                          .cast<GovernorateCount>(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'التفاصيل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Detail List Items - Using reusable DetailListItemWithProgress widget
                  ...sortedCounts.map((item) {
                    return DetailListItemWithProgress(
                      title: item.governorate,
                      subtitle: PercentageHelper.getCountWithPercentage(
                        item.count,
                        total,
                      ),
                      progressValue:
                          PercentageHelper.calculatePercentage(
                            item.count,
                            total,
                          ) /
                          100,
                    );
                  }).toList(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('خطأ: $error')),
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
        final reportAsync = ref.watch(categoryReportProvider);

        return ReportModalSheet(
          title: 'تقرير حسب الفئة',
          scrollController: scrollController,
          children: [
            reportAsync.when(
              data: (categoryCounts) {
                final total = categoryCounts.fold(
                  0,
                  (sum, item) => sum + item.count,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chart Section - Using reusable ChartSection widget
                    ChartSection(
                      title: 'التوزيع حسب الفئة',
                      chart: CategoryPieChart(
                        data: categoryCounts,
                        total: total,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'التفاصيل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Detail List Items - Using reusable DetailListItem widget
                    ...categoryCounts.map((item) {
                      final color = CategoryColors.getColorByName(
                        item.category,
                      );

                      return DetailListItem(
                        title: item.category,
                        subtitle: PercentageHelper.getCountWithPercentage(
                          item.count,
                          total,
                        ),
                        progressValue: 0.0, // Not used in this layout
                        indicatorColor: color,
                      );
                    }).toList(),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('خطأ: $error')),
            ),
          ],
        );
      },
    );
  }
}

class _GenderReportSheet extends ConsumerStatefulWidget {
  const _GenderReportSheet();

  @override
  ConsumerState<_GenderReportSheet> createState() => _GenderReportSheetState();
}

class _GenderReportSheetState extends ConsumerState<_GenderReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<GenderCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfExportService.exportGenderReport(
        data: data,
        total: total,
      );
      await PdfExportService.shareOrPrint(
        pdfBytes,
        'gender_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تصدير PDF بنجاح')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تصدير PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportToExcel(List<GenderCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExcelExportService.exportGenderReport(
        data: data,
        total: total,
      );
      await Share.shareXFiles([XFile(filePath)], text: 'تقرير حسب الجنس');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تصدير Excel بنجاح')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تصدير Excel: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        final reportAsync = ref.watch(genderReportProvider);
        final totalAsync = ref.watch(summaryStatisticsProvider);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                'تقرير حسب الجنس',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              // Content
              Expanded(
                child: reportAsync.when(
                  data: (genderCounts) {
                    final total = totalAsync.value?.total ?? 0;
                    final males = genderCounts
                        .firstWhere(
                          (g) => g.gender == 'ذكور',
                          orElse: () => GenderCount(gender: 'ذكور', count: 0),
                        )
                        .count;
                    final females = genderCounts
                        .firstWhere(
                          (g) => g.gender == 'إناث',
                          orElse: () => GenderCount(gender: 'إناث', count: 0),
                        )
                        .count;

                    return Column(
                      children: [
                        // Donut Chart
                        Expanded(
                          flex: 2,
                          child: GenderDonutChart(
                            data: genderCounts,
                            total: total,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Statistics Cards
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: StatisticCard(
                                  icon: Icons.male,
                                  label: 'ذكور',
                                  count: '$males',
                                  percentage:
                                      PercentageHelper.getPercentageText(
                                        males,
                                        total,
                                      ),
                                  iconColor: Colors.blue,
                                  backgroundColor: Colors.blue[50],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: StatisticCard(
                                  icon: Icons.female,
                                  label: 'إناث',
                                  count: '$females',
                                  percentage:
                                      PercentageHelper.getPercentageText(
                                        females,
                                        total,
                                      ),
                                  iconColor: Colors.pink,
                                  backgroundColor: Colors.pink[50],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Export Buttons
                        ExportButtons(
                          isLoading: _isExporting,
                          onPdfExport: () => _exportToPdf(genderCounts, total),
                          onExcelExport: () =>
                              _exportToExcel(genderCounts, total),
                          onPrint: () => _exportToPdf(genderCounts, total),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('خطأ: $error')),
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
                        final synced = syncCounts
                            .firstWhere(
                              (s) => s.status == 'تمت المزامنة',
                              orElse: () => SyncStatusCount(
                                status: 'تمت المزامنة',
                                count: 0,
                              ),
                            )
                            .count;
                        final pending = syncCounts
                            .firstWhere(
                              (s) => s.status == 'بانتظار المزامنة',
                              orElse: () => SyncStatusCount(
                                status: 'بانتظار المزامنة',
                                count: 0,
                              ),
                            )
                            .count;
                        final failed = syncCounts
                            .firstWhere(
                              (s) => s.status == 'فشلت المزامنة',
                              orElse: () => SyncStatusCount(
                                status: 'فشلت المزامنة',
                                count: 0,
                              ),
                            )
                            .count;

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

class _AgeReportSheet extends ConsumerWidget {
  const _AgeReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        final reportAsync = ref.watch(ageReportProvider);
        final total = ref.watch(summaryStatisticsProvider).value?.total ?? 0;

        return CompactReportModalSheet(
          title: 'تقرير حسب الفئة العمرية',
          child: reportAsync.when(
            data: (ageCounts) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Chart Section - Using reusable ChartSection widget
                  ChartSection(
                    title: 'التوزيع حسب العمر',
                    chart: AgeBarChart(data: ageCounts),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'التفاصيل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Detail List Items - Using reusable DetailListItemWithProgress widget
                  ...ageCounts.map((item) {
                    final color = AgeBracketColors.getColor(item.ageBracket);

                    return DetailListItemWithProgress(
                      title: '${item.ageBracket} سنة',
                      subtitle: PercentageHelper.getCountWithPercentage(
                        item.count,
                        total,
                      ),
                      progressValue:
                          PercentageHelper.calculatePercentage(
                            item.count,
                            total,
                          ) /
                          100,
                      progressColor: color,
                      indicatorColor: color,
                    );
                  }).toList(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('خطأ: $error')),
          ),
        );
      },
    );
  }
}
