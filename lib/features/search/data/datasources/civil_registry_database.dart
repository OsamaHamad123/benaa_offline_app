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

      // Enable performance optimizations
      await db.rawQuery('PRAGMA cache_size = 10000');
      await db.rawQuery('PRAGMA temp_store = MEMORY');
      await db.rawQuery('PRAGMA mmap_size = 30000000000');
      await db.rawQuery('PRAGMA page_size = 4096');

      // Create indexes in background (non-blocking)
      _createIndexesAsync(db);

      return db;
    } catch (e) {
      print('❌ Database error: $e');
      rethrow;
    }
  }

  /// Create indexes for better search performance (async - non-blocking)
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
        'CREATE INDEX IF NOT EXISTS idx_persons_composite ON persons(CI_FIRST_ARB, CI_FATHER_ARB, CI_FAMILY_ARB)',
      ];

      for (final index in indexes) {
        await db.execute(index);
      }
    } catch (e) {
      // Indexes might already exist, safe to ignore
    }
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

    // Single optimized query with OR condition
    final results = await db.rawQuery(
      '''
      SELECT * FROM persons 
      WHERE CI_ID_NUM = ? OR CAST(CI_ID_NUM AS TEXT) LIKE ?
      LIMIT 1
      ''',
      [cleaned, '%$cleaned%'],
    );

    if (results.isNotEmpty) {
      return _mapToPerson(results.first);
    }

    return null;
  }

  /// Search by Name - Optimized with better SQL
  Future<List<CivilPerson>> searchByName(
    String query, {
    String? governorate,
    int? genderCode,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    final normalized = _normalizeName(query);
    final pattern = '%$normalized%';

    final where = <String>[];
    final args = <dynamic>[];

    // Optimized name search with priority (first name first)
    where.add(
      '(CI_FIRST_ARB LIKE ? COLLATE NOCASE OR CI_FATHER_ARB LIKE ? COLLATE NOCASE OR CI_GRAND_FATHER_ARB LIKE ? COLLATE NOCASE OR CI_FAMILY_ARB LIKE ? COLLATE NOCASE)',
    );
    args.addAll([pattern, pattern, pattern, pattern]);

    // Filters
    if (governorate != null && governorate.isNotEmpty) {
      where.add('CITY LIKE ? COLLATE NOCASE');
      args.add('%$governorate%');
    }

    if (genderCode != null) {
      where.add('CI_SEX_CD = ?');
      args.add(genderCode);
    }

    // Use raw query for better performance with ORDER BY optimization
    final results = await db.rawQuery(
      '''
      SELECT * FROM persons
      WHERE ${where.join(' AND ')}
      ORDER BY 
        CASE 
          WHEN CI_FIRST_ARB LIKE ? THEN 1
          WHEN CI_FATHER_ARB LIKE ? THEN 2
          WHEN CI_GRAND_FATHER_ARB LIKE ? THEN 3
          ELSE 4
        END,
        CI_FIRST_ARB
      LIMIT ? OFFSET ?
      ''',
      [...args, pattern, pattern, pattern, limit, offset],
    );

    return results.map(_mapToPerson).toList();
  }

  /// Get search count
  Future<int> getSearchCount(
    String query, {
    String? governorate,
    int? genderCode,
  }) async {
    final db = await database;
    final normalized = _normalizeName(query);
    final pattern = '%$normalized%';

    final where = <String>[];
    final args = <dynamic>[];

    where.add(
      '(CI_FIRST_ARB LIKE ? OR CI_FATHER_ARB LIKE ? OR CI_GRAND_FATHER_ARB LIKE ? OR CI_FAMILY_ARB LIKE ?)',
    );
    args.addAll([pattern, pattern, pattern, pattern]);

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

  /// Normalize name for Arabic search
  String _normalizeName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
