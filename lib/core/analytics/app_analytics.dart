import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📊 Analytics Service لتتبع أداء التطبيق واستخدامه
class AppAnalytics {
  static final Map<String, int> _screenVisits = {};
  static final Map<String, Duration> _screenDurations = {};
  static final Map<String, DateTime> _screenStartTimes = {};
  static final List<PerformanceMetric> _performanceMetrics = [];

  /// تسجيل زيارة شاشة
  static void logScreenView(String screenName) {
    _screenVisits[screenName] = (_screenVisits[screenName] ?? 0) + 1;
    _screenStartTimes[screenName] = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        '📊 Screen View: $screenName (${_screenVisits[screenName]} visits)',
      );
    }
  }

  /// تسجيل مغادرة شاشة
  static void logScreenExit(String screenName) {
    final startTime = _screenStartTimes[screenName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _screenDurations[screenName] =
          (_screenDurations[screenName] ?? Duration.zero) + duration;
      _screenStartTimes.remove(screenName);

      if (kDebugMode) {
        debugPrint(
          '📊 Screen Exit: $screenName (duration: ${duration.inSeconds}s)',
        );
      }
    }
  }

  /// تسجيل إجراء مستخدم
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint(
        '📊 Event: $eventName ${parameters != null ? parameters.toString() : ''}',
      );
    }
  }

  /// تسجيل مقياس أداء
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final metric = PerformanceMetric(
      operation: operation,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _performanceMetrics.add(metric);

    // الاحتفاظ بآخر 100 مقياس فقط
    if (_performanceMetrics.length > 100) {
      _performanceMetrics.removeAt(0);
    }

    if (kDebugMode && duration.inMilliseconds > 100) {
      debugPrint(
        '⚠️  Slow Operation: $operation took ${duration.inMilliseconds}ms',
      );
    }
  }

  /// قياس وقت تنفيذ عملية
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await task();
      stopwatch.stop();
      logPerformance(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      logPerformance(
        operation,
        stopwatch.elapsed,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// الحصول على إحصائيات الشاشات
  static Map<String, ScreenStats> getScreenStats() {
    return _screenVisits.map((screen, visits) {
      return MapEntry(
        screen,
        ScreenStats(
          visits: visits,
          totalDuration: _screenDurations[screen] ?? Duration.zero,
          averageDuration: visits > 0
              ? Duration(
                  milliseconds:
                      (_screenDurations[screen]?.inMilliseconds ?? 0) ~/ visits,
                )
              : Duration.zero,
        ),
      );
    });
  }

  /// الحصول على مقاييس الأداء
  static List<PerformanceMetric> getPerformanceMetrics({
    String? operation,
    Duration? minDuration,
  }) {
    var metrics = _performanceMetrics;

    if (operation != null) {
      metrics = metrics.where((m) => m.operation == operation).toList();
    }

    if (minDuration != null) {
      metrics = metrics.where((m) => m.duration >= minDuration).toList();
    }

    return metrics;
  }

  /// الحصول على متوسط أداء عملية
  static Duration? getAveragePerformance(String operation) {
    final metrics = getPerformanceMetrics(operation: operation);
    if (metrics.isEmpty) return null;

    final totalMs = metrics.fold<int>(
      0,
      (sum, m) => sum + m.duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  /// مسح كل البيانات
  static void clear() {
    _screenVisits.clear();
    _screenDurations.clear();
    _screenStartTimes.clear();
    _performanceMetrics.clear();
  }

  /// تصدير التقرير
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 App Analytics Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('\n--- Screen Statistics ---');

    final stats = getScreenStats();
    stats.forEach((screen, stat) {
      buffer.writeln('$screen:');
      buffer.writeln('  Visits: ${stat.visits}');
      buffer.writeln('  Total Time: ${stat.totalDuration.inSeconds}s');
      buffer.writeln('  Avg Time: ${stat.averageDuration.inSeconds}s');
    });

    buffer.writeln('\n--- Performance Metrics ---');
    final operations = <String>{};
    for (final metric in _performanceMetrics) {
      operations.add(metric.operation);
    }

    for (final operation in operations) {
      final avg = getAveragePerformance(operation);
      buffer.writeln('$operation: avg ${avg?.inMilliseconds}ms');
    }

    return buffer.toString();
  }
}

/// إحصائيات شاشة
class ScreenStats {
  final int visits;
  final Duration totalDuration;
  final Duration averageDuration;

  const ScreenStats({
    required this.visits,
    required this.totalDuration,
    required this.averageDuration,
  });
}

/// مقياس أداء
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });
}

/// Provider لـ Analytics
final analyticsProvider = Provider<AppAnalytics>((ref) {
  return AppAnalytics();
});
