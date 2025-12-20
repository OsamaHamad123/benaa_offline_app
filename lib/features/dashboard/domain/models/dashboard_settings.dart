// Dashboard Settings Model without dart:convert

/// Dashboard Settings Model - إعدادات قابلة للتخصيص
class DashboardSettings {
  // Section Visibility
  final bool showQuickActions;
  final bool showStatistics;
  final bool showCharts;
  final bool showGeographicDistribution;
  final bool showDailyPerformance;
  final bool showRecentActivities;

  // Section Order (0-based index)
  final int quickActionsOrder;
  final int statisticsOrder;
  final int chartsOrder;
  final int geographicDistributionOrder;
  final int dailyPerformanceOrder;
  final int recentActivitiesOrder;

  // Color Theme
  final String colorTheme; // 'default', 'blue', 'green', 'purple'

  // Display Preferences
  final bool showWelcomeBanner;
  final bool showFilterChips;
  final bool enableHapticFeedback;
  final bool enableAnimations;

  // Refresh Settings
  final int autoRefreshSeconds; // 0 = disabled

  const DashboardSettings({
    this.showQuickActions = true,
    this.showStatistics = true,
    this.showCharts = true,
    this.showGeographicDistribution = true,
    this.showDailyPerformance = true,
    this.showRecentActivities = true,
    this.quickActionsOrder = 0,
    this.statisticsOrder = 1,
    this.chartsOrder = 2,
    this.geographicDistributionOrder = 3,
    this.dailyPerformanceOrder = 4,
    this.recentActivitiesOrder = 5,
    this.colorTheme = 'default',
    this.showWelcomeBanner = true,
    this.showFilterChips = true,
    this.enableHapticFeedback = true,
    this.enableAnimations = true,
    this.autoRefreshSeconds = 300,
  });

  factory DashboardSettings.fromJson(Map<String, dynamic> json) {
    return DashboardSettings(
      showQuickActions: json['showQuickActions'] as bool? ?? true,
      showStatistics: json['showStatistics'] as bool? ?? true,
      showCharts: json['showCharts'] as bool? ?? true,
      showGeographicDistribution: json['showGeographicDistribution'] as bool? ?? true,
      showDailyPerformance: json['showDailyPerformance'] as bool? ?? true,
      showRecentActivities: json['showRecentActivities'] as bool? ?? true,
      quickActionsOrder: json['quickActionsOrder'] as int? ?? 0,
      statisticsOrder: json['statisticsOrder'] as int? ?? 1,
      chartsOrder: json['chartsOrder'] as int? ?? 2,
      geographicDistributionOrder: json['geographicDistributionOrder'] as int? ?? 3,
      dailyPerformanceOrder: json['dailyPerformanceOrder'] as int? ?? 4,
      recentActivitiesOrder: json['recentActivitiesOrder'] as int? ?? 5,
      colorTheme: json['colorTheme'] as String? ?? 'default',
      showWelcomeBanner: json['showWelcomeBanner'] as bool? ?? true,
      showFilterChips: json['showFilterChips'] as bool? ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      autoRefreshSeconds: json['autoRefreshSeconds'] as int? ?? 300,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showQuickActions': showQuickActions,
      'showStatistics': showStatistics,
      'showCharts': showCharts,
      'showGeographicDistribution': showGeographicDistribution,
      'showDailyPerformance': showDailyPerformance,
      'showRecentActivities': showRecentActivities,
      'quickActionsOrder': quickActionsOrder,
      'statisticsOrder': statisticsOrder,
      'chartsOrder': chartsOrder,
      'geographicDistributionOrder': geographicDistributionOrder,
      'dailyPerformanceOrder': dailyPerformanceOrder,
      'recentActivitiesOrder': recentActivitiesOrder,
      'colorTheme': colorTheme,
      'showWelcomeBanner': showWelcomeBanner,
      'showFilterChips': showFilterChips,
      'enableHapticFeedback': enableHapticFeedback,
      'enableAnimations': enableAnimations,
      'autoRefreshSeconds': autoRefreshSeconds,
    };
  }

  DashboardSettings copyWith({
    bool? showQuickActions,
    bool? showStatistics,
    bool? showCharts,
    bool? showGeographicDistribution,
    bool? showDailyPerformance,
    bool? showRecentActivities,
    int? quickActionsOrder,
    int? statisticsOrder,
    int? chartsOrder,
    int? geographicDistributionOrder,
    int? dailyPerformanceOrder,
    int? recentActivitiesOrder,
    String? colorTheme,
    bool? showWelcomeBanner,
    bool? showFilterChips,
    bool? enableHapticFeedback,
    bool? enableAnimations,
    int? autoRefreshSeconds,
  }) {
    return DashboardSettings(
      showQuickActions: showQuickActions ?? this.showQuickActions,
      showStatistics: showStatistics ?? this.showStatistics,
      showCharts: showCharts ?? this.showCharts,
      showGeographicDistribution: showGeographicDistribution ?? this.showGeographicDistribution,
      showDailyPerformance: showDailyPerformance ?? this.showDailyPerformance,
      showRecentActivities: showRecentActivities ?? this.showRecentActivities,
      quickActionsOrder: quickActionsOrder ?? this.quickActionsOrder,
      statisticsOrder: statisticsOrder ?? this.statisticsOrder,
      chartsOrder: chartsOrder ?? this.chartsOrder,
      geographicDistributionOrder: geographicDistributionOrder ?? this.geographicDistributionOrder,
      dailyPerformanceOrder: dailyPerformanceOrder ?? this.dailyPerformanceOrder,
      recentActivitiesOrder: recentActivitiesOrder ?? this.recentActivitiesOrder,
      colorTheme: colorTheme ?? this.colorTheme,
      showWelcomeBanner: showWelcomeBanner ?? this.showWelcomeBanner,
      showFilterChips: showFilterChips ?? this.showFilterChips,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      autoRefreshSeconds: autoRefreshSeconds ?? this.autoRefreshSeconds,
    );
  }

  /// Default Settings
  factory DashboardSettings.defaultSettings() => const DashboardSettings();
}
