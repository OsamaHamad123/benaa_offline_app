/// 📊 Unified Excel Export Service - Application-wide Excel export
///
/// خدمة موحدة لتصدير Excel في كامل التطبيق
/// تدعم: المستفيدين، الزيارات، الأنشطة، التقارير

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

import 'export_models.dart';
import 'base_export_service.dart';

/// خدمة تصدير Excel موحدة
class UnifiedExcelExportService implements BaseExportService {
  @override
  Future<ExportResult> exportToExcel(ExportData data) async {
    try {
      String filePath;

      // اختيار الطريقة المناسبة حسب نوع البيانات
      if (data is BeneficiariesExportData) {
        filePath = await _exportBeneficiaries(data);
      } else if (data is VisitsExportData) {
        filePath = await _exportVisits(data);
      } else if (data is ActivitiesExportData) {
        filePath = await _exportActivities(data);
      } else if (data is ComprehensiveBeneficiariesExportData) {
        filePath = await _exportComprehensiveBeneficiaries(data);
      } else if (data is ReportExportData) {
        filePath = await _exportReport(data);
      } else {
        throw UnsupportedError('Unsupported export data type');
      }

      return ExportResult.success(filePath: filePath, type: ExportType.excel);
    } catch (e) {
      return ExportResult.failure(
        errorMessage: e.toString(),
        type: ExportType.excel,
      );
    }
  }

  /// تصدير قائمة المستفيدين
  Future<String> _exportBeneficiaries(BeneficiariesExportData data) async {
    final excel = Excel.createExcel();

    // استخدام الشيت الافتراضي وتسميته
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'المستفيدين');
    }
    final sheet = excel['المستفيدين'];

    // تفعيل RTL
    sheet.isRTL = true;

    // إضافة العنوان
    sheet.appendRow([TextCellValue(data.title)]);
    if (data.subtitle != null) {
      sheet.appendRow([TextCellValue(data.subtitle!)]);
    }
    sheet.appendRow([
      TextCellValue('التاريخ: ${data.formattedDate} - ${data.formattedTime}'),
    ]);
    sheet.appendRow([]); // Empty row

    // إضافة الإحصائيات (إن وجدت)
    if (data.statistics != null && data.statistics!.isNotEmpty) {
      for (final stat in data.statistics!) {
        sheet.appendRow([TextCellValue(stat.label), TextCellValue(stat.value)]);
      }
      sheet.appendRow([]); // Empty row
    }

    // إضافة الجدول
    final table = data.toTable();
    _appendTable(sheet, table);

    // التنسيق
    _styleSheet(sheet, hasStatistics: data.statistics?.isNotEmpty ?? false);

    // حفظ الملف
    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.excel,
      timestamp: data.timestamp,
    );

    return _saveExcelFile(excel, fileName);
  }

  /// تصدير قائمة الزيارات
  Future<String> _exportVisits(VisitsExportData data) async {
    final excel = Excel.createExcel();

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'الزيارات');
    }
    final sheet = excel['الزيارات'];
    sheet.isRTL = true;

    // Header
    sheet.appendRow([TextCellValue(data.title)]);
    if (data.subtitle != null) {
      sheet.appendRow([TextCellValue(data.subtitle!)]);
    }
    sheet.appendRow([
      TextCellValue('التاريخ: ${data.formattedDate} - ${data.formattedTime}'),
    ]);
    sheet.appendRow([]);

    // Statistics
    if (data.statistics != null && data.statistics!.isNotEmpty) {
      for (final stat in data.statistics!) {
        sheet.appendRow([TextCellValue(stat.label), TextCellValue(stat.value)]);
      }
      sheet.appendRow([]);
    }

    // Table
    final table = data.toTable();
    _appendTable(sheet, table);

    _styleSheet(sheet, hasStatistics: data.statistics?.isNotEmpty ?? false);

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.excel,
      timestamp: data.timestamp,
    );

    return _saveExcelFile(excel, fileName);
  }

  /// تصدير الأنشطة
  Future<String> _exportActivities(ActivitiesExportData data) async {
    final excel = Excel.createExcel();

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'الأنشطة');
    }
    final sheet = excel['الأنشطة'];
    sheet.isRTL = true;

    // Header
    sheet.appendRow([TextCellValue(data.title)]);
    if (data.subtitle != null) {
      sheet.appendRow([TextCellValue(data.subtitle!)]);
    }
    sheet.appendRow([
      TextCellValue('التاريخ: ${data.formattedDate} - ${data.formattedTime}'),
    ]);
    sheet.appendRow([]);

    // Statistics
    if (data.statistics != null && data.statistics!.isNotEmpty) {
      for (final stat in data.statistics!) {
        sheet.appendRow([TextCellValue(stat.label), TextCellValue(stat.value)]);
      }
      sheet.appendRow([]);
    }

    // Table
    final table = data.toTable();
    _appendTable(sheet, table);

    _styleSheet(sheet, hasStatistics: data.statistics?.isNotEmpty ?? false);

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.excel,
      timestamp: data.timestamp,
    );

    return _saveExcelFile(excel, fileName);
  }

  /// تصدير شامل للمستفيدين
  Future<String> _exportComprehensiveBeneficiaries(
    ComprehensiveBeneficiariesExportData data,
  ) async {
    final excel = Excel.createExcel();
    final tables = data.getAllTables();

    // إنشاء شيت لكل جدول
    for (var i = 0; i < tables.length; i++) {
      final table = tables[i];
      final sheetName = table.title ?? 'Sheet ${i + 1}';

      // حذف الشيت الافتراضي في المرة الأولى فقط
      if (i == 0) {
        final defaultSheet = excel.getDefaultSheet();
        if (defaultSheet != null && defaultSheet != sheetName) {
          excel.delete(defaultSheet);
        }
      }

      final sheet = excel[sheetName];
      sheet.isRTL = true;

      // Header (في الشيت الأول فقط)
      if (i == 0) {
        sheet.appendRow([TextCellValue(data.title)]);
        if (data.subtitle != null) {
          sheet.appendRow([TextCellValue(data.subtitle!)]);
        }
        sheet.appendRow([
          TextCellValue(
            'التاريخ: ${data.formattedDate} - ${data.formattedTime}',
          ),
        ]);
        sheet.appendRow([]);

        // Statistics
        if (data.statistics != null && data.statistics!.isNotEmpty) {
          for (final stat in data.statistics!) {
            sheet.appendRow([
              TextCellValue(stat.label),
              TextCellValue(stat.value),
            ]);
          }
          sheet.appendRow([]);
        }
      }

      // Table title
      if (table.title != null) {
        sheet.appendRow([TextCellValue(table.title!)]);
      }

      // Table data
      _appendTable(sheet, table);

      _styleSheet(
        sheet,
        hasStatistics: i == 0 && (data.statistics?.isNotEmpty ?? false),
      );
    }

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.excel,
      timestamp: data.timestamp,
    );

    return _saveExcelFile(excel, fileName);
  }

  /// تصدير التقرير
  Future<String> _exportReport(ReportExportData data) async {
    final excel = Excel.createExcel();

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'التقرير');
    }
    final sheet = excel['التقرير'];
    sheet.isRTL = true;

    // Header
    sheet.appendRow([TextCellValue(data.title)]);
    if (data.subtitle != null) {
      sheet.appendRow([TextCellValue(data.subtitle!)]);
    }
    sheet.appendRow([
      TextCellValue('التاريخ: ${data.formattedDate} - ${data.formattedTime}'),
    ]);
    sheet.appendRow([]);

    // Statistics
    if (data.statistics != null && data.statistics!.isNotEmpty) {
      for (final stat in data.statistics!) {
        sheet.appendRow([TextCellValue(stat.label), TextCellValue(stat.value)]);
      }
      sheet.appendRow([]);
    }

    // Multiple tables
    for (final table in data.tables) {
      if (table.title != null) {
        sheet.appendRow([TextCellValue(table.title!)]);
        sheet.appendRow([]);
      }
      _appendTable(sheet, table);
      sheet.appendRow([]); // Empty row between tables
    }

    _styleSheet(sheet, hasStatistics: data.statistics?.isNotEmpty ?? false);

    final fileName = ExportFileNameBuilder.build(
      contentType: data.contentType,
      exportType: ExportType.excel,
      timestamp: data.timestamp,
    );

    return _saveExcelFile(excel, fileName);
  }

  /// إضافة جدول إلى الشيت
  void _appendTable(Sheet sheet, ExportTable table) {
    if (table.isEmpty) {
      sheet.appendRow([TextCellValue('لا توجد بيانات')]);
      return;
    }

    // Table headers
    sheet.appendRow(table.headers.map((h) => TextCellValue(h)).toList());

    // Table rows
    for (final row in table.rows) {
      sheet.appendRow(
        row.map((cell) {
          // Try to parse as integer
          final intValue = int.tryParse(cell);
          if (intValue != null) {
            return IntCellValue(intValue);
          }
          // Try to parse as double
          final doubleValue = double.tryParse(cell);
          if (doubleValue != null) {
            return DoubleCellValue(doubleValue);
          }
          // Default to text
          return TextCellValue(cell);
        }).toList(),
      );
    }
  }

  /// تنسيق الشيت
  void _styleSheet(Sheet sheet, {bool hasStatistics = false}) {
    // Style title row (row 0)
    _styleCellBold(sheet, row: 0, col: 0);

    // Style date row at row 2
    // (title, subtitle?, date are the first rows)

    // Statistics styling can be added here if needed

    // Auto-size columns
    _autoSizeColumns(sheet);
  }

  /// تنسيق خلية بالخط العريض
  void _styleCellBold(Sheet sheet, {required int row, required int col}) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.cellStyle = CellStyle(bold: true, fontSize: 14);
  }

  /// تحديد حجم الأعمدة تلقائياً
  void _autoSizeColumns(Sheet sheet) {
    if (sheet.maxColumns == 0) return;

    for (int col = 0; col < sheet.maxColumns; col++) {
      int maxLength = 10; // minimum width

      for (int row = 0; row < sheet.maxRows; row++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
        );
        final value = cell.value?.toString() ?? '';
        if (value.length > maxLength) {
          maxLength = value.length;
        }
      }

      // Set column width (Excel width units)
      // Each character is roughly 1.2 units in Excel
      sheet.setColumnWidth(col, (maxLength * 1.5).clamp(10, 50).toDouble());
    }
  }

  /// حفظ الملف
  Future<String> _saveExcelFile(Excel excel, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final filePath = '${exportsDir.path}/$fileName';

    // Encode to bytes and save
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  @override
  Future<void> openFile(String filePath) async {
    if (Platform.isAndroid) {
      await OpenFile.open(filePath);
    } else if (Platform.isIOS) {
      // On iOS, use share sheet
      await shareFile(filePath);
    }
  }

  @override
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'ملف Excel من تطبيق بناء');
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
  Future<ExportResult> exportToCsv(ExportData data) {
    throw UnimplementedError('استخدم UnifiedCsvExportService');
  }
}
