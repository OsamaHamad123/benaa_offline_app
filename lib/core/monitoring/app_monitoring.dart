import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/analytics/app_analytics.dart';
import 'package:benaa_offline_app/core/error/error_tracker.dart';
import 'package:benaa_offline_app/core/monitoring/performance_monitor.dart'
    as perf;

/// 📊 خدمة المراقبة الشاملة - دمج Analytics + Errors + Performance
class AppMonitoring {
  final AppAnalytics analytics;
  final ErrorTracker errorTracker = ErrorTracker();
  final perf.PerformanceMonitor performanceMonitor = perf.PerformanceMonitor();

  AppMonitoring(this.analytics);

  // ==================== Screen Tracking ====================

  /// تتبع دخول شاشة
  void logScreenView(String screenName) {
    AppAnalytics.logScreenView(screenName);
  }

  /// تتبع خروج من شاشة
  void logScreenExit(String screenName) {
    AppAnalytics.logScreenExit(screenName);
  }

  // ==================== Event Tracking ====================

  /// تسجيل حدث
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    AppAnalytics.logEvent(eventName, parameters: parameters);
  }

  // ==================== Performance Tracking ====================

  /// قياس عملية غير متزامنة مع Analytics + Performance Monitor
  Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() task, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // قياس مع Performance Monitor
      return await perf.PerformanceMonitor.measure(operation, () async {
        // قياس مع Analytics
        return await AppAnalytics.measureAsync(operation, task);
      }, metadata: metadata);
    } catch (error, stackTrace) {
      // تسجيل الخطأ
      ErrorTracker.logError(
        error,
        stackTrace,
        context: operation,
        metadata: metadata,
      );
      rethrow;
    }
  }

  /// قياس عملية متزامنة
  T measureSync<T>(
    String operation,
    T Function() task, {
    Map<String, dynamic>? metadata,
  }) {
    try {
      return perf.PerformanceMonitor.measureSync(
        operation,
        () => task(),
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      ErrorTracker.logError(
        error,
        stackTrace,
        context: operation,
        metadata: metadata,
      );
      rethrow;
    }
  }

  // ==================== Error Tracking ====================

  /// تسجيل خطأ
  void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? metadata,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    ErrorTracker.logError(
      error,
      stackTrace,
      context: context,
      metadata: metadata,
      severity: severity,
    );
  }

  /// تسجيل خطأ حرج
  void logCritical(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    ErrorTracker.logCritical(
      error,
      stackTrace,
      context: context,
      metadata: metadata,
    );
  }

  /// تسجيل تحذير
  void logWarning(
    String message, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    ErrorTracker.logWarning(message, context: context, metadata: metadata);
  }

  // ==================== Reports ====================

  /// تقرير شامل عن كل شيء
  String generateComprehensiveReport() {
    final buffer = StringBuffer();

    buffer.writeln('=' * 60);
    buffer.writeln('📊 COMPREHENSIVE MONITORING REPORT');
    buffer.writeln('=' * 60);
    buffer.writeln('Generated: ${DateTime.now()}\n');

    // Analytics Report
    buffer.writeln(AppAnalytics.generateReport());
    buffer.writeln('\n${'=' * 60}\n');

    // Performance Report
    buffer.writeln(perf.PerformanceMonitor.generateReport());
    buffer.writeln('\n${'=' * 60}\n');

    // Error Report
    buffer.writeln(ErrorTracker.generateErrorReport());
    buffer.writeln('\n${'=' * 60}');

    return buffer.toString();
  }

  /// تقرير الأداء فقط
  String generatePerformanceReport() {
    return perf.PerformanceMonitor.generateReport();
  }

  /// تقرير الأخطاء فقط
  String generateErrorReport() {
    return ErrorTracker.generateErrorReport();
  }

  /// تقرير Analytics فقط
  String generateAnalyticsReport() {
    return AppAnalytics.generateReport();
  }

  // ==================== Statistics ====================

  /// إحصائيات سريعة
  MonitoringStats getStats() {
    final analyticsStats = AppAnalytics.getScreenStats();
    final performanceMetrics = perf.PerformanceMonitor.getAllMetrics();
    final errors = ErrorTracker.getAllErrors();
    final criticalErrors = ErrorTracker.getCriticalErrors();
    final performanceAlerts = perf.PerformanceMonitor.getAlerts();

    return MonitoringStats(
      totalScreenVisits: analyticsStats.values.fold<int>(
        0,
        (sum, s) => sum + s.visits,
      ),
      uniqueScreens: analyticsStats.length,
      totalOperations: performanceMetrics.length,
      totalErrors: errors.length,
      criticalErrors: criticalErrors.length,
      performanceAlerts: performanceAlerts.length,
      slowestOperation: perf.PerformanceMonitor.getSlowOperations(
        limit: 1,
      ).firstOrNull,
    );
  }

  /// مسح كل البيانات
  void clearAll() {
    ErrorTracker.clear();
    perf.PerformanceMonitor.clear();
    // Analytics لا يحتاج clear - بيانات مهمة
  }
}

/// إحصائيات المراقبة
class MonitoringStats {
  final int totalScreenVisits;
  final int uniqueScreens;
  final int totalOperations;
  final int totalErrors;
  final int criticalErrors;
  final int performanceAlerts;
  final MapEntry<String, perf.PerformanceMetric>? slowestOperation;

  const MonitoringStats({
    required this.totalScreenVisits,
    required this.uniqueScreens,
    required this.totalOperations,
    required this.totalErrors,
    required this.criticalErrors,
    required this.performanceAlerts,
    this.slowestOperation,
  });

  @override
  String toString() {
    return '''
MonitoringStats(
  Screen Visits: $totalScreenVisits ($uniqueScreens unique)
  Operations: $totalOperations
  Errors: $totalErrors ($criticalErrors critical)
  Performance Alerts: $performanceAlerts
  Slowest: ${slowestOperation?.key ?? 'N/A'}
)''';
  }
}

// ==================== Riverpod Providers ====================

/// Provider للـ Monitoring الشامل
final appMonitoringProvider = Provider<AppMonitoring>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return AppMonitoring(analytics);
});

/// Provider للإحصائيات
final monitoringStatsProvider = Provider<MonitoringStats>((ref) {
  final monitoring = ref.watch(appMonitoringProvider);
  return monitoring.getStats();
});
