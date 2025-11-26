import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/export/export_models.dart';
import '../../../core/services/export/export_providers.dart';
import '../../../core/constants/category_colors.dart';
import '../providers/reports_providers.dart';
import '../domain/entities/report_data.dart';
import '../helpers/percentage_helper.dart';
import 'category_pie_chart.dart';
import 'chart_section.dart';
import 'export_buttons.dart';
import 'report_modal_sheet.dart';
import 'detail_list_item.dart';

/// Category Report Widget - تقرير حسب الفئة
class CategoryReportSheet extends ConsumerStatefulWidget {
  const CategoryReportSheet({super.key});

  @override
  ConsumerState<CategoryReportSheet> createState() =>
      _CategoryReportSheetState();
}

class _CategoryReportSheetState extends ConsumerState<CategoryReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<CategoryCount> data) async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfExportServiceProvider);
      final total = data.fold(0, (sum, item) => sum + item.count);

      final exportData = ReportExportData(
        title: 'تقرير حسب الفئة',
        tables: [
          ExportTable(
            headers: ['الفئة', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.category,
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

  Future<void> _exportToExcel(List<CategoryCount> data) async {
    setState(() => _isExporting = true);
    try {
      final excelService = ref.read(excelExportServiceProvider);
      final total = data.fold(0, (sum, item) => sum + item.count);

      final exportData = ReportExportData(
        title: 'تقرير حسب الفئة',
        tables: [
          ExportTable(
            headers: ['الفئة', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.category,
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
                    ChartSection(
                      title: 'التوزيع حسب الفئة',
                      chart: CategoryPieChart(
                        data: categoryCounts,
                        total: total,
                      ),
                    ),
                    SizedBox(height: 12.h),
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
                        progressValue: 0.0,
                        indicatorColor: color,
                      );
                    }),
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
