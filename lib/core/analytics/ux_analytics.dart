import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📊 UX Analytics Tracker
///
/// Tracks user interactions with enhanced UX features for A/B testing:
/// - Haptic feedback usage patterns
/// - Dark mode adoption
/// - Animation performance metrics
/// - Accessibility feature usage
class UxAnalytics {
  static const String _prefixKey = 'ux_analytics_';

  // 🎯 Haptic Feedback Metrics
  static const String _hapticUsageCount = '${_prefixKey}haptic_usage_count';
  static const String _hapticDisabledCount =
      '${_prefixKey}haptic_disabled_count';
  static const String _hapticLastUsed = '${_prefixKey}haptic_last_used';

  // 🌙 Dark Mode Metrics
  static const String _darkModeEnabled = '${_prefixKey}dark_mode_enabled';
  static const String _darkModeToggleCount =
      '${_prefixKey}dark_mode_toggle_count';
  static const String _darkModeFirstEnabled =
      '${_prefixKey}dark_mode_first_enabled';

  // 🎨 Animation Metrics
  static const String _animationFrameDrops =
      '${_prefixKey}animation_frame_drops';
  static const String _averageAnimationDuration =
      '${_prefixKey}avg_animation_duration';

  // ♿ Accessibility Metrics
  static const String _screenReaderUsage = '${_prefixKey}screen_reader_usage';
  static const String _semanticsInteractions =
      '${_prefixKey}semantics_interactions';

  // 📈 Performance Metrics
  static const String _sessionStartTime = '${_prefixKey}session_start';
  static const String _totalSessions = '${_prefixKey}total_sessions';

  /// Track haptic feedback usage
  static Future<void> trackHapticUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_hapticUsageCount) ?? 0;
      await prefs.setInt(_hapticUsageCount, currentCount + 1);
      await prefs.setString(_hapticLastUsed, DateTime.now().toIso8601String());

      if (kDebugMode) {
        print('📊 Haptic usage tracked: ${currentCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking haptic usage: $e');
      }
    }
  }

  /// Track when user disables haptic feedback
  static Future<void> trackHapticDisabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_hapticDisabledCount) ?? 0;
      await prefs.setInt(_hapticDisabledCount, currentCount + 1);

      if (kDebugMode) {
        print('📊 Haptic disabled tracked: ${currentCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking haptic disabled: $e');
      }
    }
  }

  /// Track dark mode toggle
  static Future<void> trackDarkModeToggle(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeEnabled, enabled);

      final toggleCount = prefs.getInt(_darkModeToggleCount) ?? 0;
      await prefs.setInt(_darkModeToggleCount, toggleCount + 1);

      if (enabled && !prefs.containsKey(_darkModeFirstEnabled)) {
        await prefs.setString(
            _darkModeFirstEnabled, DateTime.now().toIso8601String());
      }

      if (kDebugMode) {
        print(
            '📊 Dark mode ${enabled ? "enabled" : "disabled"}: toggle #${toggleCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking dark mode toggle: $e');
      }
    }
  }

  /// Track animation performance issues
  static Future<void> trackAnimationFrameDrop() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dropCount = prefs.getInt(_animationFrameDrops) ?? 0;
      await prefs.setInt(_animationFrameDrops, dropCount + 1);

      if (kDebugMode) {
        print('📊 Animation frame drop tracked: ${dropCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking animation drop: $e');
      }
    }
  }

  /// Track animation duration for performance monitoring
  static Future<void> trackAnimationDuration(int milliseconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentAvg = prefs.getInt(_averageAnimationDuration) ?? 0;
      final newAvg = (currentAvg + milliseconds) ~/ 2;
      await prefs.setInt(_averageAnimationDuration, newAvg);

      if (kDebugMode && milliseconds > 350) {
        print('⚠️ Slow animation detected: ${milliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking animation duration: $e');
      }
    }
  }

  /// Track screen reader usage
  static Future<void> trackScreenReaderUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_screenReaderUsage, true);

      if (kDebugMode) {
        print('📊 Screen reader usage detected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking screen reader: $e');
      }
    }
  }

  /// Track semantics interactions
  static Future<void> trackSemanticsInteraction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_semanticsInteractions) ?? 0;
      await prefs.setInt(_semanticsInteractions, count + 1);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking semantics: $e');
      }
    }
  }

  /// Start a new session
  static Future<void> startSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _sessionStartTime, DateTime.now().toIso8601String());

      final sessionCount = prefs.getInt(_totalSessions) ?? 0;
      await prefs.setInt(_totalSessions, sessionCount + 1);

      if (kDebugMode) {
        print('📊 Session started: #${sessionCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting session: $e');
      }
    }
  }

  /// Get analytics summary for debugging/reporting
  static Future<Map<String, dynamic>> getAnalyticsSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'haptic': {
          'usageCount': prefs.getInt(_hapticUsageCount) ?? 0,
          'disabledCount': prefs.getInt(_hapticDisabledCount) ?? 0,
          'lastUsed': prefs.getString(_hapticLastUsed),
        },
        'darkMode': {
          'enabled': prefs.getBool(_darkModeEnabled) ?? false,
          'toggleCount': prefs.getInt(_darkModeToggleCount) ?? 0,
          'firstEnabled': prefs.getString(_darkModeFirstEnabled),
        },
        'animations': {
          'frameDrops': prefs.getInt(_animationFrameDrops) ?? 0,
          'avgDuration': prefs.getInt(_averageAnimationDuration) ?? 0,
        },
        'accessibility': {
          'screenReaderUsed': prefs.getBool(_screenReaderUsage) ?? false,
          'semanticsInteractions': prefs.getInt(_semanticsInteractions) ?? 0,
        },
        'sessions': {
          'total': prefs.getInt(_totalSessions) ?? 0,
          'currentStart': prefs.getString(_sessionStartTime),
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting analytics summary: $e');
      }
      return {};
    }
  }

  /// Reset all analytics (for testing)
  static Future<void> resetAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefixKey));
      for (final key in keys) {
        await prefs.remove(key);
      }

      if (kDebugMode) {
        print('📊 Analytics reset complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting analytics: $e');
      }
    }
  }

  /// Export analytics data as JSON string
  static Future<String> exportAnalytics() async {
    final summary = await getAnalyticsSummary();
    return summary.toString();
  }
}
