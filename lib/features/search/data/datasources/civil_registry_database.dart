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

      // Safe performance settings
      await db.rawQuery('PRAGMA cache_size = 20000');
      await db.rawQuery('PRAGMA temp_store = MEMORY');

      // Create simple indexes in background (NON-BLOCKING)
      _createIndexesAsync(db);

      // Run database migrations (idempotent)
      await _runMigrations(db);

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

  Future<void> _runMigrations(Database db) async {
    await _ensureNameNormColumn(db);
    await _ensureNameNormIndex(db);
    await _ensureFtsInfrastructure(db);
  }

  Future<void> _ensureNameNormColumn(Database db) async {
    final hasColumn = await _columnExists(db, 'persons', 'name_norm');
    if (!hasColumn) {
      await db.execute('ALTER TABLE persons ADD COLUMN name_norm TEXT');
    }

    // Populate missing name_norm values in batches to avoid blocking.
    const batchSize = 5000;
    int? lastRowId;

    while (true) {
      final params = <dynamic>[];
      var whereClause = '(name_norm IS NULL OR name_norm = "")';
      if (lastRowId != null) {
        whereClause += ' AND rowid > ?';
        params.add(lastRowId);
      }
      params.add(batchSize);

      final rows = await db.rawQuery('''
        SELECT rowid, CI_ID_NUM, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB
        FROM persons
        WHERE $whereClause
        ORDER BY rowid
        LIMIT ?
        ''', params);

      if (rows.isEmpty) {
        break;
      }

      final batch = db.batch();
      for (final row in rows) {
        final normalized = _buildNormalizedName(row);
        batch.rawUpdate('UPDATE persons SET name_norm = ? WHERE rowid = ?', [
          normalized,
          row['rowid'],
        ]);
      }

      await batch.commit(noResult: true);
      lastRowId = rows.last['rowid'] as int?;
    }
  }

  Future<void> _ensureNameNormIndex(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_persons_name_norm ON persons(name_norm)',
    );
  }

  Future<void> _ensureFtsInfrastructure(Database db) async {
    await db.execute(
      'CREATE VIRTUAL TABLE IF NOT EXISTS persons_fts USING fts5(rowid UNINDEXED, CI_ID_NUM, name_norm, tokenize="unicode61")',
    );

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) as count FROM persons_fts'),
        ) ??
        0;

    if (count == 0) {
      await _populateFtsTable(db);
    }

    await _createFtsTriggers(db);
  }

  Future<void> _populateFtsTable(Database db) async {
    await db.execute('DELETE FROM persons_fts');

    const batchSize = 5000;
    int? lastRowId;

    while (true) {
      final params = <dynamic>[];
      var whereClause = '(name_norm IS NOT NULL AND name_norm != "")';
      if (lastRowId != null) {
        whereClause += ' AND rowid > ?';
        params.add(lastRowId);
      }
      params.add(batchSize);

      final rows = await db.rawQuery('''
        SELECT rowid, CI_ID_NUM, name_norm
        FROM persons
        WHERE $whereClause
        ORDER BY rowid
        LIMIT ?
        ''', params);

      if (rows.isEmpty) {
        break;
      }

      final batch = db.batch();
      for (final row in rows) {
        batch.rawInsert(
          'INSERT INTO persons_fts(rowid, CI_ID_NUM, name_norm) VALUES (?, ?, ?)',
          [row['rowid'], row['CI_ID_NUM'], row['name_norm']],
        );
      }

      await batch.commit(noResult: true);
      lastRowId = rows.last['rowid'] as int?;
    }
  }

  Future<void> _createFtsTriggers(Database db) async {
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ai AFTER INSERT ON persons
      BEGIN
        INSERT INTO persons_fts(rowid, CI_ID_NUM, name_norm) VALUES (new.rowid, new.CI_ID_NUM, new.name_norm);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ad AFTER DELETE ON persons
      BEGIN
        DELETE FROM persons_fts WHERE rowid = old.rowid;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_au AFTER UPDATE ON persons
      BEGIN
        UPDATE persons_fts SET CI_ID_NUM = new.CI_ID_NUM, name_norm = new.name_norm WHERE rowid = new.rowid;
      END;
    ''');
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  String _buildNormalizedName(Map<String, Object?> row) {
    final parts = <String>[];
    final fields = [
      row['CI_FIRST_ARB'] as String?,
      row['CI_FATHER_ARB'] as String?,
      row['CI_GRAND_FATHER_ARB'] as String?,
      row['CI_FAMILY_ARB'] as String?,
    ];

    for (final value in fields) {
      if (value != null && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    if (parts.isEmpty) {
      return '';
    }

    return _normalizeArabic(parts.join(' '), keepHamza: false);
  }

  String? _buildFtsMatchQuery(String normalized) {
    final tokens = normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      return null;
    }

    return tokens.map((token) => 'name_norm:${token}*').join(' ');
  }

  /// Normalize Arabic text
  String _normalizeArabic(String? text, {bool keepHamza = true}) {
    if (text == null) return '';
    var s = text.trim().toLowerCase();
    if (s.isEmpty) return '';

    // Remove Arabic diacritics (tashkeel) and Quranic marks
    s = s.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );

    // Remove tatweel
    s = s.replaceAll('ـ', '');

    // Normalize alef variants: أ إ آ ٱ -> ا
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Alef maksura -> ي
    s = s.replaceAll('ى', 'ي');

    // Ta marbuta -> ه
    s = s.replaceAll('ة', 'ه');

    // Hamza variants on letters -> practical mapping
    if (keepHamza) {
      s = s.replaceAll('ؤ', 'ء');
      s = s.replaceAll('ئ', 'ء');
    } else {
      s = s.replaceAll('ؤ', 'و');
      s = s.replaceAll('ئ', 'ي');
      s = s.replaceAll('ء', '');
    }

    // Remove non-Arabic letters but keep spaces
    s = s.replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), ' ');

    // Collapse multiple spaces and trim
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
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

  /// Search by National ID - Optimized with Fallback
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final db = await database;
    final cleaned = nationalId.trim().replaceAll(' ', '').replaceAll('-', '');

    // 1. Exact match (fastest - uses index)
    var results = await db.rawQuery(
      'SELECT * FROM persons WHERE CI_ID_NUM = ? LIMIT 1',
      [cleaned],
    );

    if (results.isNotEmpty) {
      return _mapToPerson(results.first);
    }

    // 2. Fallback: Prefix search
    if (cleaned.length >= 3) {
      results = await db.rawQuery(
        'SELECT * FROM persons WHERE CI_ID_NUM LIKE ? LIMIT 5',
        ['$cleaned%'],
      );

      if (results.isNotEmpty) {
        return _mapToPerson(results.first);
      }
    }

    return null;
  }

  /// Search by Name - FTS + Indexed Prefix
  Future<List<CivilPerson>> searchByName(
    String query, {
    String? governorate,
    int? genderCode,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;

    final normalized = _normalizeArabic(query, keepHamza: false);
    final raw = query.trim();

    if (normalized.isEmpty && raw.isEmpty) {
      return [];
    }

    final filterArgs = <dynamic>[];
    final ftsFilters = <String>[];
    final baseFilters = <String>[];

    if (governorate != null && governorate.isNotEmpty) {
      ftsFilters.add('p.CITY LIKE ?');
      baseFilters.add('CITY LIKE ?');
      filterArgs.add('%$governorate%');
    }

    if (genderCode != null) {
      ftsFilters.add('p.CI_SEX_CD = ?');
      baseFilters.add('CI_SEX_CD = ?');
      filterArgs.add(genderCode);
    }

    final ftsFilterClause = ftsFilters.isEmpty
        ? ''
        : ' AND ${ftsFilters.join(' AND ')}';
    final baseFilterClause = baseFilters.isEmpty
        ? ''
        : ' AND ${baseFilters.join(' AND ')}';

    // 1) FTS search
    final ftsQuery = _buildFtsMatchQuery(normalized);
    if (ftsQuery != null) {
      final ftsResults = await db.rawQuery(
        '''
        SELECT p.*
        FROM persons_fts f
        JOIN persons p ON p.rowid = f.rowid
        WHERE persons_fts MATCH ?$ftsFilterClause
        LIMIT ? OFFSET ?
        ''',
        [ftsQuery, ...filterArgs, limit, offset],
      );

      if (ftsResults.isNotEmpty) {
        return ftsResults.map(_mapToPerson).toList();
      }
    }

    // 2) name_norm prefix fallback
    if (normalized.isNotEmpty) {
      final prefixResults = await db.rawQuery(
        '''
        SELECT * FROM persons
        WHERE name_norm LIKE ?$baseFilterClause
        ORDER BY LENGTH(CI_FIRST_ARB), CI_FIRST_ARB
        LIMIT ? OFFSET ?
        ''',
        ['$normalized%', ...filterArgs, limit, offset],
      );

      if (prefixResults.isNotEmpty) {
        return prefixResults.map(_mapToPerson).toList();
      }
    }

    // 3) Final fallback: prefix search on raw fields (union strategy)
    if (raw.isEmpty) {
      return [];
    }

    final prefix = '${raw.trim()}%';
    final unionArgs = <dynamic>[];
    for (var i = 0; i < 4; i++) {
      unionArgs.add(prefix);
      unionArgs.addAll(filterArgs);
    }
    unionArgs
      ..add(limit)
      ..add(offset);

    final unionResults = await db.rawQuery('''
      SELECT * FROM (
        SELECT p.*, 1 AS priority FROM persons p WHERE p.CI_FIRST_ARB LIKE ?$ftsFilterClause
        UNION ALL
        SELECT p.*, 2 AS priority FROM persons p WHERE p.CI_FATHER_ARB LIKE ?$ftsFilterClause
        UNION ALL
        SELECT p.*, 3 AS priority FROM persons p WHERE p.CI_GRAND_FATHER_ARB LIKE ?$ftsFilterClause
        UNION ALL
        SELECT p.*, 4 AS priority FROM persons p WHERE p.CI_FAMILY_ARB LIKE ?$ftsFilterClause
      )
      ORDER BY priority, LENGTH(CI_FIRST_ARB), CI_FIRST_ARB
      LIMIT ? OFFSET ?
      ''', unionArgs);

    return unionResults.map(_mapToPerson).toList();
  }

  /// Get search count - FTS aware
  Future<int> getSearchCount(
    String query, {
    String? governorate,
    int? genderCode,
  }) async {
    final db = await database;

    final normalized = _normalizeArabic(query, keepHamza: false);
    final raw = query.trim();

    if (normalized.isEmpty && raw.isEmpty) {
      return 0;
    }

    final filterArgs = <dynamic>[];
    final ftsFilters = <String>[];
    final baseFilters = <String>[];

    if (governorate != null && governorate.isNotEmpty) {
      ftsFilters.add('p.CITY LIKE ?');
      baseFilters.add('CITY LIKE ?');
      filterArgs.add('%$governorate%');
    }

    if (genderCode != null) {
      ftsFilters.add('p.CI_SEX_CD = ?');
      baseFilters.add('CI_SEX_CD = ?');
      filterArgs.add(genderCode);
    }

    final ftsFilterClause = ftsFilters.isEmpty
        ? ''
        : ' AND ${ftsFilters.join(' AND ')}';
    final baseFilterClause = baseFilters.isEmpty
        ? ''
        : ' AND ${baseFilters.join(' AND ')}';

    final ftsQuery = _buildFtsMatchQuery(normalized);
    if (ftsQuery != null) {
      final ftsCount = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
          SELECT COUNT(*) as count
          FROM persons_fts f
          JOIN persons p ON p.rowid = f.rowid
          WHERE persons_fts MATCH ?$ftsFilterClause
          ''',
          [ftsQuery, ...filterArgs],
        ),
      );

      if ((ftsCount ?? 0) > 0) {
        return ftsCount!;
      }
    }

    if (normalized.isNotEmpty) {
      final prefixCount = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
          SELECT COUNT(*) as count
          FROM persons
          WHERE name_norm LIKE ?$baseFilterClause
          ''',
          ['$normalized%', ...filterArgs],
        ),
      );

      if ((prefixCount ?? 0) > 0) {
        return prefixCount!;
      }
    }

    if (raw.isEmpty) {
      return 0;
    }

    final prefix = '${raw.trim()}%';
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
        SELECT COUNT(DISTINCT CI_ID_NUM) as count
        FROM persons
        WHERE (
          CI_FIRST_ARB LIKE ? OR
          CI_FATHER_ARB LIKE ? OR
          CI_GRAND_FATHER_ARB LIKE ? OR
          CI_FAMILY_ARB LIKE ?
        )$baseFilterClause
        ''',
        [prefix, prefix, prefix, prefix, ...filterArgs],
      ),
    );

    return count ?? 0;
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
