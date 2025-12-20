import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_mode_settings.dart';

/// 🌙 Theme Mode Notifier
///
/// إدارة حالة وضع السمة
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAutoSwitch = 'auto_switch_theme';

  bool _autoSwitch = false;
  bool get autoSwitch => _autoSwitch;

  /// تحميل وضع السمة المحفوظ
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_keyThemeMode);
      final autoSwitch = prefs.getBool(_keyAutoSwitch) ?? false;

      _autoSwitch = autoSwitch;

      state = ThemeModeSettings.getCurrentThemeMode(
        savedMode: savedMode,
        autoSwitch: autoSwitch,
      );
    } catch (e) {
      // في حالة الخطأ، استخدم النظام
      state = ThemeMode.system;
    }
  }

  /// تغيير وضع السمة
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyThemeMode,
        ThemeModeSettings.themeModeToString(mode),
      );

      // إيقاف التبديل التلقائي عند الاختيار اليدوي
      if (_autoSwitch) {
        await setAutoSwitch(false);
      }

      state = mode;
    } catch (e) {
      // في حالة الخطأ، لا تغير الحالة
    }
  }

  /// تفعيل/إيقاف التبديل التلقائي
  Future<void> setAutoSwitch(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAutoSwitch, enabled);
      _autoSwitch = enabled;

      if (enabled) {
        // تطبيق الوضع التلقائي فوراً
        state = ThemeModeSettings.getCurrentThemeMode(
          savedMode: null,
          autoSwitch: true,
        );
      }
    } catch (e) {
      // في حالة الخطأ، لا تغير الحالة
    }
  }

  /// تحديث الوضع التلقائي (يُستدعى دورياً)
  void updateAutomaticMode() {
    if (_autoSwitch) {
      final newMode = ThemeModeSettings.getCurrentThemeMode(
        savedMode: null,
        autoSwitch: true,
      );

      if (state != newMode) {
        state = newMode;
      }
    }
  }
}

/// Provider لوضع السمة
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
