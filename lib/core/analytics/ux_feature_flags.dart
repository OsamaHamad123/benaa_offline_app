import 'package:shared_preferences/shared_preferences.dart';

class UxFeatureFlags {
  final bool enableDashboardAnalyticalMode;
  final bool enableSyncDiagnosticMode;

  const UxFeatureFlags({
    this.enableDashboardAnalyticalMode = true,
    this.enableSyncDiagnosticMode = true,
  });
}

class UxFeatureFlagsStore {
  static const String _dashboardAnalyticalKey = 'ux_flag_dashboard_analytical_mode';
  static const String _syncDiagnosticKey = 'ux_flag_sync_diagnostic_mode';

  final SharedPreferences _prefs;

  const UxFeatureFlagsStore(this._prefs);

  UxFeatureFlags readFlags() {
    return UxFeatureFlags(
      enableDashboardAnalyticalMode: _prefs.getBool(_dashboardAnalyticalKey) ?? true,
      enableSyncDiagnosticMode: _prefs.getBool(_syncDiagnosticKey) ?? true,
    );
  }

  Future<void> setDashboardAnalyticalMode(bool enabled) async {
    await _prefs.setBool(_dashboardAnalyticalKey, enabled);
  }

  Future<void> setSyncDiagnosticMode(bool enabled) async {
    await _prefs.setBool(_syncDiagnosticKey, enabled);
  }
}
