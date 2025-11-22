import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⚙️ App Settings Manager - مدير إعدادات التطبيق
class AppSettingsManager {
  static final AppSettingsManager _instance = AppSettingsManager._();
  factory AppSettingsManager() => _instance;
  AppSettingsManager._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 🔔 Notifications Settings
  bool get notificationsEnabled =>
      _prefs?.getBool('notifications_enabled') ?? true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool('notifications_enabled', value);
  }

  // 🔊 Sound Settings
  bool get soundEnabled => _prefs?.getBool('sound_enabled') ?? true;

  Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool('sound_enabled', value);
  }

  // 📳 Vibration Settings
  bool get vibrationEnabled => _prefs?.getBool('vibration_enabled') ?? true;

  Future<void> setVibrationEnabled(bool value) async {
    await _prefs?.setBool('vibration_enabled', value);
  }

  // 🌐 Auto Sync Settings
  bool get autoSyncEnabled => _prefs?.getBool('auto_sync_enabled') ?? false;

  Future<void> setAutoSyncEnabled(bool value) async {
    await _prefs?.setBool('auto_sync_enabled', value);
  }

  // 📶 WiFi Only Sync
  bool get wifiOnlySync => _prefs?.getBool('wifi_only_sync') ?? true;

  Future<void> setWifiOnlySync(bool value) async {
    await _prefs?.setBool('wifi_only_sync', value);
  }

  // 🕐 Sync Interval (in hours)
  int get syncInterval => _prefs?.getInt('sync_interval') ?? 24;

  Future<void> setSyncInterval(int hours) async {
    await _prefs?.setInt('sync_interval', hours);
  }

  // 🎨 Theme Mode
  String get themeMode => _prefs?.getString('theme_mode') ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  // 🔤 Font Size
  double get fontSize => _prefs?.getDouble('font_size') ?? 14.0;

  Future<void> setFontSize(double size) async {
    await _prefs?.setDouble('font_size', size);
  }

  // 📄 Items Per Page
  int get itemsPerPage => _prefs?.getInt('items_per_page') ?? 20;

  Future<void> setItemsPerPage(int count) async {
    await _prefs?.setInt('items_per_page', count);
  }

  // 🗂️ Default Sort
  String get defaultSort => _prefs?.getString('default_sort') ?? 'name_asc';

  Future<void> setDefaultSort(String sort) async {
    await _prefs?.setString('default_sort', sort);
  }

  // 💾 Cache Duration (in minutes)
  int get cacheDuration => _prefs?.getInt('cache_duration') ?? 30;

  Future<void> setCacheDuration(int minutes) async {
    await _prefs?.setInt('cache_duration', minutes);
  }

  // 🔍 Search History Size
  int get searchHistorySize => _prefs?.getInt('search_history_size') ?? 10;

  Future<void> setSearchHistorySize(int size) async {
    await _prefs?.setInt('search_history_size', size);
  }

  // 📊 Show Statistics
  bool get showStatistics => _prefs?.getBool('show_statistics') ?? true;

  Future<void> setShowStatistics(bool value) async {
    await _prefs?.setBool('show_statistics', value);
  }

  // 🎯 Show Performance Dashboard
  bool get showPerformanceDashboard =>
      _prefs?.getBool('show_performance_dashboard') ?? false;

  Future<void> setShowPerformanceDashboard(bool value) async {
    await _prefs?.setBool('show_performance_dashboard', value);
  }

  // 🗑️ Clear All Settings
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // 🔄 Reset to Defaults
  Future<void> resetToDefaults() async {
    await setNotificationsEnabled(true);
    await setSoundEnabled(true);
    await setVibrationEnabled(true);
    await setAutoSyncEnabled(false);
    await setWifiOnlySync(true);
    await setSyncInterval(24);
    await setThemeMode('system');
    await setFontSize(14.0);
    await setItemsPerPage(20);
    await setDefaultSort('name_asc');
    await setCacheDuration(30);
    await setSearchHistorySize(10);
    await setShowStatistics(true);
    await setShowPerformanceDashboard(false);
  }
}

/// Provider للإعدادات
final appSettingsProvider = Provider<AppSettingsManager>((ref) {
  return AppSettingsManager();
});

/// 🎯 Settings Page - صفحة الإعدادات
class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'استعادة الإعدادات الافتراضية',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('استعادة الإعدادات'),
                  content: const Text(
                    'هل تريد استعادة جميع الإعدادات إلى القيم الافتراضية؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('استعادة'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await settings.resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم استعادة الإعدادات الافتراضية'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('الإشعارات'),
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('عرض إشعارات للأحداث المهمة'),
            value: settings.notificationsEnabled,
            onChanged: (value) => settings.setNotificationsEnabled(value),
          ),
          SwitchListTile(
            title: const Text('الصوت'),
            subtitle: const Text('تشغيل الأصوات مع الإشعارات'),
            value: settings.soundEnabled,
            onChanged: (value) => settings.setSoundEnabled(value),
          ),
          SwitchListTile(
            title: const Text('الاهتزاز'),
            subtitle: const Text('اهتزاز الجهاز عند الإجراءات'),
            value: settings.vibrationEnabled,
            onChanged: (value) => settings.setVibrationEnabled(value),
          ),

          const Divider(),

          // Sync Section
          _buildSectionHeader('المزامنة'),
          SwitchListTile(
            title: const Text('مزامنة تلقائية'),
            subtitle: const Text('مزامنة البيانات تلقائياً'),
            value: settings.autoSyncEnabled,
            onChanged: (value) => settings.setAutoSyncEnabled(value),
          ),
          SwitchListTile(
            title: const Text('WiFi فقط'),
            subtitle: const Text('المزامنة عند الاتصال بـ WiFi فقط'),
            value: settings.wifiOnlySync,
            onChanged: (value) => settings.setWifiOnlySync(value),
          ),
          ListTile(
            title: const Text('فترة المزامنة'),
            subtitle: Text('كل ${settings.syncInterval} ساعة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSyncIntervalDialog(context, settings),
          ),

          const Divider(),

          // Display Section
          _buildSectionHeader('العرض'),
          ListTile(
            title: const Text('المظهر'),
            subtitle: Text(_getThemeModeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(context, settings),
          ),
          ListTile(
            title: const Text('حجم الخط'),
            subtitle: Text('${settings.fontSize.toInt()} نقطة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(context, settings),
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader('البيانات'),
          ListTile(
            title: const Text('عدد العناصر في الصفحة'),
            subtitle: Text('${settings.itemsPerPage} عنصر'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showItemsPerPageDialog(context, settings),
          ),
          SwitchListTile(
            title: const Text('عرض الإحصائيات'),
            subtitle: const Text('إظهار لوحة الإحصائيات'),
            value: settings.showStatistics,
            onChanged: (value) => settings.setShowStatistics(value),
          ),

          const Divider(),

          // Advanced Section
          _buildSectionHeader('متقدم'),
          SwitchListTile(
            title: const Text('لوحة الأداء'),
            subtitle: const Text('عرض معلومات الأداء (للمطورين)'),
            value: settings.showPerformanceDashboard,
            onChanged: (value) => settings.setShowPerformanceDashboard(value),
          ),
          ListTile(
            title: const Text('مدة التخزين المؤقت'),
            subtitle: Text('${settings.cacheDuration} دقيقة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCacheDurationDialog(context, settings),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      case 'system':
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  void _showThemeModeDialog(BuildContext context, AppSettingsManager settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('فاتح'),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('داكن'),
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('تلقائي'),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, AppSettingsManager settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجم الخط'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مثال على النص',
                  style: TextStyle(fontSize: settings.fontSize),
                ),
                Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 20,
                  divisions: 8,
                  label: settings.fontSize.toInt().toString(),
                  onChanged: (value) {
                    settings.setFontSize(value);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showSyncIntervalDialog(
    BuildContext context,
    AppSettingsManager settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فترة المزامنة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final hours in [1, 6, 12, 24, 48])
              RadioListTile<int>(
                title: Text('كل $hours ساعة'),
                value: hours,
                groupValue: settings.syncInterval,
                onChanged: (value) {
                  if (value != null) {
                    settings.setSyncInterval(value);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showItemsPerPageDialog(
    BuildContext context,
    AppSettingsManager settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عدد العناصر في الصفحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final count in [10, 20, 30, 50, 100])
              RadioListTile<int>(
                title: Text('$count عنصر'),
                value: count,
                groupValue: settings.itemsPerPage,
                onChanged: (value) {
                  if (value != null) {
                    settings.setItemsPerPage(value);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCacheDurationDialog(
    BuildContext context,
    AppSettingsManager settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مدة التخزين المؤقت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [15, 30, 60, 120])
              RadioListTile<int>(
                title: Text('$minutes دقيقة'),
                value: minutes,
                groupValue: settings.cacheDuration,
                onChanged: (value) {
                  if (value != null) {
                    settings.setCacheDuration(value);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
