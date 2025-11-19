/// 📊 Search Performance Analytics Service
/// Tracks search performance metrics for production monitoring
class SearchPerformanceAnalytics {
  static final SearchPerformanceAnalytics _instance =
      SearchPerformanceAnalytics._internal();

  factory SearchPerformanceAnalytics() => _instance;

  SearchPerformanceAnalytics._internal();

  // ⚡ Performance Metrics
  final List<SearchMetric> _recentSearches = [];
  static const int _maxRecentSearches = 100;

  // 📊 Cache Metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalSearches = 0;

  // ⚠️ Error Tracking
  final List<SearchError> _errors = [];
  static const int _maxErrors = 50;

  // ⏱️ Performance Thresholds
  static const int _slowSearchThresholdMs = 200;
  static const int _verySlowSearchThresholdMs = 500;

  /// Record a search operation
  void recordSearch({
    required String query,
    required int durationMs,
    required int resultsCount,
    required bool fromCache,
  }) {
    _totalSearches++;

    if (fromCache) {
      _cacheHits++;
    } else {
      _cacheMisses++;
    }

    final metric = SearchMetric(
      query: query,
      durationMs: durationMs,
      resultsCount: resultsCount,
      fromCache: fromCache,
      timestamp: DateTime.now(),
      isSlow: durationMs > _slowSearchThresholdMs,
      isVerySlow: durationMs > _verySlowSearchThresholdMs,
    );

    _recentSearches.add(metric);

    // Keep only recent searches
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeAt(0);
    }
  }

  /// Record a search error
  void recordError({
    required String query,
    required String error,
    String? stackTrace,
  }) {
    final searchError = SearchError(
      query: query,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _errors.add(searchError);

    // Keep only recent errors
    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }
  }

  /// Get cache hit rate
  double get cacheHitRate {
    if (_totalSearches == 0) return 0.0;
    return (_cacheHits / _totalSearches) * 100;
  }

  /// Get average search duration
  double get averageSearchDurationMs {
    if (_recentSearches.isEmpty) return 0.0;
    final total = _recentSearches.fold<int>(
      0,
      (sum, metric) => sum + metric.durationMs,
    );
    return total / _recentSearches.length;
  }

  /// Get percentage of slow searches
  double get slowSearchPercentage {
    if (_recentSearches.isEmpty) return 0.0;
    final slowCount = _recentSearches.where((m) => m.isSlow).length;
    return (slowCount / _recentSearches.length) * 100;
  }

  /// Get performance summary
  PerformanceSummary getSummary() {
    return PerformanceSummary(
      totalSearches: _totalSearches,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      cacheHitRate: cacheHitRate,
      averageDurationMs: averageSearchDurationMs,
      slowSearchPercentage: slowSearchPercentage,
      recentErrors: _errors.length,
      fastestSearchMs: _recentSearches.isEmpty
          ? 0
          : _recentSearches
                .map((m) => m.durationMs)
                .reduce((a, b) => a < b ? a : b),
      slowestSearchMs: _recentSearches.isEmpty
          ? 0
          : _recentSearches
                .map((m) => m.durationMs)
                .reduce((a, b) => a > b ? a : b),
    );
  }

  /// Get recent slow searches
  List<SearchMetric> getSlowSearches({int limit = 10}) {
    return _recentSearches.where((m) => m.isSlow).take(limit).toList();
  }

  /// Get recent errors
  List<SearchError> getRecentErrors({int limit = 10}) {
    return _errors.reversed.take(limit).toList();
  }

  /// Clear all metrics (useful for testing)
  void clear() {
    _recentSearches.clear();
    _errors.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _totalSearches = 0;
  }

  /// Export metrics for external analysis
  Map<String, dynamic> exportMetrics() {
    return {
      'summary': getSummary().toJson(),
      'recent_searches': _recentSearches.map((m) => m.toJson()).toList(),
      'recent_errors': _errors.map((e) => e.toJson()).toList(),
    };
  }
}

/// 📈 Search Metric Model
class SearchMetric {
  final String query;
  final int durationMs;
  final int resultsCount;
  final bool fromCache;
  final DateTime timestamp;
  final bool isSlow;
  final bool isVerySlow;

  SearchMetric({
    required this.query,
    required this.durationMs,
    required this.resultsCount,
    required this.fromCache,
    required this.timestamp,
    required this.isSlow,
    required this.isVerySlow,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'duration_ms': durationMs,
      'results_count': resultsCount,
      'from_cache': fromCache,
      'timestamp': timestamp.toIso8601String(),
      'is_slow': isSlow,
      'is_very_slow': isVerySlow,
    };
  }
}

/// ⚠️ Search Error Model
class SearchError {
  final String query;
  final String error;
  final String? stackTrace;
  final DateTime timestamp;

  SearchError({
    required this.query,
    required this.error,
    this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'error': error,
      'stack_trace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 📊 Performance Summary Model
class PerformanceSummary {
  final int totalSearches;
  final int cacheHits;
  final int cacheMisses;
  final double cacheHitRate;
  final double averageDurationMs;
  final double slowSearchPercentage;
  final int recentErrors;
  final int fastestSearchMs;
  final int slowestSearchMs;

  PerformanceSummary({
    required this.totalSearches,
    required this.cacheHits,
    required this.cacheMisses,
    required this.cacheHitRate,
    required this.averageDurationMs,
    required this.slowSearchPercentage,
    required this.recentErrors,
    required this.fastestSearchMs,
    required this.slowestSearchMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_searches': totalSearches,
      'cache_hits': cacheHits,
      'cache_misses': cacheMisses,
      'cache_hit_rate': cacheHitRate,
      'average_duration_ms': averageDurationMs,
      'slow_search_percentage': slowSearchPercentage,
      'recent_errors': recentErrors,
      'fastest_search_ms': fastestSearchMs,
      'slowest_search_ms': slowestSearchMs,
    };
  }

  @override
  String toString() {
    return '''
📊 Search Performance Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Searches: $totalSearches
Cache Hit Rate: ${cacheHitRate.toStringAsFixed(1)}%
Average Duration: ${averageDurationMs.toStringAsFixed(0)}ms
Slow Searches: ${slowSearchPercentage.toStringAsFixed(1)}%
Fastest: ${fastestSearchMs}ms
Slowest: ${slowestSearchMs}ms
Recent Errors: $recentErrors
━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}
