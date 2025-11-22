import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🧠 محسن إدارة الحالة - State Management Optimizer
class StateOptimizer {
  static final Map<String, StateMetrics> _metrics = {};
  static final Map<String, dynamic> _stateCache = {};

  /// تسجيل تحديث State
  static void recordStateUpdate(
    String stateName, {
    dynamic oldValue,
    dynamic newValue,
  }) {
    if (!_metrics.containsKey(stateName)) {
      _metrics[stateName] = StateMetrics(stateName: stateName);
    }

    _metrics[stateName]!._incrementUpdates();

    // فحص التحديثات غير الضرورية
    if (oldValue != null && newValue != null && oldValue == newValue) {
      _metrics[stateName]!._incrementUnnecessaryUpdates();
      if (kDebugMode) {
        print('⚠️ Unnecessary state update: $stateName (same value)');
      }
    }

    _stateCache[stateName] = newValue;
  }

  /// الحصول على الـ metrics
  static StateMetrics? getMetrics(String stateName) {
    return _metrics[stateName];
  }

  /// الحصول على كل الـ metrics
  static Map<String, StateMetrics> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// أكثر الـ states تحديثاً
  static List<MapEntry<String, StateMetrics>> getMostUpdatedStates({
    int limit = 10,
  }) {
    final entries = _metrics.entries.toList()
      ..sort((a, b) => b.value.updateCount.compareTo(a.value.updateCount));
    return entries.take(limit).toList();
  }

  /// الـ states مع أكثر تحديثات غير ضرورية
  static List<MapEntry<String, StateMetrics>> getStatesWithMostWaste({
    int limit = 10,
  }) {
    final entries =
        _metrics.entries
            .where((e) => e.value.unnecessaryUpdateCount > 0)
            .toList()
          ..sort(
            (a, b) => b.value.unnecessaryUpdateCount.compareTo(
              a.value.unnecessaryUpdateCount,
            ),
          );
    return entries.take(limit).toList();
  }

  /// تحليل State
  static StateAnalysis analyzeState(String stateName) {
    final metrics = _metrics[stateName];
    if (metrics == null) {
      return StateAnalysis(
        stateName: stateName,
        isOptimized: false,
        recommendations: ['State not tracked yet'],
      );
    }

    final recommendations = <String>[];
    var isOptimized = true;

    // فحص التحديثات غير الضرورية
    final wasteRate = metrics.wasteRate;
    if (wasteRate > 20) {
      isOptimized = false;
      recommendations.add(
        '⚠️ High waste rate: ${wasteRate.toStringAsFixed(1)}%',
      );
      recommendations.add('💡 Use equality checks before setState');
      recommendations.add('💡 Consider using shouldRebuild or Equatable');
    }

    // فحص التحديثات المتكررة
    if (metrics.updateCount > 100) {
      recommendations.add('💡 High update frequency - consider debouncing');
    }

    if (isOptimized) {
      recommendations.add('✅ State is well optimized');
    }

    return StateAnalysis(
      stateName: stateName,
      isOptimized: isOptimized,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  /// تقرير شامل
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🧠 State Optimization Report');
    buffer.writeln('=' * 60);
    buffer.writeln('Total States Tracked: ${_metrics.length}');
    buffer.writeln();

    // أكثر تحديثاً
    buffer.writeln('--- Most Updated States ---');
    final mostUpdated = getMostUpdatedStates(limit: 5);
    for (final entry in mostUpdated) {
      buffer.writeln('${entry.key}: ${entry.value.updateCount} updates');
      buffer.writeln(
        '  Waste Rate: ${entry.value.wasteRate.toStringAsFixed(1)}%',
      );
    }
    buffer.writeln();

    // أكثر هدراً
    final mostWaste = getStatesWithMostWaste(limit: 5);
    if (mostWaste.isNotEmpty) {
      buffer.writeln('--- States With Most Waste ---');
      for (final entry in mostWaste) {
        buffer.writeln(
          '${entry.key}: ${entry.value.unnecessaryUpdateCount} unnecessary',
        );
        buffer.writeln(
          '  Total: ${entry.value.updateCount} (${entry.value.wasteRate.toStringAsFixed(1)}% waste)',
        );

        final analysis = analyzeState(entry.key);
        buffer.writeln('  Recommendations:');
        for (final rec in analysis.recommendations) {
          buffer.writeln('    $rec');
        }
      }
    }

    return buffer.toString();
  }

  /// مسح البيانات
  static void clear() {
    _metrics.clear();
    _stateCache.clear();
  }
}

/// Metrics للـ State
class StateMetrics {
  final String stateName;
  int updateCount = 0;
  int unnecessaryUpdateCount = 0;

  StateMetrics({required this.stateName});

  void _incrementUpdates() {
    updateCount++;
  }

  void _incrementUnnecessaryUpdates() {
    unnecessaryUpdateCount++;
  }

  double get wasteRate {
    if (updateCount == 0) return 0;
    return (unnecessaryUpdateCount / updateCount) * 100;
  }

  @override
  String toString() {
    return 'StateMetrics($stateName: updates=$updateCount, waste=${wasteRate.toStringAsFixed(1)}%)';
  }
}

/// تحليل State
class StateAnalysis {
  final String stateName;
  final bool isOptimized;
  final List<String> recommendations;
  final StateMetrics? metrics;

  const StateAnalysis({
    required this.stateName,
    required this.isOptimized,
    required this.recommendations,
    this.metrics,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('State: $stateName');
    buffer.writeln(
      'Status: ${isOptimized ? '✅ Optimized' : '⚠️ Needs Optimization'}',
    );
    buffer.writeln('Recommendations:');
    for (final rec in recommendations) {
      buffer.writeln('  $rec');
    }
    return buffer.toString();
  }
}

/// Mixin لتتبع الـ State تلقائياً
mixin StateTrackingMixin<T extends StatefulWidget> on State<T> {
  String get stateName => T.toString();

  @override
  void setState(VoidCallback fn) {
    final oldState = _captureState();
    super.setState(fn);
    final newState = _captureState();

    StateOptimizer.recordStateUpdate(
      stateName,
      oldValue: oldState,
      newValue: newState,
    );
  }

  dynamic _captureState() {
    // يمكن تخصيصها في الـ subclass
    return DateTime.now().millisecondsSinceEpoch;
  }
}
