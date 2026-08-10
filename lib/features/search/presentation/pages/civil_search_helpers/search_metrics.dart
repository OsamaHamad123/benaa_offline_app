/// 📊 Search Analytics & Metrics
///
/// يتتبع ويحلل:
/// - عمليات البحث
/// - الأداء
/// - أنماط الاستخدام
/// - التحسينات المقترحة
class SearchMetrics {
  final _searchHistory = <SearchMetric>[];
  static const int _maxHistorySize = 100;

  /// Record a search operation
  void recordSearch({
    required String query,
    required int resultsCount,
    required Duration duration,
    required bool fromCache,
  }) {
    final metric = SearchMetric(
      query: query,
      resultsCount: resultsCount,
      duration: duration,
      fromCache: fromCache,
      timestamp: DateTime.now(),
    );

    _searchHistory.add(metric);

    // Keep only recent history
    if (_searchHistory.length > _maxHistorySize) {
      _searchHistory.removeAt(0);
    }
  }

  /// Get average search duration
  Duration get averageSearchDuration {
    if (_searchHistory.isEmpty) return Duration.zero;

    final total = _searchHistory.fold<int>(
      0,
      (sum, metric) => sum + metric.duration.inMilliseconds,
    );

    return Duration(milliseconds: total ~/ _searchHistory.length);
  }

  /// Get cache hit rate
  double get cacheHitRate {
    if (_searchHistory.isEmpty) return 0.0;

    final cacheHits = _searchHistory.where((m) => m.fromCache).length;
    return cacheHits / _searchHistory.length;
  }

  /// Get most common queries
  List<String> getMostCommonQueries({int limit = 10}) {
    final queryCount = <String, int>{};

    for (final metric in _searchHistory) {
      queryCount[metric.query] = (queryCount[metric.query] ?? 0) + 1;
    }

    final sorted = queryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Get queries with no results
  List<String> getNoResultQueries() {
    return _searchHistory
        .where((m) => m.resultsCount == 0)
        .map((m) => m.query)
        .toSet()
        .toList();
  }

  /// Get performance statistics
  PerformanceStats get performanceStats {
    if (_searchHistory.isEmpty) {
      return PerformanceStats(
        totalSearches: 0,
        averageDuration: Duration.zero,
        cacheHitRate: 0.0,
        totalResults: 0,
      );
    }

    final totalResults = _searchHistory.fold<int>(
      0,
      (sum, metric) => sum + metric.resultsCount,
    );

    return PerformanceStats(
      totalSearches: _searchHistory.length,
      averageDuration: averageSearchDuration,
      cacheHitRate: cacheHitRate,
      totalResults: totalResults,
    );
  }

  /// Clear all metrics
  void clear() {
    _searchHistory.clear();
  }
}

/// Search metric data class
class SearchMetric {
  final String query;
  final int resultsCount;
  final Duration duration;
  final bool fromCache;
  final DateTime timestamp;

  SearchMetric({
    required this.query,
    required this.resultsCount,
    required this.duration,
    required this.fromCache,
    required this.timestamp,
  });
}

/// Performance statistics
class PerformanceStats {
  final int totalSearches;
  final Duration averageDuration;
  final double cacheHitRate;
  final int totalResults;

  PerformanceStats({
    required this.totalSearches,
    required this.averageDuration,
    required this.cacheHitRate,
    required this.totalResults,
  });

  @override
  String toString() {
    return 'PerformanceStats('
        'searches: $totalSearches, '
        'avgDuration: ${averageDuration.inMilliseconds}ms, '
        'cacheHitRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
        'results: $totalResults'
        ')';
  }
}
