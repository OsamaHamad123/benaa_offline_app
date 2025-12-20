import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/dashboard_statistics.dart'; // ✅ Use existing model

/// Dashboard PDF Exporter
class DashboardPdfExporter {
  /// تصدير الداشبورد إلى PDF
  static Future<File?> exportToPdf(DashboardStatistics dashboard, {String? filename}) async {
    final pdf = pw.Document();

    // Load Arabic font
    final arabicFont = await _loadArabicFont();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Total Statistics
              _buildSectionTitle('الإحصائيات الإجمالية'),
              pw.SizedBox(height: 10),
              _buildStatisticsTable(dashboard),
              pw.SizedBox(height: 20),

              // Beneficiary Types
              _buildSectionTitle('توزيع المستفيدين حسب النوع'),
              pw.SizedBox(height: 10),
              _buildBeneficiaryTypesTable(dashboard),
              pw.SizedBox(height: 20),

              // Footer
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final output = await _getOutputFile(filename ?? 'dashboard_report.pdf');
    await output.writeAsBytes(await pdf.save());
    return output;
  }

  /// طباعة الداشبورد
  static Future<void> printDashboard(DashboardStatistics dashboard) async {
    final arabicFont = await _loadArabicFont();

    await Printing.layoutPdf(
      onLayout: (format) async {
        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: arabicFont),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  pw.SizedBox(height: 20),
                  _buildSectionTitle('الإحصائيات الإجمالية'),
                  pw.SizedBox(height: 10),
                  _buildStatisticsTable(dashboard),
                  pw.SizedBox(height: 20),
                  _buildSectionTitle('توزيع المستفيدين حسب النوع'),
                  pw.SizedBox(height: 10),
                  _buildBeneficiaryTypesTable(dashboard),
                ],
              );
            },
          ),
        );

        return pdf.save();
      },
    );
  }

  /// مشاركة PDF
  static Future<void> sharePdf(DashboardStatistics dashboard) async {
    final file = await exportToPdf(dashboard);
    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'تقرير الداشبورد',
        text: 'تقرير الداشبورد - تطبيق بناء',
      );
    }
  }

  // Private Helper Methods

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تقرير الداشبورد',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'تطبيق بناء لإدارة المستفيدين',
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'تاريخ التقرير: ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _buildStatisticsTable(DashboardStatistics stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('إجمالي المستفيدين', '${stats.totalBeneficiaries}', isHeader: true),
        _buildTableRow('الأيتام', '${stats.categoryCounts['يتيم'] ?? 0}'),
        _buildTableRow('الأرامل', '${stats.categoryCounts['أرملة'] ?? 0}'),
        _buildTableRow('الفقراء', '${stats.categoryCounts['فقير'] ?? 0}'),
        _buildTableRow('ذوي الإعاقة', '${stats.categoryCounts['معاق'] ?? 0}'),
      ],
    );
  }

  static pw.Widget _buildBeneficiaryTypesTable(DashboardStatistics dashboard) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('النوع', 'العدد', isHeader: true),
        _buildTableRow('أيتام', '${dashboard.categoryCounts['يتيم'] ?? 0}'),
        _buildTableRow('أرامل', '${dashboard.categoryCounts['أرملة'] ?? 0}'),
        _buildTableRow('فقراء', '${dashboard.categoryCounts['فقير'] ?? 0}'),
        _buildTableRow('ذوي إعاقة', '${dashboard.categoryCounts['معاق'] ?? 0}'),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Text(
        'تم إنشاء التقرير بواسطة تطبيق بناء © ${DateTime.now().year}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Future<pw.Font> _loadArabicFont() async {
    // Load Arabic font from assets
    // You need to add an Arabic font file to assets/fonts/
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // Fallback to default font if Arabic font not found
      return pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    }
  }

  static Future<File> _getOutputFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }
}
