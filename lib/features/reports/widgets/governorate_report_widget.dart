import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/export/export_models.dart';
import '../../../core/services/export/export_providers.dart';
import '../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/reports_providers.dart';
import '../domain/entities/report_data.dart';
import '../helpers/percentage_helper.dart';
import 'governorate_bar_chart.dart';
import 'chart_section.dart';
import 'export_buttons.dart';
import 'report_search_field.dart';
import 'detail_list_item.dart';

/// Governorate Report Widget - تقرير حسب المنطقة
class GovernorateReportSheet extends ConsumerStatefulWidget {
  const GovernorateReportSheet({super.key});

  @override
  ConsumerState<GovernorateReportSheet> createState() => _GovernorateReportSheetState();
}

class _GovernorateReportSheetState extends ConsumerState<GovernorateReportSheet> {
  bool _isExporting = false;
  String _searchQuery = '';

  Future<void> _exportToPdf(List<GovernorateCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب المنطقة',
        tables: [
          ExportTable(
            headers: ['المنطقة', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.governorate,
                item.count.toString(),
                '${percentage.toStringAsFixed(1)}%',
              ];
            }).toList(),
          ),
        ],
        statistics: [
          ExportStatistic(label: 'إجمالي المستفيدين', value: total.toString()),
        ],
      );

      final result = await pdfService.exportToPdf(exportData);

      if (mounted && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير PDF بنجاح: ${result.fileName}'),
            action: SnackBarAction(
              label: 'فتح',
              onPressed: () => pdfService.openFile(result.filePath!),
            ),
          ),
        );
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
      final excelService = ref.read(excelExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب المنطقة',
        tables: [
          ExportTable(
            headers: ['المنطقة', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.governorate,
                item.count.toString(),
                '${percentage.toStringAsFixed(1)}%',
              ];
            }).toList(),
          ),
        ],
        statistics: [
          ExportStatistic(label: 'إجمالي المستفيدين', value: total.toString()),
        ],
      );

      final result = await excelService.exportToExcel(exportData);

      if (mounted && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير Excel بنجاح: ${result.fileName}'),
            action: SnackBarAction(
              label: 'فتح',
              onPressed: () => excelService.openFile(result.filePath!),
            ),
          ),
        );
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
    final reportAsync = ref.watch(governorateReportProvider);
    final total = ref.watch(summaryStatisticsProvider).value?.total ?? 0;

    return ResponsiveBottomSheet(
      title: 'تقرير حسب المنطقة',
      icon: Icons.location_city,
      builder: (scrollController) {
        return reportAsync.when(
          data: (governorateCounts) {
            final sortedCounts = List<GovernorateCount>.from(
              governorateCounts,
            )..sort((a, b) => b.count.compareTo(a.count));

            final filteredCounts = _searchQuery.isEmpty
                ? sortedCounts
                : sortedCounts
                    .where(
                      (item) => item.governorate.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                ReportSearchField(
                  hint: 'ابحث عن منطقة...',
                  onSearch: (query) {
                    setState(() => _searchQuery = query);
                  },
                ),
                const SizedBox(height: 16),
                ChartSection(
                  title: 'التوزيع حسب المنطقة',
                  chart: GovernorateBarChart(
                    data: sortedCounts.take(10).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ExportButtons(
                  isLoading: _isExporting,
                  onPdfExport: () => _exportToPdf(sortedCounts, total),
                  onExcelExport: () => _exportToExcel(sortedCounts, total),
                  onPrint: () => _exportToPdf(sortedCounts, total),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التفاصيل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        '${filteredCounts.length} نتيجة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (filteredCounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد نتائج',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredCounts.map((item) {
                    return DetailListItemWithProgress(
                      title: item.governorate,
                      subtitle: PercentageHelper.getCountWithPercentage(
                        item.count,
                        total,
                      ),
                      progressValue: PercentageHelper.calculatePercentage(
                            item.count,
                            total,
                          ) /
                          100,
                    );
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('خطأ: $error')),
        );
      },
    );
  }
}
