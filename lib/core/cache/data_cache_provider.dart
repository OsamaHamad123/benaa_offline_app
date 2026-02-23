import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_manager.dart';
import 'image_cache_manager.dart';

/// 💾 Data Cache Providers
///
/// Providers للـ caching الذكي

// Memory cache للبيانات العامة
final dataCacheProvider = Provider<CacheManager<String, dynamic>>((ref) {
  return CacheManager(
    maxSize: 200,
    ttl: const Duration(minutes: 15),
  );
});

// Cache للمستفيدين
final beneficiariesCacheProvider = Provider<CacheManager<int, dynamic>>((ref) {
  return CacheManager(
    ttl: const Duration(minutes: 30),
  );
});

// Cache للجمعيات
final associationsCacheProvider = Provider<CacheManager<int, dynamic>>((ref) {
  return CacheManager(
    maxSize: 50,
    ttl: const Duration(minutes: 30),
  );
});

// Cache للكفالات
final sponsorshipsCacheProvider = Provider<CacheManager<int, dynamic>>((ref) {
  return CacheManager(
    ttl: const Duration(minutes: 20),
  );
});

// Image cache singleton
final imageCacheProvider = Provider<ImageCacheManager>((ref) {
  final manager = ImageCacheManager();
  manager.initialize();
  return manager;
});

// Provider لإدارة جميع الـ caches
final cacheManagerProvider = Provider<GlobalCacheManager>((ref) {
  return GlobalCacheManager(
    dataCache: ref.watch(dataCacheProvider),
    beneficiariesCache: ref.watch(beneficiariesCacheProvider),
    associationsCache: ref.watch(associationsCacheProvider),
    sponsorshipsCache: ref.watch(sponsorshipsCacheProvider),
    imageCache: ref.watch(imageCacheProvider),
  );
});

/// Global Cache Manager
class GlobalCacheManager {
  final CacheManager<String, dynamic> dataCache;
  final CacheManager<int, dynamic> beneficiariesCache;
  final CacheManager<int, dynamic> associationsCache;
  final CacheManager<int, dynamic> sponsorshipsCache;
  final ImageCacheManager imageCache;

  GlobalCacheManager({
    required this.dataCache,
    required this.beneficiariesCache,
    required this.associationsCache,
    required this.sponsorshipsCache,
    required this.imageCache,
  });

  /// مسح جميع الـ caches
  Future<void> clearAll() async {
    dataCache.clear();
    beneficiariesCache.clear();
    associationsCache.clear();
    sponsorshipsCache.clear();
    await imageCache.clearCache();
  }

  /// الحصول على الإحصائيات الشاملة
  Future<Map<String, dynamic>> getAllStats() async {
    final imageStats = await imageCache.getStats();

    return {
      'data_cache': 'Size: ${dataCache.stats.size}/${dataCache.maxSize}',
      'beneficiaries_cache': 'Size: ${beneficiariesCache.stats.size}/${beneficiariesCache.maxSize}',
      'associations_cache': 'Size: ${associationsCache.stats.size}/${associationsCache.maxSize}',
      'sponsorships_cache': 'Size: ${sponsorshipsCache.stats.size}/${sponsorshipsCache.maxSize}',
      'image_cache': imageStats.toString(),
    };
  }
}
