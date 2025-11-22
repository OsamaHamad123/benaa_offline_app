import '../../domain/entities/dashboard_statistics.dart';

/// Dashboard Statistics Model - extends Entity with JSON serialization
class DashboardStatisticsModel extends DashboardStatistics {
  const DashboardStatisticsModel({
    required super.totalBeneficiaries,
    required super.activeBeneficiaries,
    required super.pendingSync,
    required super.completedVisitsToday,
    super.lastSyncTime,
    required super.categoryCounts,
    required super.growthData,
    required super.todayStats,
    super.totalFamilyMembers,
    super.totalDeceased,
    super.totalOrphans,
    super.averageFamilySize,
  });

  factory DashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatisticsModel(
      totalBeneficiaries: json['totalBeneficiaries'] as int,
      activeBeneficiaries: json['activeBeneficiaries'] as int,
      pendingSync: json['pendingSync'] as int,
      completedVisitsToday: json['completedVisitsToday'] as int,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      categoryCounts: Map<String, int>.from(json['categoryCounts'] as Map),
      growthData: (json['growthData'] as List)
          .map((e) => GrowthDataPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayStats: TodayStatsModel.fromJson(
        json['todayStats'] as Map<String, dynamic>,
      ),
      totalFamilyMembers: json['totalFamilyMembers'] as int? ?? 0,
      totalDeceased: json['totalDeceased'] as int? ?? 0,
      totalOrphans: json['totalOrphans'] as int? ?? 0,
      averageFamilySize: (json['averageFamilySize'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBeneficiaries': totalBeneficiaries,
      'activeBeneficiaries': activeBeneficiaries,
      'pendingSync': pendingSync,
      'completedVisitsToday': completedVisitsToday,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'categoryCounts': categoryCounts,
      'growthData': growthData
          .map((e) => (e as GrowthDataPointModel).toJson())
          .toList(),
      'todayStats': (todayStats as TodayStatsModel).toJson(),
      'totalFamilyMembers': totalFamilyMembers,
      'totalDeceased': totalDeceased,
      'totalOrphans': totalOrphans,
      'averageFamilySize': averageFamilySize,
    };
  }
}

class GrowthDataPointModel extends GrowthDataPoint {
  const GrowthDataPointModel({required super.date, required super.count});

  factory GrowthDataPointModel.fromJson(Map<String, dynamic> json) {
    return GrowthDataPointModel(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'count': count};
  }
}

class TodayStatsModel extends TodayStats {
  const TodayStatsModel({
    required super.newBeneficiaries,
    required super.completedVisits,
    required super.pendingTasks,
    required super.syncedRecords,
  });

  factory TodayStatsModel.fromJson(Map<String, dynamic> json) {
    return TodayStatsModel(
      newBeneficiaries: json['newBeneficiaries'] as int,
      completedVisits: json['completedVisits'] as int,
      pendingTasks: json['pendingTasks'] as int,
      syncedRecords: json['syncedRecords'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newBeneficiaries': newBeneficiaries,
      'completedVisits': completedVisits,
      'pendingTasks': pendingTasks,
      'syncedRecords': syncedRecords,
    };
  }
}
