import 'dart:async';
import 'package:flutter/foundation.dart';

/// ⚡ خدمة مراقبة الأداء في الوقت الفعلي
class PerformanceMonitor {
  static final Map<String, PerformanceMetric> _metrics = {};
  static final List<PerformanceAlert> _alerts = [];
  static const int _maxAlerts = 20;

  // العتبات
  static const Duration slowOperationThreshold = Duration(milliseconds: 100);
  static const Duration criticalOperationThreshold = Duration(
    milliseconds: 500,
  );
  static const int memoryWarningMB = 100;

  /// قياس عملية
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() task, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await task();
      stopwatch.stop();

      _recordMetric(operation, stopwatch.elapsed, metadata: metadata);
      _checkPerformance(operation, stopwatch.elapsed);

      return result;
    } catch (error) {
      stopwatch.stop();
      _recordMetric(
        operation,
        stopwatch.elapsed,
        metadata: metadata,
        hasError: true,
      );
      rethrow;
    }
  }

  /// قياس عملية متزامنة
  static T measureSync<T>(
    String operation,
    T Function() task, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = task();
      stopwatch.stop();

      _recordMetric(operation, stopwatch.elapsed, metadata: metadata);
      _checkPerformance(operation, stopwatch.elapsed);

      return result;
    } catch (error) {
      stopwatch.stop();
      _recordMetric(
        operation,
        stopwatch.elapsed,
        metadata: metadata,
        hasError: true,
      );
      rethrow;
    }
  }

  /// تسجيل metric يدويًا
  static void record(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    _recordMetric(operation, duration, metadata: metadata);
    _checkPerformance(operation, duration);
  }

  /// الحصول على metric محدد
  static PerformanceMetric? getMetric(String operation) {
    return _metrics[operation];
  }

  /// الحصول على كل الـ metrics
  static Map<String, PerformanceMetric> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// الحصول على العمليات البطيئة
  static List<MapEntry<String, PerformanceMetric>> getSlowOperations({
    int limit = 10,
  }) {
    final entries = _metrics.entries.toList()
      ..sort((a, b) => b.value.average.compareTo(a.value.average));
    return entries.take(limit).toList();
  }

  /// الحصول على التنبيهات
  static List<PerformanceAlert> getAlerts() {
    return List.unmodifiable(_alerts);
  }

  /// مسح الـ metrics
  static void clear() {
    _metrics.clear();
    _alerts.clear();
  }

  /// تصدير تقرير الأداء
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('⚡ Performance Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Operations: ${_metrics.length}');
    buffer.writeln('Total Alerts: ${_alerts.length}\n');

    // أبطأ العمليات
    buffer.writeln('--- Slowest Operations ---');
    final slowOps = getSlowOperations(limit: 5);
    for (final entry in slowOps) {
      final metric = entry.value;
      buffer.writeln('${entry.key}:');
      buffer.writeln('  Avg: ${metric.average.inMilliseconds}ms');
      buffer.writeln('  Min: ${metric.min.inMilliseconds}ms');
      buffer.writeln('  Max: ${metric.max.inMilliseconds}ms');
      buffer.writeln('  Count: ${metric.count}');
    }

    // التنبيهات الأخيرة
    if (_alerts.isNotEmpty) {
      buffer.writeln('\n--- Recent Alerts ---');
      final recentAlerts = _alerts.reversed.take(5);
      for (final alert in recentAlerts) {
        buffer.writeln('${alert.severity.emoji} ${alert.timestamp}');
        buffer.writeln(
          '  ${alert.operation}: ${alert.duration.inMilliseconds}ms',
        );
      }
    }

    return buffer.toString();
  }

  static void _recordMetric(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
    bool hasError = false,
  }) {
    if (!_metrics.containsKey(operation)) {
      _metrics[operation] = PerformanceMetric(operation);
    }

    _metrics[operation]!.record(duration, hasError: hasError);

    if (kDebugMode && duration > slowOperationThreshold) {
      print('⚠️ Slow operation: $operation (${duration.inMilliseconds}ms)');
    }
  }

  static void _checkPerformance(String operation, Duration duration) {
    PerformanceAlertSeverity? severity;

    if (duration > criticalOperationThreshold) {
      severity = PerformanceAlertSeverity.critical;
    } else if (duration > slowOperationThreshold) {
      severity = PerformanceAlertSeverity.warning;
    }

    if (severity != null) {
      final alert = PerformanceAlert(
        operation: operation,
        duration: duration,
        severity: severity,
        timestamp: DateTime.now(),
      );

      _alerts.add(alert);

      // الاحتفاظ بآخر 20 تنبيه
      if (_alerts.length > _maxAlerts) {
        _alerts.removeAt(0);
      }

      if (kDebugMode) {
        print(
          '${severity.emoji} Performance Alert: $operation '
          '(${duration.inMilliseconds}ms)',
        );
      }
    }
  }
}

/// Metric الأداء
class PerformanceMetric {
  final String operation;
  final List<Duration> _durations = [];
  final List<DateTime> _timestamps = [];
  int _errorCount = 0;

  static const int _maxSamples = 100;

  PerformanceMetric(this.operation);

  void record(Duration duration, {bool hasError = false}) {
    _durations.add(duration);
    _timestamps.add(DateTime.now());

    if (hasError) {
      _errorCount++;
    }

    // الاحتفاظ بآخر 100 قياس
    if (_durations.length > _maxSamples) {
      _durations.removeAt(0);
      _timestamps.removeAt(0);
    }
  }

  int get count => _durations.length;

  Duration get average {
    if (_durations.isEmpty) return Duration.zero;
    final total = _durations.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
    return Duration(microseconds: total ~/ _durations.length);
  }

  Duration get min {
    if (_durations.isEmpty) return Duration.zero;
    return _durations.reduce((a, b) => a < b ? a : b);
  }

  Duration get max {
    if (_durations.isEmpty) return Duration.zero;
    return _durations.reduce((a, b) => a > b ? a : b);
  }

  Duration get total {
    if (_durations.isEmpty) return Duration.zero;
    return _durations.fold(Duration.zero, (sum, d) => sum + d);
  }

  int get errorCount => _errorCount;

  double get errorRate {
    if (count == 0) return 0;
    return (_errorCount / count) * 100;
  }

  DateTime? get lastRun {
    if (_timestamps.isEmpty) return null;
    return _timestamps.last;
  }

  @override
  String toString() {
    return 'PerformanceMetric($operation: avg=${average.inMilliseconds}ms, '
        'count=$count, errors=$_errorCount)';
  }
}

/// تنبيه الأداء
class PerformanceAlert {
  final String operation;
  final Duration duration;
  final PerformanceAlertSeverity severity;
  final DateTime timestamp;

  const PerformanceAlert({
    required this.operation,
    required this.duration,
    required this.severity,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceAlert(${severity.name}, $operation, '
        '${duration.inMilliseconds}ms)';
  }
}

/// خطورة تنبيه الأداء
enum PerformanceAlertSeverity {
  info('ℹ️'),
  warning('⚠️'),
  critical('🔴');

  final String emoji;
  const PerformanceAlertSeverity(this.emoji);
}
