import 'package:flutter/material.dart';

/// 🎭 مدير الـ Animations المتقدم
class AnimationOptimizer {
  static final Map<String, AnimationMetrics> _metrics = {};
  static bool _reduceMotion = false;

  /// ضبط وضع تقليل الحركة
  static void setReduceMotion(bool enabled) {
    _reduceMotion = enabled;
  }

  /// الحصول على المدة المثلى
  static Duration getOptimalDuration(Duration baseDuration) {
    if (_reduceMotion) {
      return Duration.zero; // بدون حركة
    }
    return baseDuration;
  }

  /// الحصول على الـ Curve المثلى
  static Curve getOptimalCurve(Curve baseCurve) {
    if (_reduceMotion) {
      return Curves.linear;
    }
    return baseCurve;
  }

  /// تسجيل animation
  static void recordAnimation(String name, Duration duration) {
    if (!_metrics.containsKey(name)) {
      _metrics[name] = AnimationMetrics(name: name);
    }
    _metrics[name]!._record(duration);
  }

  /// تحليل الـ animations
  static AnimationAnalysis analyzeAnimation(String name) {
    final metrics = _metrics[name];
    if (metrics == null) {
      return AnimationAnalysis(
        name: name,
        isOptimized: false,
        recommendations: ['Animation not tracked'],
      );
    }

    final recommendations = <String>[];
    var isOptimized = true;

    // فحص المدة
    if (metrics.averageDuration.inMilliseconds > 500) {
      isOptimized = false;
      recommendations.add(
        '⚠️ Animation too long (${metrics.averageDuration.inMilliseconds}ms)',
      );
      recommendations.add('💡 Consider reducing duration to 200-300ms');
    }

    // فحص التكرار
    if (metrics.playCount > 100) {
      recommendations.add(
        '💡 High play count - ensure efficient implementation',
      );
    }

    if (isOptimized) {
      recommendations.add('✅ Animation is well optimized');
    }

    return AnimationAnalysis(
      name: name,
      isOptimized: isOptimized,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  /// تقرير الأداء
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🎭 Animation Performance Report');
    buffer.writeln('=' * 60);
    buffer.writeln('Total Animations: ${_metrics.length}');
    buffer.writeln('Reduce Motion: ${_reduceMotion ? 'ON' : 'OFF'}');
    buffer.writeln();

    final sorted = _metrics.entries.toList()
      ..sort((a, b) => b.value.playCount.compareTo(a.value.playCount));

    for (final entry in sorted.take(10)) {
      buffer.writeln('${entry.key}:');
      buffer.writeln('  Play Count: ${entry.value.playCount}');
      buffer.writeln(
        '  Avg Duration: ${entry.value.averageDuration.inMilliseconds}ms',
      );
    }

    return buffer.toString();
  }

  /// مسح البيانات
  static void clear() {
    _metrics.clear();
  }
}

/// Metrics للـ Animation
class AnimationMetrics {
  final String name;
  int playCount = 0;
  final List<Duration> _durations = [];
  static const int _maxSamples = 50;

  AnimationMetrics({required this.name});

  void _record(Duration duration) {
    playCount++;
    _durations.add(duration);
    if (_durations.length > _maxSamples) {
      _durations.removeAt(0);
    }
  }

  Duration get averageDuration {
    if (_durations.isEmpty) return Duration.zero;
    final total = _durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: total ~/ _durations.length);
  }
}

/// تحليل Animation
class AnimationAnalysis {
  final String name;
  final bool isOptimized;
  final List<String> recommendations;
  final AnimationMetrics? metrics;

  const AnimationAnalysis({
    required this.name,
    required this.isOptimized,
    required this.recommendations,
    this.metrics,
  });
}

/// Animation Controller المحسّن
class OptimizedAnimationController extends AnimationController {
  final String name;

  OptimizedAnimationController({
    required this.name,
    required super.vsync,
    super.duration,
    super.reverseDuration,
    super.debugLabel,
    super.lowerBound,
    super.upperBound,
    super.animationBehavior,
    super.value,
  });

  @override
  TickerFuture forward({double? from}) {
    final duration = this.duration ?? Duration.zero;
    AnimationOptimizer.recordAnimation(name, duration);
    return super.forward(from: from);
  }

  @override
  TickerFuture reverse({double? from}) {
    final duration = reverseDuration ?? this.duration ?? Duration.zero;
    AnimationOptimizer.recordAnimation(name, duration);
    return super.reverse(from: from);
  }
}

/// Animation Builder المحسّن
class OptimizedAnimatedBuilder extends StatelessWidget {
  final String name;
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const OptimizedAnimatedBuilder({
    super.key,
    required this.name,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

/// Stagger Animation Helper
class StaggerHelper {
  /// إنشاء تأخيرات متدرجة
  static List<Duration> createDelays({
    required int count,
    Duration baseDelay = const Duration(milliseconds: 50),
    double factor = 1.0,
  }) {
    return List.generate(
      count,
      (index) => Duration(
        milliseconds: (baseDelay.inMilliseconds * index * factor).round(),
      ),
    );
  }

  /// إنشاء intervals متدرجة
  static List<Interval> createIntervals({
    required int count,
    Curve curve = Curves.easeOut,
  }) {
    final step = 1.0 / count;
    return List.generate(
      count,
      (index) => Interval(index * step, (index + 1) * step, curve: curve),
    );
  }
}

/// Physics Helper للحركات الطبيعية
class PhysicsHelper {
  /// Spring description ناعم
  static SpringDescription createSmoothSpring() {
    return const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 15.0);
  }

  /// Bounce spring description
  static SpringDescription createBounceSpring() {
    return SpringDescription.withDampingRatio(
      mass: 0.5,
      stiffness: 100.0,
      ratio: 1.1,
    );
  }
}
