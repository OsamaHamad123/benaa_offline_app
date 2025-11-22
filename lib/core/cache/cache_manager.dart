import 'dart:async';

/// 🗄️ مدير الـ Cache المتقدم - LRU Cache مع TTL
class CacheManager<K, V> {
  final int maxSize;
  final Duration? ttl;
  final Map<K, _CacheEntry<V>> _cache = {};
  final List<K> _accessOrder = [];

  CacheManager({this.maxSize = 100, this.ttl});

  /// وضع قيمة في الـ Cache
  void put(K key, V value) {
    // حذف القديم إذا موجود
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    }

    // إضافة الجديد
    _cache[key] = _CacheEntry(value: value, timestamp: DateTime.now());
    _accessOrder.add(key);

    // تطبيق LRU - حذف الأقدم
    while (_cache.length > maxSize) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }
  }

  /// الحصول على قيمة من الـ Cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // فحص TTL
    if (ttl != null) {
      final age = DateTime.now().difference(entry.timestamp);
      if (age > ttl!) {
        remove(key);
        return null;
      }
    }

    // تحديث Access Order (LRU)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return entry.value;
  }

  /// الحصول أو حساب القيمة
  Future<V> getOrPut(K key, Future<V> Function() compute) async {
    final cached = get(key);
    if (cached != null) return cached;

    final value = await compute();
    put(key, value);
    return value;
  }

  /// حذف قيمة
  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// مسح كل الـ Cache
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// حذف العناصر المنتهية
  void evictExpired() {
    if (ttl == null) return;

    final now = DateTime.now();
    final keysToRemove = <K>[];

    _cache.forEach((key, entry) {
      final age = now.difference(entry.timestamp);
      if (age > ttl!) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// إحصائيات الـ Cache
  CacheStats get stats {
    return CacheStats(
      size: _cache.length,
      maxSize: maxSize,
      hitRate: 0.0, // يمكن تتبعها لاحقًا
    );
  }

  /// هل الـ Cache فارغ
  bool get isEmpty => _cache.isEmpty;

  /// هل الـ Cache ممتلئ
  bool get isFull => _cache.length >= maxSize;
}

/// مدخل الـ Cache
class _CacheEntry<V> {
  final V value;
  final DateTime timestamp;

  _CacheEntry({required this.value, required this.timestamp});
}

/// إحصائيات الـ Cache
class CacheStats {
  final int size;
  final int maxSize;
  final double hitRate;

  const CacheStats({
    required this.size,
    required this.maxSize,
    required this.hitRate,
  });

  double get usagePercent => (size / maxSize) * 100;

  @override
  String toString() {
    return 'CacheStats(size: $size/$maxSize, usage: ${usagePercent.toStringAsFixed(1)}%, hitRate: ${hitRate.toStringAsFixed(1)}%)';
  }
}

/// مدير Cache عام للتطبيق
class AppCacheManager {
  static final AppCacheManager _instance = AppCacheManager._internal();
  factory AppCacheManager() => _instance;
  AppCacheManager._internal();

  // Caches مختلفة حسب النوع
  final beneficiaries = CacheManager<int, dynamic>(
    maxSize: 50,
    ttl: const Duration(minutes: 5),
  );

  final families = CacheManager<int, dynamic>(
    maxSize: 30,
    ttl: const Duration(minutes: 5),
  );

  final images = CacheManager<String, dynamic>(
    maxSize: 20,
    ttl: const Duration(minutes: 10),
  );

  final queries = CacheManager<String, dynamic>(
    maxSize: 100,
    ttl: const Duration(minutes: 2),
  );

  /// مسح كل الـ Caches
  void clearAll() {
    beneficiaries.clear();
    families.clear();
    images.clear();
    queries.clear();
  }

  /// تنظيف العناصر المنتهية
  void evictAllExpired() {
    beneficiaries.evictExpired();
    families.evictExpired();
    images.evictExpired();
    queries.evictExpired();
  }

  /// إحصائيات شاملة
  String generateReport() {
    return '''
🗄️ Cache Manager Report
========================
Beneficiaries: ${beneficiaries.stats}
Families: ${families.stats}
Images: ${images.stats}
Queries: ${queries.stats}
''';
  }
}
