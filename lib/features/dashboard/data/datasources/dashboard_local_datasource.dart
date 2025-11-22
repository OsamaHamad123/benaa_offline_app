import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/db/drift_database.dart';
import '../models/dashboard_statistics_model.dart';
import '../models/activity_model.dart';

/// Local Data Source with Caching Strategy
/// Implements: Memory Cache → Disk Cache → Database
class DashboardLocalDataSource {
  final AppDatabase database;
  final SharedPreferences prefs;

  // Cache keys
  static const String _statsCacheKey = 'dashboard_stats_v2';
  static const String _todayStatsCacheKey = 'today_stats_v2';

  // Cache duration: 5 minutes for full stats, 2 minutes for today stats
  static const Duration _fullStatsCacheDuration = Duration(minutes: 5);
  static const Duration _todayStatsCacheDuration = Duration(minutes: 2);

  DashboardLocalDataSource({required this.database, required this.prefs});

  // ============================================================================
  // CACHE MANAGEMENT - Performance Optimized
  // ============================================================================

  bool _isCacheValid(String key, Duration duration) {
    final cacheTime = prefs.getString('${key}_time');
    if (cacheTime == null) return false;

    final lastCache = DateTime.parse(cacheTime);
    return DateTime.now().difference(lastCache) < duration;
  }

  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    await prefs.setString(key, json.encode(data));
    await prefs.setString('${key}_time', DateTime.now().toIso8601String());
  }

  T? _getCachedData<T>(
    String key,
    Duration duration,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (!_isCacheValid(key, duration)) return null;

    final cached = prefs.getString(key);
    if (cached == null) return null;

    try {
      return fromJson(json.decode(cached) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // DATA FETCHING - Optimized Queries
  // ============================================================================

  /// Get complete dashboard statistics with caching
  Future<DashboardStatisticsModel> getStatistics({
    bool forceRefresh = false,
  }) async {
    // Check cache first (if not forcing refresh)
    if (!forceRefresh) {
      final cached = _getCachedData(
        _statsCacheKey,
        _fullStatsCacheDuration,
        DashboardStatisticsModel.fromJson,
      );
      if (cached != null) return cached;
    }

    // Fetch from database with parallel queries for performance
    final results = await Future.wait([
      database.beneficiariesDao.countBeneficiaries(),
      _getActiveBeneficiariesCount(),
      database.beneficiariesDao.countPendingSync(),
      _getCompletedVisitstodayCount(),
      _getCategoryCounts(),
      _getGrowthData(),
      getTodayStatsData(),
      _getFamilyStatistics(), // NEW: Family statistics
    ]);

    final familyStats = results[7] as Map<String, dynamic>;

    final stats = DashboardStatisticsModel(
      totalBeneficiaries: results[0] as int,
      activeBeneficiaries: results[1] as int,
      pendingSync: results[2] as int,
      completedVisitsToday: results[3] as int,
      lastSyncTime: DateTime.now().subtract(
        const Duration(hours: 1),
      ), // TODO: from sync service
      categoryCounts: results[4] as Map<String, int>,
      growthData: results[5] as List<GrowthDataPointModel>,
      todayStats: results[6] as TodayStatsModel,
      totalFamilyMembers: familyStats['totalFamilyMembers'] as int,
      totalDeceased: familyStats['totalDeceased'] as int,
      totalOrphans: familyStats['totalOrphans'] as int,
      averageFamilySize: familyStats['averageFamilySize'] as double,
    );

    // Cache the result
    await _cacheData(_statsCacheKey, stats.toJson());

    return stats;
  }

  /// Get today stats only (lighter operation)
  Future<TodayStatsModel> getTodayStatsData() async {
    // Check cache
    final cached = _getCachedData(
      _todayStatsCacheKey,
      _todayStatsCacheDuration,
      TodayStatsModel.fromJson,
    );
    if (cached != null) return cached;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Parallel queries
    final results = await Future.wait([
      _getNewBeneficiariesToday(startOfDay),
      _getCompletedVisitstodayCount(),
      database.beneficiariesDao.countPendingSync(),
      _getSyncedRecordsToday(startOfDay),
    ]);

    final stats = TodayStatsModel(
      newBeneficiaries: results[0],
      completedVisits: results[1],
      pendingTasks: results[2],
      syncedRecords: results[3],
    );

    await _cacheData(_todayStatsCacheKey, stats.toJson());

    return stats;
  }

  /// Get recent activities with pagination
  Future<List<ActivityModel>> getRecentActivities({
    int limit = 10,
    int offset = 0,
  }) async {
    final query = database.select(database.activities)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    final activities = await query.get();

    return activities.map((item) {
      return ActivityModel(
        id: item.id,
        type: item.activityType,
        description: item.description,
        timestamp: item.createdAt,
        beneficiaryId: item.beneficiaryId,
        beneficiaryName: null, // TODO: Join with beneficiaries if needed
        metadata: {'userId': item.userId},
      );
    }).toList();
  }

  // Method removed - not used anymore (description comes from sync_log table)

  // ============================================================================
  // HELPER METHODS - Database Queries
  // ============================================================================

  Future<int> _getActiveBeneficiariesCount() async {
    // Count beneficiaries with recent activity (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final result = await database
        .customSelect(
          'SELECT COUNT(*) as count FROM beneficiaries WHERE updated_at >= ?',
          variables: [Variable.withDateTime(thirtyDaysAgo)],
          readsFrom: {database.beneficiaries},
        )
        .getSingle();
    return result.read<int>('count');
  }

  Future<int> _getCompletedVisitstodayCount() async {
    // TODO: Implement when visits feature is ready
    return 0;
  }

  Future<int> _getNewBeneficiariesToday(DateTime startOfDay) async {
    final result = await database
        .customSelect(
          'SELECT COUNT(*) as count FROM beneficiaries WHERE created_at >= ?',
          variables: [Variable.withDateTime(startOfDay)],
          readsFrom: {database.beneficiaries},
        )
        .getSingle();
    return result.read<int>('count');
  }

  Future<int> _getSyncedRecordsToday(DateTime startOfDay) async {
    // TODO: Implement with sync service
    return 0;
  }

  Future<Map<String, int>> _getCategoryCounts() async {
    // Category codes: 1=orphan, 2=poor, 3=widow, 4=disabled
    final categoryCodes = [1, 2, 3, 4];
    final categoryNames = ['orphan', 'widow', 'poor', 'disabled'];
    final counts = await Future.wait(
      categoryCodes.map(
        (code) => database.beneficiariesDao.countBeneficiariesByCategory(code),
      ),
    );

    return Map.fromIterables(categoryNames, counts);
  }

  Future<List<GrowthDataPointModel>> _getGrowthData() async {
    // Get last 7 days growth data
    final growthData = <GrowthDataPointModel>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final nextDay = date.add(const Duration(days: 1));

      final result = await database
          .customSelect(
            'SELECT COUNT(*) as count FROM beneficiaries WHERE created_at >= ? AND created_at < ?',
            variables: [
              Variable.withDateTime(date),
              Variable.withDateTime(nextDay),
            ],
            readsFrom: {database.beneficiaries},
          )
          .getSingle();

      growthData.add(
        GrowthDataPointModel(date: date, count: result.read<int>('count')),
      );
    }

    return growthData;
  }

  /// ⚡ Get family statistics (NEW)
  Future<Map<String, dynamic>> _getFamilyStatistics() async {
    // Count all family members
    final totalOrphansResult = await database
        .customSelect(
          'SELECT COUNT(*) as count FROM family_members',
          readsFrom: {database.familyMembersTable},
        )
        .getSingle();
    final totalOrphans = totalOrphansResult.read<int>('count');

    // Count deceased members
    final totalDeceasedResult = await database
        .customSelect(
          'SELECT COUNT(*) as count FROM family_deceased',
          readsFrom: {database.familyDeceasedTable},
        )
        .getSingle();
    final totalDeceased = totalDeceasedResult.read<int>('count');

    // Total family members (deceased + orphans)
    final totalFamilyMembers = totalDeceased + totalOrphans;

    // Average family size (orphans per beneficiary)
    final beneficiariesCount = await database.beneficiariesDao
        .countBeneficiaries();
    final averageFamilySize = beneficiariesCount > 0
        ? (totalOrphans / beneficiariesCount)
        : 0.0;

    return {
      'totalFamilyMembers': totalFamilyMembers,
      'totalDeceased': totalDeceased,
      'totalOrphans': totalOrphans,
      'averageFamilySize': averageFamilySize,
    };
  }

  /// Clear all caches
  Future<void> clearCache() async {
    await prefs.remove(_statsCacheKey);
    await prefs.remove(_todayStatsCacheKey);
    await prefs.remove('${_statsCacheKey}_time');
    await prefs.remove('${_todayStatsCacheKey}_time');
  }
}
