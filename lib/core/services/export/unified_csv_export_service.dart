/// 📑 Unified CSV Export Service - Application-wide CSV export
///
/// خدمة موحدة لتصدير CSV في كامل التطبيق
/// تدعم: المستفيدين، الزيارات، الأنشطة، التقارير
/// مع دعم كامل للعربية UTF-8
library;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

import 'export_models.dart';
import 'base_export_service.dart';

/// خدمة تصدير CSV موحدة
class UnifiedCsvExportService implements BaseExportService {
  @override
  Future<ExportResult> exportToCsv(ExportData data) async {
    try {
      String filePath;

      // اختيار الطريقة المناسبة حسب نوع البيانات
      if (data is BeneficiariesExportData) {
        filePath = await _exportBeneficiaries(data);
      } else if (data is VisitsExportData) {
        filePath = await _exportVisits(data);
      } else if (data is ReportExportData) {
        filePath = await _exportReport(data);
      } else {
        throw UnsupportedError('Unsupported export data type');
      }

      return ExportResult.success(filePath: filePath, type: ExportType.csv);
    } catch (e) {
      return ExportResult.failure(
        errorMessage: e.toString(),
        type: ExportType.csv,
      );
    }
  }

  /// تصدير قائمة المستفيدين
  Future<String> _exportBeneficiaries(BeneficiariesExportData data) async {
    final table = data.toTable();
    final csvContent = _tableToCsv(table);

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.csv,
      timestamp: data.timestamp,
    );

    return _saveToFile(csvContent, fileName);
  }

  /// تصدير قائمة الزيارات
  Future<String> _exportVisits(VisitsExportData data) async {
    final table = data.toTable();
    final csvContent = _tableToCsv(table);

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.csv,
      timestamp: data.timestamp,
    );

    return _saveToFile(csvContent, fileName);
  }

  /// تصدير التقرير
  Future<String> _exportReport(ReportExportData data) async {
    final buffer = StringBuffer();

    // Add title
    buffer.writeln(_escapeCsv(data.title));
    buffer.writeln(); // Empty line

    // Add statistics
    if (data.statistics != null && data.statistics!.isNotEmpty) {
      for (final stat in data.statistics!) {
        buffer.writeln('${_escapeCsv(stat.label)},${_escapeCsv(stat.value)}');
      }
      buffer.writeln(); // Empty line
    }

    // Add tables
    for (final table in data.tables) {
      if (table.title != null) {
        buffer.writeln(_escapeCsv(table.title!));
        buffer.writeln(); // Empty line
      }

      buffer.write(_tableToCsv(table));
      buffer.writeln(); // Empty line between tables
    }

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.csv,
      timestamp: data.timestamp,
    );

    return _saveToFile(buffer.toString(), fileName);
  }

  /// تحويل جدول إلى CSV
  String _tableToCsv(ExportTable table) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(table.headers.map(_escapeCsv).join(','));

    // Add rows
    for (final row in table.rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    return buffer.toString();
  }

  /// Escape CSV special characters
  String _escapeCsv(String value) {
    // If value contains comma, newline, or double quote, wrap in quotes
    if (value.contains(',') || value.contains('\n') || value.contains('"') || value.contains('\r')) {
      // Escape double quotes by doubling them
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }

  /// حفظ الملف
  Future<String> _saveToFile(String csvContent, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final filePath = '${exportsDir.path}/$fileName';

    // Write with UTF-8 encoding (supports Arabic)
    final file = File(filePath);
    await file.writeAsString(csvContent);

    return filePath;
  }

  @override
  Future<void> openFile(String filePath) async {
    if (Platform.isAndroid) {
      await OpenFile.open(filePath);
    } else {
      // On other platforms, share the file
      await shareFile(filePath);
    }
  }

  @override
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'ملف CSV من تطبيق بناء');
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<ExportResult> exportToPdf(ExportData data) {
    throw UnimplementedError('استخدم UnifiedPdfExportService');
  }

  @override
  Future<ExportResult> exportToExcel(ExportData data) {
    throw UnimplementedError('استخدم UnifiedExcelExportService');
  }
}
