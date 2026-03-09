import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/db/drift_database.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../security/crypto_box.dart';
import '../services/database_maintenance_service.dart';
import '../analytics/ux_feature_flags.dart';

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
  final config = ref.watch(appConfigProvider).requireValue;
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

final uxFeatureFlagsStoreProvider = Provider<UxFeatureFlagsStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return UxFeatureFlagsStore(prefs);
});

final uxFeatureFlagsProvider = FutureProvider<UxFeatureFlags>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final store = UxFeatureFlagsStore(prefs);
  return store.readFlags();
});

// Database Maintenance Service Provider
final databaseMaintenanceProvider = Provider<DatabaseMaintenanceService>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
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
final beneficiariesSearchProvider =
    FutureProvider.family.autoDispose<List<Beneficiary>, BeneficiariesFilter>((ref, filter) async {
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

  final categoryCodes = await _resolveLegacyCategoryCodes(db);
  final results = await Future.wait([
    db.beneficiariesDao.countBeneficiaries(),
    db.beneficiariesDao.countPendingSync(),
    db.beneficiariesDao.countBeneficiariesByCategory(categoryCodes.orphanCode),
    db.beneficiariesDao.countBeneficiariesByCategory(categoryCodes.poorCode),
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
final beneficiaryProvider = FutureProvider.family.autoDispose<Beneficiary?, int>((ref, id) async {
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

class _ResolvedCategoryCodes {
  final int orphanCode;
  final int poorCode;

  const _ResolvedCategoryCodes({
    required this.orphanCode,
    required this.poorCode,
  });
}

Future<_ResolvedCategoryCodes> _resolveLegacyCategoryCodes(AppDatabase db) async {
  final categories = <Taxonomy>[];
  categories.addAll(await db.taxonomiesDao.getByGroup('category'));
  categories.addAll(await db.taxonomiesDao.getByGroup('section'));

  int? orphanCode;
  int? poorCode;

  for (final taxonomy in categories) {
    final key = _parseTaxonomyNumericKey(taxonomy);
    if (key == null) {
      continue;
    }

    final label = taxonomy.label.trim();
    if (orphanCode == null && (label == 'أيتام' || label == 'يتيم')) {
      orphanCode = key;
    }
    if (poorCode == null && (label == 'فقراء' || label == 'فقير')) {
      poorCode = key;
    }
  }

  return _ResolvedCategoryCodes(
    orphanCode: orphanCode ?? 1,
    poorCode: poorCode ?? 2,
  );
}

int? _parseTaxonomyNumericKey(Taxonomy taxonomy) {
  final code = int.tryParse(taxonomy.code.trim());
  if (code != null) {
    return code;
  }

  final rawId = taxonomy.id.trim();
  if (rawId.isEmpty) {
    return null;
  }

  final separatorIndex = rawId.indexOf('::');
  final suffix = separatorIndex >= 0 ? rawId.substring(separatorIndex + 2) : rawId;
  return int.tryParse(suffix.trim());
}
