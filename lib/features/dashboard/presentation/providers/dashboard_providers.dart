import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';

/// Dashboard Summary Stats Provider
/// يتم تحديثه تلقائياً كل 30 ثانية للحصول على بيانات محدّثة
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((
  ref,
) async {
  // Keep alive for 30 seconds
  final link = ref.keepAlive();
  Timer(const Duration(seconds: 30), link.close);

  final db = ref.watch(databaseProvider);

  // Get counts in parallel for better performance
  final results = await Future.wait([
    db.beneficiariesDao.countBeneficiaries(),
    db.beneficiariesDao.countBeneficiariesByCategory(1), // orphans
    db.beneficiariesDao.countBeneficiariesByCategory(3), // poor
    db.beneficiariesDao.countPendingSync(),
  ]);

  final total = results[0];
  final orphans = results[1];
  final poor = results[2];
  final pending = results[3];

  // Calculate sync percentage
  final synced = total - pending;
  final syncPercentage = total > 0 ? (synced / total * 100) : 0.0;

  return DashboardSummary(
    total: total,
    orphans: orphans,
    poor: poor,
    pending: pending,
    synced: synced,
    syncPercentage: syncPercentage,
  );
});

/// Daily Performance Data Provider
final dailyPerformanceProvider = FutureProvider<DailyPerformance>((ref) async {
  final db = ref.watch(databaseProvider);

  // Count visits today
  final visitsToday = await db.visitsDao.countVisitsToday();

  // Count new beneficiaries today
  final newBeneficiariesToday =
      await db.beneficiariesDao.countNewBeneficiariesToday();

  // Simplified: use today's count as average for now
  final avgVisitsPerDay = visitsToday.toDouble();

  return DailyPerformance(
    visitsToday: visitsToday,
    newBeneficiariesToday: newBeneficiariesToday,
    avgVisitsPerDay: avgVisitsPerDay,
  );
});

/// Urgent Cases Data Provider
final urgentCasesProvider = FutureProvider<UrgentCases>((ref) async {
  final db = ref.watch(databaseProvider);

  // Count beneficiaries with no visits in last 30 days
  final noVisitsCount =
      await db.beneficiariesDao.countBeneficiariesWithNoRecentVisits(30);

  // Count beneficiaries with poor health
  final poorHealthCount =
      await db.beneficiariesDao.countBeneficiariesWithPoorHealth();

  // Count beneficiaries with disabilities
  final disabilitiesCount =
      await db.beneficiariesDao.countBeneficiariesWithDisabilities();

  return UrgentCases(
    noVisitsCount: noVisitsCount,
    poorHealthCount: poorHealthCount,
    disabilitiesCount: disabilitiesCount,
  );
});

/// Geographic Distribution Provider
final geographicDistributionProvider = FutureProvider<Map<int, int>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  return await db.beneficiariesDao.getBeneficiariesCountByProvince();
});

/// Dashboard Summary Model
class DashboardSummary {
  final int total;
  final int orphans;
  final int poor;
  final int pending;
  final int synced;
  final double syncPercentage;

  const DashboardSummary({
    required this.total,
    required this.orphans,
    required this.poor,
    required this.pending,
    required this.synced,
    required this.syncPercentage,
  });
}

/// Daily Performance Model
class DailyPerformance {
  final int visitsToday;
  final int newBeneficiariesToday;
  final double avgVisitsPerDay;

  const DailyPerformance({
    required this.visitsToday,
    required this.newBeneficiariesToday,
    required this.avgVisitsPerDay,
  });
}

/// Urgent Cases Model
class UrgentCases {
  final int noVisitsCount;
  final int poorHealthCount;
  final int disabilitiesCount;

  int get totalUrgent => noVisitsCount + poorHealthCount + disabilitiesCount;

  const UrgentCases({
    required this.noVisitsCount,
    required this.poorHealthCount,
    required this.disabilitiesCount,
  });
}

/// Pending Sync Count Provider
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.beneficiariesDao.countPendingSync();
});

/// Data Quality Score Provider
final dataQualityProvider = FutureProvider<DataQuality>((ref) async {
  final db = ref.watch(databaseProvider);
  final total = await db.beneficiariesDao.countBeneficiaries();

  if (total == 0) {
    return const DataQuality(total: 0, complete: 0, score: 0);
  }

  // TODO: حساب البيانات الكاملة من قاعدة البيانات
  final complete = (total * 0.85).round();
  final score = (complete / total * 100).round();

  return DataQuality(total: total, complete: complete, score: score);
});

/// Data Quality Model
class DataQuality {
  final int total;
  final int complete;
  final int score;

  const DataQuality({
    required this.total,
    required this.complete,
    required this.score,
  });
}
