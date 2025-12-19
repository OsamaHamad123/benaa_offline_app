/// 🎯 Base Export Service - Abstract interface for all export operations
///
/// كل خدمات التصدير (PDF, Excel, CSV) ترث من هذا الـ Base
/// لضمان توحيد الواجهة والسلوك

import 'dart:typed_data';
import 'export_models.dart';

/// الواجهة الأساسية لجميع خدمات التصدير
abstract class BaseExportService {
  /// تصدير إلى PDF
  Future<ExportResult> exportToPdf(ExportData data);

  /// تصدير إلى Excel
  Future<ExportResult> exportToExcel(ExportData data);

  /// تصدير إلى CSV
  Future<ExportResult> exportToCsv(ExportData data);

  /// فتح الملف المُصدَّر
  Future<void> openFile(String filePath);

  /// مشاركة الملف المُصدَّر
  Future<void> shareFile(String filePath);

  /// حذف الملف المُصدَّر (تنظيف الملفات المؤقتة)
  Future<void> deleteFile(String filePath);
}

/// مُساعد لبناء أسماء الملفات
class ExportFileNameBuilder {
  /// بناء اسم الملف من البيانات
  static String build({
    required ExportContentType contentType,
    required ExportType exportType,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';

    final prefix = _getPrefix(contentType);
    final extension = _getExtension(exportType);

    return '${prefix}_${dateStr}_$timeStr.$extension';
  }

  static String _getPrefix(ExportContentType contentType) {
    switch (contentType) {
      case ExportContentType.beneficiaries:
        return 'beneficiaries';
      case ExportContentType.visits:
        return 'visits';
      case ExportContentType.activities:
        return 'activities';
      case ExportContentType.report:
        return 'report';
      case ExportContentType.custom:
        return 'export';
    }
  }

  static String _getExtension(ExportType exportType) {
    switch (exportType) {
      case ExportType.pdf:
        return 'pdf';
      case ExportType.excel:
        return 'xlsx';
      case ExportType.csv:
        return 'csv';
    }
  }
}

/// مُساعد لحفظ الملفات
class ExportFileHelper {
  /// الحصول على مسار الحفظ
  static Future<String> getSavePath(String fileName) async {
    throw UnimplementedError('Implement in concrete service');
  }

  /// حفظ البيانات إلى ملف
  static Future<String> saveFile({
    required Uint8List data,
    required String fileName,
  }) async {
    throw UnimplementedError('Implement in concrete service');
  }

  /// قراءة ملف
  static Future<Uint8List> readFile(String filePath) async {
    throw UnimplementedError('Implement in concrete service');
  }

  /// التحقق من وجود الملف
  static Future<bool> fileExists(String filePath) async {
    throw UnimplementedError('Implement in concrete service');
  }
}
