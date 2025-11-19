import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'services/pdf_export_service.dart';
import 'services/excel_export_service.dart';
import 'providers/reports_providers.dart';

/// Custom Reports Page - صفحة التقارير المخصصة
/// تسمح للمستخدم بإنشاء تقارير حسب احتياجاته
class CustomReportsPage extends ConsumerStatefulWidget {
  const CustomReportsPage({super.key});

  @override
  ConsumerState<CustomReportsPage> createState() => _CustomReportsPageState();
}

class _CustomReportsPageState extends ConsumerState<CustomReportsPage> {
  // Report Configuration
  String _reportTitle = 'تقرير مخصص';
  DateTime? _startDate;
  DateTime? _endDate;

  // Selected Fields
  final Set<String> _selectedFields = {'total', 'orphans', 'poor'};

  // Selected Reports
  final Set<String> _selectedReports = {'summary'};

  // Include Charts
  bool _includeCharts = true;
  bool _includeDetails = true;

  // Export Format
  String _exportFormat = 'pdf'; // pdf, excel, both

  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء تقرير مخصص'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'مساعدة',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Report Title
          _buildSection(
            title: 'عنوان التقرير',
            icon: Icons.title,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'أدخل عنوان التقرير',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) => setState(() => _reportTitle = value),
            ),
          ),

          SizedBox(height: 24.h),

          // Date Range
          _buildSection(
            title: 'الفترة الزمنية',
            icon: Icons.date_range,
            child: Column(
              children: [
                _buildDateButton(
                  label: 'من تاريخ',
                  date: _startDate,
                  onTap: () => _selectStartDate(),
                ),
                SizedBox(height: 12.h),
                _buildDateButton(
                  label: 'إلى تاريخ',
                  date: _endDate,
                  onTap: () => _selectEndDate(),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Fields Selection
          _buildSection(
            title: 'الحقول المطلوبة',
            icon: Icons.checklist,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildFieldChip('total', 'إجمالي المستفيدين'),
                _buildFieldChip('orphans', 'الأيتام'),
                _buildFieldChip('poor', 'الفقراء'),
                _buildFieldChip('pending', 'بانتظار المزامنة'),
                _buildFieldChip('synced', 'تمت المزامنة'),
                _buildFieldChip('males', 'الذكور'),
                _buildFieldChip('females', 'الإناث'),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Reports Selection
          _buildSection(
            title: 'التقارير المطلوبة',
            icon: Icons.assessment,
            child: Column(
              children: [
                _buildReportCheckbox('summary', 'ملخص الإحصائيات'),
                _buildReportCheckbox('gender', 'تقرير الجنس'),
                _buildReportCheckbox('governorate', 'تقرير المحافظات'),
                _buildReportCheckbox('category', 'تقرير الفئات'),
                _buildReportCheckbox('age', 'تقرير الأعمار'),
                _buildReportCheckbox('sync', 'تقرير المزامنة'),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Display Options
          _buildSection(
            title: 'خيارات العرض',
            icon: Icons.display_settings,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تضمين الرسوم البيانية'),
                  subtitle: const Text('عرض Charts في التقرير'),
                  value: _includeCharts,
                  onChanged: (value) => setState(() => _includeCharts = value),
                  secondary: const Icon(Icons.bar_chart),
                ),
                SwitchListTile(
                  title: const Text('تضمين التفاصيل'),
                  subtitle: const Text('عرض جداول التفاصيل'),
                  value: _includeDetails,
                  onChanged: (value) => setState(() => _includeDetails = value),
                  secondary: const Icon(Icons.table_chart),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Export Format
          _buildSection(
            title: 'صيغة التصدير',
            icon: Icons.file_download,
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('PDF فقط'),
                  subtitle: const Text('ملف PDF قابل للطباعة'),
                  value: 'pdf',
                  groupValue: _exportFormat,
                  onChanged: (value) => setState(() => _exportFormat = value!),
                  secondary: const Icon(Icons.picture_as_pdf),
                ),
                RadioListTile<String>(
                  title: const Text('Excel فقط'),
                  subtitle: const Text('ملف Excel قابل للتعديل'),
                  value: 'excel',
                  groupValue: _exportFormat,
                  onChanged: (value) => setState(() => _exportFormat = value!),
                  secondary: const Icon(Icons.table_view),
                ),
                RadioListTile<String>(
                  title: const Text('كلاهما'),
                  subtitle: const Text('PDF و Excel معاً'),
                  value: 'both',
                  groupValue: _exportFormat,
                  onChanged: (value) => setState(() => _exportFormat = value!),
                  secondary: const Icon(Icons.folder),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Generate Button
          SizedBox(
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateReport,
              icon: _isGenerating
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isGenerating ? 'جاري الإنشاء...' : 'إنشاء وتصدير التقرير',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: date != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldChip(String key, String label) {
    final isSelected = _selectedFields.contains(key);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFields.add(key);
          } else {
            _selectedFields.remove(key);
          }
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildReportCheckbox(String key, String label) {
    return CheckboxListTile(
      title: Text(label),
      value: _selectedReports.contains(key),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedReports.add(key);
          } else {
            _selectedReports.remove(key);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _generateReport() async {
    // Validation
    if (_reportTitle.isEmpty) {
      _showError('يرجى إدخال عنوان التقرير');
      return;
    }

    if (_selectedReports.isEmpty) {
      _showError('يرجى اختيار تقرير واحد على الأقل');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final files = <XFile>[];

      // Generate PDF
      if (_exportFormat == 'pdf' || _exportFormat == 'both') {
        final pdfBytes = await _generatePdfReport();
        final pdfPath = await PdfExportService.savePdfToFile(
          pdfBytes,
          '${_reportTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        files.add(XFile(pdfPath));
      }

      // Generate Excel
      if (_exportFormat == 'excel' || _exportFormat == 'both') {
        final excelPath = await _generateExcelReport();
        files.add(XFile(excelPath));
      }

      // Share files
      await Share.shareXFiles(files, text: _reportTitle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء التقرير بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل إنشاء التقرير: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<Uint8List> _generatePdfReport() async {
    // Fetch data based on selected reports
    final data = await _fetchReportData();

    final pdfBytes = await PdfExportService.exportCustomReport(
      title: _reportTitle,
      startDate: _startDate,
      endDate: _endDate,
      selectedReports: _selectedReports.toList(),
      selectedFields: _selectedFields.toList(),
      includeCharts: _includeCharts,
      includeDetails: _includeDetails,
      data: data,
    );

    return Uint8List.fromList(pdfBytes);
  }

  Future<String> _generateExcelReport() async {
    // Fetch data based on selected reports
    final data = await _fetchReportData();

    return await ExcelExportService.exportCustomReport(
      title: _reportTitle,
      startDate: _startDate,
      endDate: _endDate,
      selectedReports: _selectedReports.toList(),
      selectedFields: _selectedFields.toList(),
      data: data,
    );
  }

  Future<Map<String, dynamic>> _fetchReportData() async {
    final data = <String, dynamic>{};

    // Create date range filter
    final dateRange = _startDate != null || _endDate != null
        ? DateRangeFilter(startDate: _startDate, endDate: _endDate)
        : null;

    if (_selectedReports.contains('summary')) {
      final summary = dateRange != null
          ? await ref.read(summaryStatisticsWithDateProvider(dateRange).future)
          : await ref.read(summaryStatisticsProvider.future);
      data['summary'] = summary;
    }

    if (_selectedReports.contains('gender')) {
      final gender = await ref.read(genderReportProvider.future);
      data['gender'] = gender;
    }

    if (_selectedReports.contains('governorate')) {
      final governorate = await ref.read(governorateReportProvider.future);
      data['governorate'] = governorate;
    }

    if (_selectedReports.contains('category')) {
      final category = await ref.read(categoryReportProvider.future);
      data['category'] = category;
    }

    if (_selectedReports.contains('age')) {
      final age = await ref.read(ageReportProvider.future);
      data['age'] = age;
    }

    if (_selectedReports.contains('sync')) {
      final sync = await ref.read(syncStatusReportProvider.future);
      data['sync'] = sync;
    }

    return data;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'كيفية إنشاء تقرير مخصص:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildHelpItem('1. اختر عنواناً مناسباً للتقرير'),
              _buildHelpItem('2. حدد الفترة الزمنية (اختياري)'),
              _buildHelpItem('3. اختر الحقول التي تريد تضمينها'),
              _buildHelpItem('4. اختر نوع أو أكثر من التقارير'),
              _buildHelpItem('5. حدد خيارات العرض'),
              _buildHelpItem('6. اختر صيغة التصدير'),
              _buildHelpItem('7. اضغط "إنشاء وتصدير التقرير"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
          SizedBox(width: 8.w),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
