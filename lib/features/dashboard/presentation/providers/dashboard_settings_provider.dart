import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/dashboard_settings.dart';
import '../../../../core/providers/providers.dart';

/// Dashboard Settings Notifier
class DashboardSettingsNotifier extends StateNotifier<DashboardSettings> {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'dashboard_settings';

  DashboardSettingsNotifier(this._prefs) : super(DashboardSettings.defaultSettings()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final json = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = DashboardSettings.fromJson(json);
      } catch (e) {
        // If error, use default settings
        state = DashboardSettings.defaultSettings();
      }
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final json = state.toJson();
    await _prefs.setString(_settingsKey, jsonEncode(json));
  }

  /// Toggle section visibility
  Future<void> toggleSection(String section, bool value) async {
    switch (section) {
      case 'quickActions':
        state = state.copyWith(showQuickActions: value);
        break;
      case 'statistics':
        state = state.copyWith(showStatistics: value);
        break;
      case 'charts':
        state = state.copyWith(showCharts: value);
        break;
      case 'geographicDistribution':
        state = state.copyWith(showGeographicDistribution: value);
        break;
      case 'dailyPerformance':
        state = state.copyWith(showDailyPerformance: value);
        break;
      case 'recentActivities':
        state = state.copyWith(showRecentActivities: value);
        break;
    }
    await _saveSettings();
  }

  /// Update section order
  Future<void> updateSectionOrder(String section, int order) async {
    switch (section) {
      case 'quickActions':
        state = state.copyWith(quickActionsOrder: order);
        break;
      case 'statistics':
        state = state.copyWith(statisticsOrder: order);
        break;
      case 'charts':
        state = state.copyWith(chartsOrder: order);
        break;
      case 'geographicDistribution':
        state = state.copyWith(geographicDistributionOrder: order);
        break;
      case 'dailyPerformance':
        state = state.copyWith(dailyPerformanceOrder: order);
        break;
      case 'recentActivities':
        state = state.copyWith(recentActivitiesOrder: order);
        break;
    }
    await _saveSettings();
  }

  /// Change color theme
  Future<void> changeColorTheme(String theme) async {
    state = state.copyWith(colorTheme: theme);
    await _saveSettings();
  }

  /// Toggle display preferences
  Future<void> toggleWelcomeBanner(bool value) async {
    state = state.copyWith(showWelcomeBanner: value);
    await _saveSettings();
  }

  Future<void> toggleFilterChips(bool value) async {
    state = state.copyWith(showFilterChips: value);
    await _saveSettings();
  }

  Future<void> toggleHapticFeedback(bool value) async {
    state = state.copyWith(enableHapticFeedback: value);
    await _saveSettings();
  }

  Future<void> toggleAnimations(bool value) async {
    state = state.copyWith(enableAnimations: value);
    await _saveSettings();
  }

  /// Update auto-refresh interval
  Future<void> updateAutoRefresh(int seconds) async {
    state = state.copyWith(autoRefreshSeconds: seconds);
    await _saveSettings();
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    state = DashboardSettings.defaultSettings();
    await _saveSettings();
  }
}

/// Dashboard Settings Provider
final dashboardSettingsProvider = StateNotifierProvider<DashboardSettingsNotifier, DashboardSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return DashboardSettingsNotifier(prefs);
});
