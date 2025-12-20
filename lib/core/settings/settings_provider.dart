import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/ux_analytics.dart';

/// ⚙️ Settings State - حالة الإعدادات
class SettingsState {
  // Notifications
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  // Sync
  final bool autoSyncEnabled;
  final bool wifiOnlySync;
  final int syncIntervalHours;

  // Theme
  final String themeMode; // 'light', 'dark', 'system'
  final String colorScheme; // 'blue', 'green', 'purple', etc.
  final double fontSize;
  final bool useMaterial3;

  // Display
  final int itemsPerPage;
  final String defaultSort;
  final bool showStatistics;
  final bool showPerformanceDashboard;

  // Data
  final int cacheDurationMinutes;
  final int searchHistorySize;
  final bool offlineMode;

  // Advanced
  final bool developerMode;
  final bool debugLogging;
  final bool showDebugInfo;

  const SettingsState({
    // Notifications
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    // Sync
    this.autoSyncEnabled = false,
    this.wifiOnlySync = true,
    this.syncIntervalHours = 24,
    // Theme
    this.themeMode = 'system',
    this.colorScheme = 'blue',
    this.fontSize = 14.0,
    this.useMaterial3 = true,
    // Display
    this.itemsPerPage = 20,
    this.defaultSort = 'name_asc',
    this.showStatistics = true,
    this.showPerformanceDashboard = false,
    // Data
    this.cacheDurationMinutes = 30,
    this.searchHistorySize = 10,
    this.offlineMode = false,
    // Advanced
    this.developerMode = false,
    this.debugLogging = false,
    this.showDebugInfo = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoSyncEnabled,
    bool? wifiOnlySync,
    int? syncIntervalHours,
    String? themeMode,
    String? colorScheme,
    double? fontSize,
    bool? useMaterial3,
    int? itemsPerPage,
    String? defaultSort,
    bool? showStatistics,
    bool? showPerformanceDashboard,
    int? cacheDurationMinutes,
    int? searchHistorySize,
    bool? offlineMode,
    bool? developerMode,
    bool? debugLogging,
    bool? showDebugInfo,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      wifiOnlySync: wifiOnlySync ?? this.wifiOnlySync,
      syncIntervalHours: syncIntervalHours ?? this.syncIntervalHours,
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
      fontSize: fontSize ?? this.fontSize,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      defaultSort: defaultSort ?? this.defaultSort,
      showStatistics: showStatistics ?? this.showStatistics,
      showPerformanceDashboard:
          showPerformanceDashboard ?? this.showPerformanceDashboard,
      cacheDurationMinutes: cacheDurationMinutes ?? this.cacheDurationMinutes,
      searchHistorySize: searchHistorySize ?? this.searchHistorySize,
      offlineMode: offlineMode ?? this.offlineMode,
      developerMode: developerMode ?? this.developerMode,
      debugLogging: debugLogging ?? this.debugLogging,
      showDebugInfo: showDebugInfo ?? this.showDebugInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'wifiOnlySync': wifiOnlySync,
      'syncIntervalHours': syncIntervalHours,
      'themeMode': themeMode,
      'colorScheme': colorScheme,
      'fontSize': fontSize,
      'useMaterial3': useMaterial3,
      'itemsPerPage': itemsPerPage,
      'defaultSort': defaultSort,
      'showStatistics': showStatistics,
      'showPerformanceDashboard': showPerformanceDashboard,
      'cacheDurationMinutes': cacheDurationMinutes,
      'searchHistorySize': searchHistorySize,
      'offlineMode': offlineMode,
      'developerMode': developerMode,
      'debugLogging': debugLogging,
      'showDebugInfo': showDebugInfo,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      autoSyncEnabled: json['autoSyncEnabled'] ?? false,
      wifiOnlySync: json['wifiOnlySync'] ?? true,
      syncIntervalHours: json['syncIntervalHours'] ?? 24,
      themeMode: json['themeMode'] ?? 'system',
      colorScheme: json['colorScheme'] ?? 'blue',
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      useMaterial3: json['useMaterial3'] ?? true,
      itemsPerPage: json['itemsPerPage'] ?? 20,
      defaultSort: json['defaultSort'] ?? 'name_asc',
      showStatistics: json['showStatistics'] ?? true,
      showPerformanceDashboard: json['showPerformanceDashboard'] ?? false,
      cacheDurationMinutes: json['cacheDurationMinutes'] ?? 30,
      searchHistorySize: json['searchHistorySize'] ?? 10,
      offlineMode: json['offlineMode'] ?? false,
      developerMode: json['developerMode'] ?? false,
      debugLogging: json['debugLogging'] ?? false,
      showDebugInfo: json['showDebugInfo'] ?? false,
    );
  }
}

/// ⚙️ Settings Notifier - مدير حالة الإعدادات
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;
  static const String _key = 'app_settings';

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final json = _prefs.getString(_key);
    if (json != null) {
      try {
        final data = Map<String, dynamic>.from(
          _prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
            if (key.startsWith('settings_')) {
              final settingKey = key.replaceFirst('settings_', '');
              final value = _prefs.get(key);
              map[settingKey] = value;
            }
            return map;
          }),
        );
        state = SettingsState.fromJson(data);
      } catch (e) {
        // If loading fails, use default settings
        state = const SettingsState();
      }
    }
  }

  Future<void> _saveSettings() async {
    final data = state.toJson();
    for (final entry in data.entries) {
      final key = 'settings_${entry.key}';
      final value = entry.value;

      if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is String) {
        await _prefs.setString(key, value);
      }
    }
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _saveSettings();
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _saveSettings();
  }

  Future<void> setVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _saveSettings();

    // 📊 Track haptic disabled
    if (!value) {
      await UxAnalytics.trackHapticDisabled();
    }
  }

  // Sync
  Future<void> setAutoSyncEnabled(bool value) async {
    state = state.copyWith(autoSyncEnabled: value);
    await _saveSettings();
  }

  Future<void> setWifiOnlySync(bool value) async {
    state = state.copyWith(wifiOnlySync: value);
    await _saveSettings();
  }

  Future<void> setSyncInterval(int hours) async {
    state = state.copyWith(syncIntervalHours: hours);
    await _saveSettings();
  }

  // Theme
  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();

    // 📊 Track dark mode toggle
    if (mode == 'dark') {
      await UxAnalytics.trackDarkModeToggle(true);
    } else if (mode == 'light') {
      await UxAnalytics.trackDarkModeToggle(false);
    }
  }

  Future<void> setColorScheme(String scheme) async {
    state = state.copyWith(colorScheme: scheme);
    await _saveSettings();
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _saveSettings();
  }

  Future<void> setUseMaterial3(bool value) async {
    state = state.copyWith(useMaterial3: value);
    await _saveSettings();
  }

  // Display
  Future<void> setItemsPerPage(int count) async {
    state = state.copyWith(itemsPerPage: count);
    await _saveSettings();
  }

  Future<void> setDefaultSort(String sort) async {
    state = state.copyWith(defaultSort: sort);
    await _saveSettings();
  }

  Future<void> setShowStatistics(bool value) async {
    state = state.copyWith(showStatistics: value);
    await _saveSettings();
  }

  Future<void> setShowPerformanceDashboard(bool value) async {
    state = state.copyWith(showPerformanceDashboard: value);
    await _saveSettings();
  }

  // Data
  Future<void> setCacheDuration(int minutes) async {
    state = state.copyWith(cacheDurationMinutes: minutes);
    await _saveSettings();
  }

  Future<void> setSearchHistorySize(int size) async {
    state = state.copyWith(searchHistorySize: size);
    await _saveSettings();
  }

  Future<void> setOfflineMode(bool value) async {
    state = state.copyWith(offlineMode: value);
    await _saveSettings();
  }

  // Advanced
  Future<void> setDeveloperMode(bool value) async {
    state = state.copyWith(developerMode: value);
    await _saveSettings();
  }

  Future<void> setDebugLogging(bool value) async {
    state = state.copyWith(debugLogging: value);
    await _saveSettings();
  }

  Future<void> setShowDebugInfo(bool value) async {
    state = state.copyWith(showDebugInfo: value);
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    state = const SettingsState();
    await _saveSettings();
  }
}

/// Provider للإعدادات
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final prefs = ref.watch(
      sharedPreferencesProvider.select(
        (asyncPrefs) => asyncPrefs.maybeWhen(
          data: (p) => p,
          orElse: () => throw Exception('SharedPreferences not ready'),
        ),
      ),
    );
    return SettingsNotifier(prefs);
  },
);

/// Provider لـ SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});
