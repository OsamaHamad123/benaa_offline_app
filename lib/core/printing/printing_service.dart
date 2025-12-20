import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'pdf_generator_service.dart';

/// 🖨️ Printing Service
/// خدمة الطباعة والمعاينة

class PrintingService {
  /// طباعة بطاقة مستفيد
  static Future<void> printBeneficiaryCard({
    required String beneficiaryId,
    required String fullName,
    required String nationalId,
    required String? phoneNumber,
    required String? address,
    required String? dateOfBirth,
    required String? gender,
    Uint8List? photoBytes,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiaryCard(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      nationalId: nationalId,
      phoneNumber: phoneNumber,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      photoBytes: photoBytes,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'بطاقة_مستفيد_$beneficiaryId.pdf',
    );
  }

  /// معاينة بطاقة مستفيد
  static Future<void> previewBeneficiaryCard({
    required String beneficiaryId,
    required String fullName,
    required String nationalId,
    required String? phoneNumber,
    required String? address,
    required String? dateOfBirth,
    required String? gender,
    Uint8List? photoBytes,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiaryCard(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      nationalId: nationalId,
      phoneNumber: phoneNumber,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      photoBytes: photoBytes,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'بطاقة_مستفيد_$beneficiaryId.pdf',
    );
  }

  /// طباعة تقرير كامل
  static Future<void> printBeneficiaryReport({
    required String beneficiaryId,
    required String fullName,
    required Map<String, dynamic> beneficiaryData,
    required List<Map<String, dynamic>> visits,
    required List<Map<String, dynamic>> sponsorships,
    Uint8List? photoBytes,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiaryReport(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      beneficiaryData: beneficiaryData,
      visits: visits,
      sponsorships: sponsorships,
      photoBytes: photoBytes,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'تقرير_مستفيد_$beneficiaryId.pdf',
    );
  }

  /// معاينة تقرير كامل
  static Future<void> previewBeneficiaryReport({
    required String beneficiaryId,
    required String fullName,
    required Map<String, dynamic> beneficiaryData,
    required List<Map<String, dynamic>> visits,
    required List<Map<String, dynamic>> sponsorships,
    Uint8List? photoBytes,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiaryReport(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      beneficiaryData: beneficiaryData,
      visits: visits,
      sponsorships: sponsorships,
      photoBytes: photoBytes,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'تقرير_مستفيد_$beneficiaryId.pdf',
    );
  }

  /// طباعة قائمة مستفيدين
  static Future<void> printBeneficiariesList({
    required List<Map<String, dynamic>> beneficiaries,
    required String title,
    Map<String, String>? filters,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiariesList(
      beneficiaries: beneficiaries,
      title: title,
      filters: filters,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'قائمة_المستفيدين.pdf',
    );
  }

  /// معاينة قائمة مستفيدين
  static Future<void> previewBeneficiariesList({
    required List<Map<String, dynamic>> beneficiaries,
    required String title,
    Map<String, String>? filters,
  }) async {
    final pdfBytes = await PdfGeneratorService.generateBeneficiariesList(
      beneficiaries: beneficiaries,
      title: title,
      filters: filters,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'قائمة_المستفيدين.pdf',
    );
  }

  /// حفظ PDF كملف
  static Future<Uint8List> saveBeneficiaryCard({
    required String beneficiaryId,
    required String fullName,
    required String nationalId,
    required String? phoneNumber,
    required String? address,
    required String? dateOfBirth,
    required String? gender,
    Uint8List? photoBytes,
  }) async {
    return await PdfGeneratorService.generateBeneficiaryCard(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      nationalId: nationalId,
      phoneNumber: phoneNumber,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      photoBytes: photoBytes,
    );
  }

  /// حفظ تقرير كامل كملف
  static Future<Uint8List> saveBeneficiaryReport({
    required String beneficiaryId,
    required String fullName,
    required Map<String, dynamic> beneficiaryData,
    required List<Map<String, dynamic>> visits,
    required List<Map<String, dynamic>> sponsorships,
    Uint8List? photoBytes,
  }) async {
    return await PdfGeneratorService.generateBeneficiaryReport(
      beneficiaryId: beneficiaryId,
      fullName: fullName,
      beneficiaryData: beneficiaryData,
      visits: visits,
      sponsorships: sponsorships,
      photoBytes: photoBytes,
    );
  }

  /// حفظ قائمة مستفيدين كملف
  static Future<Uint8List> saveBeneficiariesList({
    required List<Map<String, dynamic>> beneficiaries,
    required String title,
    Map<String, String>? filters,
  }) async {
    return await PdfGeneratorService.generateBeneficiariesList(
      beneficiaries: beneficiaries,
      title: title,
      filters: filters,
    );
  }
}
