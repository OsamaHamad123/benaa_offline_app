import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔧 Cache Manager for Beneficiaries List
class CacheManager {
  static DateTime? _lastCacheTime;
  static const _cacheExpiryDuration = Duration(minutes: 5);

  /// التحقق من صلاحية الـ cache
  static bool isCacheValid() {
    if (_lastCacheTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastCacheTime!) < _cacheExpiryDuration;
  }

  /// تحديث وقت الـ cache
  static void updateCacheTime() {
    _lastCacheTime = DateTime.now();
  }

  /// مسح الـ cache
  static void clearCache() {
    _lastCacheTime = null;
  }

  /// الحصول على عمر الـ cache
  static Duration? getCacheAge() {
    if (_lastCacheTime == null) return null;
    return DateTime.now().difference(_lastCacheTime!);
  }
}

/// 🔄 Provider لإدارة الـ cache
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});
