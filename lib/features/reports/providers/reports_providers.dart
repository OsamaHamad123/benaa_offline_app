import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../data/repositories/reports_repository_impl.dart';
import '../domain/entities/report_data.dart';
import '../domain/entities/summary_statistics.dart';
import '../domain/usecases/get_summary_statistics.dart';
import '../domain/usecases/get_gender_report.dart';
import '../domain/usecases/get_governorate_report.dart';
import '../domain/usecases/get_category_report.dart';
import '../domain/usecases/get_age_report.dart';
import '../domain/usecases/get_sync_status_report.dart';

/// Reports cache duration - 5 minutes
const _reportsCacheDuration = Duration(minutes: 5);

// ============================================================================
// REPOSITORY & USE CASES PROVIDERS
// ============================================================================

/// Reports repository provider
final reportsRepositoryProvider = Provider<ReportsRepositoryImpl>((ref) {
  final database = ref.watch(databaseProvider);
  return ReportsRepositoryImpl(
    beneficiariesDao: database.beneficiariesDao,
    taxonomiesDao: database.taxonomiesDao,
  );
});

/// Get Summary Statistics Use Case Provider
final getSummaryStatisticsUseCaseProvider = Provider<GetSummaryStatistics>((
  ref,
) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetSummaryStatistics(repository);
});

/// Get Gender Report Use Case Provider
final getGenderReportUseCaseProvider = Provider<GetGenderReport>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetGenderReport(repository);
});

/// Get Governorate Report Use Case Provider
final getGovernorateReportUseCaseProvider = Provider<GetGovernorateReport>((
  ref,
) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetGovernorateReport(repository);
});

/// Get Category Report Use Case Provider
final getCategoryReportUseCaseProvider = Provider<GetCategoryReport>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetCategoryReport(repository);
});

/// Get Age Report Use Case Provider
final getAgeReportUseCaseProvider = Provider<GetAgeReport>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetAgeReport(repository);
});

/// Get Sync Status Report Use Case Provider
final getSyncStatusReportUseCaseProvider = Provider<GetSyncStatusReport>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return GetSyncStatusReport(repository);
});

// ============================================================================
// DATA PROVIDERS (with caching)
// ============================================================================

/// Summary Statistics Provider with caching
final summaryStatisticsProvider = FutureProvider.autoDispose<SummaryStatistics>(
  (ref) async {
    // Keep provider alive for cache duration
    final link = ref.keepAlive();
    Timer? timer;

    ref.onDispose(() {
      timer?.cancel();
    });

    timer = Timer(_reportsCacheDuration, () {
      link.close();
    });

    final useCase = ref.watch(getSummaryStatisticsUseCaseProvider);
    return await useCase();
  },
);

/// Gender Report Provider with caching
final genderReportProvider = FutureProvider.autoDispose<List<GenderCount>>((
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

  final useCase = ref.watch(getGenderReportUseCaseProvider);
  return await useCase();
});

/// Governorate Report Provider with caching
final governorateReportProvider =
    FutureProvider.autoDispose<List<GovernorateCount>>((ref) async {
      // Keep provider alive for cache duration
      final link = ref.keepAlive();
      Timer? timer;

      ref.onDispose(() {
        timer?.cancel();
      });

      timer = Timer(_reportsCacheDuration, () {
        link.close();
      });

      final useCase = ref.watch(getGovernorateReportUseCaseProvider);
      return await useCase();
    });

/// Category Report Provider with caching
final categoryReportProvider = FutureProvider.autoDispose<List<CategoryCount>>((
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

  final useCase = ref.watch(getCategoryReportUseCaseProvider);
  return await useCase();
});

/// Age Report Provider with caching
final ageReportProvider = FutureProvider.autoDispose<List<AgeCount>>((
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

  final useCase = ref.watch(getAgeReportUseCaseProvider);
  return await useCase();
});

/// Sync Status Report Provider with caching
final syncStatusReportProvider =
    FutureProvider.autoDispose<List<SyncStatusCount>>((ref) async {
      // Keep provider alive for cache duration
      final link = ref.keepAlive();
      Timer? timer;

      ref.onDispose(() {
        timer?.cancel();
      });

      timer = Timer(_reportsCacheDuration, () {
        link.close();
      });

      final useCase = ref.watch(getSyncStatusReportUseCaseProvider);
      return await useCase();
    });
