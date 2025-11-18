import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/report_data.dart';
import '../../beneficiaries/domain/entities/beneficiary.dart';

/// Service for exporting reports to Excel format
class ExcelExportService {
  /// Export Gender Report to Excel
  static Future<String> exportGenderReport({
    required List<GenderCount> data,
    required int total,
  }) async {
    final excel = Excel.createExcel();

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'تقرير الجنس');
    }
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

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'تقرير الفئات');
    }
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

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'تقرير المحافظات');
    }
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

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'تقرير الأعمار');
    }
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

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'تقرير حالة المزامنة');
    }
    final sheet = excel['تقرير حالة المزامنة'];
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

  /// Export All Beneficiaries to Excel with complete details
  static Future<String> exportAllBeneficiaries({
    required List<Beneficiary> beneficiaries,
  }) async {
    final excel = Excel.createExcel();

    // Use the default sheet and rename it
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.rename(defaultSheet, 'قائمة المستفيدين');
    }
    final sheet = excel['قائمة المستفيدين'];
    sheet.isRTL = true;

    final now = DateTime.now();

    // Header - Title row
    sheet.appendRow([TextCellValue('قائمة شاملة بجميع المستفيدين')]);

    // Merge title cells (A1:V1) for better appearance
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('V1'),
      customValue: TextCellValue('قائمة شاملة بجميع المستفيدين'),
    );

    // Date row
    sheet.appendRow([
      TextCellValue('التاريخ: ${now.day}/${now.month}/${now.year}'),
    ]);
    sheet.appendRow([]); // Empty row

    // Summary row
    sheet.appendRow([
      TextCellValue('إجمالي المستفيدين:'),
      IntCellValue(beneficiaries.length),
    ]);
    sheet.appendRow([]); // Empty row before headers

    // Table headers - comprehensive columns
    sheet.appendRow([
      TextCellValue('الرقم'),
      TextCellValue('الاسم الكامل'),
      TextCellValue('رقم الهوية'),
      TextCellValue('الجنس'),
      TextCellValue('الفئة'),
      TextCellValue('تاريخ الميلاد'),
      TextCellValue('العمر'),
      TextCellValue('المحافظة'),
      TextCellValue('المديرية'),
      TextCellValue('رقم الهاتف'),
      TextCellValue('اسم الأم'),
      TextCellValue('اسم الأب'),
      TextCellValue('رقم الملف'),
      TextCellValue('حجم الأسرة'),
      TextCellValue('الحالة الاجتماعية'),
      TextCellValue('المستوى التعليمي'),
      TextCellValue('الحالة الصحية'),
      TextCellValue('ذوي احتياجات خاصة'),
      TextCellValue('حالة التشرد'),
      TextCellValue('حالة التوظيف'),
      TextCellValue('حالة السكن'),
      TextCellValue('تاريخ الإنشاء'),
    ]);

    // Data rows
    int rowNumber = 1;
    for (final beneficiary in beneficiaries) {
      // Calculate age
      int? age;
      if (beneficiary.birthDate != null) {
        final today = DateTime.now();
        age = today.year - beneficiary.birthDate!.year;
        if (today.month < beneficiary.birthDate!.month ||
            (today.month == beneficiary.birthDate!.month &&
                today.day < beneficiary.birthDate!.day)) {
          age--;
        }
      }

      sheet.appendRow([
        IntCellValue(rowNumber++),
        TextCellValue(beneficiary.fullName),
        TextCellValue(beneficiary.nationalId),
        TextCellValue(_getGenderLabel(beneficiary.gender)),
        TextCellValue(_getCategoryLabel(beneficiary.category)),
        TextCellValue(
          beneficiary.birthDate != null
              ? '${beneficiary.birthDate!.year}/${beneficiary.birthDate!.month}/${beneficiary.birthDate!.day}'
              : '-',
        ),
        TextCellValue(age != null ? '$age سنة' : '-'),
        TextCellValue(beneficiary.governorate ?? '-'),
        TextCellValue(beneficiary.district ?? '-'),
        TextCellValue(beneficiary.phoneNumber ?? '-'),
        TextCellValue(beneficiary.motherName ?? '-'),
        TextCellValue(beneficiary.fatherName ?? '-'),
        TextCellValue(beneficiary.fileNo ?? '-'),
        TextCellValue(beneficiary.familySize?.toString() ?? '-'),
        TextCellValue(_getMaritalStatusLabel(beneficiary.maritalStatus)),
        TextCellValue(_getEducationLevelLabel(beneficiary.educationLevel)),
        TextCellValue(_getHealthStatusLabel(beneficiary.healthStatus)),
        TextCellValue(beneficiary.hasDisability ? 'نعم' : 'لا'),
        TextCellValue(
          _getDisplacementStatusLabel(beneficiary.displacementStatus),
        ),
        TextCellValue(_getEmploymentStatusLabel(beneficiary.employmentStatus)),
        TextCellValue(_getHousingStatusLabel(beneficiary.housingStatus)),
        TextCellValue(
          '${beneficiary.createdAt.year}/${beneficiary.createdAt.month}/${beneficiary.createdAt.day}',
        ),
      ]);
    }

    // Style header row (row 5 is the table header)
    _styleHeaderRow(sheet, 5);

    // Style title rows
    _styleTitleRows(sheet);

    // Auto-size columns for beneficiary list
    _autoSizeColumnsForBeneficiaries(sheet);

    return _saveExcelFile(excel, 'all_beneficiaries');
  }

  // Helper methods for converting enums to Arabic labels
  static String _getGenderLabel(Gender gender) {
    return gender.arabicLabel;
  }

  static String _getCategoryLabel(BeneficiaryCategory category) {
    return category.arabicLabel;
  }

  static String _getMaritalStatusLabel(MaritalStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  static String _getEducationLevelLabel(EducationLevel? level) {
    return level?.arabicLabel ?? '-';
  }

  static String _getHealthStatusLabel(HealthStatus status) {
    return status.arabicLabel;
  }

  static String _getDisplacementStatusLabel(DisplacementStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  static String _getEmploymentStatusLabel(EmploymentStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  static String _getHousingStatusLabel(HousingStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Style header row with bold formatting
  static void _styleHeaderRow(Sheet sheet, int rowIndex) {
    final headerRow = sheet.row(rowIndex);
    for (final cell in headerRow) {
      if (cell != null) {
        cell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontSize: 11,
          underline: Underline.Single, // Add underline for emphasis
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

  /// Auto-size columns for beneficiary list (wider columns for more data)
  static void _autoSizeColumnsForBeneficiaries(Sheet sheet) {
    // Set specific column widths for beneficiary data
    sheet.setColumnWidth(0, 8); // الرقم
    sheet.setColumnWidth(1, 30); // الاسم الكامل (wide)
    sheet.setColumnWidth(2, 18); // رقم الهوية
    sheet.setColumnWidth(3, 12); // الجنس
    sheet.setColumnWidth(4, 22); // الفئة
    sheet.setColumnWidth(5, 15); // تاريخ الميلاد
    sheet.setColumnWidth(6, 12); // العمر
    sheet.setColumnWidth(7, 18); // المحافظة
    sheet.setColumnWidth(8, 18); // المديرية
    sheet.setColumnWidth(9, 16); // رقم الهاتف
    sheet.setColumnWidth(10, 25); // اسم الأم
    sheet.setColumnWidth(11, 25); // اسم الأب
    sheet.setColumnWidth(12, 14); // رقم الملف
    sheet.setColumnWidth(13, 12); // حجم الأسرة
    sheet.setColumnWidth(14, 18); // الحالة الاجتماعية
    sheet.setColumnWidth(15, 18); // المستوى التعليمي
    sheet.setColumnWidth(16, 15); // الحالة الصحية
    sheet.setColumnWidth(17, 20); // ذوي احتياجات خاصة
    sheet.setColumnWidth(18, 15); // حالة التشرد
    sheet.setColumnWidth(19, 15); // حالة التوظيف
    sheet.setColumnWidth(20, 15); // حالة السكن
    sheet.setColumnWidth(21, 16); // تاريخ الإنشاء
  }

  /// Style title rows (first rows)
  static void _styleTitleRows(Sheet sheet) {
    // Style title row (row 0) - bold and large
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Style date row (row 1) - smaller font
    final dateCell = sheet.cell(CellIndex.indexByString('A2'));
    dateCell.cellStyle = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Style summary label (row 3) - bold
    final summaryLabelCell = sheet.cell(CellIndex.indexByString('A4'));
    summaryLabelCell.cellStyle = CellStyle(bold: true, fontSize: 12);

    // Style summary value (row 3) - bold and centered
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
