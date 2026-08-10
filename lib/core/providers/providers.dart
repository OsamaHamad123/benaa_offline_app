import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/db/drift_database.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../security/crypto_box.dart';
import '../services/database_maintenance_service.dart';

// App Config Provider
final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  return await AppConfig.load();
});

// Database Provider (Singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openEncryptedDb());
  ref.onDispose(() {
    db.close();
  });
  return db;
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider).value;
  if (config == null) {
    throw Exception('App config not loaded');
  }
  return ApiClient(config);
});

// Crypto Box Provider
final cryptoBoxProvider = FutureProvider<CryptoBox>((ref) async {
  return await CryptoBox.create();
});

// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Database Maintenance Service Provider
final databaseMaintenanceProvider = Provider<DatabaseMaintenanceService>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not loaded');
  }
  return DatabaseMaintenanceService(database: db, prefs: prefs);
});

// Database ready provider - waits for database to be initialized
final databaseReadyProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  // Ensure database is open
  try {
    await db.customSelect('SELECT 1').get();
    return true;
  } catch (e) {
    return false;
  }
});

// ============================================================================
// PERFORMANCE OPTIMIZED PROVIDERS - محسّنة للأداء
// ============================================================================

// Beneficiaries Search Provider with filters
final beneficiariesSearchProvider = FutureProvider.family
    .autoDispose<List<Beneficiary>, BeneficiariesFilter>((ref, filter) async {
  final db = ref.watch(databaseProvider);
  return await db.beneficiariesDao.searchBeneficiariesFiltered(
    query: filter.searchQuery,
    category: filter.category,
    governorate: filter.governorate,
    limit: filter.limit,
    offset: filter.offset,
  );
});

// Statistics Provider - Cached for 5 minutes
final statisticsProvider = FutureProvider.autoDispose<Statistics>((ref) async {
  final db = ref.watch(databaseProvider);

  // TODO: Update to use actual category codes from backend
  // For now, using placeholder values (orphan=1, poor=2)
  final results = await Future.wait([
    db.beneficiariesDao.countBeneficiaries(),
    db.beneficiariesDao.countPendingSync(),
    db.beneficiariesDao.countBeneficiariesByCategory(1), // orphan code
    db.beneficiariesDao.countBeneficiariesByCategory(2), // poor code
  ]);

  return Statistics(
    totalBeneficiaries: results[0],
    pendingSync: results[1],
    orphans: results[2],
    poor: results[3],
  );
});

// Notifications Count Provider
final notificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(databaseProvider);

  // حساب عدد الإشعارات:
  // 1. عدد البيانات المعلقة للمزامنة
  // 2. عدد البيانات الناقصة (incomplete)
  final results = await Future.wait([
    db.beneficiariesDao.countPendingSync(),
    db.beneficiariesDao.countIncompleteBeneficiaries(),
  ]);

  return results[0] + results[1];
});

// Single Beneficiary Provider
final beneficiaryProvider =
    FutureProvider.family.autoDispose<Beneficiary?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return await db.beneficiariesDao.getBeneficiaryById(id);
});

// ============================================================================
// DATA CLASSES
// ============================================================================

class BeneficiariesFilter {
  final String searchQuery;
  final int? category;
  final int? governorate;
  final int limit;
  final int offset;

  const BeneficiariesFilter({
    this.searchQuery = '',
    this.category,
    this.governorate,
    this.limit = 50,
    this.offset = 0,
  });

  BeneficiariesFilter copyWith({
    String? searchQuery,
    int? category,
    int? governorate,
    int? limit,
    int? offset,
  }) {
    return BeneficiariesFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      governorate: governorate ?? this.governorate,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeneficiariesFilter &&
        other.searchQuery == searchQuery &&
        other.category == category &&
        other.governorate == governorate &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return Object.hash(searchQuery, category, governorate, limit, offset);
  }
}

class Statistics {
  final int totalBeneficiaries;
  final int pendingSync;
  final int orphans;
  final int poor;

  const Statistics({
    required this.totalBeneficiaries,
    required this.pendingSync,
    required this.orphans,
    required this.poor,
  });
}
