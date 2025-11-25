import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_performance_analyzer.dart';
import 'state_optimizer.dart';
import 'smart_preloader.dart';
import 'animation_optimizer.dart';
import '../cache/cache_manager.dart';
import '../database/query_optimizer.dart';

/// 🚀 مجموعة الأداء الشاملة - Complete Performance Suite
class PerformanceSuite {
  static final PerformanceSuite _instance = PerformanceSuite._internal();
  factory PerformanceSuite() => _instance;
  PerformanceSuite._internal();

  bool _isInitialized = false;

  /// تهيئة مجموعة الأداء
  void initialize() {
    if (_isInitialized) return;

    try {
      // بدء تتبع الإطارات (مع الحماية من الأخطاء)
      FramePerformanceTracker.startTracking();

      // تسجيل استراتيجيات التحميل المسبق
      _registerPreloadStrategies();

      _isInitialized = true;
    } catch (e) {
      // تسجيل الخطأ ولكن عدم إيقاف التطبيق
      if (kDebugMode) {
        debugPrint('⚠️ Performance Suite initialization warning: $e');
      }
    }
  }

  void _registerPreloadStrategies() {
    // يمكن تخصيص الاستراتيجيات هنا
  }

  /// تنظيف دوري
  void cleanup() {
    // مسح البيانات القديمة من الـ Cache
    AppCacheManager().evictAllExpired();

    // مسح البيانات القديمة من الـ Preloader
    SmartPreloader.evictStale(const Duration(minutes: 10));
  }

  /// تقرير شامل
  String generateComprehensiveReport() {
    final buffer = StringBuffer();

    buffer.writeln('=' * 80);
    buffer.writeln('🚀 COMPREHENSIVE PERFORMANCE REPORT');
    buffer.writeln('=' * 80);
    buffer.writeln('Generated: ${DateTime.now()}\n');

    // Widget Performance
    buffer.writeln(WidgetPerformanceAnalyzer.generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // State Optimization
    buffer.writeln(StateOptimizer.generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // Frame Performance
    buffer.writeln(FramePerformanceTracker.generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // Animation Performance
    buffer.writeln(AnimationOptimizer.generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // Query Optimization
    buffer.writeln(QueryOptimizer.generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // Cache Statistics
    buffer.writeln(AppCacheManager().generateReport());
    buffer.writeln('\n${'=' * 80}\n');

    // Adaptive Preloader
    buffer.writeln(AdaptivePreloader.getStatus());

    return buffer.toString();
  }

  /// ملخص الأداء
  PerformanceSummary getSummary() {
    final widgetMetrics = WidgetPerformanceAnalyzer.getAllMetrics();
    final stateMetrics = StateOptimizer.getAllMetrics();
    final queryStats = QueryOptimizer.getQueryStats();

    return PerformanceSummary(
      totalWidgetsTracked: widgetMetrics.length,
      totalStatesTracked: stateMetrics.length,
      totalQueriesTracked: queryStats.length,
      averageFPS: FramePerformanceTracker.currentFPS ?? 0,
      droppedFrameRate: FramePerformanceTracker.droppedFrameRate,
      cacheHitRate: _calculateCacheHitRate(),
      stateWasteRate: _calculateStateWasteRate(),
    );
  }

  double _calculateCacheHitRate() {
    // حساب نسبة نجاح الـ Cache
    final beneficiaries = AppCacheManager().beneficiaries.stats;
    return beneficiaries.usagePercent;
  }

  double _calculateStateWasteRate() {
    final stateMetrics = StateOptimizer.getAllMetrics();
    if (stateMetrics.isEmpty) return 0;

    final totalUpdates = stateMetrics.values.fold<int>(
      0,
      (sum, m) => sum + m.updateCount,
    );
    final totalWaste = stateMetrics.values.fold<int>(
      0,
      (sum, m) => sum + m.unnecessaryUpdateCount,
    );

    if (totalUpdates == 0) return 0;
    return (totalWaste / totalUpdates) * 100;
  }

  /// توصيات التحسين
  List<PerformanceRecommendation> getRecommendations() {
    final recommendations = <PerformanceRecommendation>[];

    // فحص الـ FPS
    final fps = FramePerformanceTracker.currentFPS;
    if (fps != null && fps < 50) {
      recommendations.add(
        PerformanceRecommendation(
          category: 'Frame Performance',
          severity: RecommendationSeverity.high,
          message: 'Low FPS detected: ${fps.toStringAsFixed(1)}',
          suggestion:
              'Consider reducing widget rebuilds and optimizing animations',
        ),
      );
    }

    // فحص الـ State Waste
    final stateWaste = _calculateStateWasteRate();
    if (stateWaste > 20) {
      recommendations.add(
        PerformanceRecommendation(
          category: 'State Management',
          severity: RecommendationSeverity.medium,
          message: 'High state waste rate: ${stateWaste.toStringAsFixed(1)}%',
          suggestion: 'Implement equality checks before setState calls',
        ),
      );
    }

    // فحص الـ Widget Rebuilds
    final mostRebuilt = WidgetPerformanceAnalyzer.getMostRebuiltWidgets(
      limit: 1,
    );
    if (mostRebuilt.isNotEmpty && mostRebuilt.first.value.buildCount > 100) {
      recommendations.add(
        PerformanceRecommendation(
          category: 'Widget Performance',
          severity: RecommendationSeverity.medium,
          message:
              '${mostRebuilt.first.key} rebuilt ${mostRebuilt.first.value.buildCount} times',
          suggestion: 'Consider using const constructors or memoization',
        ),
      );
    }

    // فحص الـ Queries
    final slowQueries = QueryOptimizer.getSlowestQueries(limit: 1);
    if (slowQueries.isNotEmpty) {
      final query = slowQueries.first;
      if (query.value.averageDuration.inMilliseconds > 100) {
        recommendations.add(
          PerformanceRecommendation(
            category: 'Database',
            severity: RecommendationSeverity.high,
            message:
                'Slow query: ${query.key} (${query.value.averageDuration.inMilliseconds}ms)',
            suggestion: 'Add database indexes or optimize the query',
          ),
        );
      }
    }

    return recommendations;
  }

  /// مسح كل البيانات
  void clearAll() {
    WidgetPerformanceAnalyzer.clear();
    StateOptimizer.clear();
    FramePerformanceTracker.clear();
    AnimationOptimizer.clear();
    QueryOptimizer.clear();
    AppCacheManager().clearAll();
    SmartPreloader.clear();
  }

  /// إيقاف التتبع
  void shutdown() {
    FramePerformanceTracker.stopTracking();
    _isInitialized = false;
  }
}

/// ملخص الأداء
class PerformanceSummary {
  final int totalWidgetsTracked;
  final int totalStatesTracked;
  final int totalQueriesTracked;
  final double averageFPS;
  final double droppedFrameRate;
  final double cacheHitRate;
  final double stateWasteRate;

  const PerformanceSummary({
    required this.totalWidgetsTracked,
    required this.totalStatesTracked,
    required this.totalQueriesTracked,
    required this.averageFPS,
    required this.droppedFrameRate,
    required this.cacheHitRate,
    required this.stateWasteRate,
  });

  /// تقييم عام
  PerformanceGrade get overallGrade {
    var score = 100.0;

    // خصم النقاط بناءً على المشاكل
    if (averageFPS < 60) score -= (60 - averageFPS) * 0.5;
    if (droppedFrameRate > 5) score -= droppedFrameRate;
    if (stateWasteRate > 10) score -= stateWasteRate * 0.5;

    if (score >= 90) return PerformanceGrade.excellent;
    if (score >= 75) return PerformanceGrade.good;
    if (score >= 60) return PerformanceGrade.fair;
    return PerformanceGrade.poor;
  }

  @override
  String toString() {
    return '''
PerformanceSummary(
  Widgets Tracked: $totalWidgetsTracked
  States Tracked: $totalStatesTracked
  Queries Tracked: $totalQueriesTracked
  Average FPS: ${averageFPS.toStringAsFixed(1)}
  Dropped Frames: ${droppedFrameRate.toStringAsFixed(1)}%
  Cache Hit Rate: ${cacheHitRate.toStringAsFixed(1)}%
  State Waste: ${stateWasteRate.toStringAsFixed(1)}%
  Grade: ${overallGrade.name.toUpperCase()}
)''';
  }
}

/// تقييم الأداء
enum PerformanceGrade { excellent, good, fair, poor }

/// توصية تحسين
class PerformanceRecommendation {
  final String category;
  final RecommendationSeverity severity;
  final String message;
  final String suggestion;

  const PerformanceRecommendation({
    required this.category,
    required this.severity,
    required this.message,
    required this.suggestion,
  });

  @override
  String toString() {
    final icon = severity == RecommendationSeverity.high
        ? '🔴'
        : severity == RecommendationSeverity.medium
        ? '🟡'
        : '🟢';
    return '$icon [$category] $message\n   💡 $suggestion';
  }
}

/// خطورة التوصية
enum RecommendationSeverity { low, medium, high }

// ==================== Riverpod Providers ====================

/// Provider لمجموعة الأداء
final performanceSuiteProvider = Provider<PerformanceSuite>((ref) {
  final suite = PerformanceSuite();
  suite.initialize();
  return suite;
});

/// Provider لملخص الأداء
final performanceSummaryProvider = Provider<PerformanceSummary>((ref) {
  final suite = ref.watch(performanceSuiteProvider);
  return suite.getSummary();
});

/// Provider للتوصيات
final performanceRecommendationsProvider =
    Provider<List<PerformanceRecommendation>>((ref) {
      final suite = ref.watch(performanceSuiteProvider);
      return suite.getRecommendations();
    });
