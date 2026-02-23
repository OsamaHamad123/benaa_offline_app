import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// 🖨️ PDF Generator Service
/// خدمة إنشاء ملفات PDF للطباعة

class PdfGeneratorService {
  /// إنشاء بطاقة مستفيد
  static Future<Uint8List> generateBeneficiaryCard({
    required String beneficiaryId,
    required String fullName,
    required String nationalId,
    required String? phoneNumber,
    required String? address,
    required String? dateOfBirth,
    required String? gender,
    Uint8List? photoBytes,
  }) async {
    final pdf = pw.Document();

    // تحميل الخط العربي
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    // إنشاء QR Code
    final qrData = 'BENAA:$beneficiaryId:$nationalId';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue, width: 2),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'بطاقة مستفيد',
                      style: pw.TextStyle(
                        font: arabicFontBold,
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Content
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo (if available)
                  if (photoBytes != null)
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Image(
                        pw.MemoryImage(photoBytes),
                        fit: pw.BoxFit.cover,
                      ),
                    )
                  else
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Center(
                        child: pw.Icon(
                          const pw.IconData(0xe7fd), // person icon
                          size: 40,
                          color: PdfColors.grey,
                        ),
                      ),
                    ),
                  pw.SizedBox(width: 16),

                  // Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'الاسم:',
                          fullName,
                          arabicFont,
                          arabicFontBold,
                        ),
                        _buildDetailRow(
                          'الرقم الوطني:',
                          nationalId,
                          arabicFont,
                          arabicFontBold,
                        ),
                        if (dateOfBirth != null)
                          _buildDetailRow(
                            'تاريخ الميلاد:',
                            dateOfBirth,
                            arabicFont,
                            arabicFontBold,
                          ),
                        if (gender != null)
                          _buildDetailRow(
                            'الجنس:',
                            gender,
                            arabicFont,
                            arabicFontBold,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Contact Info
              if (phoneNumber != null)
                _buildDetailRow(
                  'الهاتف:',
                  phoneNumber,
                  arabicFont,
                  arabicFontBold,
                ),
              if (address != null)
                _buildDetailRow(
                  'العنوان:',
                  address,
                  arabicFont,
                  arabicFontBold,
                ),

              pw.SizedBox(height: 12),

              // QR Code
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'رقم المستفيد: $beneficiaryId',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'تاريخ الإصدار: ${DateTime.now().toString().substring(0, 10)}',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                  pw.BarcodeWidget(
                    data: qrData,
                    barcode: pw.Barcode.qrCode(),
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  /// إنشاء تقرير كامل للمستفيد
  static Future<Uint8List> generateBeneficiaryReport({
    required String beneficiaryId,
    required String fullName,
    required Map<String, dynamic> beneficiaryData,
    required List<Map<String, dynamic>> visits,
    required List<Map<String, dynamic>> sponsorships,
    Uint8List? photoBytes,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFontBold,
        ),
        build: (context) => [
          // Header
          _buildReportHeader(fullName, beneficiaryId, arabicFont, arabicFontBold),
          pw.SizedBox(height: 20),

          // Personal Info Section
          _buildSection(
            'المعلومات الشخصية',
            [
              _buildInfoGrid(beneficiaryData, arabicFont, arabicFontBold),
            ],
            arabicFontBold,
          ),
          pw.SizedBox(height: 20),

          // Visits Section
          if (visits.isNotEmpty)
            _buildSection(
              'سجل الزيارات (${visits.length})',
              [
                _buildVisitsTable(visits, arabicFont, arabicFontBold),
              ],
              arabicFontBold,
            ),
          pw.SizedBox(height: 20),

          // Sponsorships Section
          if (sponsorships.isNotEmpty)
            _buildSection(
              'الكفالات (${sponsorships.length})',
              [
                _buildSponsorshipsTable(sponsorships, arabicFont, arabicFontBold),
              ],
              arabicFontBold,
            ),

          // Footer
          pw.SizedBox(height: 30),
          _buildReportFooter(arabicFont),
        ],
      ),
    );

    return pdf.save();
  }

  /// إنشاء قائمة مستفيدين
  static Future<Uint8List> generateBeneficiariesList({
    required List<Map<String, dynamic>> beneficiaries,
    required String title,
    Map<String, String>? filters,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFontBold,
        ),
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: arabicFontBold,
                fontSize: 24,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(height: 10),

          // Filters (if any)
          if (filters != null && filters.isNotEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Wrap(
                spacing: 10,
                children: filters.entries
                    .map((e) => pw.Text(
                          '${e.key}: ${e.value}',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 10,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ))
                    .toList(),
              ),
            ),
          pw.SizedBox(height: 20),

          // Table
          _buildBeneficiariesTable(beneficiaries, arabicFont, arabicFontBold),

          // Footer
          pw.SizedBox(height: 20),
          _buildReportFooter(arabicFont),
        ],
      ),
    );

    return pdf.save();
  }

  // Helper methods
  static pw.Widget _buildDetailRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              '$label $value',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportHeader(
    String fullName,
    String beneficiaryId,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'تقرير مستفيد',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.white,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            fullName,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 18,
              color: PdfColors.white,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            'رقم المستفيد: $beneficiaryId',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.white,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(
    String title,
    List<pw.Widget> children,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
            color: PdfColors.blue900,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Divider(color: PdfColors.blue),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  static pw.Widget _buildInfoGrid(
    Map<String, dynamic> data,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.GridView(
      crossAxisCount: 2,
      childAspectRatio: 4,
      children: data.entries
          .map((e) => pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '${e.key}: ',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.Text(
                      '${e.value ?? "-"}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  static pw.Widget _buildVisitsTable(
    List<Map<String, dynamic>> visits,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('التاريخ', fontBold, isHeader: true),
            _buildTableCell('النوع', fontBold, isHeader: true),
            _buildTableCell('الملاحظات', fontBold, isHeader: true),
          ],
        ),
        // Rows
        ...visits.map((visit) => pw.TableRow(
              children: [
                _buildTableCell(visit['date'] ?? '-', font),
                _buildTableCell(visit['type'] ?? '-', font),
                _buildTableCell(visit['notes'] ?? '-', font),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildSponsorshipsTable(
    List<Map<String, dynamic>> sponsorships,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('النوع', fontBold, isHeader: true),
            _buildTableCell('المبلغ', fontBold, isHeader: true),
            _buildTableCell('الحالة', fontBold, isHeader: true),
            _buildTableCell('تاريخ البدء', fontBold, isHeader: true),
          ],
        ),
        // Rows
        ...sponsorships.map((s) => pw.TableRow(
              children: [
                _buildTableCell(s['type'] ?? '-', font),
                _buildTableCell(s['amount']?.toString() ?? '-', font),
                _buildTableCell(s['status'] ?? '-', font),
                _buildTableCell(s['startDate'] ?? '-', font),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildBeneficiariesTable(
    List<Map<String, dynamic>> beneficiaries,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('#', fontBold, isHeader: true),
            _buildTableCell('الاسم', fontBold, isHeader: true),
            _buildTableCell('الرقم الوطني', fontBold, isHeader: true),
            _buildTableCell('الهاتف', fontBold, isHeader: true),
            _buildTableCell('العنوان', fontBold, isHeader: true),
          ],
        ),
        // Rows
        ...beneficiaries.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final b = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell(index.toString(), font),
              _buildTableCell(b['name'] ?? '-', font),
              _buildTableCell(b['nationalId'] ?? '-', font),
              _buildTableCell(b['phone'] ?? '-', font),
              _buildTableCell(b['address'] ?? '-', font),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  static pw.Widget _buildReportFooter(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'منظومة بناء - إدارة المستفيدين',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          'تاريخ الطباعة: ${DateTime.now().toString().substring(0, 16)}',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }
}
