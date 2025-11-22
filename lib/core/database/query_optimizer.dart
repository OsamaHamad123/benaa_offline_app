import '../monitoring/performance_monitor.dart' as perf;

/// 🎯 محسّن استعلامات قاعدة البيانات
class QueryOptimizer {
  static final Map<String, QueryPlan> _queryPlans = {};
  static final Map<String, int> _queryExecutionCount = {};

  /// تنفيذ استعلام محسّن
  static Future<T> execute<T>(
    String queryName,
    Future<T> Function() query, {
    bool useCache = true,
    Duration? cacheDuration,
  }) async {
    // تتبع عدد التنفيذ
    _queryExecutionCount[queryName] =
        (_queryExecutionCount[queryName] ?? 0) + 1;

    // قياس الأداء
    return await perf.PerformanceMonitor.measure(
      'Query: $queryName',
      query,
      metadata: {
        'executionCount': _queryExecutionCount[queryName],
        'useCache': useCache,
      },
    );
  }

  /// تسجيل خطة استعلام
  static void registerQueryPlan(String queryName, QueryPlan plan) {
    _queryPlans[queryName] = plan;
  }

  /// الحصول على إحصائيات الاستعلامات
  static Map<String, QueryStats> getQueryStats() {
    final stats = <String, QueryStats>{};

    _queryExecutionCount.forEach((query, count) {
      final metrics = perf.PerformanceMonitor.getMetric('Query: $query');
      stats[query] = QueryStats(
        queryName: query,
        executionCount: count,
        averageDuration: metrics?.average ?? Duration.zero,
        plan: _queryPlans[query],
      );
    });

    return stats;
  }

  /// الحصول على أبطأ الاستعلامات
  static List<MapEntry<String, QueryStats>> getSlowestQueries({
    int limit = 10,
  }) {
    final stats = getQueryStats();
    final entries = stats.entries.toList()
      ..sort(
        (a, b) => b.value.averageDuration.compareTo(a.value.averageDuration),
      );
    return entries.take(limit).toList();
  }

  /// تحليل الاستعلام
  static QueryAnalysis analyzeQuery(String queryName) {
    final stats = getQueryStats()[queryName];
    if (stats == null) {
      return QueryAnalysis(
        queryName: queryName,
        isOptimized: false,
        recommendations: ['Query not executed yet'],
      );
    }

    final recommendations = <String>[];
    var isOptimized = true;

    // فحص الأداء
    if (stats.averageDuration.inMilliseconds > 100) {
      isOptimized = false;
      recommendations.add(
        '⚠️ Query is slow (${stats.averageDuration.inMilliseconds}ms)',
      );
      recommendations.add('💡 Consider adding database indexes');
    }

    // فحص عدد التنفيذ
    if (stats.executionCount > 100) {
      recommendations.add('💡 High execution count - consider caching results');
    }

    // فحص وجود خطة
    if (stats.plan == null) {
      recommendations.add('💡 No query plan registered - consider optimizing');
    }

    if (isOptimized) {
      recommendations.add('✅ Query is well optimized');
    }

    return QueryAnalysis(
      queryName: queryName,
      isOptimized: isOptimized,
      recommendations: recommendations,
      stats: stats,
    );
  }

  /// تقرير شامل
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🎯 Query Optimizer Report');
    buffer.writeln('=' * 50);
    buffer.writeln('Total Queries: ${_queryExecutionCount.length}');
    buffer.writeln(
      'Total Executions: ${_queryExecutionCount.values.fold<int>(0, (sum, count) => sum + count)}',
    );
    buffer.writeln();

    // أبطأ الاستعلامات
    buffer.writeln('--- Slowest Queries ---');
    final slowest = getSlowestQueries(limit: 5);
    for (final entry in slowest) {
      buffer.writeln('${entry.key}:');
      buffer.writeln(
        '  Avg Duration: ${entry.value.averageDuration.inMilliseconds}ms',
      );
      buffer.writeln('  Executions: ${entry.value.executionCount}');

      final analysis = analyzeQuery(entry.key);
      if (!analysis.isOptimized) {
        buffer.writeln('  Recommendations:');
        for (final rec in analysis.recommendations) {
          buffer.writeln('    $rec');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// مسح الإحصائيات
  static void clear() {
    _queryPlans.clear();
    _queryExecutionCount.clear();
  }
}

/// خطة الاستعلام
class QueryPlan {
  final String description;
  final List<String> indexes;
  final bool usesIndex;
  final int estimatedRows;

  const QueryPlan({
    required this.description,
    this.indexes = const [],
    this.usesIndex = false,
    this.estimatedRows = 0,
  });
}

/// إحصائيات الاستعلام
class QueryStats {
  final String queryName;
  final int executionCount;
  final Duration averageDuration;
  final QueryPlan? plan;

  const QueryStats({
    required this.queryName,
    required this.executionCount,
    required this.averageDuration,
    this.plan,
  });

  @override
  String toString() {
    return 'QueryStats($queryName: ${averageDuration.inMilliseconds}ms, executions: $executionCount)';
  }
}

/// تحليل الاستعلام
class QueryAnalysis {
  final String queryName;
  final bool isOptimized;
  final List<String> recommendations;
  final QueryStats? stats;

  const QueryAnalysis({
    required this.queryName,
    required this.isOptimized,
    required this.recommendations,
    this.stats,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Query: $queryName');
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
