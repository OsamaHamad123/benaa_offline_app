import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/drift_database.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../security/crypto_box.dart';

// App Config Provider
final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  return await AppConfig.load();
});

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(openEncryptedDb());
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
      return await db.searchBeneficiariesFiltered(
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

  final results = await Future.wait([
    db.countBeneficiaries(),
    db.countPendingSync(),
    db.countBeneficiariesByCategory('orphan'),
    db.countBeneficiariesByCategory('poor'),
  ]);

  return Statistics(
    totalBeneficiaries: results[0],
    pendingSync: results[1],
    orphans: results[2],
    poor: results[3],
  );
});

// Single Beneficiary Provider
final beneficiaryProvider = FutureProvider.family
    .autoDispose<Beneficiary?, String>((ref, id) async {
      final db = ref.watch(databaseProvider);
      return await db.getBeneficiaryById(id);
    });

// ============================================================================
// DATA CLASSES
// ============================================================================

class BeneficiariesFilter {
  final String searchQuery;
  final String? category;
  final String? governorate;
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
    String? category,
    String? governorate,
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
