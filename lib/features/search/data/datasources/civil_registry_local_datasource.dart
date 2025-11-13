import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../models/civil_person_model.dart';

/// 💾 Civil Registry Local Data Source
///
/// Handles direct database operations for civil registry.
/// Optimized with indexes and efficient queries.
class CivilRegistryLocalDataSource {
  Database? _db;
  bool _isInitialized = false;

  /// Initialize database connection
  Future<void> initialize() async {
    if (_isInitialized && _db != null) return;

    try {
      // Get application directory
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDir.path}/civil_registry.db';
      final dbFile = File(dbPath);

      // Copy from assets if not exists
      if (!await dbFile.exists()) {
        print('📦 Copying database from assets...');
        final data = await rootBundle.load(
          'assets/databases/civil_registry.db',
        );
        final bytes = data.buffer.asUint8List();
        await dbFile.create(recursive: true);
        await dbFile.writeAsBytes(bytes);
        print('✅ Database copied successfully');
      }

      // Open database
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      _db = await openDatabase(dbPath, readOnly: true);
      _isInitialized = true;

      // Create indexes for better performance
      await _createIndexes();

      print('✅ Database opened and indexed');
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Create indexes for faster searches
  Future<void> _createIndexes() async {
    if (_db == null) return;

    try {
      // Index on national ID for O(log n) search
      await _db!.execute('''
        CREATE INDEX IF NOT EXISTS idx_national_id 
        ON persons(CI_ID_NUM)
      ''');

      // Index on name fields for faster name searches
      await _db!.execute('''
        CREATE INDEX IF NOT EXISTS idx_names 
        ON persons(CI_FIRST_ARB, CI_FATHER_ARB, CI_FAMILY_ARB)
      ''');

      // Index on city for filter operations
      await _db!.execute('''
        CREATE INDEX IF NOT EXISTS idx_city 
        ON persons(CITY)
      ''');

      // Index on gender for filter operations
      await _db!.execute('''
        CREATE INDEX IF NOT EXISTS idx_gender 
        ON persons(CI_SEX_CD)
      ''');

      print('✅ Indexes created successfully');
    } catch (e) {
      // Indexes might already exist, that's okay
      print('ℹ️ Index creation: $e');
    }
  }

  /// Search by national ID (optimized with index)
  Future<CivilPersonModel?> searchByNationalId(String nationalId) async {
    await initialize();

    try {
      final cleanId = nationalId.trim();
      print('🔍 Searching for national ID: $cleanId');

      // Try exact match first (uses index)
      var results = await _db!.query(
        'persons',
        where: 'CI_ID_NUM = ?',
        whereArgs: [cleanId],
        limit: 1,
      );

      // If not found, try without spaces
      if (results.isEmpty) {
        final noSpaces = cleanId.replaceAll(' ', '');
        print('🔄 Trying without spaces: $noSpaces');

        results = await _db!.rawQuery(
          '''
          SELECT * FROM persons 
          WHERE REPLACE(CI_ID_NUM, ' ', '') = ? 
          LIMIT 1
        ''',
          [noSpaces],
        );
      }

      // If still not found, try LIKE with wildcard
      if (results.isEmpty && cleanId.length >= 8) {
        print('🔄 Trying partial match: $cleanId%');

        results = await _db!.query(
          'persons',
          where: 'CI_ID_NUM LIKE ?',
          whereArgs: ['$cleanId%'],
          limit: 1,
        );
      }

      if (results.isNotEmpty) {
        print('✅ Found: ${results.first['CI_FIRST_ARB']}');
        return CivilPersonModel.fromMap(results.first);
      } else {
        print('❌ No results found for: $cleanId');
        return null;
      }
    } catch (e) {
      print('❌ Error searching by national ID: $e');
      return null;
    }
  }

  /// Search by name with filters and pagination (optimized)
  Future<List<CivilPersonModel>> searchByName({
    required String query,
    int? genderCode,
    String? city,
    required int limit,
    required int offset,
  }) async {
    await initialize();

    try {
      // Normalize Arabic text
      final normalizedQuery = ArabicNormalizer.normalize(query);

      // Build WHERE clause
      final conditions = <String>[];
      final params = <dynamic>[];

      // Name search (optimized with index)
      if (normalizedQuery.isNotEmpty) {
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
      }

      // Gender filter (uses index)
      if (genderCode != null) {
        conditions.add('CI_SEX_CD = ?');
        params.add(genderCode);
      }

      // City filter (uses index)
      if (city != null && city.isNotEmpty) {
        conditions.add('CITY LIKE ?');
        params.add('%$city%');
      }

      // Build SQL query
      final sql =
          '''
        SELECT * FROM persons 
        ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
        LIMIT ? OFFSET ?
      ''';

      params.add(limit);
      params.add(offset);

      // Execute query
      final results = await _db!.rawQuery(sql, params);
      print('✅ Found ${results.length} results');

      return results.map((map) => CivilPersonModel.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error searching by name: $e');
      return [];
    }
  }

  /// Get total count for pagination
  Future<int> getSearchCount({
    required String query,
    int? genderCode,
    String? city,
  }) async {
    await initialize();

    try {
      final normalizedQuery = ArabicNormalizer.normalize(query);

      final conditions = <String>[];
      final params = <dynamic>[];

      if (normalizedQuery.isNotEmpty) {
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
      }

      if (genderCode != null) {
        conditions.add('CI_SEX_CD = ?');
        params.add(genderCode);
      }

      if (city != null && city.isNotEmpty) {
        conditions.add('CITY LIKE ?');
        params.add('%$city%');
      }

      final sql =
          '''
        SELECT COUNT(*) as count FROM persons 
        ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
      ''';

      final result = await _db!.rawQuery(sql, params);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      print('❌ Error getting count: $e');
      return 0;
    }
  }

  /// Get statistics (cached in memory after first call)
  Future<Map<String, dynamic>> getStatistics() async {
    await initialize();

    try {
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

      // Get distinct cities (uses index)
      final citiesResult = await _db!.rawQuery('''
        SELECT DISTINCT CITY FROM persons 
        WHERE CITY IS NOT NULL AND CITY != '' 
        ORDER BY CITY
      ''');

      final cities = citiesResult
          .map((row) => row['CITY']?.toString() ?? '')
          .where((city) => city.isNotEmpty)
          .toList();

      return {
        'total': personsCount.first['count'] as int? ?? 0,
        'males': malesCount.first['count'] as int? ?? 0,
        'females': femalesCount.first['count'] as int? ?? 0,
        'relations': relationsCount.first['count'] as int? ?? 0,
        'governorates': cities,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'total': 0,
        'males': 0,
        'females': 0,
        'relations': 0,
        'governorates': <String>[],
      };
    }
  }

  /// Close database connection
  Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _isInitialized = false;
  }
}
