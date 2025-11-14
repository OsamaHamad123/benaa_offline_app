import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/civil_person.dart';

/// 📂 Civil Registry Database - Direct SQLite Access
///
/// Reads from downloaded persons.db file
/// This is a SEPARATE database from AppDatabase (app.db)
class CivilRegistryDatabase {
  static CivilRegistryDatabase? _instance;
  static Database? _database;

  CivilRegistryDatabase._();

  static CivilRegistryDatabase get instance {
    _instance ??= CivilRegistryDatabase._();
    return _instance!;
  }

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDir.path, 'persons.db');

      final file = File(dbPath);
      final exists = await file.exists();

      if (!exists) {
        throw Exception(
          'قاعدة بيانات السجل المدني غير موجودة.\n'
          'الرجاء الذهاب إلى صفحة "تنزيل قاعدة بيانات السجل المدني" أولاً.\n'
          'سيتم نسخ القاعدة تلقائياً من الملفات.',
        );
      }

      // Open database WITHOUT version (existing database with data)
      final db = await openDatabase(dbPath);

      // Verify table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='persons'",
      );

      if (tables.isEmpty) {
        throw Exception('جدول persons غير موجود في قاعدة البيانات!');
      }

      // ULTRA FAST performance settings
      await db.rawQuery('PRAGMA synchronous = OFF');
      await db.rawQuery('PRAGMA journal_mode = MEMORY');
      await db.rawQuery('PRAGMA cache_size = 20000');
      await db.rawQuery('PRAGMA temp_store = MEMORY');
      await db.rawQuery('PRAGMA mmap_size = 30000000000');

      // Create simple indexes in background (NON-BLOCKING)
      _createIndexesAsync(db);

      return db;
    } catch (e) {
      print('❌ Database error: $e');
      rethrow;
    }
  }

  /// Create simple indexes ONLY (non-blocking)
  void _createIndexesAsync(Database db) async {
    try {
      final indexes = [
        'CREATE INDEX IF NOT EXISTS idx_persons_national_id ON persons(CI_ID_NUM)',
        'CREATE INDEX IF NOT EXISTS idx_persons_first_name ON persons(CI_FIRST_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_father_name ON persons(CI_FATHER_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_grand_father ON persons(CI_GRAND_FATHER_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_family_name ON persons(CI_FAMILY_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_city ON persons(CITY)',
        'CREATE INDEX IF NOT EXISTS idx_persons_gender ON persons(CI_SEX_CD)',
      ];

      for (final index in indexes) {
        await db.execute(index);
      }
    } catch (e) {
      // Indexes exist, safe to ignore
    }
  }

  /// Generate search variants for Arabic fuzzy matching
  List<String> _generateSearchVariants(String query) {
    final variants = <String>{};
    final cleaned = query.trim();

    variants.add(cleaned);

    // Alef variants
    if (cleaned.contains(RegExp(r'[أإآٱ]'))) {
      variants.add(cleaned.replaceAll(RegExp(r'[أإآٱ]'), 'ا'));
    }

    // Ta Marbuta
    if (cleaned.contains('ة')) {
      variants.add(cleaned.replaceAll('ة', 'ه'));
    }

    // Alef Maksura
    if (cleaned.contains('ى')) {
      variants.add(cleaned.replaceAll('ى', 'ي'));
    }

    return variants.toList();
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _instance = null;
    }
  }

  /// Reset instance (for testing)
  static void reset() {
    _instance = null;
    _database = null;
  }

  /// Search by National ID - Optimized
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final db = await database;
    final cleaned = nationalId.trim().replaceAll(' ', '').replaceAll('-', '');

    // Direct exact match (fastest - uses index)
    final results = await db.rawQuery(
      'SELECT * FROM persons WHERE CI_ID_NUM = ? LIMIT 1',
      [cleaned],
    );

    if (results.isNotEmpty) {
      return _mapToPerson(results.first);
    }

    return null;
  }

  /// Search by Name - ULTRA FAST (<100ms)
  Future<List<CivilPerson>> searchByName(
    String query, {
    String? governorate,
    int? genderCode,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;

    // Generate search variants
    final variants = _generateSearchVariants(query);

    final where = <String>[];
    final args = <dynamic>[];

    // Multi-variant search (LIKE pattern%)
    final patterns = <String>[];
    for (final variant in variants) {
      patterns.addAll([
        'CI_FIRST_ARB LIKE ?',
        'CI_FATHER_ARB LIKE ?',
        'CI_GRAND_FATHER_ARB LIKE ?',
        'CI_FAMILY_ARB LIKE ?',
      ]);
      args.addAll(['$variant%', '$variant%', '$variant%', '$variant%']);
    }

    where.add('(${patterns.join(' OR ')})');

    // Filters
    if (governorate != null && governorate.isNotEmpty) {
      where.add('CITY LIKE ?');
      args.add('%$governorate%');
    }

    if (genderCode != null) {
      where.add('CI_SEX_CD = ?');
      args.add(genderCode);
    }

    // Simple fast query
    final results = await db.rawQuery(
      '''
      SELECT * FROM persons
      WHERE ${where.join(' AND ')}
      ORDER BY LENGTH(CI_FIRST_ARB), CI_FIRST_ARB
      LIMIT ? OFFSET ?
      ''',
      [...args, limit, offset],
    );

    return results.map(_mapToPerson).toList();
  }

  /// Get search count - FAST
  Future<int> getSearchCount(
    String query, {
    String? governorate,
    int? genderCode,
  }) async {
    final db = await database;
    final searchVariants = _generateSearchVariants(query);

    final where = <String>[];
    final args = <dynamic>[];

    final patterns = <String>[];
    for (final variant in searchVariants) {
      patterns.add('CI_FIRST_ARB LIKE ?');
      patterns.add('CI_FATHER_ARB LIKE ?');
      patterns.add('CI_GRAND_FATHER_ARB LIKE ?');
      patterns.add('CI_FAMILY_ARB LIKE ?');
      args.addAll(['$variant%', '$variant%', '$variant%', '$variant%']);
    }

    where.add('(${patterns.join(' OR ')})');

    if (governorate != null && governorate.isNotEmpty) {
      where.add('CITY LIKE ?');
      args.add('%$governorate%');
    }

    if (genderCode != null) {
      where.add('CI_SEX_CD = ?');
      args.add(genderCode);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE ${where.join(' AND ')}',
      args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final total = await db.rawQuery('SELECT COUNT(*) as count FROM persons');
    final males = await db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 1',
    );
    final females = await db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 2',
    );

    final cities = await db.rawQuery(
      'SELECT DISTINCT CITY FROM persons WHERE CITY IS NOT NULL ORDER BY CITY LIMIT 50',
    );

    return {
      'total': Sqflite.firstIntValue(total) ?? 0,
      'males': Sqflite.firstIntValue(males) ?? 0,
      'females': Sqflite.firstIntValue(females) ?? 0,
      'relations': 0,
      'governorates': cities.map((e) => e['CITY'].toString()).toList(),
    };
  }

  /// Map database row to CivilPerson
  CivilPerson _mapToPerson(Map<String, dynamic> row) {
    return CivilPerson(
      nationalId: row['CI_ID_NUM']?.toString() ?? '',
      firstName: row['CI_FIRST_ARB'] as String? ?? '',
      fatherName: row['CI_FATHER_ARB'] as String? ?? '',
      grandFatherName: row['CI_GRAND_FATHER_ARB'] as String? ?? '',
      familyName: row['CI_FAMILY_ARB'] as String? ?? '',
      motherName: row['MOTHER_NAME1'] as String?,
      gender: Gender.fromCode(row['CI_SEX_CD'] as int?),
      birthDate: row['CI_BIRTH_DT'] as String?,
      city: row['CITY']?.toString(),
      governorate: row['CITY']?.toString(),
    );
  }
}
