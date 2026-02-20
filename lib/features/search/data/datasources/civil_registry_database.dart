import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:benaa_offline_app/core/utils/unified_logger.dart';

import 'database_migrations_service.dart';
import 'civil_registry_search_queries.dart';
import '../../domain/entities/civil_person.dart';

/// 🚫 Exception thrown when civil registry database is not available
class CivilRegistryNotAvailableException implements Exception {
  final String message;
  CivilRegistryNotAvailableException(this.message);

  @override
  String toString() => 'CivilRegistryNotAvailableException: $message';
}

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
  static bool _backgroundSetupStarted = false;
  static bool _runtimeMaintenanceEnabled = false;

  CivilRegistryDatabase._();

  static CivilRegistryDatabase get instance {
    _instance ??= CivilRegistryDatabase._();
    return _instance!;
  }

  /// Get database instance
  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  /// Get search queries instance
  Future<CivilRegistrySearchQueries?> get searchQueries async {
    if (_searchQueries != null) return _searchQueries!;
    final db = await database;
    if (db == null) return null;
    _searchQueries = CivilRegistrySearchQueries(db);
    return _searchQueries;
  }

  /// ✅ Check if database is available (without throwing)
  static Future<bool> isAvailable() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDir.path, 'databases', 'civil_registry.db');
      final file = File(dbPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// ✅ Get database path
  static Future<String> getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'databases', 'civil_registry.db');
  }

  /// Opt-in hook for heavy maintenance tasks (ANALYZE/index verification).
  /// Keep disabled during normal runtime to avoid ANR on low-end devices.
  static void setRuntimeMaintenanceEnabled(bool enabled) {
    _runtimeMaintenanceEnabled = enabled;
  }

  /// Initialize database
  Future<Database?> _initDatabase() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDir.path, 'databases', 'civil_registry.db');

      final file = File(dbPath);
      final exists = await file.exists();

      if (!exists) {
        // ✅ Return null: Don't throw, let caller handle
        UnifiedLogger.warning(
          '⚠️ Civil registry database not found at: $dbPath\n'
          'Please download from Settings → Database Download',
        );
        return null; // ✅ Return null instead of throwing
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

      // ⚡ IMPORTANT: keep init lightweight to avoid ANR on low-end devices.
      // Heavy optimization and index setup are deferred to background.
      await _applyPragmaSettings(db);

      if (_runtimeMaintenanceEnabled) {
        _scheduleBackgroundSetup(db);
      }

      // ⚠️ Background migrations DISABLED to prevent lag after fetch
      // These were causing heavy GC and app slowdown:
      // - createIndexesAsync: 15 indexes on 5M records (CPU/Memory intensive)
      // - runOtherMigrationsAsync: name_norm population (10K batches × 500 iterations)
      //
      // Result: App is now smooth after fetch, no background processing lag
      //
      // If you need to run migrations, use UpdateNormalizationPage manually
      // DatabaseMigrationsService.createIndexesAsync(db);
      // DatabaseMigrationsService.runOtherMigrationsAsync(db);

      return db;
    } catch (e) {
      UnifiedLogger.error('Database error', error: e);
      return null; // ✅ Return null on initialization error
    }
  }

  /// Apply PRAGMA settings - SMART PERFORMANCE MODE ⚡
  Future<void> _applyPragmaSettings(Database db) async {
    // Keep PRAGMA setup minimal and safe for UI responsiveness.
    await db.rawQuery('PRAGMA journal_mode = WAL');
    await db.rawQuery('PRAGMA temp_store = MEMORY');
    await db.rawQuery('PRAGMA cache_size = -65536'); // ~64MB
    await db.rawQuery('PRAGMA synchronous = NORMAL');
    await db.rawQuery('PRAGMA foreign_keys = OFF');
    await db.rawQuery('PRAGMA wal_autocheckpoint = 1000');
  }

  void _scheduleBackgroundSetup(Database db) {
    if (_backgroundSetupStarted) return;
    _backgroundSetupStarted = true;

    Future<void>(() async {
      try {
        final needsOptimization = await _needsOptimization(db);
        if (needsOptimization) {
          UnifiedLogger.info('⏳ Running deferred database optimization...');
          await _optimizeDatabase(db);
        }
      } catch (e) {
        UnifiedLogger.warning('Deferred optimization skipped: $e');
      }

      try {
        UnifiedLogger.info('⏳ Running deferred index setup...');
        await DatabaseMigrationsService.ensureOptimizedIndexes(db);
        UnifiedLogger.success('Deferred index setup completed');
      } catch (e) {
        UnifiedLogger.warning('Deferred index setup skipped: $e');
      }
    });
  }

  /// Check if database needs optimization (first time after copy from assets)
  Future<bool> _needsOptimization(Database db) async {
    try {
      // Check if optimization marker exists in SQLite's application_id
      final result = await db.rawQuery('PRAGMA application_id');
      final appId = result.first.values.first as int?;

      // If application_id != 0xBEAA (optimized marker), needs optimization
      return appId != 0xBEAA;
    } catch (e) {
      // On error, assume needs optimization
      return true;
    }
  }

  /// Optimize database after first copy (ANALYZE + set marker)
  /// ⚠️ NOTE: VACUUM removed - causes OOM on large databases (5M records = 2GB)
  Future<void> _optimizeDatabase(Database db) async {
    try {
      // 1️⃣ ANALYZE - Update query optimizer statistics
      UnifiedLogger.info('  📊 Running ANALYZE...');
      await db.rawQuery('ANALYZE');

      // 2️⃣ Set optimization marker to avoid re-running
      UnifiedLogger.info('  ✅ Setting optimization marker...');
      await db.rawQuery('PRAGMA application_id = 0xBEAA'); // BEAA = بناء

      UnifiedLogger.success('Database optimization complete! 🚀');
    } catch (e) {
      UnifiedLogger.error('Database optimization failed', error: e);
      // Don't rethrow - app should still work even if optimization fails
    }
  }

  /// Search by National ID
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final queries = await searchQueries;
    if (queries == null) return null;
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
    if (queries == null) return [];
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
    if (queries == null) return 0;
    return queries.getSearchCount(
      query,
      governorate: governorate,
      genderCode: genderCode,
    );
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final queries = await searchQueries;
    if (queries == null) return {'total': 0, 'males': 0, 'females': 0};
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
    _backgroundSetupStarted = false;
    _runtimeMaintenanceEnabled = false;
  }
}
