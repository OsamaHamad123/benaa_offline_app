import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/export/export_models.dart';
import '../../../core/services/export/export_providers.dart';
import '../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/reports_providers.dart';
import '../domain/entities/report_data.dart';
import '../helpers/percentage_helper.dart';
import 'gender_donut_chart.dart';
import 'statistic_card.dart';
import 'export_buttons.dart';

/// Gender Report Widget - تقرير حسب الجنس
class GenderReportSheet extends ConsumerStatefulWidget {
  const GenderReportSheet({super.key});

  @override
  ConsumerState<GenderReportSheet> createState() => _GenderReportSheetState();
}

class _GenderReportSheetState extends ConsumerState<GenderReportSheet> {
  bool _isExporting = false;

  Future<void> _exportToPdf(List<GenderCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب الجنس',
        tables: [
          ExportTable(
            headers: ['الجنس', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.gender,
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

  Future<void> _exportToExcel(List<GenderCount> data, int total) async {
    setState(() => _isExporting = true);
    try {
      final excelService = ref.read(excelExportServiceProvider);

      final exportData = ReportExportData(
        title: 'تقرير حسب الجنس',
        tables: [
          ExportTable(
            headers: ['الجنس', 'العدد', 'النسبة المئوية'],
            rows: data.map((item) {
              final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
              return [
                item.gender,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final reportAsync = ref.watch(genderReportProvider);
    final totalAsync = ref.watch(summaryStatisticsProvider);

    return ResponsiveBottomSheet(
      title: 'تقرير حسب الجنس',
      icon: Icons.people,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (scrollController) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                width: 40.w,
                height: 4.h,
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
              SizedBox(height: 12.h),
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
                        Expanded(
                          flex: isTablet ? 2 : 3,
                          child: GenderDonutChart(
                            data: genderCounts,
                            total: total,
                          ),
                        ),
                        SizedBox(height: 8.h),
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
                        ExportButtons(
                          isLoading: _isExporting,
                          onPdfExport: () => _exportToPdf(genderCounts, total),
                          onExcelExport: () => _exportToExcel(genderCounts, total),
                          onPrint: () => _exportToPdf(genderCounts, total),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
