import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 🎨 محلل أداء الـ Widgets
class WidgetPerformanceAnalyzer {
  static final Map<String, WidgetMetrics> _metrics = {};
  static final Map<String, int> _buildCounts = {};
  static final Map<String, DateTime> _lastBuildTime = {};

  /// تسجيل عملية build
  static void recordBuild(String widgetName) {
    _buildCounts[widgetName] = (_buildCounts[widgetName] ?? 0) + 1;
    _lastBuildTime[widgetName] = DateTime.now();

    // تحديث الـ metrics
    if (!_metrics.containsKey(widgetName)) {
      _metrics[widgetName] = WidgetMetrics(widgetName: widgetName);
    }
    _metrics[widgetName]!._incrementBuilds();
  }

  /// قياس وقت الـ build
  static T measureBuild<T>(String widgetName, T Function() builder) {
    final stopwatch = Stopwatch()..start();
    final result = builder();
    stopwatch.stop();

    recordBuild(widgetName);
    _metrics[widgetName]!._recordBuildDuration(stopwatch.elapsed);

    if (stopwatch.elapsed.inMilliseconds > 16) {
      debugPrint(
        '⚠️ Slow build: $widgetName (${stopwatch.elapsed.inMilliseconds}ms)',
      );
    }

    return result;
  }

  /// الحصول على الـ metrics
  static WidgetMetrics? getMetrics(String widgetName) {
    return _metrics[widgetName];
  }

  /// الحصول على كل الـ metrics
  static Map<String, WidgetMetrics> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// أكثر الـ widgets إعادة بناء
  static List<MapEntry<String, WidgetMetrics>> getMostRebuiltWidgets({
    int limit = 10,
  }) {
    final entries = _metrics.entries.toList()
      ..sort((a, b) => b.value.buildCount.compareTo(a.value.buildCount));
    return entries.take(limit).toList();
  }

  /// أبطأ الـ widgets
  static List<MapEntry<String, WidgetMetrics>> getSlowestWidgets({
    int limit = 10,
  }) {
    final entries = _metrics.entries
        .where((e) => e.value.averageBuildDuration != null)
        .toList()
      ..sort(
        (a, b) => b.value.averageBuildDuration!.compareTo(
          a.value.averageBuildDuration!,
        ),
      );
    return entries.take(limit).toList();
  }

  /// تقرير الأداء
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🎨 Widget Performance Report');
    buffer.writeln('=' * 60);
    buffer.writeln('Total Widgets Tracked: ${_metrics.length}');
    buffer.writeln();

    // أكثر إعادة بناء
    buffer.writeln('--- Most Rebuilt Widgets ---');
    final mostRebuilt = getMostRebuiltWidgets(limit: 5);
    for (final entry in mostRebuilt) {
      buffer.writeln('${entry.key}: ${entry.value.buildCount} builds');
      if (entry.value.averageBuildDuration != null) {
        buffer.writeln(
          '  Avg Duration: ${entry.value.averageBuildDuration!.inMilliseconds}ms',
        );
      }
    }
    buffer.writeln();

    // أبطأ widgets
    buffer.writeln('--- Slowest Widgets ---');
    final slowest = getSlowestWidgets(limit: 5);
    for (final entry in slowest) {
      buffer.writeln(
        '${entry.key}: ${entry.value.averageBuildDuration!.inMilliseconds}ms avg',
      );
      buffer.writeln('  Builds: ${entry.value.buildCount}');
    }

    return buffer.toString();
  }

  /// مسح البيانات
  static void clear() {
    _metrics.clear();
    _buildCounts.clear();
    _lastBuildTime.clear();
  }
}

/// Metrics للـ Widget
class WidgetMetrics {
  final String widgetName;
  int buildCount = 0;
  final List<Duration> _buildDurations = [];
  static const int _maxSamples = 100;

  WidgetMetrics({required this.widgetName});

  void _incrementBuilds() {
    buildCount++;
  }

  void _recordBuildDuration(Duration duration) {
    _buildDurations.add(duration);
    if (_buildDurations.length > _maxSamples) {
      _buildDurations.removeAt(0);
    }
  }

  Duration? get averageBuildDuration {
    if (_buildDurations.isEmpty) return null;
    final total = _buildDurations.fold<int>(
      0,
      (sum, d) => sum + d.inMicroseconds,
    );
    return Duration(microseconds: total ~/ _buildDurations.length);
  }

  Duration? get maxBuildDuration {
    if (_buildDurations.isEmpty) return null;
    return _buildDurations.reduce((a, b) => a > b ? a : b);
  }

  bool get isPerformant {
    if (averageBuildDuration == null) return true;
    return averageBuildDuration!.inMilliseconds < 16; // 60 FPS = 16ms per frame
  }

  @override
  String toString() {
    return 'WidgetMetrics($widgetName: builds=$buildCount, avg=${averageBuildDuration?.inMilliseconds}ms)';
  }
}

/// Widget wrapper للتتبع التلقائي
class PerformanceTrackedWidget extends StatelessWidget {
  final String name;
  final Widget child;

  const PerformanceTrackedWidget({
    required this.name, required this.child, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetPerformanceAnalyzer.measureBuild(name, () => child);
  }
}

/// Mixin للتتبع التلقائي
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  String get widgetName => T.toString();

  @override
  void initState() {
    super.initState();
    WidgetPerformanceAnalyzer.recordBuild(widgetName);
  }

  @override
  Widget build(BuildContext context) {
    WidgetPerformanceAnalyzer.recordBuild(widgetName);
    return buildWithTracking(context);
  }

  Widget buildWithTracking(BuildContext context);
}

/// Frame Callback للتتبع الـ rendering
class FramePerformanceTracker {
  static final List<Duration> _frameDurations = [];
  static int _droppedFrames = 0;
  static const int _maxSamples = 100;
  static bool _isTracking = false;

  /// بدء التتبع
  static void startTracking() {
    if (_isTracking) return;

    // التأكد من أن الـ SchedulerBinding جاهز
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      _isTracking = true;
      SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
    } else {
      // الانتظار حتى يكون جاهزاً
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _isTracking = true;
        SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
      });
    }
  }

  /// إيقاف التتبع
  static void stopTracking() {
    _isTracking = false;
  }

  static void _onFrameCallback(List<FrameTiming> timings) {
    for (final timing in timings) {
      final duration = timing.totalSpan;
      _frameDurations.add(duration);

      if (_frameDurations.length > _maxSamples) {
        _frameDurations.removeAt(0);
      }

      // إطار محذوف إذا أخذ أكثر من 16ms (60 FPS)
      if (duration.inMilliseconds > 16) {
        _droppedFrames++;
      }
    }

    if (_isTracking) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
    }
  }

  /// متوسط وقت الإطار
  static Duration? get averageFrameDuration {
    if (_frameDurations.isEmpty) return null;
    final total = _frameDurations.fold<int>(
      0,
      (sum, d) => sum + d.inMicroseconds,
    );
    return Duration(microseconds: total ~/ _frameDurations.length);
  }

  /// FPS الحالي
  static double? get currentFPS {
    if (averageFrameDuration == null) return null;
    return 1000000 / averageFrameDuration!.inMicroseconds;
  }

  /// نسبة الإطارات المحذوفة
  static double get droppedFrameRate {
    if (_frameDurations.isEmpty) return 0;
    return (_droppedFrames / _frameDurations.length) * 100;
  }

  /// تقرير الأداء
  static String generateReport() {
    return '''
🎬 Frame Performance Report
===========================
Avg Frame Duration: ${averageFrameDuration?.inMilliseconds ?? 'N/A'}ms
Current FPS: ${currentFPS?.toStringAsFixed(1) ?? 'N/A'}
Dropped Frames: $_droppedFrames (${droppedFrameRate.toStringAsFixed(1)}%)
Total Frames: ${_frameDurations.length}
''';
  }

  /// مسح البيانات
  static void clear() {
    _frameDurations.clear();
    _droppedFrames = 0;
  }
}
