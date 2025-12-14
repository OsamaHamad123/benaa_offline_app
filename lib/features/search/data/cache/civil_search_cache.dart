import 'dart:collection';
import '../../domain/entities/civil_person.dart';

/// 🗄️ Civil Registry Cache Layer
///
/// يوفر caching ذكي لنتائج البحث في السجل المدني:
/// - LRU Cache للنتائج الأخيرة
/// - TTL (Time To Live) للبيانات
/// - Memory management
///
/// Performance Benefits:
/// - تقليل استعلامات قاعدة البيانات
/// - تحسين سرعة الاستجابة
/// - تقليل استهلاك CPU
class CivilSearchCache {
  // ⚡ LRU Cache with max size
  final int maxCacheSize;
  final Duration cacheDuration;

  final _cache = LinkedHashMap<String, _CacheEntry>();

  CivilSearchCache({
    this.maxCacheSize = 50, // Store last 50 searches
    this.cacheDuration = const Duration(minutes: 10),
  });

  /// Get cached results if available and not expired
  List<CivilPerson>? get(String cacheKey) {
    final entry = _cache[cacheKey];

    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().difference(entry.timestamp) > cacheDuration) {
      _cache.remove(cacheKey);
      return null;
    }

    // Move to end (LRU)
    _cache.remove(cacheKey);
    _cache[cacheKey] = entry;

    return entry.results;
  }

  /// Cache results
  void put(String cacheKey, List<CivilPerson> results) {
    // Remove oldest if at max size
    if (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[cacheKey] = _CacheEntry(
      results: results,
      timestamp: DateTime.now(),
    );
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      return now.difference(entry.timestamp) > cacheDuration;
    });
  }

  /// Get cache statistics
  CacheStats get stats => CacheStats(
        size: _cache.length,
        maxSize: maxCacheSize,
        hitRate: _hitRate,
      );

  // Track hit rate
  int _hits = 0;
  int _misses = 0;

  double get _hitRate {
    final total = _hits + _misses;
    return total == 0 ? 0.0 : _hits / total;
  }

  void _recordHit() => _hits++;
  void _recordMiss() => _misses++;

  /// Generate cache key from search parameters
  static String generateKey({
    required String query,
    int? minAge,
    int? maxAge,
    String? governorate,
    String? gender,
  }) {
    return [
      query.toLowerCase().trim(),
      minAge?.toString() ?? '',
      maxAge?.toString() ?? '',
      governorate ?? '',
      gender ?? '',
    ].join('|');
  }
}

/// Cache entry with timestamp
class _CacheEntry {
  final List<CivilPerson> results;
  final DateTime timestamp;

  _CacheEntry({
    required this.results,
    required this.timestamp,
  });
}

/// Cache statistics
class CacheStats {
  final int size;
  final int maxSize;
  final double hitRate;

  CacheStats({
    required this.size,
    required this.maxSize,
    required this.hitRate,
  });

  @override
  String toString() => 'CacheStats(size: $size/$maxSize, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
}
