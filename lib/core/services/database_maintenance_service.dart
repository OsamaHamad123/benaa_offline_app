import 'package:shared_preferences/shared_preferences.dart';
import '../../data/db/drift_database.dart';

/// Database Maintenance Service
/// Performs periodic optimization tasks
class DatabaseMaintenanceService {
  final AppDatabase database;
  final SharedPreferences prefs;

  static const String _lastVacuumKey = 'last_vacuum_date';
  static const String _lastAnalyzeKey = 'last_analyze_date';
  static const String _lastFtsOptimizeKey = 'last_fts_optimize_date';

  // Run VACUUM weekly (7 days)
  static const Duration _vacuumInterval = Duration(days: 7);

  // Run ANALYZE every 3 days
  static const Duration _analyzeInterval = Duration(days: 3);

  // Run FTS optimization every 7 days
  static const Duration _ftsOptimizeInterval = Duration(days: 7);

  DatabaseMaintenanceService({required this.database, required this.prefs});

  /// Check and perform maintenance if needed
  Future<void> performMaintenanceIfNeeded() async {
    await _checkAndVacuum();
    await _checkAndAnalyze();
    await _checkAndOptimizeFts();
  }

  /// VACUUM - Rebuild database file to reduce size and improve performance
  Future<void> _checkAndVacuum() async {
    final lastVacuum = prefs.getString(_lastVacuumKey);
    final shouldVacuum =
        lastVacuum == null ||
        DateTime.now().difference(DateTime.parse(lastVacuum)) > _vacuumInterval;

    if (shouldVacuum) {
      await vacuum();
      await prefs.setString(_lastVacuumKey, DateTime.now().toIso8601String());
    }
  }

  /// ANALYZE - Update query planner statistics
  Future<void> _checkAndAnalyze() async {
    final lastAnalyze = prefs.getString(_lastAnalyzeKey);
    final shouldAnalyze =
        lastAnalyze == null ||
        DateTime.now().difference(DateTime.parse(lastAnalyze)) >
            _analyzeInterval;

    if (shouldAnalyze) {
      await analyze();
      await prefs.setString(_lastAnalyzeKey, DateTime.now().toIso8601String());
    }
  }

  /// FTS Optimize - Optimize Full Text Search tables
  Future<void> _checkAndOptimizeFts() async {
    final lastOptimize = prefs.getString(_lastFtsOptimizeKey);
    final shouldOptimize =
        lastOptimize == null ||
        DateTime.now().difference(DateTime.parse(lastOptimize)) >
            _ftsOptimizeInterval;

    if (shouldOptimize) {
      await optimizeFTS();
      await prefs.setString(
        _lastFtsOptimizeKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Perform VACUUM - Reduces database file size
  Future<void> vacuum() async {
    try {
      await database.customStatement('VACUUM;');
      print('✅ Database VACUUM completed successfully');
    } catch (e) {
      print('❌ Database VACUUM failed: $e');
    }
  }

  /// Perform ANALYZE - Updates statistics for query optimizer
  Future<void> analyze() async {
    try {
      await database.customStatement('ANALYZE;');
      print('✅ Database ANALYZE completed successfully');
    } catch (e) {
      print('❌ Database ANALYZE failed: $e');
    }
  }

  /// Get database size in MB
  Future<double> getDatabaseSize() async {
    try {
      final result = await database
          .customSelect(
            'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size();',
          )
          .getSingle();

      final bytes = result.read<int>('size');
      return bytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('❌ Failed to get database size: $e');
      return 0.0;
    }
  }

  /// Optimize FTS (Full Text Search) tables
  Future<void> optimizeFTS() async {
    try {
      await database.customStatement('''
        INSERT INTO beneficiaries_fts(beneficiaries_fts, rank)
        SELECT 'optimize', 2;
      ''');
      print('✅ FTS optimization completed successfully');
    } catch (e) {
      print('❌ FTS optimization failed: $e');
    }
  }

  /// Full maintenance - Run all optimization tasks
  Future<Map<String, dynamic>> performFullMaintenance() async {
    final sizeBefore = await getDatabaseSize();

    await vacuum();
    await analyze();
    await optimizeFTS();

    final sizeAfter = await getDatabaseSize();
    final savedSpace = sizeBefore - sizeAfter;

    return {
      'sizeBefore': sizeBefore,
      'sizeAfter': sizeAfter,
      'savedSpace': savedSpace,
      'savedPercentage': sizeBefore > 0 ? (savedSpace / sizeBefore * 100) : 0,
    };
  }

  /// Get maintenance status
  Future<Map<String, dynamic>> getMaintenanceStatus() async {
    final lastVacuum = prefs.getString(_lastVacuumKey);
    final lastAnalyze = prefs.getString(_lastAnalyzeKey);
    final dbSize = await getDatabaseSize();

    return {
      'databaseSize': dbSize,
      'lastVacuum': lastVacuum != null ? DateTime.parse(lastVacuum) : null,
      'lastAnalyze': lastAnalyze != null ? DateTime.parse(lastAnalyze) : null,
      'daysSinceVacuum': lastVacuum != null
          ? DateTime.now().difference(DateTime.parse(lastVacuum)).inDays
          : null,
      'daysSinceAnalyze': lastAnalyze != null
          ? DateTime.now().difference(DateTime.parse(lastAnalyze)).inDays
          : null,
    };
  }
}
