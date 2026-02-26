import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../../../core/utils/arabic_normalizer.dart';

class KafalatImportParseResult {
  final List<KafalatExcelSponsorshipRow> rows;
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int duplicateRows;
  final List<String> warnings;

  const KafalatImportParseResult({
    required this.rows,
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.duplicateRows,
    required this.warnings,
  });
}

class KafalatExcelSponsorshipRow {
  final int idNumber;
  final String beneficiaryName;
  final String guardianName;
  final int? guardianIdNumber;
  final String associationName;
  final String sponsorName;
  final String internalFileNo;
  final String externalFileNo;
  final int? durationMonths;
  final String sponsorshipPeriodText;
  final String? sponsorshipTypeCode;
  final String city;
  final String address;
  final String bankName;
  final String accountHolderName;
  final int? accountHolderIdNumber;
  final String accountLinkedMobile;
  final double? remainingAmount;
  final DateTime? addedAt;
  final int phoneNumber;
  final int altPhoneNumber;

  const KafalatExcelSponsorshipRow({
    required this.idNumber,
    required this.beneficiaryName,
    required this.guardianName,
    required this.guardianIdNumber,
    required this.associationName,
    required this.sponsorName,
    required this.internalFileNo,
    required this.externalFileNo,
    required this.durationMonths,
    required this.sponsorshipPeriodText,
    required this.sponsorshipTypeCode,
    required this.city,
    required this.address,
    required this.bankName,
    required this.accountHolderName,
    required this.accountHolderIdNumber,
    required this.accountLinkedMobile,
    required this.remainingAmount,
    required this.addedAt,
    required this.phoneNumber,
    required this.altPhoneNumber,
  });

  String get normalizedAssociationName => KafalatExcelImportParser._normalizeHeader(associationName);

  String get firstName {
    final parts = _nameParts;
    return parts.isEmpty ? '' : parts.first;
  }

  String get fatherName {
    final parts = _nameParts;
    return parts.length >= 2 ? parts[1] : '';
  }

  String get grandFatherName {
    final parts = _nameParts;
    return parts.length >= 3 ? parts[2] : '';
  }

  String get familyName {
    final parts = _nameParts;
    if (parts.length <= 3) return '';
    return parts.sublist(3).join(' ');
  }

  String get fullNameOrFallback {
    final name = beneficiaryName.trim();
    if (name.isNotEmpty) return name;
    return 'مستفيد ($idNumber)';
  }

  DateTime? get inferredPeriodStart => KafalatExcelImportParser._tryParseStartFromPeriod(sponsorshipPeriodText);
  DateTime? get inferredPeriodEnd => KafalatExcelImportParser._tryParseEndFromPeriod(sponsorshipPeriodText);

  String get dedupeSignature {
    final parts = <String>[
      idNumber.toString(),
      KafalatExcelImportParser._normalizeHeader(associationName),
      KafalatExcelImportParser._normalizeHeader(internalFileNo),
      KafalatExcelImportParser._normalizeHeader(externalFileNo),
      KafalatExcelImportParser._normalizeHeader(sponsorName),
    ];
    return parts.join('|');
  }

  List<String> get _nameParts {
    final normalized = beneficiaryName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return const <String>[];
    return normalized.split(' ').where((part) => part.trim().isNotEmpty).toList(growable: false);
  }
}

class KafalatExcelImportParser {
  const KafalatExcelImportParser();

  KafalatImportParseResult parse(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw Exception('لا توجد أوراق داخل الملف');
    }

    final sheet = excel.tables.values.first;
    final sheetRows = sheet.rows;
    if (sheetRows.isEmpty) {
      throw Exception('لا توجد بيانات');
    }

    final headers = sheetRows.first.map((cell) => _normalizeHeader(_cellToString(cell))).toList(growable: false);

    final rows = <KafalatExcelSponsorshipRow>[];
    final warnings = <String>[];
    final signatures = <String>{};

    int total = 0;
    int invalid = 0;
    int duplicates = 0;

    for (var i = 1; i < sheetRows.length; i++) {
      total++;
      final row = sheetRows[i];
      final map = <String, String>{};
      for (var j = 0; j < headers.length && j < row.length; j++) {
        final key = headers[j];
        if (key.isEmpty) continue;
        map[key] = _cellToString(row[j]).trim();
      }

      final idNumber = _parseNationalId(map);
      if (idNumber == null) {
        invalid++;
        continue;
      }

      final rowModel = KafalatExcelSponsorshipRow(
        idNumber: idNumber,
        beneficiaryName: _value(map, 'beneficiary_name'),
        guardianName: _value(map, 'guardian_name'),
        guardianIdNumber: _parseInt(_value(map, 'guardian_id_number')),
        associationName: _value(map, 'association_name'),
        sponsorName: _value(map, 'sponsor_name'),
        internalFileNo: _value(map, 'internal_file_no'),
        externalFileNo: _value(map, 'external_file_no'),
        durationMonths: _parseDurationMonths(_value(map, 'duration_months')),
        sponsorshipPeriodText: _value(map, 'sponsorship_period'),
        sponsorshipTypeCode: _parseSponsorshipType(_value(map, 'sponsorship_type')),
        city: _value(map, 'city'),
        address: _value(map, 'address'),
        bankName: _value(map, 'bank_name'),
        accountHolderName: _value(map, 'account_holder_name'),
        accountHolderIdNumber: _parseInt(_value(map, 'account_holder_id_number')),
        accountLinkedMobile: _value(map, 'account_linked_mobile'),
        remainingAmount: _parseDouble(_value(map, 'remaining_amount')),
        addedAt: _parseDate(_value(map, 'added_at')),
        phoneNumber: _parseInt(_value(map, 'phone')) ?? _parseInt(_value(map, 'account_linked_mobile')) ?? 0,
        altPhoneNumber: _parseInt(_value(map, 'alt_phone')) ?? 0,
      );

      final signature = rowModel.dedupeSignature;
      if (signatures.contains(signature)) {
        duplicates++;
        continue;
      }
      signatures.add(signature);

      if (rowModel.associationName.trim().isEmpty) {
        warnings.add('صف ${i + 1}: لا يحتوي على اسم المؤسسة الكافلة (سيستخدم الافتراضي إن وُجد).');
      }

      rows.add(rowModel);
    }

    return KafalatImportParseResult(
      rows: rows,
      totalRows: total,
      validRows: rows.length,
      invalidRows: invalid,
      duplicateRows: duplicates,
      warnings: warnings,
    );
  }

  static String _value(Map<String, String> map, String canonical) {
    final aliases = _aliases[canonical] ?? const <String>[];
    for (final alias in aliases) {
      final normalized = _normalizeHeader(alias);
      final value = map[normalized];
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    for (final entry in map.entries) {
      final key = entry.key;
      if (_isLooseMatch(canonical, key) && entry.value.trim().isNotEmpty) {
        return entry.value.trim();
      }
    }

    return '';
  }

  static bool _isLooseMatch(String canonical, String key) {
    if (canonical == 'beneficiary_name') {
      return key.contains('الاسم') || key == 'name' || key.contains('اسمالمكفول');
    }
    if (canonical == 'association_name') {
      return key.contains('المؤسسة') || key.contains('الكافلة');
    }
    if (canonical == 'sponsorship_type') {
      return key.contains('نوعالكفالة');
    }
    if (canonical == 'added_at') {
      return key.contains('تاريخ') && key.contains('الإضافة');
    }
    if (canonical == 'remaining_amount') {
      return key.contains('المتبقي');
    }
    return false;
  }

  static int? _parseNationalId(Map<String, String> map) {
    for (final alias in _aliases['id_number'] ?? const <String>[]) {
      final value = map[_normalizeHeader(alias)];
      final parsed = _parseInt(value);
      if (parsed != null) return parsed;
    }

    for (final entry in map.entries) {
      if (entry.key.contains('هوية') || entry.key.contains('id')) {
        final parsed = _parseInt(entry.value);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  static int? _parseDurationMonths(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final direct = _parseInt(raw);
    if (direct != null) return direct;

    final normalized = ArabicNormalizer.normalize(raw).toLowerCase();
    if (normalized.contains('سنة') || normalized.contains('year')) {
      final num = _parseInt(normalized);
      if (num != null) return num * 12;
    }

    return null;
  }

  static String? _parseSponsorshipType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = ArabicNormalizer.normalize(raw).toLowerCase();

    if (normalized.contains('شهر')) return 'monthly';
    if (normalized.contains('مرة') || normalized.contains('مره') || normalized.contains('one')) return 'one_time';
    return 'other';
  }

  static int? _parseInt(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static double? _parseDouble(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final normalized = s.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9\.]'), '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final direct = DateTime.tryParse(s);
    if (direct != null) return direct;

    final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$').firstMatch(s);
    if (slash != null) {
      final d = int.tryParse(slash.group(1)!);
      final m = int.tryParse(slash.group(2)!);
      final y = int.tryParse(slash.group(3)!);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }

    return null;
  }

  static DateTime? _tryParseStartFromPeriod(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final range = RegExp(r'(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}).*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4})').firstMatch(s);
    if (range == null) return null;
    return _parseDate(range.group(1));
  }

  static DateTime? _tryParseEndFromPeriod(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final range = RegExp(r'(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}).*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4})').firstMatch(s);
    if (range == null) return null;
    return _parseDate(range.group(2));
  }

  static String _cellToString(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    return value.toString();
  }

  static String _normalizeHeader(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '';

    final normalized = ArabicNormalizer.normalize(trimmed)
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll('/', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    return normalized;
  }

  static const Map<String, List<String>> _aliases = {
    'beneficiary_name': ['الإسم', 'الاسم', 'اسم المكفول', 'الاسم الكامل', 'name', 'full_name'],
    'id_number': ['رقم الهوية', 'رقم الوطني', 'الرقم الوطني', 'هوية', 'id', 'national_id'],
    'guardian_name': ['إسم المعيل', 'اسم المعيل', 'المعيل', 'guardian_name'],
    'guardian_id_number': ['رقم هوية المعيل', 'هوية المعيل', 'guardian_id', 'guardian_id_number'],
    'association_name': ['إسم المؤسسة الكافلة', 'اسم المؤسسة الكافلة', 'المؤسسة الكافلة', 'sponsoring_institution'],
    'sponsor_name': ['إسم الكافل', 'اسم الكافل', 'الكافل', 'sponsor_name'],
    'internal_file_no': ['رقم الملف الداخلي', 'الملف الداخلي', 'internal_file_no'],
    'external_file_no': ['رقم الملف الخارجي', 'الملف الخارجي', 'external_file_no'],
    'duration_months': ['مدة الكفالة', 'المدة', 'duration_months'],
    'sponsorship_period': ['فترة الكفالة', 'الفترة', 'period', 'sponsorship_period'],
    'sponsorship_type': ['نوع الكفالة', 'نوع', 'sponsorship_type'],
    'city': ['المدينة', 'city'],
    'address': ['العنوان', 'address'],
    'bank_name': ['إسم البنك', 'اسم البنك', 'bank_name'],
    'account_holder_name': ['إسم صاحب الحساب', 'اسم صاحب الحساب', 'account_holder_name'],
    'account_holder_id_number': ['رقم هوية صاحب الحساب', 'هوية صاحب الحساب', 'account_holder_id'],
    'account_linked_mobile': ['رقم الجوال المربوط بالحساب', 'جوال الحساب', 'mobile_linked_account'],
    'remaining_amount': ['المتبقي', 'remaining', 'remaining_amount'],
    'added_at': ['تاريخ الإضافة', 'تاريخ الاضافة', 'added_at', 'created_at'],
    'phone': ['الهاتف', 'رقم الهاتف', 'phone', 'phone_number'],
    'alt_phone': ['هاتف بديل', 'جوال بديل', 'alt_phone', 'alt_phone_number'],
  };
}
