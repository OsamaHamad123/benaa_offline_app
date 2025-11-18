import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/report_data.dart';

/// Service for exporting reports to Excel format
class ExcelExportService {
  /// Export Gender Report to Excel
  static Future<String> exportGenderReport({
    required List<GenderCount> data,
    required int total,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير الجنس'];

    // Set RTL direction
    sheet.isRTL = true;

    // Add header
    final now = DateTime.now();
    sheet.appendRow([TextCellValue('تقرير حسب الجنس')]);
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.year}/${now.month}/${now.day}'),
    ]);
    sheet.appendRow([]); // Empty row

    // Add summary
    sheet.appendRow([TextCellValue('إجمالي المستفيدين'), IntCellValue(total)]);
    sheet.appendRow([]); // Empty row

    // Add table headers
    sheet.appendRow([
      TextCellValue('الجنس'),
      TextCellValue('العدد'),
      TextCellValue('النسبة المئوية'),
    ]);

    // Add data rows
    for (final item in data) {
      final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
      sheet.appendRow([
        TextCellValue(item.gender),
        IntCellValue(item.count),
        TextCellValue('${percentage.toStringAsFixed(1)}%'),
      ]);
    }

    // Style header cells
    _styleHeaderRow(sheet, 5); // Row 5 is the table header (0-indexed)

    // Style title and summary rows
    _styleTitleRows(sheet);

    // Auto-size columns
    _autoSizeColumns(sheet);

    // Save file
    return _saveExcelFile(excel, 'gender_report');
  }

  /// Export Category Report to Excel
  static Future<String> exportCategoryReport({
    required List<CategoryCount> data,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير الفئات'];
    sheet.isRTL = true;

    final total = data.fold(0, (sum, item) => sum + item.count);
    final now = DateTime.now();

    // Header
    sheet.appendRow([TextCellValue('تقرير حسب الفئة')]);
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.year}/${now.month}/${now.day}'),
    ]);
    sheet.appendRow([]);

    // Summary
    sheet.appendRow([TextCellValue('إجمالي المستفيدين'), IntCellValue(total)]);
    sheet.appendRow([]);

    // Table headers
    sheet.appendRow([
      TextCellValue('الفئة'),
      TextCellValue('العدد'),
      TextCellValue('النسبة المئوية'),
    ]);

    // Data rows
    for (final item in data) {
      final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
      sheet.appendRow([
        TextCellValue(item.category),
        IntCellValue(item.count),
        TextCellValue('${percentage.toStringAsFixed(1)}%'),
      ]);
    }

    _styleHeaderRow(sheet, 5);
    _styleTitleRows(sheet);
    _autoSizeColumns(sheet);
    return _saveExcelFile(excel, 'category_report');
  }

  /// Export Governorate Report to Excel
  static Future<String> exportGovernorateReport({
    required List<GovernorateCount> data,
    required int total,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المحافظات'];
    sheet.isRTL = true;

    final now = DateTime.now();
    final sortedData = List<GovernorateCount>.from(data)
      ..sort((a, b) => b.count.compareTo(a.count));

    // Header
    sheet.appendRow([TextCellValue('تقرير حسب المحافظة')]);
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.year}/${now.month}/${now.day}'),
    ]);
    sheet.appendRow([]);

    // Summary
    sheet.appendRow([TextCellValue('إجمالي المستفيدين'), IntCellValue(total)]);
    sheet.appendRow([]);

    // Table headers
    sheet.appendRow([
      TextCellValue('المحافظة'),
      TextCellValue('العدد'),
      TextCellValue('النسبة المئوية'),
    ]);

    // Data rows
    for (final item in sortedData) {
      final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
      sheet.appendRow([
        TextCellValue(item.governorate),
        IntCellValue(item.count),
        TextCellValue('${percentage.toStringAsFixed(1)}%'),
      ]);
    }

    _styleHeaderRow(sheet, 5);
    _styleTitleRows(sheet);
    _autoSizeColumns(sheet);
    return _saveExcelFile(excel, 'governorate_report');
  }

  /// Export Age Report to Excel
  static Future<String> exportAgeReport({
    required List<AgeCount> data,
    required int total,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير الأعمار'];
    sheet.isRTL = true;

    final now = DateTime.now();

    // Header
    sheet.appendRow([TextCellValue('تقرير حسب الفئة العمرية')]);
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.year}/${now.month}/${now.day}'),
    ]);
    sheet.appendRow([]);

    // Summary
    sheet.appendRow([TextCellValue('إجمالي المستفيدين'), IntCellValue(total)]);
    sheet.appendRow([]);

    // Table headers
    sheet.appendRow([
      TextCellValue('الفئة العمرية'),
      TextCellValue('العدد'),
      TextCellValue('النسبة المئوية'),
    ]);

    // Data rows
    for (final item in data) {
      final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
      sheet.appendRow([
        TextCellValue('${item.ageBracket} سنة'),
        IntCellValue(item.count),
        TextCellValue('${percentage.toStringAsFixed(1)}%'),
      ]);
    }

    _styleHeaderRow(sheet, 5);
    _styleTitleRows(sheet);
    _autoSizeColumns(sheet);
    return _saveExcelFile(excel, 'age_report');
  }

  /// Export Sync Status Report to Excel
  static Future<String> exportSyncStatusReport({
    required List<SyncStatusCount> data,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المزامنة'];
    sheet.isRTL = true;

    final total = data.fold(0, (sum, item) => sum + item.count);
    final now = DateTime.now();

    // Header
    sheet.appendRow([TextCellValue('تقرير حالة المزامنة')]);
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.year}/${now.month}/${now.day}'),
    ]);
    sheet.appendRow([]);

    // Summary
    sheet.appendRow([TextCellValue('إجمالي المستفيدين'), IntCellValue(total)]);
    sheet.appendRow([]);

    // Table headers
    sheet.appendRow([
      TextCellValue('الحالة'),
      TextCellValue('العدد'),
      TextCellValue('النسبة المئوية'),
    ]);

    // Data rows
    for (final item in data) {
      final percentage = total == 0 ? 0.0 : (item.count / total) * 100;
      sheet.appendRow([
        TextCellValue(item.status),
        IntCellValue(item.count),
        TextCellValue('${percentage.toStringAsFixed(1)}%'),
      ]);
    }

    _styleHeaderRow(sheet, 5);
    _styleTitleRows(sheet);
    _autoSizeColumns(sheet);
    return _saveExcelFile(excel, 'sync_status_report');
  }

  /// Style header row with bold and background color
  static void _styleHeaderRow(Sheet sheet, int rowIndex) {
    final headerRow = sheet.row(rowIndex);
    for (final cell in headerRow) {
      if (cell != null) {
        cell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontSize: 12,
        );
      }
    }
  }

  /// Auto-size columns for better readability
  static void _autoSizeColumns(Sheet sheet) {
    // Set column widths (A, B, C) - using setColumnWidth
    sheet.setColumnWidth(0, 25); // Column A (wider for Arabic text)
    sheet.setColumnWidth(1, 15); // Column B (numbers)
    sheet.setColumnWidth(2, 18); // Column C (percentages)
  }

  /// Style title rows (first two rows)
  static void _styleTitleRows(Sheet sheet) {
    // Style title row (row 0)
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Style date row (row 1)
    final dateCell = sheet.cell(CellIndex.indexByString('A2'));
    dateCell.cellStyle = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Style summary row (row 3)
    final summaryLabelCell = sheet.cell(CellIndex.indexByString('A4'));
    summaryLabelCell.cellStyle = CellStyle(bold: true, fontSize: 12);
    final summaryValueCell = sheet.cell(CellIndex.indexByString('B4'));
    summaryValueCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  /// Save Excel file to temporary directory and return file path
  static Future<String> _saveExcelFile(Excel excel, String filename) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${filename}_$timestamp.xlsx';

    final file = File(filePath);
    final excelBytes = excel.encode();

    if (excelBytes != null) {
      await file.writeAsBytes(excelBytes);
      return filePath;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }
}
