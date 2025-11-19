import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/report_data.dart';
import '../domain/entities/summary_statistics.dart';

/// CSV Export Service - تصدير التقارير بصيغة CSV
class CsvExportService {
  /// Export Gender Report to CSV
  static Future<String> exportGenderReport({
    required List<GenderCount> data,
    required int total,
  }) async {
    final csvData = StringBuffer();
    csvData.writeln('الجنس,العدد,النسبة المئوية');

    for (var item in data) {
      final percentage = total > 0
          ? (item.count / total * 100).toStringAsFixed(1)
          : '0.0';
      csvData.writeln('${item.gender},${item.count},$percentage%');
    }

    csvData.writeln();
    csvData.writeln('الإجمالي,$total,100%');

    return _saveFile(csvData.toString(), 'gender_report');
  }

  /// Export Category Report to CSV
  static Future<String> exportCategoryReport({
    required List<CategoryCount> data,
  }) async {
    final total = data.fold(0, (sum, item) => sum + item.count);
    final csvData = StringBuffer();
    csvData.writeln('الفئة,العدد,النسبة المئوية');

    for (var item in data) {
      final percentage = total > 0
          ? (item.count / total * 100).toStringAsFixed(1)
          : '0.0';
      csvData.writeln('${item.category},${item.count},$percentage%');
    }

    csvData.writeln();
    csvData.writeln('الإجمالي,$total,100%');

    return _saveFile(csvData.toString(), 'category_report');
  }

  /// Export Governorate Report to CSV
  static Future<String> exportGovernorateReport({
    required List<GovernorateCount> data,
  }) async {
    final total = data.fold(0, (sum, item) => sum + item.count);
    final csvData = StringBuffer();
    csvData.writeln('المحافظة,العدد,النسبة المئوية');

    for (var item in data) {
      final percentage = total > 0
          ? (item.count / total * 100).toStringAsFixed(1)
          : '0.0';
      csvData.writeln('${item.governorate},${item.count},$percentage%');
    }

    csvData.writeln();
    csvData.writeln('الإجمالي,$total,100%');

    return _saveFile(csvData.toString(), 'governorate_report');
  }

  /// Export Age Report to CSV
  static Future<String> exportAgeReport({required List<AgeCount> data}) async {
    final total = data.fold(0, (sum, item) => sum + item.count);
    final csvData = StringBuffer();
    csvData.writeln('الفئة العمرية,العدد,النسبة المئوية');

    for (var item in data) {
      final percentage = total > 0
          ? (item.count / total * 100).toStringAsFixed(1)
          : '0.0';
      csvData.writeln('${item.ageBracket},${item.count},$percentage%');
    }

    csvData.writeln();
    csvData.writeln('الإجمالي,$total,100%');

    return _saveFile(csvData.toString(), 'age_report');
  }

  /// Export Sync Status Report to CSV
  static Future<String> exportSyncStatusReport({
    required List<SyncStatusCount> data,
  }) async {
    final total = data.fold(0, (sum, item) => sum + item.count);
    final csvData = StringBuffer();
    csvData.writeln('حالة المزامنة,العدد,النسبة المئوية');

    for (var item in data) {
      final percentage = total > 0
          ? (item.count / total * 100).toStringAsFixed(1)
          : '0.0';
      csvData.writeln('${item.status},${item.count},$percentage%');
    }

    csvData.writeln();
    csvData.writeln('الإجمالي,$total,100%');

    return _saveFile(csvData.toString(), 'sync_status_report');
  }

  /// Export Summary Statistics to CSV
  static Future<String> exportSummaryStatistics({
    required SummaryStatistics stats,
  }) async {
    final csvData = StringBuffer();
    csvData.writeln('الإحصائية,القيمة');
    csvData.writeln('إجمالي المستفيدين,${stats.total}');
    csvData.writeln('الأيتام,${stats.orphans}');
    csvData.writeln('الفقراء,${stats.poor}');
    csvData.writeln('معلقين,${stats.pending}');

    return _saveFile(csvData.toString(), 'summary_statistics');
  }

  /// Save CSV file to temporary directory
  static Future<String> _saveFile(String csvContent, String fileName) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${fileName}_$timestamp.csv';

    final file = File(filePath);
    await file.writeAsString(
      '\uFEFF$csvContent',
    ); // UTF-8 BOM for Excel compatibility

    return filePath;
  }
}
