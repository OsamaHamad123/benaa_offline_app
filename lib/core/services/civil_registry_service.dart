import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

/// نموذج سجل مدني
class CivilRecord {
  final String nationalId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String birthDate;
  final String gender;
  final String governorate;
  final String district;

  CivilRecord({
    required this.nationalId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.birthDate,
    required this.gender,
    required this.governorate,
    required this.district,
  });

  factory CivilRecord.fromCsv(List<dynamic> row) {
    return CivilRecord(
      nationalId: row[0].toString().trim(),
      fullName: row[1].toString().trim(),
      fatherName: row[2].toString().trim(),
      motherName: row[3].toString().trim(),
      birthDate: row[4].toString().trim(),
      gender: row[5].toString().trim(),
      governorate: row[6].toString().trim(),
      district: row[7].toString().trim(),
    );
  }

  Map<String, String> toMap() {
    return {
      'nationalId': nationalId,
      'fullName': fullName,
      'fatherName': fatherName,
      'motherName': motherName,
      'birthDate': birthDate,
      'gender': gender,
      'governorate': governorate,
      'district': district,
    };
  }
}

/// خدمة البحث في السجل المدني
class CivilRegistryService {
  static List<CivilRecord>? _cachedRecords;

  /// تحميل جميع السجلات من ملف CSV
  static Future<List<CivilRecord>> loadAllRecords() async {
    if (_cachedRecords != null) {
      return _cachedRecords!;
    }

    try {
      // قراءة ملف CSV من assets
      final csvString = await rootBundle.loadString(
        'assets/data/civil_registry/test_registry.csv',
      );

      // تحويل CSV إلى قائمة
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(
        csvString,
        eol: '\n',
      );

      // تحويل البيانات إلى كائنات CivilRecord (تخطي الصف الأول - العناوين)
      _cachedRecords = csvData
          .skip(1)
          .where((row) => row.isNotEmpty && row.length >= 8)
          .map((row) => CivilRecord.fromCsv(row))
          .toList();

      return _cachedRecords!;
    } catch (e) {
      throw Exception('فشل تحميل السجل المدني: $e');
    }
  }

  /// البحث في السجل المدني
  static Future<List<CivilRecord>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final allRecords = await loadAllRecords();
    final searchQuery = query.trim().toLowerCase();

    // البحث في جميع الحقول
    return allRecords.where((record) {
      return record.nationalId.contains(searchQuery) ||
          record.fullName.toLowerCase().contains(searchQuery) ||
          record.fatherName.toLowerCase().contains(searchQuery) ||
          record.motherName.toLowerCase().contains(searchQuery) ||
          record.governorate.toLowerCase().contains(searchQuery) ||
          record.district.toLowerCase().contains(searchQuery);
    }).toList();
  }

  /// البحث بالرقم الوطني (دقيق)
  static Future<CivilRecord?> searchByNationalId(String nationalId) async {
    if (nationalId.trim().isEmpty) {
      return null;
    }

    final allRecords = await loadAllRecords();
    final searchId = nationalId.trim();

    try {
      return allRecords.firstWhere((record) => record.nationalId == searchId);
    } catch (e) {
      return null;
    }
  }

  /// البحث بالاسم (جزئي)
  static Future<List<CivilRecord>> searchByName(String name) async {
    if (name.trim().isEmpty) {
      return [];
    }

    final allRecords = await loadAllRecords();
    final searchName = name.trim().toLowerCase();

    return allRecords.where((record) {
      return record.fullName.toLowerCase().contains(searchName);
    }).toList();
  }

  /// البحث بالمحافظة
  static Future<List<CivilRecord>> searchByGovernorate(
    String governorate,
  ) async {
    if (governorate.trim().isEmpty) {
      return [];
    }

    final allRecords = await loadAllRecords();

    return allRecords.where((record) {
      return record.governorate == governorate;
    }).toList();
  }

  /// مسح الـ cache
  static void clearCache() {
    _cachedRecords = null;
  }
}
