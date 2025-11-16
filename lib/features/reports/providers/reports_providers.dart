import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';

// Cache duration for reports (5 minutes)
const _reportsCacheDuration = Duration(minutes: 5);

/// Summary Statistics Provider with caching
final summaryStatisticsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  // Keep provider alive for cache duration
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  // Invalidate cache after duration
  timer = Timer(_reportsCacheDuration, () {
    link.close();
  });

  final database = ref.watch(databaseProvider);

  final results = await Future.wait([
    database.beneficiariesDao.countBeneficiaries(),
    database.beneficiariesDao.countBeneficiariesByCategory(1), // orphan
    database.beneficiariesDao.countBeneficiariesByCategory(2), // poor
    database.beneficiariesDao.countPendingSync(),
  ]);

  return {
    'total': results[0],
    'orphans': results[1],
    'poor': results[2],
    'pending': results[3],
  };
});

/// Governorate Report Provider with caching
final governorateReportProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  // Keep provider alive for cache duration
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  timer = Timer(_reportsCacheDuration, () {
    link.close();
  });

  final database = ref.watch(databaseProvider);
  final beneficiaries = await database.beneficiariesDao.getAllBeneficiaries();

  final governorateCounts = <String, int>{};
  for (var b in beneficiaries) {
    final provinceKey = b.province?.toString() ?? 'غير محدد';
    governorateCounts[provinceKey] = (governorateCounts[provinceKey] ?? 0) + 1;
  }

  return governorateCounts;
});

/// Category Report Provider with caching
final categoryReportProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  // Keep provider alive for cache duration
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  timer = Timer(_reportsCacheDuration, () {
    link.close();
  });

  final database = ref.watch(databaseProvider);
  final beneficiaries = await database.beneficiariesDao.getAllBeneficiaries();

  final categoryCounts = <String, int>{};
  for (var b in beneficiaries) {
    final categoryKey = _getCategoryName(b.sectionId);
    categoryCounts[categoryKey] = (categoryCounts[categoryKey] ?? 0) + 1;
  }

  return categoryCounts;
});

/// Gender Report Provider with caching
final genderReportProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  // Keep provider alive for cache duration
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  timer = Timer(_reportsCacheDuration, () {
    link.close();
  });

  final database = ref.watch(databaseProvider);
  final beneficiaries = await database.beneficiariesDao.getAllBeneficiaries();

  final genderCounts = <String, int>{};
  for (var b in beneficiaries) {
    final genderKey = b.gender == 'male' ? 'ذكور' : 'إناث';
    genderCounts[genderKey] = (genderCounts[genderKey] ?? 0) + 1;
  }

  return genderCounts;
});

/// Sync Status Report Provider with caching
final syncStatusReportProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  // Keep provider alive for cache duration
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  timer = Timer(_reportsCacheDuration, () {
    link.close();
  });

  final database = ref.watch(databaseProvider);
  final beneficiaries = await database.beneficiariesDao.getAllBeneficiaries();

  final syncCounts = <String, int>{};
  for (var b in beneficiaries) {
    final statusKey = _getSyncStatusName(b.syncState);
    syncCounts[statusKey] = (syncCounts[statusKey] ?? 0) + 1;
  }

  return syncCounts;
});

/// Helper function to get category name
String _getCategoryName(int? sectionId) {
  switch (sectionId) {
    case 1:
      return 'أيتام';
    case 2:
      return 'أرامل';
    case 3:
      return 'فقراء';
    case 4:
      return 'معاقين';
    default:
      return 'غير محدد';
  }
}

/// Helper function to get sync status name
String _getSyncStatusName(String syncState) {
  switch (syncState) {
    case 'synced':
      return 'متزامن';
    case 'pending':
      return 'بانتظار المزامنة';
    case 'failed':
      return 'فشل';
    default:
      return 'غير محدد';
  }
}
