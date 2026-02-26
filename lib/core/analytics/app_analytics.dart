import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📊 Analytics Service لتتبع أداء التطبيق واستخدامه
class AppAnalytics {
  static final Map<String, int> _screenVisits = {};
  static final Map<String, Duration> _screenDurations = {};
  static final Map<String, DateTime> _screenStartTimes = {};
  static final List<PerformanceMetric> _performanceMetrics = [];
  static final List<AnalyticsEvent> _events = [];

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
      _screenDurations[screenName] = (_screenDurations[screenName] ?? Duration.zero) + duration;
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
    _events.add(
      AnalyticsEvent(
        name: eventName,
        timestamp: DateTime.now(),
        parameters: parameters,
      ),
    );

    if (_events.length > 500) {
      _events.removeAt(0);
    }

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
                  milliseconds: (_screenDurations[screen]?.inMilliseconds ?? 0) ~/ visits,
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

  /// الحصول على أحداث مسجلة (اختياريًا حسب الاسم)
  static List<AnalyticsEvent> getEvents({String? eventName}) {
    if (eventName == null) return List.unmodifiable(_events);
    return List.unmodifiable(_events.where((event) => event.name == eventName));
  }

  /// KPI خاص بتدفق تسجيل الدخول
  ///
  /// [window]:
  /// - null => كل البيانات المتاحة
  /// - Duration(...) => آخر فترة زمنية فقط (مثال: 24 ساعة أو 7 أيام)
  static LoginKpiStats getLoginKpiStats({Duration? window}) {
    final cutoff = window == null ? null : DateTime.now().subtract(window);

    List<AnalyticsEvent> filterByWindow(List<AnalyticsEvent> source) {
      if (cutoff == null) return source;
      return source.where((event) => event.timestamp.isAfter(cutoff)).toList();
    }

    final attempts = filterByWindow(getEvents(eventName: 'auth_login_attempt'));
    final success = filterByWindow(getEvents(eventName: 'auth_login_success'));
    final failed = filterByWindow(getEvents(eventName: 'auth_login_failed'));
    final destinations = filterByWindow(getEvents(eventName: 'auth_post_login_destination'));

    final dashboardConversions = destinations.where((event) => event.parameters?['destination'] == 'dashboard').length;
    final databaseDownloadBounces =
        destinations.where((event) => event.parameters?['destination'] == 'database_download').length;

    final successfulDurations = success
        .map((event) => event.parameters?['duration_ms'])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList();

    final avgSuccessDurationMs =
        successfulDurations.isEmpty ? 0 : successfulDurations.reduce((a, b) => a + b) ~/ successfulDurations.length;

    final successRate = attempts.isEmpty ? 0.0 : (success.length / attempts.length) * 100.0;
    final failureRate = attempts.isEmpty ? 0.0 : (failed.length / attempts.length) * 100.0;
    final dashboardConversionRate = success.isEmpty ? 0.0 : (dashboardConversions / success.length) * 100.0;
    final databaseDownloadBounceRate = success.isEmpty ? 0.0 : (databaseDownloadBounces / success.length) * 100.0;

    return LoginKpiStats(
      attempts: attempts.length,
      success: success.length,
      failed: failed.length,
      avgSuccessDurationMs: avgSuccessDurationMs,
      successRate: successRate,
      failureRate: failureRate,
      dashboardConversions: dashboardConversions,
      dashboardConversionRate: dashboardConversionRate,
      databaseDownloadBounces: databaseDownloadBounces,
      databaseDownloadBounceRate: databaseDownloadBounceRate,
    );
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
    _events.clear();
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

    final loginKpi = getLoginKpiStats();
    buffer.writeln('\n--- Login KPIs ---');
    buffer.writeln('Attempts: ${loginKpi.attempts}');
    buffer.writeln('Success: ${loginKpi.success} (${loginKpi.successRate.toStringAsFixed(1)}%)');
    buffer.writeln('Failed: ${loginKpi.failed} (${loginKpi.failureRate.toStringAsFixed(1)}%)');
    buffer.writeln(
        'Dashboard Conversion: ${loginKpi.dashboardConversions} (${loginKpi.dashboardConversionRate.toStringAsFixed(1)}%)');
    buffer.writeln(
        'Database Download Bounce: ${loginKpi.databaseDownloadBounces} (${loginKpi.databaseDownloadBounceRate.toStringAsFixed(1)}%)');
    buffer.writeln('Avg Success Duration: ${loginKpi.avgSuccessDurationMs}ms');

    return buffer.toString();
  }
}

/// حدث Analytics
class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic>? parameters;

  const AnalyticsEvent({
    required this.name,
    required this.timestamp,
    this.parameters,
  });
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

/// مؤشرات KPI لتسجيل الدخول
class LoginKpiStats {
  final int attempts;
  final int success;
  final int failed;
  final int avgSuccessDurationMs;
  final double successRate;
  final double failureRate;
  final int dashboardConversions;
  final double dashboardConversionRate;
  final int databaseDownloadBounces;
  final double databaseDownloadBounceRate;

  const LoginKpiStats({
    required this.attempts,
    required this.success,
    required this.failed,
    required this.avgSuccessDurationMs,
    required this.successRate,
    required this.failureRate,
    required this.dashboardConversions,
    required this.dashboardConversionRate,
    required this.databaseDownloadBounces,
    required this.databaseDownloadBounceRate,
  });
}

/// Provider لـ Analytics
final analyticsProvider = Provider<AppAnalytics>((ref) {
  return AppAnalytics();
});
