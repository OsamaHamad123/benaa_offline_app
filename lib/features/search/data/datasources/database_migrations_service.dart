import 'package:sqflite/sqflite.dart';
import 'text_normalization_service.dart';

/// 🔄 Database Migrations Service - Handles all database migrations
///
/// Single Responsibility: Database schema migrations and data population
class DatabaseMigrationsService {
  /// ⚡ Ensure FTS infrastructure (MUST be called synchronously before searches!)
  static Future<void> ensureFtsInfrastructure(Database db) async {
    try {
      await _ensureFtsInfrastructure(db);
    } catch (e) {
      print('⚠️ FTS setup error: $e');
      rethrow;
    }
  }

  /// Run other migrations in background (non-blocking)
  static void runOtherMigrationsAsync(Database db) async {
    try {
      await _ensureNameNormColumn(db);
      await _ensureNameNormIndex(db);
    } catch (e) {
      print('⚠️ Background migration error (non-critical): $e');
    }
  }

  /// Run all migrations in background (non-blocking) - DEPRECATED
  static void runMigrationsAsync(Database db) async {
    try {
      await _ensureNameNormColumn(db);
      await _ensureNameNormIndex(db);
      // FTS is expensive - run it last
      await _ensureFtsInfrastructure(db);
    } catch (e) {
      print('⚠️ Background migration error (non-critical): $e');
    }
  }

  /// Create simple indexes (non-blocking)
  static void createIndexesAsync(Database db) async {
    try {
      final indexes = [
        // Original indexes
        'CREATE INDEX IF NOT EXISTS idx_persons_national_id ON persons(CI_ID_NUM)',
        'CREATE INDEX IF NOT EXISTS idx_persons_first_name ON persons(CI_FIRST_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_father_name ON persons(CI_FATHER_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_grand_father ON persons(CI_GRAND_FATHER_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_family_name ON persons(CI_FAMILY_ARB)',
        'CREATE INDEX IF NOT EXISTS idx_persons_city ON persons(CITY)',
        'CREATE INDEX IF NOT EXISTS idx_persons_gender ON persons(CI_SEX_CD)',

        // 🚀 COVERING INDEXES for ultra-fast searches (include all needed columns)
        // Multi-word search covering index (first 2 names + filters)
        'CREATE INDEX IF NOT EXISTS idx_persons_name_search ON persons(CI_FIRST_ARB, CI_FATHER_ARB, CITY, CI_SEX_CD)',

        // Extended multi-word covering index (first 4 names + filters)
        'CREATE INDEX IF NOT EXISTS idx_persons_full_name_search ON persons(CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB, CITY, CI_SEX_CD)',

        // National ID covering index with filters
        'CREATE INDEX IF NOT EXISTS idx_persons_id_search ON persons(CI_ID_NUM, CITY, CI_SEX_CD)',

        // City + Gender composite for filtering
        'CREATE INDEX IF NOT EXISTS idx_persons_city_gender ON persons(CITY, CI_SEX_CD)',
      ];

      for (final index in indexes) {
        await db.execute(index);
      }

      // 🚀 Update statistics for query planner optimization
      await db.rawQuery('ANALYZE');
    } catch (e) {
      // Indexes exist, safe to ignore
    }
  }

  /// Ensure name_norm column exists and is populated
  static Future<void> _ensureNameNormColumn(Database db) async {
    final hasColumn = await _columnExists(db, 'persons', 'name_norm');
    if (!hasColumn) {
      await db.execute('ALTER TABLE persons ADD COLUMN name_norm TEXT');
    }

    // Populate missing name_norm values in larger batches
    const batchSize = 10000;
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
        final normalized = TextNormalizationService.buildNormalizedName(row);
        batch.rawUpdate('UPDATE persons SET name_norm = ? WHERE rowid = ?', [
          normalized,
          row['rowid'],
        ]);
      }

      await batch.commit(noResult: true);
      lastRowId = rows.last['rowid'] as int?;
    }
  }

  /// Ensure name_norm index exists
  static Future<void> _ensureNameNormIndex(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_persons_name_norm ON persons(name_norm)',
    );
  }

  /// Ensure FTS infrastructure exists - ULTRA PRECISE with individual columns
  static Future<void> _ensureFtsInfrastructure(Database db) async {
    // Create FTS4 table (FTS5 not available on all platforms)
    // FTS4 handles Arabic text well with unicode61 tokenizer
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS persons_fts USING fts4(
        CI_FIRST_ARB, 
        CI_FATHER_ARB, 
        CI_GRAND_FATHER_ARB, 
        CI_FAMILY_ARB,
        tokenize=unicode61
      )
      ''');

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

  /// Populate FTS table with individual name columns
  static Future<void> _populateFtsTable(Database db) async {
    print('📥 Populating FTS table...');
    
    // Delete existing FTS data
    await db.execute('DELETE FROM persons_fts');

    // FTS4: Manual insert (no rebuild command)
    // Insert in batches for performance
    const batchSize = 1000;
    int offset = 0;
    int totalInserted = 0;

    while (true) {
      final rows = await db.rawQuery(
        '''
        SELECT rowid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB
        FROM persons
        LIMIT ? OFFSET ?
        ''',
        [batchSize, offset],
      );

      if (rows.isEmpty) break;

      final batch = db.batch();
      for (final row in rows) {
        batch.rawInsert(
          '''
          INSERT INTO persons_fts(docid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB)
          VALUES (?, ?, ?, ?, ?)
          ''',
          [
            row['rowid'],
            row['CI_FIRST_ARB'],
            row['CI_FATHER_ARB'],
            row['CI_GRAND_FATHER_ARB'],
            row['CI_FAMILY_ARB'],
          ],
        );
      }

      await batch.commit(noResult: true);
      totalInserted += rows.length;
      offset += batchSize;

      if (totalInserted % 10000 == 0) {
        print('  📊 Inserted $totalInserted rows into FTS...');
      }
    }

    print('✅ FTS populated with $totalInserted rows');
  }

  /// Create FTS triggers for auto-sync
  static Future<void> _createFtsTriggers(Database db) async {
    // Drop old triggers first
    await db.execute('DROP TRIGGER IF EXISTS persons_ai');
    await db.execute('DROP TRIGGER IF EXISTS persons_ad');
    await db.execute('DROP TRIGGER IF EXISTS persons_au');

    // FTS4: Use docid instead of rowid
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ai AFTER INSERT ON persons
      BEGIN
        INSERT INTO persons_fts(docid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
        VALUES (new.rowid, new.CI_FIRST_ARB, new.CI_FATHER_ARB, new.CI_GRAND_FATHER_ARB, new.CI_FAMILY_ARB);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ad AFTER DELETE ON persons
      BEGIN
        DELETE FROM persons_fts WHERE docid = old.rowid;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_au AFTER UPDATE ON persons
      BEGIN
        DELETE FROM persons_fts WHERE docid = old.rowid;
        INSERT INTO persons_fts(docid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
        VALUES (new.rowid, new.CI_FIRST_ARB, new.CI_FATHER_ARB, new.CI_GRAND_FATHER_ARB, new.CI_FAMILY_ARB);
      END;
    ''');
  }
  

  /// Check if column exists in table
  static Future<bool> _columnExists(
    Database db,
    String table,
    String column,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  /// Check if table exists
  static Future<bool> checkTableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }
}
