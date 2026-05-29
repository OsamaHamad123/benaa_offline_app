import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import '../analytics_service.dart';
import '../../services/export/export_models.dart';
import '../../services/export/export_providers.dart';
import 'beneficiary_chart.dart';
import 'pie_chart_widget.dart';
import 'bar_chart_widget.dart';

/// 📊 Analytics Dashboard Page
/// لوحة التحكم التحليلية الاحترافية

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage> {
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  String? _lastExportedFilePath;
  ExportType? _lastExportedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 لوحة التحكم التحليلية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'تصدير التقرير',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _lastExportedFilePath == null ? null : _shareLastExport,
            tooltip: 'مشاركة آخر تقرير مُصدّر',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: 'طباعة التقرير',
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'اختيار السنة',
            onSelected: (year) {
              setState(() => _selectedYear = year);
            },
            itemBuilder: (context) {
              final currentYear = DateTime.now().year;
              return List.generate(
                5,
                (index) => PopupMenuItem(
                  value: currentYear - index,
                  child: Text('${currentYear - index}'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Stats Cards
                    _buildGeneralStatsSection(),
                    SizedBox(height: 24.h),

                    // Monthly Charts
                    _buildMonthlyChartsSection(),
                    SizedBox(height: 24.h),

                    // Distribution Charts
                    _buildDistributionSection(),
                    SizedBox(height: 24.h),

                    // Comparison Section
                    _buildComparisonSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGeneralStatsSection() {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: analyticsService.getGeneralStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات العامة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.h,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'إجمالي المستفيدين',
                  stats['totalBeneficiaries'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'إجمالي العائلات',
                  stats['totalFamilies'].toString(),
                  Icons.family_restroom,
                  Colors.green,
                ),
                _buildStatCard(
                  'إجمالي الزيارات',
                  stats['totalVisits'].toString(),
                  Icons.home_work,
                  Colors.orange,
                ),
                _buildStatCard(
                  'الكفالات النشطة',
                  stats['totalSponsorships'].toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.sp, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChartsSection() {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: analyticsService.getMonthlyStats(_selectedYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final monthlyData = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات الشهرية - $_selectedYear',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16.h),
            BeneficiaryChart(
              monthlyData: monthlyData,
            ),
            SizedBox(height: 16.h),
            BeneficiaryChart(
              monthlyData: monthlyData,
              showVisits: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistributionSection() {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'توزيع البيانات',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),

        // Gender Distribution
        FutureBuilder<Map<String, int>>(
          future: analyticsService.getGenderStats(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return PieChartWidget(
                data: snapshot.data!,
                title: 'توزيع حسب الجنس',
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: 16.h),

        // Marital Status Distribution
        FutureBuilder<Map<String, int>>(
          future: analyticsService.getMaritalStatusStats(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return PieChartWidget(
                data: snapshot.data!,
                title: 'توزيع حسب الحالة الاجتماعية',
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: 16.h),

        // Age Groups
        FutureBuilder<Map<String, int>>(
          future: analyticsService.getAgeGroupStats(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final barData = snapshot.data!.entries.map((e) => {'label': e.key, 'value': e.value}).toList();

              return BarChartWidget(
                data: barData,
                title: 'توزيع حسب الفئة العمرية',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    final analyticsService = ref.watch(analyticsServiceProvider);
    final previousYear = _selectedYear - 1;

    return FutureBuilder<Map<String, dynamic>>(
      future: analyticsService.compareYears(previousYear, _selectedYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final comparison = snapshot.data!;
        final growth = comparison['growth'] as Map<String, dynamic>;

        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مقارنة السنوات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16.h),
                _buildComparisonRow(
                  'المستفيدون',
                  growth['beneficiaries'] as double,
                ),
                _buildComparisonRow(
                  'الزيارات',
                  growth['visits'] as double,
                ),
                _buildComparisonRow(
                  'الكفالات',
                  growth['sponsorships'] as double,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(String label, double growthPercent) {
    final isPositive = growthPercent >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '${growthPercent.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _exportReport() async {
    final exportType = await showModalBottomSheet<ExportType>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded),
                title: const Text('تصدير PDF'),
                onTap: () => Navigator.of(sheetContext).pop(ExportType.pdf),
              ),
              ListTile(
                leading: const Icon(Icons.table_view_rounded),
                title: const Text('تصدير Excel'),
                onTap: () => Navigator.of(sheetContext).pop(ExportType.excel),
              ),
            ],
          ),
        );
      },
    );

    if (exportType == null) return;

    try {
      setState(() => _isLoading = true);

      final reportData = await _buildReportExportData();
      if (exportType == ExportType.pdf) {
        final service = ref.read(pdfExportServiceProvider);
        final result = await service.exportToPdf(reportData);

        if (!mounted) return;
        if (result.success && result.filePath != null) {
          setState(() {
            _lastExportedFilePath = result.filePath;
            _lastExportedType = ExportType.pdf;
          });
          await service.openFile(result.filePath!);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تصدير التقرير: ${result.fileName}'),
              action: SnackBarAction(
                label: 'مشاركة',
                onPressed: _shareLastExport,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل التصدير: ${result.errorMessage ?? 'خطأ غير معروف'}')),
          );
        }
      } else {
        final service = ref.read(excelExportServiceProvider);
        final result = await service.exportToExcel(reportData);

        if (!mounted) return;
        if (result.success && result.filePath != null) {
          setState(() {
            _lastExportedFilePath = result.filePath;
            _lastExportedType = ExportType.excel;
          });
          await service.openFile(result.filePath!);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تصدير التقرير: ${result.fileName}'),
              action: SnackBarAction(
                label: 'مشاركة',
                onPressed: _shareLastExport,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل التصدير: ${result.errorMessage ?? 'خطأ غير معروف'}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _printReport() async {
    try {
      setState(() => _isLoading = true);

      final reportData = await _buildReportExportData();
      final service = ref.read(pdfExportServiceProvider);
      final result = await service.exportToPdf(reportData);

      if (!mounted) return;

      if (!result.success || result.filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إنشاء ملف الطباعة: ${result.errorMessage ?? 'خطأ غير معروف'}')),
        );
        return;
      }

      final bytes = await File(result.filePath!).readAsBytes();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'analytics_$_selectedYear',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الطباعة: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareLastExport() async {
    final filePath = _lastExportedFilePath;
    final exportType = _lastExportedType;
    if (filePath == null || exportType == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد ملف مُصدّر للمشاركة بعد')),
      );
      return;
    }

    try {
      if (!File(filePath).existsSync()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف غير موجود. صدّر التقرير مرة أخرى.')),
        );
        return;
      }

      if (exportType == ExportType.pdf) {
        final service = ref.read(pdfExportServiceProvider);
        await service.shareFile(filePath);
      } else if (exportType == ExportType.excel) {
        final service = ref.read(excelExportServiceProvider);
        await service.shareFile(filePath);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشلت المشاركة: $e')),
      );
    }
  }

  Future<ReportExportData> _buildReportExportData() async {
    final analyticsService = ref.read(analyticsServiceProvider);
    final generalStats = await analyticsService.getGeneralStats();
    final monthlyStats = await analyticsService.getMonthlyStats(_selectedYear);
    final genderStats = await analyticsService.getGenderStats();
    final maritalStats = await analyticsService.getMaritalStatusStats();
    final ageStats = await analyticsService.getAgeGroupStats();
    final comparison = await analyticsService.compareYears(
      _selectedYear - 1,
      _selectedYear,
    );

    final growth = comparison['growth'] as Map<String, dynamic>? ??
        <String, dynamic>{'beneficiaries': 0.0, 'visits': 0.0, 'sponsorships': 0.0};

    return ReportExportData(
      title: 'لوحة التحكم التحليلية - $_selectedYear',
      subtitle: 'تقرير شامل للإحصائيات العامة والتحليلية',
      statistics: [
        ExportStatistic(label: 'إجمالي المستفيدين', value: '${generalStats['totalBeneficiaries'] ?? 0}'),
        ExportStatistic(label: 'إجمالي العائلات', value: '${generalStats['totalFamilies'] ?? 0}'),
        ExportStatistic(label: 'إجمالي الزيارات', value: '${generalStats['totalVisits'] ?? 0}'),
        ExportStatistic(label: 'الكفالات النشطة', value: '${generalStats['totalSponsorships'] ?? 0}'),
      ],
      tables: [
        ExportTable(
          title: 'الإحصائيات العامة',
          headers: const ['المؤشر', 'القيمة'],
          rows: [
            ['إجمالي المستفيدين', '${generalStats['totalBeneficiaries'] ?? 0}'],
            ['إجمالي العائلات', '${generalStats['totalFamilies'] ?? 0}'],
            ['إجمالي الزيارات', '${generalStats['totalVisits'] ?? 0}'],
            ['الكفالات النشطة', '${generalStats['totalSponsorships'] ?? 0}'],
          ],
        ),
        ExportTable(
          title: 'الإحصائيات الشهرية ($_selectedYear)',
          headers: const ['الشهر', 'المستفيدون', 'الزيارات', 'الكفالات'],
          rows: monthlyStats
              .map(
                (row) => [
                  '${row['month'] ?? '-'}',
                  '${row['beneficiaries'] ?? 0}',
                  '${row['visits'] ?? 0}',
                  '${row['sponsorships'] ?? 0}',
                ],
              )
              .toList(),
        ),
        ExportTable(
          title: 'توزيع حسب الجنس',
          headers: const ['الفئة', 'العدد'],
          rows: genderStats.entries.map((entry) => [entry.key, entry.value.toString()]).toList(),
        ),
        ExportTable(
          title: 'توزيع حسب الحالة الاجتماعية',
          headers: const ['الفئة', 'العدد'],
          rows: maritalStats.entries.map((entry) => [entry.key, entry.value.toString()]).toList(),
        ),
        ExportTable(
          title: 'توزيع حسب الفئة العمرية',
          headers: const ['الفئة', 'العدد'],
          rows: ageStats.entries.map((entry) => [entry.key, entry.value.toString()]).toList(),
        ),
        ExportTable(
          title: 'مقارنة السنوات',
          headers: const ['المؤشر', 'النمو %'],
          rows: [
            ['المستفيدون', (growth['beneficiaries'] as num?)?.toStringAsFixed(1) ?? '0.0'],
            ['الزيارات', (growth['visits'] as num?)?.toStringAsFixed(1) ?? '0.0'],
            ['الكفالات', (growth['sponsorships'] as num?)?.toStringAsFixed(1) ?? '0.0'],
          ],
        ),
      ],
    );
  }
}
