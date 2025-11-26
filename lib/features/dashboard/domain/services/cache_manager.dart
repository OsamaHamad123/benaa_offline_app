import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🗑️ Cache Manager - مدير الذاكرة المؤقتة
///
/// يوفر آليات لـ:
/// - مسح الذاكرة المؤقتة بشكل دوري
/// - مسح ذاكرة مؤقتة محددة
/// - تتبع حجم الذاكرة المؤقتة
/// - جدولة المسح التلقائي

class CacheManager {
  // Removed unused _ref field
  DateTime? _lastCacheCleared;

  // إعدادات الذاكرة المؤقتة
  static const Duration _autoClearInterval = Duration(hours: 24);

  CacheManager();

  /// آخر مرة تم مسح الذاكرة المؤقتة
  DateTime? get lastCacheCleared => _lastCacheCleared;

  /// التحقق إذا كان يجب مسح الذاكرة تلقائياً
  bool shouldAutoClear() {
    if (_lastCacheCleared == null) return true;

    final timeSinceLastClear = DateTime.now().difference(_lastCacheCleared!);
    return timeSinceLastClear >= _autoClearInterval;
  }

  /// مسح كل الذاكرة المؤقتة
  Future<bool> clearAllCache() async {
    try {
      // مسح ذاكرة الأنشطة
      await _clearActivitiesCache();

      // مسح ذاكرة لوحة التحكم
      await _clearDashboardCache();

      // مسح ذاكرة الإحصائيات
      await _clearStatsCache();

      _lastCacheCleared = DateTime.now();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح ذاكرة الأنشطة فقط
  Future<bool> clearActivitiesCache() async {
    try {
      await _clearActivitiesCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح ذاكرة لوحة التحكم فقط
  Future<bool> clearDashboardCache() async {
    try {
      await _clearDashboardCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح ذاكرة الإحصائيات فقط
  Future<bool> clearStatsCache() async {
    try {
      await _clearStatsCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// مسح الذاكرة القديمة تلقائياً
  Future<void> autoClearIfNeeded() async {
    if (shouldAutoClear()) {
      await clearAllCache();
    }
  }

  /// الحصول على حجم الذاكرة المؤقتة التقريبي
  Future<CacheInfo> getCacheInfo() async {
    // TODO: حساب الحجم الفعلي من قاعدة البيانات
    return CacheInfo(
      activitiesCount: 0,
      dashboardCacheAge: Duration.zero,
      totalSizeKB: 0,
      lastCleared: _lastCacheCleared,
    );
  }

  // Private methods

  Future<void> _clearActivitiesCache() async {
    // TODO: مسح الأنشطة من قاعدة البيانات أو الذاكرة
    // يمكن استخدام Riverpod invalidate:
    // _ref.invalidate(activitiesProvider);

    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _clearDashboardCache() async {
    // TODO: مسح cache لوحة التحكم
    // _ref.invalidate(dashboardStatsProvider);
    // _ref.invalidate(urgentCasesProvider);
    // _ref.invalidate(dailyPerformanceProvider);

    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _clearStatsCache() async {
    // TODO: مسح الإحصائيات القديمة
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// معلومات الذاكرة المؤقتة
class CacheInfo {
  final int activitiesCount;
  final Duration dashboardCacheAge;
  final int totalSizeKB;
  final DateTime? lastCleared;

  CacheInfo({
    required this.activitiesCount,
    required this.dashboardCacheAge,
    required this.totalSizeKB,
    this.lastCleared,
  });

  String get formattedSize {
    if (totalSizeKB < 1024) {
      return '$totalSizeKB KB';
    } else {
      final mb = (totalSizeKB / 1024).toStringAsFixed(2);
      return '$mb MB';
    }
  }

  String get formattedLastCleared {
    if (lastCleared == null) return 'لم يتم المسح بعد';

    final now = DateTime.now();
    final diff = now.difference(lastCleared!);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}

/// Provider لمدير الذاكرة المؤقتة
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});
