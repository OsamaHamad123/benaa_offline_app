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
import 'widgets/summary_statistics_widget.dart';
import 'widgets/report_card_widget.dart';
import 'widgets/export_all_section.dart';
import 'widgets/date_filter_actions.dart';
import 'helpers/percentage_helper.dart';
import 'services/pdf_export_service.dart';
import 'services/excel_export_service.dart';
import '../../core/constants/report_styles.dart';
import '../../core/constants/category_colors.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with AutomaticKeepAliveClientMixin {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  bool get wantKeepAlive => true;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _refreshData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _refreshData();
  }

  void _refreshData() {
    ref.invalidate(summaryStatisticsProvider);
    ref.invalidate(genderReportProvider);
    ref.invalidate(categoryReportProvider);
    ref.invalidate(governorateReportProvider);
    ref.invalidate(ageReportProvider);
    ref.invalidate(syncStatusReportProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        actions: [
          DateFilterActions(
            startDate: _startDate,
            endDate: _endDate,
            onFilterTap: _selectDateRange,
            onClearFilter: _clearDateFilter,
            onRefresh: () {
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تحديث البيانات'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Summary Statistics
            const SummaryStatisticsWidget(),
            SizedBox(height: 24.h),

            // Report Categories
            Text(
              'تقارير مفصلة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            ReportCardWidget(
              title: 'تقرير حسب المحافظة',
              description: 'توزيع المستفيدين على المحافظات',
              icon: Icons.location_on,
              color: Colors.blue,
              gradient: ReportStyles.governorateGradient,
              onTap: () => _showGovernorateReport(context),
            ),
            ReportCardWidget(
              title: 'تقرير حسب الفئة',
              description: 'توزيع المستفيدين حسب الفئات',
              icon: Icons.category,
              color: Colors.green,
              gradient: ReportStyles.categoryGradient,
              onTap: () => _showCategoryReport(context),
            ),
            ReportCardWidget(
              title: 'تقرير حسب الجنس',
              description: 'توزيع المستفيدين حسب الجنس',
              icon: Icons.wc,
              color: Colors.purple,
              gradient: ReportStyles.genderGradient,
              onTap: () => _showGenderReport(context),
            ),
            ReportCardWidget(
              title: 'تقرير الأعمار',
              description: 'توزيع المستفيدين حسب الفئات العمرية',
              icon: Icons.cake,
              color: Colors.orange,
              gradient: ReportStyles.ageGradient,
              onTap: () => _showAgeReport(context),
            ),
            ReportCardWidget(
              title: 'تقرير المزامنة',
              description: 'حالة مزامنة البيانات',
              icon: Icons.sync,
              color: Colors.teal,
              gradient: ReportStyles.syncGradient,
              onTap: () => _showSyncReport(context),
            ),
            SizedBox(height: 24.h),

            // Export All Beneficiaries Section
            ExportAllSection(
              onExport: () => _exportAllBeneficiariesToExcel(context),
            ),
          ],
        ),
      ), // Close RefreshIndicator
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

  Future<void> _exportAllBeneficiariesToExcel(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تصدير البيانات...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get all beneficiaries from the repository
      final repository = ref.read(
        reportsRepositoryProvider,
      ); // Use the reports repository

      // Fetch ALL beneficiaries without pagination
      final beneficiaries = await repository.getAllBeneficiaries();

      if (!mounted) return;

      if (beneficiaries.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لا توجد بيانات للتصدير')));
        return;
      }

      // Export to Excel
      final filePath = await ExcelExportService.exportAllBeneficiaries(
        beneficiaries: beneficiaries,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Share the file
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'قائمة شاملة بجميع المستفيدين (${beneficiaries.length} مستفيد)');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير ${beneficiaries.length} مستفيد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _GovernorateReportSheet extends ConsumerStatefulWidget {
  const _GovernorateReportSheet();

  @override
  ConsumerState<_GovernorateReportSheet> createState() =>
      _GovernorateReportSheetState();
}

class _GovernorateReportSheetState
    extends ConsumerState<_GovernorateReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<GovernorateCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfExportService.exportGovernorateReport(
        data: data,
        total: total,
      );
      await PdfExportService.shareOrPrint(
        pdfBytes,
        'governorate_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
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

  Future<void> _exportToExcel(List<GovernorateCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExcelExportService.exportGovernorateReport(
        data: data,
        total: total,
      );
      await Share.shareXFiles([XFile(filePath)], text: 'تقرير حسب المحافظة');
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
              final sortedCounts = List<GovernorateCount>.from(
                governorateCounts,
              )..sort((a, b) => b.count.compareTo(a.count));

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
                  // Export Buttons
                  ExportButtons(
                    isLoading: _isExporting,
                    onPdfExport: () => _exportToPdf(sortedCounts, total),
                    onExcelExport: () => _exportToExcel(sortedCounts, total),
                    onPrint: () => _exportToPdf(sortedCounts, total),
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

class _CategoryReportSheet extends ConsumerStatefulWidget {
  const _CategoryReportSheet();

  @override
  ConsumerState<_CategoryReportSheet> createState() =>
      _CategoryReportSheetState();
}

class _CategoryReportSheetState extends ConsumerState<_CategoryReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<CategoryCount> data) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfExportService.exportCategoryReport(data: data);
      await PdfExportService.shareOrPrint(
        pdfBytes,
        'category_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
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

  Future<void> _exportToExcel(List<CategoryCount> data) async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExcelExportService.exportCategoryReport(
        data: data,
      );
      await Share.shareXFiles([XFile(filePath)], text: 'تقرير حسب الفئة');
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
                    // Export Buttons
                    ExportButtons(
                      isLoading: _isExporting,
                      onPdfExport: () => _exportToPdf(categoryCounts),
                      onExcelExport: () => _exportToExcel(categoryCounts),
                      onPrint: () => _exportToPdf(categoryCounts),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
                        // Donut Chart - smaller on mobile
                        Expanded(
                          flex: isTablet ? 2 : 3,
                          child: GenderDonutChart(
                            data: genderCounts,
                            total: total,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Statistics Cards
                        Expanded(
                          flex: isTablet ? 1 : 2,
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

class _SyncReportSheet extends ConsumerStatefulWidget {
  const _SyncReportSheet();

  @override
  ConsumerState<_SyncReportSheet> createState() => _SyncReportSheetState();
}

class _SyncReportSheetState extends ConsumerState<_SyncReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<SyncStatusCount> data) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfExportService.exportSyncStatusReport(
        data: data,
      );
      await PdfExportService.shareOrPrint(
        pdfBytes,
        'sync_status_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
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

  Future<void> _exportToExcel(List<SyncStatusCount> data) async {
    setState(() => _isExporting = true);
    try {
      await ExcelExportService.exportSyncStatusReport(data: data);
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
                            // Export Buttons
                            ExportButtons(
                              isLoading: _isExporting,
                              onPdfExport: () => _exportToPdf(syncCounts),
                              onExcelExport: () => _exportToExcel(syncCounts),
                              onPrint: () => _exportToPdf(syncCounts),
                            ),
                            const SizedBox(height: 16),
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

class _AgeReportSheet extends ConsumerStatefulWidget {
  const _AgeReportSheet();

  @override
  ConsumerState<_AgeReportSheet> createState() => _AgeReportSheetState();
}

class _AgeReportSheetState extends ConsumerState<_AgeReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<AgeCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfExportService.exportAgeReport(
        data: data,
        total: total,
      );
      await PdfExportService.shareOrPrint(
        pdfBytes,
        'age_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
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

  Future<void> _exportToExcel(List<AgeCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      await ExcelExportService.exportAgeReport(data: data, total: total);
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
                  // Export Buttons
                  ExportButtons(
                    isLoading: _isExporting,
                    onPdfExport: () => _exportToPdf(ageCounts, total),
                    onExcelExport: () => _exportToExcel(ageCounts, total),
                    onPrint: () => _exportToPdf(ageCounts, total),
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
