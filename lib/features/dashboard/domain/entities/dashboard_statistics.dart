import 'package:equatable/equatable.dart';

/// Dashboard Statistics Entity - Pure business logic
class DashboardStatistics extends Equatable {
  final int totalBeneficiaries;
  final int activeBeneficiaries;
  final int pendingSync;
  final int completedVisitsToday;
  final DateTime? lastSyncTime;
  final Map<String, int> categoryCounts;
  final List<GrowthDataPoint> growthData;
  final TodayStats todayStats;

  const DashboardStatistics({
    required this.totalBeneficiaries,
    required this.activeBeneficiaries,
    required this.pendingSync,
    required this.completedVisitsToday,
    this.lastSyncTime,
    required this.categoryCounts,
    required this.growthData,
    required this.todayStats,
  });

  @override
  List<Object?> get props => [
    totalBeneficiaries,
    activeBeneficiaries,
    pendingSync,
    completedVisitsToday,
    lastSyncTime,
    categoryCounts,
    growthData,
    todayStats,
  ];
}

/// Growth Data Point for charts
class GrowthDataPoint extends Equatable {
  final DateTime date;
  final int count;

  const GrowthDataPoint({required this.date, required this.count});

  @override
  List<Object> get props => [date, count];
}

/// Today's Statistics
class TodayStats extends Equatable {
  final int newBeneficiaries;
  final int completedVisits;
  final int pendingTasks;
  final int syncedRecords;

  const TodayStats({
    required this.newBeneficiaries,
    required this.completedVisits,
    required this.pendingTasks,
    required this.syncedRecords,
  });

  int get totalActivity => newBeneficiaries + completedVisits + syncedRecords;

  @override
  List<Object> get props => [
    newBeneficiaries,
    completedVisits,
    pendingTasks,
    syncedRecords,
  ];
}
