import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/export/export_models.dart';
import '../../../core/services/export/export_providers.dart';
import '../../../core/constants/category_colors.dart';
import '../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/reports_providers.dart';
import '../domain/entities/report_data.dart';
import '../helpers/percentage_helper.dart';
import 'age_bar_chart.dart';
import 'chart_section.dart';
import 'export_buttons.dart';
import 'detail_list_item.dart';

/// Age Report Widget - تقرير حسب الفئة العمرية
class AgeReportSheet extends ConsumerStatefulWidget {
  const AgeReportSheet({super.key});

  @override
  ConsumerState<AgeReportSheet> createState() => _AgeReportSheetState();
}

class _AgeReportSheetState extends ConsumerState<AgeReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<AgeCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب الفئة العمرية',
        tables: [
          ExportTable(
            headers: ['الفئة العمرية', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                '${item.ageBracket} سنة',
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

  Future<void> _exportToExcel(List<AgeCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final excelService = ref.read(excelExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب الفئة العمرية',
        tables: [
          ExportTable(
            headers: ['الفئة العمرية', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                '${item.ageBracket} سنة',
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
    final reportAsync = ref.watch(ageReportProvider);
    final total = ref.watch(summaryStatisticsProvider).value?.total ?? 0;

    return ResponsiveBottomSheet(
      title: 'تقرير حسب الفئة العمرية',
      icon: Icons.calendar_today,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (scrollController) {
        return reportAsync.when(
          data: (ageCounts) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              ChartSection(
                title: 'التوزيع حسب العمر',
                chart: AgeBarChart(data: ageCounts),
              ),
              const SizedBox(height: 16),
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
              ...ageCounts.map((item) {
                final color = AgeBracketColors.getColor(item.ageBracket);

                return DetailListItemWithProgress(
                  title: '${item.ageBracket} سنة',
                  subtitle: PercentageHelper.getCountWithPercentage(
                    item.count,
                    total,
                  ),
                  progressValue: PercentageHelper.calculatePercentage(
                        item.count,
                        total,
                      ) /
                      100,
                  progressColor: color,
                  indicatorColor: color,
                );
              }),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('خطأ: $error')),
        );
      },
    );
  }
}
