import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/civil_person.dart';

/// 📂 Civil Registry Database - Direct SQLite Access
///
/// Reads from downloaded civil_registry.db file
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
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'civil_registry.db');

    print('📂 Looking for database at: $dbPath');

    final file = File(dbPath);
    final exists = await file.exists();
    print('📊 Database exists: $exists');

    if (!exists) {
      throw Exception(
        'قاعدة بيانات السجل المدني غير موجودة. قم بتنزيلها أولاً.',
      );
    }

    print('🔓 Opening database...');
    final db = await openDatabase(
      dbPath,
      readOnly: false,
      singleInstance: true,
      version: 1,
      onCreate: (db, version) async {
        // This won't be called for existing databases
        await _createIndexes(db);
      },
    );

    print('✅ Database opened successfully');

    // Create indexes if they don't exist (for existing databases)
    await _createIndexes(db);

    // Test query
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM persons');
    print('📊 Total persons in database: ${Sqflite.firstIntValue(count)}');

    return db;
  }

  /// Create indexes for better search performance
  Future<void> _createIndexes(Database db) async {
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_national_id ON persons(CI_ID_NUM)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_first_name ON persons(CI_FIRST_ARB)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_father_name ON persons(CI_FATHER_ARB)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_grand_father ON persons(CI_GRAND_FATHER_ARB)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_family_name ON persons(CI_FAMILY_ARB)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_city ON persons(CITY)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_persons_gender ON persons(CI_SEX_CD)',
      );
    } catch (e) {
      // Indexes might already exist
      print('⚠️ Warning: Could not create all indexes: $e');
    }
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Search by National ID
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final db = await database;
    final cleaned = nationalId.trim().replaceAll(' ', '');

    // Level 1: Exact match
    var results = await db.query(
      'persons',
      where: 'CI_ID_NUM = ?',
      whereArgs: [cleaned],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return _mapToPerson(results.first);
    }

    // Level 2: LIKE search for flexibility
    results = await db.rawQuery(
      'SELECT * FROM persons WHERE CAST(CI_ID_NUM AS TEXT) LIKE ? LIMIT 1',
      ['%$cleaned%'],
    );

    if (results.isNotEmpty) {
      return _mapToPerson(results.first);
    }

    return null;
  }

  /// Search by Name
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

    // Name search (no full_name_normalized column, search individual names)
    where.add(
      '(CI_FIRST_ARB LIKE ? OR CI_FATHER_ARB LIKE ? OR CI_GRAND_FATHER_ARB LIKE ? OR CI_FAMILY_ARB LIKE ?)',
    );
    args.addAll([pattern, pattern, pattern, pattern]);

    // Filters
    if (governorate != null && governorate.isNotEmpty) {
      where.add('CITY LIKE ?');
      args.add('%$governorate%');
    }

    if (genderCode != null) {
      where.add('CI_SEX_CD = ?');
      args.add(genderCode);
    }

    final results = await db.query(
      'persons',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'CI_FIRST_ARB',
      limit: limit,
      offset: offset,
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
