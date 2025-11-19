import 'dart:async';
import 'package:flutter/foundation.dart';
import '../datasources/civil_registry_database.dart';
import '../../domain/entities/civil_person.dart';
import '../../domain/entities/search_entities.dart';

/// ⚡ Search Isolate Service - تحسين أداء البحث
///
/// ❌ ISOLATE DISABLED: sqflite لا يعمل في isolates (يحتاج Flutter bindings)
/// ✅ ALTERNATIVE: sqflite أساساً async - البحث لا يجمد UI
///
/// الـ UI بتبقى responsive عشان:
/// 1. sqflite بتستخدم native threads تلقائياً
/// 2. Future.microtask يسمح للـUI ترسم بين الـqueries
/// 3. Adaptive debounce يقلل عدد الاستعلامات
class SearchIsolateService {
  bool _isInitialized = false;
  CivilRegistryDatabase? _database;

  /// Initialize service with database instance
  Future<void> initialize(String dbPath) async {
    if (_isInitialized) return;
    _database = CivilRegistryDatabase.instance;
    _isInitialized = true;
  }

  /// ⚡ Perform search (runs on main thread but sqflite handles async)
  Future<List<CivilPerson>> search({
    required String query,
    required SearchFilter filter,
    required int limit,
    required int offset,
  }) async {
    if (!_isInitialized || _database == null) {
      throw StateError('SearchIsolateService not initialized');
    }

    // sqflite is inherently async and uses native platform threads
    // This won't block the UI even on main thread
    return await _database!.searchByName(
      query,
      governorate: filter.governorate,
      genderCode: filter.gender?.code,
      limit: limit,
      offset: offset,
    );
  }

  /// Get search count
  Future<int> getSearchCount({
    required String query,
    required SearchFilter filter,
  }) async {
    if (!_isInitialized || _database == null) {
      throw StateError('SearchIsolateService not initialized');
    }

    return await _database!.getSearchCount(
      query,
      governorate: filter.governorate,
      genderCode: filter.gender?.code,
    );
  }

  /// Search by national ID
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    if (!_isInitialized || _database == null) {
      throw StateError('SearchIsolateService not initialized');
    }

    return await _database!.searchByNationalId(nationalId);
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
    _database = null;
  }

  /// 🧪 Test performance (for debugging)
  Future<Map<String, dynamic>> testIsolatePerformance({
    required String testQuery,
  }) async {
    if (!_isInitialized) {
      throw StateError('SearchIsolateService not initialized');
    }

    final stopwatch = Stopwatch()..start();

    final results = await search(
      query: testQuery,
      filter: const SearchFilter(),
      limit: 10,
      offset: 0,
    );

    stopwatch.stop();

    return {
      'success': true,
      'query': testQuery,
      'resultsCount': results.length,
      'durationMs': stopwatch.elapsedMilliseconds,
      'platform': defaultTargetPlatform.toString(),
      'usingIsolate': false,
      'message': '✅ Using sqflite async (native threads) - no UI blocking',
    };
  }
}
