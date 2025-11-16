import 'package:sqflite/sqflite.dart';
import 'text_normalization_service.dart';

/// 🔄 Database Migrations Service - Handles all database migrations
///
/// Single Responsibility: Database schema migrations and data population
class DatabaseMigrationsService {
  /// Run all migrations in background (non-blocking)
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
    // Create FTS5 table with INDIVIDUAL name columns for weighted matching
    // unicode61 tokenizer handles Arabic text properly
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS persons_fts USING fts5(
        CI_FIRST_ARB, 
        CI_FATHER_ARB, 
        CI_GRAND_FATHER_ARB, 
        CI_FAMILY_ARB,
        content=persons,
        content_rowid=rowid,
        tokenize="unicode61 remove_diacritics 2"
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
    // Delete existing FTS data
    await db.execute('DELETE FROM persons_fts');

    // Rebuild FTS index from source table
    await db.execute("INSERT INTO persons_fts(persons_fts) VALUES('rebuild')");
  }

  /// Create FTS triggers for auto-sync
  static Future<void> _createFtsTriggers(Database db) async {
    // Drop old triggers first
    await db.execute('DROP TRIGGER IF EXISTS persons_ai');
    await db.execute('DROP TRIGGER IF EXISTS persons_ad');
    await db.execute('DROP TRIGGER IF EXISTS persons_au');

    // Create new triggers for FTS sync
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ai AFTER INSERT ON persons
      BEGIN
        INSERT INTO persons_fts(rowid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
        VALUES (new.rowid, new.CI_FIRST_ARB, new.CI_FATHER_ARB, new.CI_GRAND_FATHER_ARB, new.CI_FAMILY_ARB);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_ad AFTER DELETE ON persons
      BEGIN
        INSERT INTO persons_fts(persons_fts, rowid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
        VALUES('delete', old.rowid, old.CI_FIRST_ARB, old.CI_FATHER_ARB, old.CI_GRAND_FATHER_ARB, old.CI_FAMILY_ARB);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS persons_au AFTER UPDATE ON persons
      BEGIN
        INSERT INTO persons_fts(persons_fts, rowid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
        VALUES('delete', old.rowid, old.CI_FIRST_ARB, old.CI_FATHER_ARB, old.CI_GRAND_FATHER_ARB, old.CI_FAMILY_ARB);
        INSERT INTO persons_fts(rowid, CI_FIRST_ARB, CI_FATHER_ARB, CI_GRAND_FATHER_ARB, CI_FAMILY_ARB) 
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
