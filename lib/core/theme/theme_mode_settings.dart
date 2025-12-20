import 'package:flutter/material.dart';

/// 🌙 Theme Mode Settings
///
/// إدارة وضع السمة (فاتح/داكن/تلقائي)
class ThemeModeSettings {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAutoSwitch = 'auto_switch_theme';

  // أوقات التبديل التلقائي
  static const int dayStartHour = 6; // 6 صباحاً
  static const int nightStartHour = 18; // 6 مساءً

  /// الحصول على وضع السمة الحالي
  static ThemeMode getCurrentThemeMode({
    required String? savedMode,
    required bool autoSwitch,
  }) {
    if (autoSwitch) {
      return _getAutomaticThemeMode();
    }

    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// التبديل التلقائي حسب الوقت
  static ThemeMode _getAutomaticThemeMode() {
    final hour = DateTime.now().hour;

    // من 6 صباحاً إلى 6 مساءً: وضع فاتح
    // من 6 مساءً إلى 6 صباحاً: وضع داكن
    if (hour >= dayStartHour && hour < nightStartHour) {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
  }

  /// تحويل ThemeMode إلى String للحفظ
  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// الحصول على اسم الوضع بالعربية
  static String getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'حسب النظام';
    }
  }

  /// الحصول على أيقونة الوضع
  static IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
