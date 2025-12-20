import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../providers/kafalat_providers.dart';
import '../../../../../data/db/daos/sponsorships_dao.dart';

/// 📤 Export Page - تصدير البيانات إلى Excel وPDF
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  bool _isExporting = false;
  String? _lastExportPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصدير البيانات'),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16.w : 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  size: isMobile ? 32.sp : 40.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'اختر صيغة التصدير',
                    style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'يمكنك تصدير قائمة الكفالات إلى ملف Excel أو PDF',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: isMobile ? 24.h : 32.h),

            // Export Options
            _ExportOptionCard(
              icon: Icons.table_chart,
              title: 'تصدير Excel',
              subtitle: 'ملف جداول بيانات قابل للتعديل (.xlsx)',
              color: Colors.green,
              isLoading: _isExporting,
              onTap: () => _exportToExcel(),
            ),
            SizedBox(height: 16.h),
            _ExportOptionCard(
              icon: Icons.picture_as_pdf,
              title: 'تصدير PDF',
              subtitle: 'ملف PDF احترافي للطباعة (.pdf)',
              color: Colors.red,
              isLoading: _isExporting,
              onTap: () => _exportToPDF(),
            ),
            SizedBox(height: isMobile ? 24.h : 32.h),

            // Last Export Info
            if (_lastExportPath != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تم التصدير بنجاح',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _lastExportPath!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openFile(_lastExportPath!),
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'فتح الملف',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final sponsorshipsAsync = ref.read(
        kafalatSponsorshipsProvider((
          associationId: null,
          status: 'all',
          type: 'all',
          query: '',
        )),
      );

      final sponsorships = await sponsorshipsAsync.when(
        data: (data) async => data,
        loading: () async => <SponsorshipWithDetails>[],
        error: (_, __) async => <SponsorshipWithDetails>[],
      );

      // Create Excel
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['الكفالات'];

      // Headers
      sheet.appendRow([
        excel_pkg.TextCellValue('الرقم'),
        excel_pkg.TextCellValue('اسم المكفول'),
        excel_pkg.TextCellValue('الجمعية'),
        excel_pkg.TextCellValue('الحالة'),
        excel_pkg.TextCellValue('النوع'),
        excel_pkg.TextCellValue('المبلغ'),
        excel_pkg.TextCellValue('تاريخ البدء'),
        excel_pkg.TextCellValue('الملاحظات'),
      ]);

      // Data rows
      for (var i = 0; i < sponsorships.length; i++) {
        final row = sponsorships[i];
        sheet.appendRow([
          excel_pkg.IntCellValue(i + 1),
          excel_pkg.TextCellValue(row.beneficiary.fullName),
          excel_pkg.TextCellValue(row.association?.name ?? '-'),
          excel_pkg.TextCellValue(_getStatusLabel(row.sponsorship.status)),
          excel_pkg.TextCellValue(_getTypeLabel(row.sponsorship.sponsorshipType)),
          excel_pkg.DoubleCellValue(row.sponsorship.amount ?? 0),
          excel_pkg.TextCellValue(
            DateFormat('yyyy/MM/dd').format(row.sponsorship.createdAt),
          ),
          excel_pkg.TextCellValue(row.sponsorship.notes ?? '-'),
        ]);
      }

      // Style headers
      for (var i = 0; i < 8; i++) {
        final cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = excel_pkg.CellStyle(
          backgroundColorHex: excel_pkg.ExcelColor.blue,
          fontColorHex: excel_pkg.ExcelColor.white,
          bold: true,
        );
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/kafalat_export_$timestamp.xlsx';

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        setState(() {
          _lastExportPath = filePath;
          _isExporting = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم التصدير بنجاح إلى: $filePath'),
              action: SnackBarAction(
                label: 'فتح',
                onPressed: () => _openFile(filePath),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);

    try {
      final sponsorshipsAsync = ref.read(
        kafalatSponsorshipsProvider((
          associationId: null,
          status: 'all',
          type: 'all',
          query: '',
        )),
      );

      final sponsorships = await sponsorshipsAsync.when(
        data: (data) async => data,
        loading: () async => <SponsorshipWithDetails>[],
        error: (_, __) async => <SponsorshipWithDetails>[],
      );

      // Load Arabic font
      final arabicFont = await PdfGoogleFonts.cairoRegular();
      final arabicFontBold = await PdfGoogleFonts.cairoBold();

      // Create PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: arabicFontBold,
          ),
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text('تقرير الكفالات', textDirection: pw.TextDirection.rtl),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'تاريخ التقرير: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}',
              textDirection: pw.TextDirection.rtl,
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.TableHelper.fromTextArray(
              context: context,
              headerDirection: pw.TextDirection.rtl,
              headers: ['الملاحظات', 'تاريخ البدء', 'المبلغ', 'النوع', 'الحالة', 'الجمعية', 'المكفول', '#'],
              data: sponsorships.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                return [
                  row.sponsorship.notes ?? '-',
                  DateFormat('yyyy/MM/dd').format(row.sponsorship.createdAt),
                  '${row.sponsorship.amount ?? 0}',
                  _getTypeLabel(row.sponsorship.sponsorshipType),
                  _getStatusLabel(row.sponsorship.status),
                  row.association?.name ?? '-',
                  row.beneficiary.fullName,
                  '${i + 1}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerRight,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.center,
              },
            ),
          ],
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/kafalat_report_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _lastExportPath = filePath;
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التصدير بنجاح إلى: $filePath'),
            action: SnackBarAction(
              label: 'فتح',
              onPressed: () => _openFile(filePath),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }

  String _getStatusLabel(String status) {
    return switch (status) {
      'active' => 'نشطة',
      'paused' => 'متوقفة',
      'ended' => 'منتهية',
      _ => status,
    };
  }

  String _getTypeLabel(String type) {
    return switch (type) {
      'monthly' => 'شهرية',
      'one_time' => 'مرة واحدة',
      'other' => 'أخرى',
      _ => type,
    };
  }
}

/// Export Option Card
class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
