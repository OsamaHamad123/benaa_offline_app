import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_migrations_service.dart';
import 'civil_registry_search_queries.dart';
import '../../domain/entities/civil_person.dart';

/// 📂 Civil Registry Database - Clean Architecture
///
/// Responsibilities:
/// - Database initialization and connection
/// - PRAGMA configuration
/// - Delegates search operations to CivilRegistrySearchQueries
/// - Delegates migrations to DatabaseMigrationsService
class CivilRegistryDatabase {
  static CivilRegistryDatabase? _instance;
  static Database? _database;
  static CivilRegistrySearchQueries? _searchQueries;

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

  /// Get search queries instance
  Future<CivilRegistrySearchQueries> get searchQueries async {
    if (_searchQueries != null) return _searchQueries!;
    final db = await database;
    _searchQueries = CivilRegistrySearchQueries(db);
    return _searchQueries!;
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

      // Apply performance PRAGMA settings
      await _applyPragmaSettings(db);

      // 🚀 Run ANALYZE immediately for better query plans
      try {
        await db.rawQuery('ANALYZE');
      } catch (e) {
        print('⚠️ ANALYZE failed: $e');
      }

      // ⚡ Optimized indexes setup - MUST run synchronously for fast search!
      print('⏳ Setting up optimized indexes for ultra-fast search...');
      await DatabaseMigrationsService.ensureOptimizedIndexes(db);
      print('✅ Optimized indexes ready!');

      // Create indexes and other migrations in background (non-blocking)
      DatabaseMigrationsService.createIndexesAsync(db);
      DatabaseMigrationsService.runOtherMigrationsAsync(db);

      return db;
    } catch (e) {
      print('❌ Database error: $e');
      rethrow;
    }
  }

  /// Apply PRAGMA settings - SMART PERFORMANCE MODE ⚡
  Future<void> _applyPragmaSettings(Database db) async {
    // ⚡ CRITICAL: Disable synchronous for MAXIMUM SPEED (read-only DB is safe)
    await db.rawQuery('PRAGMA synchronous = OFF');

    // ⚡ MASSIVE cache (1GB for extreme speed)
    await db.rawQuery('PRAGMA cache_size = -1048576');

    // All temp operations in memory
    await db.rawQuery('PRAGMA temp_store = MEMORY');

    // WAL mode - allows concurrent reads (critical!)
    await db.rawQuery('PRAGMA journal_mode = WAL');

    // Optimal page size for modern systems
    await db.rawQuery('PRAGMA page_size = 4096');

    // ⚡ SMART memory-mapped I/O (adaptive based on 5M records DB ~2GB)
    // Conservative: 512MB (works on all devices)
    // Note: Full DB is ~2GB, but we don't need to map it all at once
    await db.rawQuery('PRAGMA mmap_size = 536870912'); // 512MB

    // ⚡ EXCLUSIVE lock for single-user app (faster)
    await db.rawQuery('PRAGMA locking_mode = EXCLUSIVE');

    // Dirty reads OK for search (huge performance boost)
    await db.rawQuery('PRAGMA read_uncommitted = 1');

    // Auto-vacuum off for speed (data is read-only)
    await db.rawQuery('PRAGMA auto_vacuum = NONE');

    // Disable foreign keys (not used, save overhead)
    await db.rawQuery('PRAGMA foreign_keys = OFF');

    // ⚡ NEW: Disable secure delete for speed
    await db.rawQuery('PRAGMA secure_delete = OFF');

    // ⚡ NEW: Disable cell size check for speed
    await db.rawQuery('PRAGMA cell_size_check = OFF');

    // Optimize query planner
    await db.rawQuery('PRAGMA optimize');

    // Analyze statistics for better query plans
    await db.rawQuery('ANALYZE');

    // Increase WAL checkpoint threshold (less frequent checkpoints)
    await db.rawQuery('PRAGMA wal_autocheckpoint = 10000');

    // Disable query_only mode for flexibility
    await db.rawQuery('PRAGMA query_only = OFF');

    // ⚡ NEW: Disable cell size check for speed
    await db.rawQuery('PRAGMA cell_size_check = OFF');
  }

  /// Search by National ID
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final queries = await searchQueries;
    return queries.searchByNationalId(nationalId);
  }

  /// Search by Name
  Future<List<CivilPerson>> searchByName(
    String query, {
    String? governorate,
    int? genderCode,
    int limit = 20,
    int offset = 0,
  }) async {
    final queries = await searchQueries;
    return queries.searchByName(
      query,
      governorate: governorate,
      genderCode: genderCode,
      limit: limit,
      offset: offset,
    );
  }

  /// Get search count
  Future<int> getSearchCount(
    String query, {
    String? governorate,
    int? genderCode,
  }) async {
    final queries = await searchQueries;
    return queries.getSearchCount(
      query,
      governorate: governorate,
      genderCode: genderCode,
    );
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final queries = await searchQueries;
    return queries.getStatistics();
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _searchQueries = null;
      _instance = null;
    }
  }

  /// Reset instance (for testing)
  static void reset() {
    _instance = null;
    _database = null;
    _searchQueries = null;
  }
}
