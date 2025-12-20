import 'dart:async';
import 'package:flutter/foundation.dart';

/// 🎯 مدير التحميل الذكي - Smart Preloading
class SmartPreloader {
  static final Map<String, _PreloadStrategy> _strategies = {};
  static final Map<String, dynamic> _preloadedData = {};
  static final Map<String, DateTime> _lastAccess = {};

  /// تسجيل استراتيجية التحميل المسبق
  static void registerStrategy(String key, _PreloadStrategy strategy) {
    _strategies[key] = strategy;
  }

  /// التحميل المسبق
  static Future<void> preload(
    String key,
    Future<dynamic> Function() loader,
  ) async {
    final strategy = _strategies[key] ?? _PreloadStrategy.eager;

    switch (strategy) {
      case _PreloadStrategy.eager:
        // تحميل فوري
        _preloadedData[key] = await loader();
        break;

      case _PreloadStrategy.lazy:
        // تحميل عند الطلب
        break;

      case _PreloadStrategy.intelligent:
        // تحميل ذكي بناءً على الوصول السابق
        final lastAccess = _lastAccess[key];
        if (lastAccess != null) {
          final timeSinceAccess = DateTime.now().difference(lastAccess);
          if (timeSinceAccess.inMinutes < 5) {
            _preloadedData[key] = await loader();
          }
        }
        break;
    }
  }

  /// الحصول على البيانات المحملة مسبقاً
  static Future<T> get<T>(
    String key,
    Future<T> Function() loader, {
    bool recordAccess = true,
  }) async {
    if (recordAccess) {
      _lastAccess[key] = DateTime.now();
    }

    if (_preloadedData.containsKey(key)) {
      return _preloadedData[key] as T;
    }

    final data = await loader();
    _preloadedData[key] = data;
    return data;
  }

  /// مسح البيانات المحملة
  static void clear([String? key]) {
    if (key != null) {
      _preloadedData.remove(key);
    } else {
      _preloadedData.clear();
    }
  }

  /// مسح البيانات القديمة
  static void evictStale(Duration maxAge) {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _lastAccess.forEach((key, lastAccess) {
      final age = now.difference(lastAccess);
      if (age > maxAge) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _preloadedData.remove(key);
      _lastAccess.remove(key);
    }
  }

  /// إحصائيات
  static PreloadStats get stats {
    return PreloadStats(
      preloadedItems: _preloadedData.length,
      strategies: _strategies.length,
    );
  }
}

/// استراتيجية التحميل المسبق
enum _PreloadStrategy {
  eager, // تحميل فوري
  lazy, // تحميل عند الطلب
  intelligent, // تحميل ذكي
}

/// إحصائيات التحميل المسبق
class PreloadStats {
  final int preloadedItems;
  final int strategies;

  const PreloadStats({required this.preloadedItems, required this.strategies});

  @override
  String toString() {
    return 'PreloadStats(items: $preloadedItems, strategies: $strategies)';
  }
}

/// مدير تحميل الصور الذكي
class SmartImagePreloader {
  static final Map<String, Uint8List> _imageCache = {};
  static const int _maxCacheSize = 50;

  /// التحميل المسبق للصور
  static Future<void> preloadImages(List<String> imagePaths) async {
    for (var i = 0;
        i < imagePaths.length && _imageCache.length < _maxCacheSize;
        i++) {
      // هنا يمكن إضافة منطق التحميل الفعلي
      // مثال: _imageCache[imagePaths[i]] = await loadImage(imagePaths[i]);
    }
  }

  /// الحصول على صورة محملة
  static Uint8List? getCachedImage(String path) {
    return _imageCache[path];
  }

  /// مسح الـ cache
  static void clear() {
    _imageCache.clear();
  }
}

/// مدير التحميل المسبق للبيانات
class DataPreloadManager {
  static final Map<String, Future<dynamic>> _pendingLoads = {};

  /// التحميل المسبق مع منع التكرار
  static Future<T> preloadOnce<T>(
    String key,
    Future<T> Function() loader,
  ) async {
    if (_pendingLoads.containsKey(key)) {
      return await _pendingLoads[key] as T;
    }

    final future = loader();
    _pendingLoads[key] = future;

    try {
      final result = await future;
      _pendingLoads.remove(key);
      return result;
    } catch (e) {
      _pendingLoads.remove(key);
      rethrow;
    }
  }

  /// التحميل المسبق بالأولوية
  static Future<void> preloadWithPriority(
    Map<String, Future<dynamic> Function()> loaders, {
    List<String>? priorityKeys,
  }) async {
    // تحميل العناصر ذات الأولوية أولاً
    if (priorityKeys != null) {
      for (final key in priorityKeys) {
        final loader = loaders[key];
        if (loader != null) {
          await preloadOnce(key, loader);
        }
      }
    }

    // تحميل الباقي
    final remaining = loaders.entries.where(
      (e) => priorityKeys == null || !priorityKeys.contains(e.key),
    );

    await Future.wait(remaining.map((e) => preloadOnce(e.key, e.value)));
  }
}

/// Adaptive Preloading - تحميل مسبق متكيف
class AdaptivePreloader {
  static bool _isLowMemory = false;
  static bool _isSlowNetwork = false;

  /// ضبط حالة الذاكرة
  static void setLowMemoryMode(bool enabled) {
    _isLowMemory = enabled;
  }

  /// ضبط حالة الشبكة
  static void setSlowNetworkMode(bool enabled) {
    _isSlowNetwork = enabled;
  }

  /// التحميل المسبق المتكيف
  static Future<T> adaptivePreload<T>(
    String key,
    Future<T> Function() loader, {
    bool essential = false,
  }) async {
    // إذا كانت الذاكرة منخفضة، لا تحمل إلا الأساسي
    if (_isLowMemory && !essential) {
      return await loader();
    }

    // إذا كانت الشبكة بطيئة، أعطي أولوية للأساسي
    if (_isSlowNetwork && essential) {
      return await SmartPreloader.get(key, loader);
    }

    return await SmartPreloader.get(key, loader);
  }

  /// تقرير الوضع الحالي
  static String getStatus() {
    return '''
🎯 Adaptive Preloader Status
=============================
Low Memory Mode: ${_isLowMemory ? 'ON' : 'OFF'}
Slow Network Mode: ${_isSlowNetwork ? 'ON' : 'OFF'}
''';
  }
}
