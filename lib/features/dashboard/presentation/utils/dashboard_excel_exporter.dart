import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/dashboard_statistics.dart'; // ✅ Use existing model

/// Dashboard Excel Exporter
class DashboardExcelExporter {
  /// تصدير الداشبورد إلى Excel
  static Future<File?> exportToExcel(DashboardStatistics dashboard, {String? filename}) async {
    final excel = Excel.createExcel();

    // Create Statistics Sheet
    _createStatisticsSheet(excel, dashboard);

    // Remove default sheet
    excel.delete('Sheet1');

    // Save to file
    final output = await _getOutputFile(filename ?? 'dashboard_report.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await output.writeAsBytes(bytes);
      return output;
    }
    return null;
  }

  /// مشاركة Excel
  static Future<void> shareExcel(DashboardStatistics dashboard) async {
    final file = await exportToExcel(dashboard);
    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'تقرير الداشبورد Excel',
        text: 'تقرير الداشبورد - تطبيق بناء',
      );
    }
  }

  // Private Helper Methods

  static void _createStatisticsSheet(Excel excel, DashboardStatistics dashboard) {
    final sheet = excel['الإحصائيات'];

    // Header
    sheet.appendRow([
      TextCellValue('البيان'),
      TextCellValue('العدد'),
    ]);

    // Apply header style
    _styleHeaderRow(sheet, 0);

    // Data rows
    sheet.appendRow([
      TextCellValue('إجمالي المستفيدين'),
      IntCellValue(dashboard.totalBeneficiaries),
    ]);
    sheet.appendRow([
      TextCellValue('الأيتام'),
      IntCellValue(dashboard.categoryCounts['يتيم'] ?? 0),
    ]);
    sheet.appendRow([
      TextCellValue('الأرامل'),
      IntCellValue(dashboard.categoryCounts['أرملة'] ?? 0),
    ]);
    sheet.appendRow([
      TextCellValue('الفقراء'),
      IntCellValue(dashboard.categoryCounts['فقير'] ?? 0),
    ]);
    sheet.appendRow([
      TextCellValue('ذوي الإعاقة'),
      IntCellValue(dashboard.categoryCounts['معاق'] ?? 0),
    ]);

    // Set column widths
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 15);
  }

  static void _styleHeaderRow(Sheet sheet, int rowIndex) {
    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Apply style to all cells in header row
    for (var colIndex = 0; colIndex < 10; colIndex++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
      );
      cell.cellStyle = headerStyle;
    }
  }

  static Future<File> _getOutputFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }
}
