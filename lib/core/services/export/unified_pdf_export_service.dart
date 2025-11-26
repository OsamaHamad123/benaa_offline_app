/// 📄 Unified PDF Export Service - Application-wide PDF export
///
/// خدمة موحدة لتصدير PDF في كامل التطبيق
/// تدعم: المستفيدين، الزيارات، الأنشطة، التقارير

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import 'export_models.dart';
import 'base_export_service.dart';

/// خدمة تصدير PDF موحدة
class UnifiedPdfExportService implements BaseExportService {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;

  /// Initialize Arabic fonts (Google Fonts - no assets needed!)
  static Future<void> initialize() async {
    if (_arabicFont == null) {
      try {
        _arabicFont = await PdfGoogleFonts.cairoRegular();
        _arabicBoldFont = await PdfGoogleFonts.cairoBold();
      } catch (e) {
        if (kDebugMode) debugPrint('Error loading Cairo font: $e');
        // Fallback to Noto Sans Arabic
        try {
          _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
          _arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();
        } catch (e2) {
          if (kDebugMode) debugPrint('Error loading fallback font: $e2');
        }
      }
    }
  }

  @override
  Future<ExportResult> exportToPdf(ExportData data) async {
    try {
      await initialize();

      Uint8List pdfBytes;

      // اختيار الطريقة المناسبة حسب نوع البيانات
      if (data is BeneficiariesExportData) {
        pdfBytes = await _exportBeneficiaries(data);
      } else if (data is VisitsExportData) {
        pdfBytes = await _exportVisits(data);
      } else if (data is ActivitiesExportData) {
        pdfBytes = await _exportActivities(data);
      } else if (data is ComprehensiveBeneficiariesExportData) {
        pdfBytes = await _exportComprehensiveBeneficiaries(data);
      } else if (data is ReportExportData) {
        pdfBytes = await _exportReport(data);
      } else {
        throw UnsupportedError('Unsupported export data type');
      }

      // حفظ الملف
      final fileName = ExportFileNameBuilder.build(
        contentType: data.contentType,
        exportType: ExportType.pdf,
        timestamp: data.timestamp,
      );

      final filePath = await _saveToFile(pdfBytes, fileName);

      return ExportResult.success(filePath: filePath, type: ExportType.pdf);
    } catch (e) {
      return ExportResult.failure(
        errorMessage: e.toString(),
        type: ExportType.pdf,
      );
    }
  }

  /// تصدير قائمة المستفيدين
  Future<Uint8List> _exportBeneficiaries(BeneficiariesExportData data) async {
    final pdf = pw.Document();
    final table = data.toTable();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(
            title: data.title,
            subtitle: data.subtitle,
            date: data.formattedDate,
            time: data.formattedTime,
          ),
          pw.SizedBox(height: 20),

          // Statistics (if available)
          if (data.statistics != null && data.statistics!.isNotEmpty) ...[
            _buildStatisticsGrid(data.statistics!),
            pw.SizedBox(height: 20),
          ],

          // Table
          _buildDataTable(table),
        ],
        footer: (context) => _buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
      ),
    );

    return pdf.save();
  }

  /// تصدير قائمة الزيارات
  Future<Uint8List> _exportVisits(VisitsExportData data) async {
    final pdf = pw.Document();
    final table = data.toTable();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title: data.title,
            subtitle: data.subtitle,
            date: data.formattedDate,
            time: data.formattedTime,
          ),
          pw.SizedBox(height: 20),

          if (data.statistics != null && data.statistics!.isNotEmpty) ...[
            _buildStatisticsGrid(data.statistics!),
            pw.SizedBox(height: 20),
          ],

          _buildDataTable(table),
        ],
        footer: (context) => _buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
      ),
    );

    return pdf.save();
  }

  /// تصدير الأنشطة
  Future<Uint8List> _exportActivities(ActivitiesExportData data) async {
    final pdf = pw.Document();
    final table = data.toTable();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title: data.title,
            subtitle: data.subtitle,
            date: data.formattedDate,
            time: data.formattedTime,
          ),
          pw.SizedBox(height: 20),

          if (data.statistics != null && data.statistics!.isNotEmpty) ...[
            _buildStatisticsGrid(data.statistics!),
            pw.SizedBox(height: 20),
          ],

          _buildDataTable(table),
        ],
        footer: (context) => _buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
      ),
    );

    return pdf.save();
  }

  /// تصدير شامل للمستفيدين مع كل التفاصيل
  Future<Uint8List> _exportComprehensiveBeneficiaries(
    ComprehensiveBeneficiariesExportData data,
  ) async {
    final pdf = pw.Document();
    final tables = data.getAllTables();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // عرضي للجداول الكبيرة
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(
            title: data.title,
            subtitle:
                data.subtitle ?? 'تقرير شامل يتضمن جميع البيانات والمرفقات',
            date: data.formattedDate,
            time: data.formattedTime,
          ),
          pw.SizedBox(height: 20),

          if (data.statistics != null && data.statistics!.isNotEmpty) ...[
            _buildStatisticsGrid(data.statistics!),
            pw.SizedBox(height: 20),
          ],

          // عرض جميع الجداول
          ...tables.expand(
            (table) => [
              if (table.title != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Text(
                    table.title!,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: _arabicBoldFont ?? _arabicFont,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
              _buildDataTable(table),
              pw.SizedBox(height: 24),
            ],
          ),
        ],
        footer: (context) => _buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
      ),
    );

    return pdf.save();
  }

  /// تصدير التقرير
  Future<Uint8List> _exportReport(ReportExportData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title: data.title,
            subtitle: data.subtitle,
            date: data.formattedDate,
            time: data.formattedTime,
          ),
          pw.SizedBox(height: 20),

          if (data.statistics != null && data.statistics!.isNotEmpty) ...[
            _buildStatisticsGrid(data.statistics!),
            pw.SizedBox(height: 20),
          ],

          // Multiple tables
          ...data.tables.expand(
            (table) => [
              if (table.title != null) ...[
                pw.Text(
                  table.title!,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: _arabicBoldFont ?? _arabicFont,
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
              _buildDataTable(table),
              pw.SizedBox(height: 20),
            ],
          ),
        ],
        footer: (context) => _buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
      ),
    );

    return pdf.save();
  }

  /// بناء رأس الصفحة
  pw.Widget _buildHeader({
    required String title,
    String? subtitle,
    required String date,
    required String time,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            font: _arabicBoldFont ?? _arabicFont,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),

        // Subtitle
        if (subtitle != null)
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 14,
              font: _arabicFont,
              color: PdfColors.grey700,
            ),
          ),

        pw.SizedBox(height: 8),

        // Date & Time
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'التاريخ: $date',
              style: pw.TextStyle(
                fontSize: 11,
                font: _arabicFont,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'الوقت: $time',
              style: pw.TextStyle(
                fontSize: 11,
                font: _arabicFont,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 8),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  /// بناء شبكة الإحصائيات
  pw.Widget _buildStatisticsGrid(List<ExportStatistic> statistics) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: statistics.map((stat) {
        return pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                stat.label,
                style: pw.TextStyle(
                  fontSize: 10,
                  font: _arabicFont,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                stat.value,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: _arabicBoldFont ?? _arabicFont,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// بناء الجدول
  pw.Widget _buildDataTable(ExportTable table) {
    if (table.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'لا توجد بيانات',
          style: pw.TextStyle(
            fontSize: 14,
            font: _arabicFont,
            color: PdfColors.grey600,
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        for (int i = 0; i < table.columnCount; i++)
          i: const pw.FlexColumnWidth(),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          children: table.headers.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  font: _arabicBoldFont ?? _arabicFont,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            );
          }).toList(),
        ),

        // Data Rows
        ...table.rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isEven = index % 2 == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.grey50 : PdfColors.white,
            ),
            children: row.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  cell,
                  style: pw.TextStyle(fontSize: 9, font: _arabicFont),
                  textAlign: pw.TextAlign.center,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  /// بناء تذييل الصفحة
  pw.Widget _buildFooter({required int pageNumber, required int totalPages}) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'تم إنشاء التقرير بواسطة تطبيق بناء',
              style: pw.TextStyle(
                fontSize: 9,
                font: _arabicFont,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'صفحة $pageNumber من $totalPages',
              style: pw.TextStyle(
                fontSize: 9,
                font: _arabicFont,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// حفظ الملف
  Future<String> _saveToFile(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final filePath = '${exportsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    return filePath;
  }

  @override
  Future<void> openFile(String filePath) async {
    if (Platform.isAndroid) {
      await OpenFile.open(filePath);
    } else {
      await Printing.sharePdf(
        bytes: await File(filePath).readAsBytes(),
        filename: filePath.split('/').last,
      );
    }
  }

  @override
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'تقرير من تطبيق بناء');
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<ExportResult> exportToExcel(ExportData data) {
    throw UnimplementedError('استخدم UnifiedExcelExportService');
  }

  @override
  Future<ExportResult> exportToCsv(ExportData data) {
    throw UnimplementedError('استخدم UnifiedCsvExportService');
  }

  /// Share or print PDF directly
  static Future<void> shareOrPrint(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
