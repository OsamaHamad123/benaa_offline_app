import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/entities/report_data.dart';

/// Service for exporting reports to PDF with Arabic support
class PdfExportService {
  static pw.Font? _arabicFont;

  /// Initialize Arabic font (must be called before first export)
  static Future<void> initialize() async {
    if (_arabicFont == null) {
      // Load Arabic font from Google Fonts (no assets needed!)
      try {
        _arabicFont = await PdfGoogleFonts.cairoRegular();
      } catch (e) {
        print('Error loading Cairo font: $e');
        // Fallback to Noto Sans Arabic
        try {
          _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
        } catch (e2) {
          print('Error loading fallback font: $e2');
        }
      }
    }
  }

  /// Export Gender Report to PDF
  static Future<Uint8List> exportGenderReport({
    required List<GenderCount> data,
    required int total,
  }) async {
    await initialize();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          final males = data
              .firstWhere(
                (g) => g.gender == 'ذكور',
                orElse: () => GenderCount(gender: 'ذكور', count: 0),
              )
              .count;
          final females = data
              .firstWhere(
                (g) => g.gender == 'إناث',
                orElse: () => GenderCount(gender: 'إناث', count: 0),
              )
              .count;

          final malePercentage = total == 0 ? 0.0 : (males / total) * 100;
          final femalePercentage = total == 0 ? 0.0 : (females / total) * 100;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader('تقرير حسب الجنس', dateStr),
              pw.SizedBox(height: 20),

              // Summary
              _buildSummaryBox('إجمالي المستفيدين', total.toString()),
              pw.SizedBox(height: 20),

              // Statistics Table
              _buildTable(
                headers: ['النسبة المئوية', 'العدد', 'الجنس'],
                rows: [
                  [
                    '${malePercentage.toStringAsFixed(1)}%',
                    males.toString(),
                    'ذكور',
                  ],
                  [
                    '${femalePercentage.toStringAsFixed(1)}%',
                    females.toString(),
                    'إناث',
                  ],
                ],
              ),

              // Footer
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Export Category Report to PDF
  static Future<Uint8List> exportCategoryReport({
    required List<CategoryCount> data,
  }) async {
    await initialize();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';
    final total = data.fold(0, (sum, item) => sum + item.count);

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('تقرير حسب الفئة', dateStr),
              pw.SizedBox(height: 20),
              _buildSummaryBox('إجمالي المستفيدين', total.toString()),
              pw.SizedBox(height: 20),
              _buildTable(
                headers: ['النسبة المئوية', 'العدد', 'الفئة'],
                rows: data.map((item) {
                  final percentage = total == 0
                      ? 0.0
                      : (item.count / total) * 100;
                  return [
                    '${percentage.toStringAsFixed(1)}%',
                    item.count.toString(),
                    item.category,
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Export Governorate Report to PDF
  static Future<Uint8List> exportGovernorateReport({
    required List<GovernorateCount> data,
    required int total,
  }) async {
    await initialize();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';

    // Sort by count descending
    final sortedData = List<GovernorateCount>.from(data)
      ..sort((a, b) => b.count.compareTo(a.count));

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('تقرير حسب المحافظة', dateStr),
              pw.SizedBox(height: 20),
              _buildSummaryBox('إجمالي المستفيدين', total.toString()),
              pw.SizedBox(height: 20),
              _buildTable(
                headers: ['النسبة المئوية', 'العدد', 'المحافظة'],
                rows: sortedData.map((item) {
                  final percentage = total == 0
                      ? 0.0
                      : (item.count / total) * 100;
                  return [
                    '${percentage.toStringAsFixed(1)}%',
                    item.count.toString(),
                    item.governorate,
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Export Age Report to PDF
  static Future<Uint8List> exportAgeReport({
    required List<AgeCount> data,
    required int total,
  }) async {
    await initialize();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('تقرير حسب الفئة العمرية', dateStr),
              pw.SizedBox(height: 20),
              _buildSummaryBox('إجمالي المستفيدين', total.toString()),
              pw.SizedBox(height: 20),
              _buildTable(
                headers: ['النسبة المئوية', 'العدد', 'الفئة العمرية'],
                rows: data.map((item) {
                  final percentage = total == 0
                      ? 0.0
                      : (item.count / total) * 100;
                  return [
                    '${percentage.toStringAsFixed(1)}%',
                    item.count.toString(),
                    '${item.ageBracket} سنة',
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Export Sync Status Report to PDF
  static Future<Uint8List> exportSyncStatusReport({
    required List<SyncStatusCount> data,
  }) async {
    await initialize();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';
    final total = data.fold(0, (sum, item) => sum + item.count);

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('تقرير حالة المزامنة', dateStr),
              pw.SizedBox(height: 20),
              _buildSummaryBox('إجمالي المستفيدين', total.toString()),
              pw.SizedBox(height: 20),
              _buildTable(
                headers: ['النسبة المئوية', 'العدد', 'الحالة'],
                rows: data.map((item) {
                  final percentage = total == 0
                      ? 0.0
                      : (item.count / total) * 100;
                  return [
                    '${percentage.toStringAsFixed(1)}%',
                    item.count.toString(),
                    item.status,
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build PDF header
  static pw.Widget _buildHeader(String title, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'التاريخ: $date',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
            font: _arabicFont,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build summary box
  static pw.Widget _buildSummaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              font: _arabicFont,
            ),
          ),
          pw.Text(label, style: pw.TextStyle(fontSize: 16, font: _arabicFont)),
        ],
      ),
    );
  }

  /// Build table
  static pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: _arabicFont,
                ),
                textAlign: pw.TextAlign.center,
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...rows.map((row) {
          return pw.TableRow(
            children: row.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  cell,
                  style: pw.TextStyle(font: _arabicFont),
                  textAlign: pw.TextAlign.center,
                ),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'تم إنشاء التقرير بواسطة تطبيق بناء',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
            font: _arabicFont,
          ),
        ),
      ],
    );
  }

  /// Share or print PDF
  static Future<void> shareOrPrint(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  /// Save PDF to file
  static Future<File> savePdf(Uint8List pdfBytes, String filePath) async {
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  /// Save PDF to file and return path
  static Future<String> savePdfToFile(
    Uint8List pdfBytes,
    String filename,
  ) async {
    final directory = await Directory.systemTemp.createTemp();
    final filePath = '${directory.path}/$filename';
    await savePdf(pdfBytes, filePath);
    return filePath;
  }

  /// Export Custom Report (for custom reports page)
  static Future<Uint8List> exportCustomReport({
    required String title,
    DateTime? startDate,
    DateTime? endDate,
    required List<String> selectedReports,
    required List<String> selectedFields,
    required bool includeCharts,
    required bool includeDetails,
    required Map<String, dynamic> data,
  }) async {
    await initialize();

    final pdf = pw.Document();

    // Build pages based on selected reports
    final pages = <pw.Widget>[];

    // Add title page
    pages.add(_buildCustomReportTitle(title, startDate, endDate));

    // Add selected reports
    if (selectedReports.contains('summary') && data.containsKey('summary')) {
      pages.add(_buildSummarySection(data['summary'], selectedFields));
    }

    if (selectedReports.contains('gender') && data.containsKey('gender')) {
      pages.add(_buildGenderSection(data['gender']));
    }

    if (selectedReports.contains('governorate') &&
        data.containsKey('governorate')) {
      pages.add(_buildGovernorateSection(data['governorate']));
    }

    if (selectedReports.contains('category') && data.containsKey('category')) {
      pages.add(_buildCategorySection(data['category']));
    }

    if (selectedReports.contains('age') && data.containsKey('age')) {
      pages.add(_buildAgeSection(data['age']));
    }

    if (selectedReports.contains('sync') && data.containsKey('sync')) {
      pages.add(_buildSyncSection(data['sync']));
    }

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (context) => pages,
        footer: (context) => _buildFooter(),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCustomReportTitle(
    String title,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              font: _arabicFont,
            ),
          ),
          pw.SizedBox(height: 10),
          if (startDate != null || endDate != null)
            pw.Text(
              'الفترة: ${startDate != null ? '${startDate.year}/${startDate.month}/${startDate.day}' : '...'} - ${endDate != null ? '${endDate.year}/${endDate.month}/${endDate.day}' : '...'}',
              style: pw.TextStyle(fontSize: 12, font: _arabicFont),
            ),
          pw.Divider(),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(dynamic summary, List<String> fields) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ملخص الإحصائيات',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        if (fields.contains('total'))
          _buildStatRow('إجمالي المستفيدين', summary.total.toString()),
        if (fields.contains('orphans'))
          _buildStatRow('الأيتام', summary.orphans.toString()),
        if (fields.contains('poor'))
          _buildStatRow('الفقراء', summary.poor.toString()),
        if (fields.contains('pending'))
          _buildStatRow('بانتظار المزامنة', summary.pending.toString()),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildGenderSection(List<dynamic> genderData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تقرير الجنس',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        ...genderData.map(
          (item) => _buildStatRow(item.gender, item.count.toString()),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildGovernorateSection(List<dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تقرير المحافظات',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        ...data
            .take(10)
            .map(
              (item) => _buildStatRow(item.governorate, item.count.toString()),
            ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildCategorySection(List<dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تقرير الفئات',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        ...data.map(
          (item) => _buildStatRow(item.category, item.count.toString()),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildAgeSection(List<dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تقرير الأعمار',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        ...data.map(
          (item) =>
              _buildStatRow('${item.ageBracket} سنة', item.count.toString()),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildSyncSection(List<dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تقرير المزامنة',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: _arabicFont,
          ),
        ),
        pw.SizedBox(height: 10),
        ...data.map(
          (item) => _buildStatRow(item.status, item.count.toString()),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: _arabicFont)),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _arabicFont,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
