import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/arabic_normalizer.dart';

/// خدمة البحث المباشرة في civil_registry.db
class DirectCivilSearchService {
  static Database? _db;
  static bool _isInitialized = false;

  /// تهيئة القاعدة من assets
  static Future<void> initialize() async {
    if (_isInitialized && _db != null) return;

    try {
      // الحصول على مسار التطبيق
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDir.path}/civil_registry.db';
      final dbFile = File(dbPath);

      // نسخ من assets إذا لم تكن موجودة
      if (!await dbFile.exists()) {
        print('📦 نسخ قاعدة البيانات من assets...');
        final data = await rootBundle.load(
          'assets/databases/civil_registry.db',
        );
        final bytes = data.buffer.asUint8List();
        await dbFile.create(recursive: true);
        await dbFile.writeAsBytes(bytes);
        print('✅ تم نسخ القاعدة بنجاح');
      }

      // فتح القاعدة
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      _db = await openDatabase(dbPath, readOnly: true);
      _isInitialized = true;
      print('✅ تم فتح قاعدة البيانات');
    } catch (e) {
      print('❌ خطأ في تهيئة القاعدة: $e');
      rethrow;
    }
  }

  /// البحث بالرقم الوطني
  static Future<Map<String, dynamic>?> searchByNationalId(
    String nationalId,
  ) async {
    try {
      await initialize();

      final cleanId = nationalId.trim();
      print('🔍 البحث عن الرقم الوطني: $cleanId');

      // البحث الأساسي
      var results = await _db!.rawQuery(
        'SELECT * FROM persons WHERE CI_ID_NUM = ? LIMIT 1',
        [cleanId],
      );

      // إذا لم نجد نتائج، جرب بدون مسافات
      if (results.isEmpty) {
        final noSpaces = cleanId.replaceAll(' ', '');
        print('🔄 محاولة البحث بدون مسافات: $noSpaces');
        results = await _db!.rawQuery(
          'SELECT * FROM persons WHERE REPLACE(CI_ID_NUM, " ", "") = ? LIMIT 1',
          [noSpaces],
        );
      }

      if (results.isNotEmpty) {
        print('✅ تم العثور على النتيجة: ${results.first['CI_FIRST_ARB']}');
        return results.first;
      } else {
        print('❌ لم يتم العثور على نتائج للرقم: $cleanId');
        // طباعة عينة من البيانات للتأكد
        final sample = await _db!.rawQuery(
          'SELECT CI_ID_NUM FROM persons LIMIT 5',
        );
        print(
          'عينة من الأرقام في القاعدة: ${sample.map((r) => r['CI_ID_NUM']).join(", ")}',
        );
        return null;
      }
    } catch (e) {
      print('❌ خطأ في البحث بالرقم الوطني: $e');
      return null;
    }
  }

  /// البحث بالاسم
  static Future<List<Map<String, dynamic>>> searchByName(
    String query, {
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];

    await initialize();

    final normalizedQuery = ArabicNormalizer.normalize(query);
    final words = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) return [];

    // بناء الاستعلام
    final conditions = <String>[];
    final params = <dynamic>[];

    for (final word in words) {
      conditions.add('''
        (CI_FIRST_ARB LIKE ? OR 
         CI_FATHER_ARB LIKE ? OR 
         CI_GRAND_FATHER_ARB LIKE ? OR 
         CI_FAMILY_ARB LIKE ?)
      ''');
      final likePattern = '%$word%';
      params.addAll([likePattern, likePattern, likePattern, likePattern]);
    }

    final sql =
        '''
      SELECT * FROM persons 
      WHERE ${conditions.join(' AND ')}
      LIMIT ?
    ''';

    params.add(limit);

    try {
      final results = await _db!.rawQuery(sql, params);
      return results;
    } catch (e) {
      print('❌ خطأ في البحث بالاسم: $e');
      return [];
    }
  }

  /// البحث المتقدم
  static Future<List<Map<String, dynamic>>> advancedSearch({
    String? query,
    int? sexCode,
    String? city,
    int limit = 50,
  }) async {
    await initialize();

    final conditions = <String>[];
    final params = <dynamic>[];

    // البحث بالنص
    if (query != null && query.trim().isNotEmpty) {
      try {
        final normalizedQuery = ArabicNormalizer.normalize(query);
        conditions.add('''
        (CI_FIRST_ARB LIKE ? OR 
         CI_FATHER_ARB LIKE ? OR 
         CI_GRAND_FATHER_ARB LIKE ? OR 
         CI_FAMILY_ARB LIKE ? OR
         MOTHER_NAME1 LIKE ?)
      ''');
        final likePattern = '%$normalizedQuery%';
        params.addAll([
          likePattern,
          likePattern,
          likePattern,
          likePattern,
          likePattern,
        ]);
      } catch (e) {
        print('⚠️ خطأ في تطبيع النص: $e');
        // استخدام النص الأصلي
        final likePattern = '%${query.trim()}%';
        conditions.add('''
        (CI_FIRST_ARB LIKE ? OR 
         CI_FATHER_ARB LIKE ? OR 
         CI_GRAND_FATHER_ARB LIKE ? OR 
         CI_FAMILY_ARB LIKE ? OR
         MOTHER_NAME1 LIKE ?)
      ''');
        params.addAll([
          likePattern,
          likePattern,
          likePattern,
          likePattern,
          likePattern,
        ]);
      }
    }

    // تصفية حسب الجنس
    if (sexCode != null) {
      conditions.add('CI_SEX_CD = ?');
      params.add(sexCode);
    }

    // تصفية حسب المدينة
    if (city != null && city.isNotEmpty) {
      conditions.add('CITY LIKE ?');
      params.add('%$city%');
    }

    final sql =
        '''
      SELECT * FROM persons 
      ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
      LIMIT ?
    ''';

    params.add(limit);

    try {
      final results = await _db!.rawQuery(sql, params);
      print('✅ تم العثور على ${results.length} نتيجة');
      return results;
    } catch (e) {
      print('❌ خطأ في البحث المتقدم: $e');
      return [];
    }
  }

  /// فحص عينة من الأرقام الوطنية
  static Future<List<String>> getSampleNationalIds({int limit = 10}) async {
    await initialize();

    final results = await _db!.rawQuery(
      'SELECT CI_ID_NUM FROM persons WHERE CI_ID_NUM IS NOT NULL LIMIT ?',
      [limit],
    );

    return results
        .map((r) => r['CI_ID_NUM']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// الحصول على الإحصائيات
  static Future<Map<String, dynamic>> getStatistics() async {
    await initialize();

    final personsCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons',
    );
    final malesCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 1',
    );
    final femalesCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 2',
    );
    final relationsCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM relations',
    );

    // الحصول على المحافظات
    final citiesResult = await _db!.rawQuery(
      'SELECT DISTINCT CITY FROM persons WHERE CITY IS NOT NULL AND CITY != "" ORDER BY CITY',
    );
    final cities = citiesResult
        .map((row) => row['CITY']?.toString() ?? '')
        .where((city) => city.isNotEmpty)
        .toList();

    return {
      'total': personsCount.first['count'],
      'males': malesCount.first['count'],
      'females': femalesCount.first['count'],
      'relations': relationsCount.first['count'],
      'governorates': cities,
    };
  }

  /// تحويل Map إلى نص قابل للعرض
  static String formatPersonName(Map<String, dynamic> person) {
    try {
      final parts = [
        person['CI_FIRST_ARB']?.toString() ?? '',
        person['CI_FATHER_ARB']?.toString() ?? '',
        person['CI_GRAND_FATHER_ARB']?.toString() ?? '',
        person['CI_FAMILY_ARB']?.toString() ?? '',
      ].where((p) => p.isNotEmpty);

      return parts.join(' ').trim();
    } catch (e) {
      print('⚠️ خطأ في تنسيق الاسم: $e');
      return 'غير محدد';
    }
  }

  /// الحصول على الجنس كنص
  static String formatGender(Map<String, dynamic> person) {
    try {
      final sexCode = person['CI_SEX_CD'];
      if (sexCode == 1 || sexCode == '1') return 'ذكر';
      if (sexCode == 2 || sexCode == '2') return 'أنثى';
      return 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  /// تنسيق التاريخ
  static String formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    return date.toString();
  }

  /// تنسيق أي قيمة بشكل آمن
  static String formatValue(dynamic value, [String defaultValue = 'غير محدد']) {
    if (value == null) return defaultValue;
    final str = value.toString().trim();
    return str.isEmpty ? defaultValue : str;
  }

  /// إغلاق القاعدة
  static Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _isInitialized = false;
  }
}
