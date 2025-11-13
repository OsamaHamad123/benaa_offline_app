import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/civil_registry_tables.dart';

part 'civil_registry_dao.g.dart';

/// Civil Registry Data Access Object
/// يحتوي على جميع عمليات البحث في السجل المدني
@DriftAccessor(
  tables: [
    CivilRegistry,
    CivilRegistryCity,
    CivilRegistryRelations,
    CivilRegistryRelationCategories,
    CivilRegistryBirthCode,
    CivilRegistryPersonalCode,
  ],
)
class CivilRegistryDao extends DatabaseAccessor<AppDatabase>
    with _$CivilRegistryDaoMixin {
  CivilRegistryDao(super.db);

  // ============================================================================
  // SEARCH OPERATIONS
  // ============================================================================

  /// Search by national ID
  Future<CivilRegistryData?> searchByNationalId(String nationalId) async {
    return await (select(
      civilRegistry,
    )..where((r) => r.nationalId.equals(nationalId))).getSingleOrNull();
  }

  /// Search by name
  Future<List<CivilRegistryData>> searchByName(
    String name, {
    String? governorate,
    int limit = 50,
  }) async {
    final normalized = _normalizeName(name);
    var query = select(civilRegistry)
      ..where((r) => r.fullNameNormalized.like('%$normalized%'));

    if (governorate != null && governorate.isNotEmpty) {
      query = query..where((r) => r.governorate.equals(governorate));
    }

    query = query
      ..orderBy([(r) => OrderingTerm.asc(r.fullName)])
      ..limit(limit);

    return await query.get();
  }

  /// Normalize name for search
  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }
}
