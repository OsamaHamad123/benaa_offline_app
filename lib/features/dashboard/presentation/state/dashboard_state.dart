import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_statistics.dart';
import '../../domain/entities/activity.dart';

/// حارس للتمييز بين "غير مُمرَّر" و"null صريح" في copyWith.
const Object _unset = Object();

/// Dashboard State - Immutable state with Equatable
class DashboardState extends Equatable {
  final DashboardStatistics? statistics;
  final TodayStats? todayStats;
  final List<Activity> activities;
  final bool isLoadingStats;
  final bool isLoadingActivities;
  final bool hasMoreActivities;
  final String? errorMessage;
  final DateTime? lastRefreshTime;

  const DashboardState({
    this.statistics,
    this.todayStats,
    this.activities = const [],
    this.isLoadingStats = false,
    this.isLoadingActivities = false,
    this.hasMoreActivities = true,
    this.errorMessage,
    this.lastRefreshTime,
  });

  const DashboardState.initial()
      : statistics = null,
        todayStats = null,
        activities = const [],
        isLoadingStats = true,
        isLoadingActivities = false,
        hasMoreActivities = true,
        errorMessage = null,
        lastRefreshTime = null;

  DashboardState copyWith({
    DashboardStatistics? statistics,
    TodayStats? todayStats,
    List<Activity>? activities,
    bool? isLoadingStats,
    bool? isLoadingActivities,
    bool? hasMoreActivities,
    Object? errorMessage = _unset,
    DateTime? lastRefreshTime,
  }) {
    return DashboardState(
      statistics: statistics ?? this.statistics,
      todayStats: todayStats ?? this.todayStats,
      activities: activities ?? this.activities,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingActivities: isLoadingActivities ?? this.isLoadingActivities,
      hasMoreActivities: hasMoreActivities ?? this.hasMoreActivities,
      // sentinel: عدم التمرير يُبقي الخطأ، وتمرير null صراحةً يمسحه
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasData => statistics != null;

  @override
  List<Object?> get props => [
        statistics,
        todayStats,
        activities,
        isLoadingStats,
        isLoadingActivities,
        hasMoreActivities,
        errorMessage,
        lastRefreshTime,
      ];
}
