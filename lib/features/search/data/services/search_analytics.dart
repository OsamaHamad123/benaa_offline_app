/// 📊 Search Analytics Service
///
/// Tracks search patterns and performance for optimization
class SearchAnalytics {
  // Analytics data storage
  static final Map<String, int> _searchFrequency = {};
  static final Map<String, List<int>> _searchDurations = {};
  static final Map<String, int> _clickThroughRate = {};
  static int _totalSearches = 0;
  static int _successfulSearches = 0;

  /// Record a search query with duration and result count
  static void recordSearch({
    required String query,
    required int durationMs,
    required int resultsCount,
  }) {
    _totalSearches++;

    if (resultsCount > 0) {
      _successfulSearches++;
    }

    // Track search frequency
    final normalized = query.trim().toLowerCase();
    _searchFrequency[normalized] = (_searchFrequency[normalized] ?? 0) + 1;

    // Track search durations for performance analysis
    if (!_searchDurations.containsKey(normalized)) {
      _searchDurations[normalized] = [];
    }
    _searchDurations[normalized]!.add(durationMs);

    // Keep only last 10 durations per query (memory efficient)
    if (_searchDurations[normalized]!.length > 10) {
      _searchDurations[normalized]!.removeAt(0);
    }

    // Cleanup old data if too many entries (max 1000 unique queries)
    if (_searchFrequency.length > 1000) {
      _cleanupOldData();
    }
  }

  /// Record when user clicks on a result
  static void recordClick(String query) {
    final normalized = query.trim().toLowerCase();
    _clickThroughRate[normalized] = (_clickThroughRate[normalized] ?? 0) + 1;
  }

  /// Get popular search queries (top 10)
  static List<MapEntry<String, int>> getPopularQueries() {
    final entries = _searchFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  /// Get average search duration for a query
  static double getAverageDuration(String query) {
    final normalized = query.trim().toLowerCase();
    final durations = _searchDurations[normalized];

    if (durations == null || durations.isEmpty) return 0.0;

    return durations.reduce((a, b) => a + b) / durations.length;
  }

  /// Get queries with slow performance (avg > 200ms)
  static List<String> getSlowQueries() {
    final slowQueries = <String>[];

    for (final entry in _searchDurations.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg > 200) {
        slowQueries.add(entry.key);
      }
    }

    return slowQueries;
  }

  /// Get success rate (searches with results / total searches)
  static double getSuccessRate() {
    if (_totalSearches == 0) return 0.0;
    return _successfulSearches / _totalSearches;
  }

  /// Get analytics summary
  static Map<String, dynamic> getSummary() {
    return {
      'totalSearches': _totalSearches,
      'successfulSearches': _successfulSearches,
      'successRate': getSuccessRate(),
      'uniqueQueries': _searchFrequency.length,
      'popularQueries': getPopularQueries(),
      'slowQueries': getSlowQueries(),
      'averageSearchDuration': _calculateOverallAverageDuration(),
    };
  }

  /// Calculate overall average search duration
  static double _calculateOverallAverageDuration() {
    if (_searchDurations.isEmpty) return 0.0;

    var totalDuration = 0;
    var totalCount = 0;

    for (final durations in _searchDurations.values) {
      totalDuration += durations.reduce((a, b) => a + b);
      totalCount += durations.length;
    }

    return totalCount > 0 ? totalDuration / totalCount : 0.0;
  }

  /// Cleanup old data to prevent memory bloat
  static void _cleanupOldData() {
    // Keep only top 500 most frequent queries
    final entries = _searchFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final toKeep = entries.take(500).map((e) => e.key).toSet();

    _searchFrequency.removeWhere((key, _) => !toKeep.contains(key));
    _searchDurations.removeWhere((key, _) => !toKeep.contains(key));
    _clickThroughRate.removeWhere((key, _) => !toKeep.contains(key));
  }

  /// Clear all analytics data
  static void clear() {
    _searchFrequency.clear();
    _searchDurations.clear();
    _clickThroughRate.clear();
    _totalSearches = 0;
    _successfulSearches = 0;
  }

  /// Get queries with high click-through rate (popular + clicked)
  static List<String> getHighEngagementQueries() {
    final engagement = <String, double>{};

    for (final query in _searchFrequency.keys) {
      final frequency = _searchFrequency[query] ?? 0;
      final clicks = _clickThroughRate[query] ?? 0;

      if (frequency > 0) {
        // Engagement score: clicks / searches
        engagement[query] = clicks / frequency;
      }
    }

    final sorted = engagement.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).map((e) => e.key).toList();
  }
}
