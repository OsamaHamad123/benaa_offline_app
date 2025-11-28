import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/widgets/enhanced_refresh_indicator.dart';
import 'providers/reports_providers.dart';
import 'widgets/summary_statistics_widget.dart';
import 'widgets/report_card_widget.dart';
import 'widgets/export_all_section.dart';
import 'widgets/date_filter_actions.dart';
import 'widgets/quick_date_filters.dart';
import 'widgets/governorate_report_widget.dart';
import 'widgets/category_report_widget.dart';
import 'widgets/gender_report_widget.dart';
import 'widgets/age_report_widget.dart';
import '../../core/constants/report_styles.dart';
import 'custom_reports_page.dart';
import '../../core/services/export/export_models.dart';
import '../../core/services/export/export_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with AutomaticKeepAliveClientMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExportingAll = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
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

  void _setQuickFilter(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
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
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomReportsPage(),
                ),
              );
            },
            tooltip: 'إنشاء تقرير مخصص',
          ),
          DateFilterActions(
            startDate: _startDate,
            endDate: _endDate,
            onFilterTap: _selectDateRange,
            onClearFilter: _clearDateFilter,
            onRefresh: () {
              _refreshData();
              context.showSuccess('تم تحديث البيانات');
            },
          ),
        ],
      ),
      body: EnhancedRefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Quick Date Filters
            QuickDateFilters(
              startDate: _startDate,
              endDate: _endDate,
              onFilterSelected: _setQuickFilter,
              onClearFilter: _clearDateFilter,
            ),
            SizedBox(height: 16.h),

            // Summary Statistics
            const SummaryStatisticsWidget(),
            SizedBox(height: 24.h),

            // Export All Reports Button
            _buildExportAllReportsSection(),
            SizedBox(height: 16.h),

            // Export Comprehensive Beneficiaries Report
            _buildComprehensiveExportSection(),
            SizedBox(height: 24.h),

            // Report Categories
            Text(
              'التقارير المفصلة',
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
            // 🆕 NEW: Comprehensive Beneficiaries Report
            ReportCardWidget(
              title: 'تقرير المستفيدين الشامل',
              description: 'عرض تفصيلي لجميع المستفيدين مع الفلاتر المتقدمة',
              icon: Icons.people,
              color: Colors.indigo,
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.push('/reports/beneficiaries'),
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
      builder: (context) => const GovernorateReportSheet(),
    );
  }

  Widget _buildExportAllReportsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download_for_offline,
                  color: Colors.white,
                  size: 32.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصدير جميع التقارير',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'احصل على ملف شامل لجميع التقارير',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExportingAll ? null : () => _exportAllReports('pdf'),
                    icon: _isExportingAll
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.deepPurple,
                            ),
                          )
                        : Icon(Icons.picture_as_pdf, size: 20.sp),
                    label: Text('PDF', style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExportingAll ? null : () => _exportAllReports('excel'),
                    icon: Icon(Icons.table_view, size: 20.sp),
                    label: Text('Excel', style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllReports(String format) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التصدير'),
        content: Text(
          'سيتم تصدير جميع التقارير بصيغة $format. قد تحتوي البيانات على معلومات حساسة. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تصدير'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isExportingAll = true);

    try {
      // TODO: Implement using UnifiedPdfExportService with ReportExportData
      // This needs complex multi-table support for 6 different report types
      /* 
      // Fetch all report data
      final summary = await ref.read(summaryStatisticsProvider.future);
      final gender = await ref.read(genderReportProvider.future);
      final governorate = await ref.read(governorateReportProvider.future);
      final category = await ref.read(categoryReportProvider.future);
      final age = await ref.read(ageReportProvider.future);
      final sync = await ref.read(syncStatusReportProvider.future);
      */

      if (format == 'pdf') {
        context.showError('تصدير التقرير المخصص قيد التطوير');
        /*
        final pdfBytes = await PdfExportService.exportCustomReport(...
          title:
              'تقرير شامل - ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
          startDate: _startDate,
          endDate: _endDate,
          selectedReports: [
            'summary',
            'gender',
            'governorate',
            'category',
            'age',
            'sync',
          ],
          selectedFields: ['total', 'orphans', 'poor', 'pending'],
          includeCharts: true,
          includeDetails: true,
          data: {
            'summary': summary,
            'gender': gender,
            'governorate': governorate,
            'category': category,
            'age': age,
            'sync': sync,
          },
        );

        final pdfPath = await PdfExportService.savePdfToFile(
          pdfBytes,
          'all_reports_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

        await Share.shareXFiles([
          XFile(pdfPath),
        ], text: 'تقرير شامل لجميع الإحصائيات');
        */
      } else {
        // TODO: Implement using UnifiedExcelExportService with ReportExportData
        context.showError('تصدير التقرير المخصص قيد التطوير');
        /*
        final excelPath = await ExcelExportService.exportCustomReport(
          title: 'تقرير شامل',
          startDate: _startDate,
          endDate: _endDate,
          selectedReports: [
            'summary',
            'gender',
            'governorate',
            'category',
            'age',
            'sync',
          ],
          selectedFields: ['total', 'orphans', 'poor', 'pending'],
          data: {
            'summary': summary,
            'gender': gender,
            'governorate': governorate,
            'category': category,
            'age': age,
            'sync': sync,
          },
        );

        await Share.shareXFiles([
          XFile(excelPath),
        ], text: 'تقرير شامل لجميع الإحصائيات');
        */
      }

      if (mounted) {
        /*
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير جميع التقارير بنجاح'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'تمام',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        */
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingAll = false);
      }
    }
  }

  void _showCategoryReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CategoryReportSheet(),
    );
  }

  void _showGenderReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GenderReportSheet(),
    );
  }

  void _showAgeReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AgeReportSheet(),
    );
  }

  void _showSyncReport(BuildContext context) {
    // TODO: Create SyncReportSheet widget
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تقرير حالة المزامنة قيد التطوير')),
    );
    /* 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SyncReportSheet(),
    );
    */
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
      final repository = ref.read(reportsRepositoryProvider);

      // Fetch ALL beneficiaries without pagination
      final beneficiaries = await repository.getAllBeneficiaries();

      if (!mounted) return;

      if (beneficiaries.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'لا توجد بيانات للتصدير.\nتأكد من إضافة مستفيدين أولاً.',
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'إعادة تشغيل',
              onPressed: () {
                // Suggest hot restart
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'جرب إعادة تشغيل التطبيق (Hot Restart) إذا كانت البيانات موجودة',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }

      // Export to Excel using unified architecture
      final excelService = ref.read(excelExportServiceProvider);

      final exportData = BeneficiariesExportData(
        beneficiaries: beneficiaries
            .map(
              (b) => BeneficiaryExportRow(
                fullName: b.fullName,
                nationalId: b.nationalId,
                gender: b.gender == 'male' ? 'ذكر' : 'أنثى',
                category: b.category.toString(),
                governorate: b.governorate,
                phoneNumber: b.phoneNumber,
                createdAt: b.createdAt.toString().split(' ')[0],
              ),
            )
            .toList(),
        statistics: [
          ExportStatistic(
            label: 'إجمالي المستفيدين',
            value: beneficiaries.length.toString(),
          ),
        ],
        subtitle: 'قائمة شاملة بجميع المستفيدين',
      );

      final result = await excelService.exportToExcel(exportData);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Share the file
      if (result.success) {
        await excelService.shareFile(result.filePath!);
        if (!mounted) return;
        context.showSuccess('تم تصدير ${beneficiaries.length} مستفيد بنجاح');
      } else {
        context.showError('فشل التصدير: ${result.errorMessage}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      context.showError('فشل التصدير: ${e.toString()}');
    }
  }

  Widget _buildComprehensiveExportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_download, color: Colors.white, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصدير تقرير شامل للمستفيدين',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'كل البيانات + المرفقات + الزيارات + الأنشطة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportComprehensivePdf(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade700,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportComprehensiveExcel(context),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade700,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportComprehensivePdf(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري إعداد التقرير الشامل...'),
                ],
              ),
            ),
          ),
        ),
      );

      // TODO: Fetch comprehensive data with visits, attachments, activities
      final pdfService = ref.read(pdfExportServiceProvider);

      // This is a placeholder - you'll need to implement actual data fetching
      final exportData = ComprehensiveBeneficiariesExportData(
        beneficiaries: [], // Add actual data here
        statistics: [
          const ExportStatistic(label: 'إجمالي المستفيدين', value: '0'),
        ],
        includeAttachments: true,
        includeVisits: true,
        includeActivities: true,
      );

      final result = await pdfService.exportToPdf(exportData);

      if (!mounted) return;
      Navigator.pop(context);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء التقرير الشامل: ${result.fileName}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'فتح',
              textColor: Colors.white,
              onPressed: () => pdfService.openFile(result.filePath!),
            ),
          ),
        );
      } else {
        context.showError('فشل التصدير: ${result.errorMessage}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      context.showError('فشل التصدير: ${e.toString()}');
    }
  }

  Future<void> _exportComprehensiveExcel(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري إعداد التقرير الشامل...'),
                ],
              ),
            ),
          ),
        ),
      );

      // TODO: Fetch comprehensive data with visits, attachments, activities
      final excelService = ref.read(excelExportServiceProvider);

      // This is a placeholder - you'll need to implement actual data fetching
      final exportData = ComprehensiveBeneficiariesExportData(
        beneficiaries: [], // Add actual data here
        statistics: [
          const ExportStatistic(label: 'إجمالي المستفيدين', value: '0'),
        ],
        includeAttachments: true,
        includeVisits: true,
        includeActivities: true,
      );

      final result = await excelService.exportToExcel(exportData);

      if (!mounted) return;
      Navigator.pop(context);

      if (result.success) {
        await excelService.shareFile(result.filePath!);
        if (!mounted) return;
        context.showSuccess('تم إنشاء التقرير الشامل بنجاح');
      } else {
        context.showError('فشل التصدير: ${result.errorMessage}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      context.showError('فشل التصدير: ${e.toString()}');
    }
  }
}
