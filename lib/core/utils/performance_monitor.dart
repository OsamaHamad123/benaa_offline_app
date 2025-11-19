import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// ⚡ Performance monitoring utilities for debugging lag issues
class PerformanceMonitor {
  static const bool _enabled = kDebugMode;

  /// Start a timeline event
  static void startEvent(String name, {Map<String, String>? arguments}) {
    if (!_enabled) return;
    developer.Timeline.startSync(name, arguments: arguments);
  }

  /// End a timeline event
  static void endEvent(String name) {
    if (!_enabled) return;
    developer.Timeline.finishSync();
  }

  /// Measure execution time of a function
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() function, {
    void Function(Duration)? onComplete,
  }) async {
    if (!_enabled) return function();

    final stopwatch = Stopwatch()..start();
    startEvent(name);

    try {
      final result = await function();
      return result;
    } finally {
      endEvent(name);
      stopwatch.stop();

      if (onComplete != null) {
        onComplete(stopwatch.elapsed);
      }

      // Log slow operations
      if (stopwatch.elapsedMilliseconds > 100) {
        developer.log(
          '⚠️ SLOW: $name took ${stopwatch.elapsedMilliseconds}ms',
          name: 'Performance',
        );
      }
    }
  }

  /// Measure synchronous execution
  static T measure<T>(
    String name,
    T Function() function, {
    void Function(Duration)? onComplete,
  }) {
    if (!_enabled) return function();

    final stopwatch = Stopwatch()..start();
    startEvent(name);

    try {
      final result = function();
      return result;
    } finally {
      endEvent(name);
      stopwatch.stop();

      if (onComplete != null) {
        onComplete(stopwatch.elapsed);
      }

      // Log slow operations
      if (stopwatch.elapsedMilliseconds > 16) {
        // 60fps = 16ms budget
        developer.log(
          '⚠️ FRAME DROP: $name took ${stopwatch.elapsedMilliseconds}ms',
          name: 'Performance',
        );
      }
    }
  }

  /// Log a performance metric
  static void logMetric(String name, num value, {String? unit}) {
    if (!_enabled) return;
    developer.log('$name: $value${unit != null ? unit : ""}', name: 'Metrics');
  }

  /// Log memory usage (approximate)
  static void logMemory(String context) {
    if (!_enabled) return;
    // Note: Accurate memory profiling requires DevTools
    developer.log('Memory checkpoint: $context', name: 'Memory');
  }
}

/// Widget wrapper for performance monitoring
class PerformanceScope {
  /// Wrap expensive build operations
  static T buildWithMetrics<T>(String widgetName, T Function() builder) {
    return PerformanceMonitor.measure('Build:$widgetName', builder);
  }
}
