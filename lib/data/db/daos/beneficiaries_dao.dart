import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/beneficiaries_table.dart';

part 'beneficiaries_dao.g.dart';

/// Beneficiaries Data Access Object
/// يحتوي على جميع عمليات CRUD والاستعلامات الخاصة بالمستفيدين
@DriftAccessor(tables: [Beneficiaries])
class BeneficiariesDao extends DatabaseAccessor<AppDatabase>
    with _$BeneficiariesDaoMixin {
  BeneficiariesDao(super.db);

  // ============================================================================
  // STATISTICS - الإحصائيات
  // ============================================================================

  /// Count total beneficiaries
  Future<int> countBeneficiaries() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Count pending sync beneficiaries
  Future<int> countPendingSync() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE sync_state = ?',
      variables: [Variable.withString('pending')],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Count beneficiaries by category
  Future<int> countBeneficiariesByCategory(String category) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE category = ?',
      variables: [Variable.withString(category)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Count incomplete beneficiaries (missing phone or address)
  Future<int> countIncompleteBeneficiaries() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries '
      'WHERE phone_number IS NULL OR phone_number = \'\' '
      'OR address IS NULL OR address = \'\'',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Count beneficiaries by governorate
  Future<int> countBeneficiariesByGovernorate(String governorate) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE governorate = ?',
      variables: [Variable.withString(governorate)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries count by governorate (for geographic distribution)
  Future<Map<String, int>> getBeneficiariesCountByGovernorate() async {
    final results = await customSelect(
      '''SELECT governorate, COUNT(*) as count 
         FROM beneficiaries 
         WHERE governorate IS NOT NULL AND governorate != \'\'
         GROUP BY governorate 
         ORDER BY count DESC''',
      readsFrom: {beneficiaries},
    ).get();

    return {
      for (final row in results)
        row.read<String>('governorate'): row.read<int>('count'),
    };
  }

  /// Count new beneficiaries today
  Future<int> countNewBeneficiariesToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE created_at >= ?',
      variables: [Variable.withDateTime(startOfDay)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  // ============================================================================
  // CRUD OPERATIONS - عمليات CRUD الأساسية
  // ============================================================================

  /// Get all beneficiaries
  Future<List<Beneficiary>> getAllBeneficiaries() async {
    return await select(beneficiaries).get();
  }

  /// Get beneficiary by ID
  Future<Beneficiary?> getBeneficiaryById(String id) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  /// Get beneficiary by server ID
  Future<Beneficiary?> getBeneficiaryByServerId(String serverId) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.serverId.equals(serverId))).getSingleOrNull();
  }

  /// Insert beneficiary
  Future<void> insertBeneficiary(BeneficiariesCompanion beneficiary) async {
    await into(beneficiaries).insert(beneficiary);
  }

  /// Update beneficiary using Companion
  Future<void> updateBeneficiaryCompanion(
    String id,
    BeneficiariesCompanion beneficiary,
  ) async {
    await (update(
      beneficiaries,
    )..where((b) => b.id.equals(id))).write(beneficiary);
  }

  /// Update beneficiary
  Future<void> updateBeneficiary(Beneficiary beneficiary) async {
    await update(beneficiaries).replace(beneficiary);
  }

  /// Delete beneficiary
  Future<void> deleteBeneficiary(String id) async {
    await (delete(beneficiaries)..where((b) => b.id.equals(id))).go();
  }

  // ============================================================================
  // SEARCH OPERATIONS - عمليات البحث
  // ============================================================================

  /// Simple search beneficiaries
  Future<List<Beneficiary>> searchBeneficiaries(String query) async {
    if (query.isEmpty) {
      return await getAllBeneficiaries();
    }

    final normalized = query.trim().toLowerCase();
    return await (select(beneficiaries)..where(
          (b) =>
              b.fullNameNorm.like('%$normalized%') |
              b.nationalId.like('%$normalized%') |
              b.fileNo.like('%$normalized%'),
        ))
        .get();
  }

  /// Advanced search with filters
  Future<List<Beneficiary>> searchBeneficiariesFiltered({
    String query = '',
    String? category,
    String? governorate,
    int limit = 50,
    int offset = 0,
  }) async {
    final normalized = query.trim().toLowerCase();

    var selectQuery = select(beneficiaries);

    selectQuery = selectQuery
      ..where((b) {
        Expression<bool> condition = const Constant(true);

        // Search filter
        if (normalized.isNotEmpty) {
          condition =
              condition &
              (b.fullNameNorm.like('%$normalized%') |
                  b.nationalId.like('%$normalized%') |
                  b.fileNo.like('%$normalized%'));
        }

        // Category filter
        if (category != null && category != 'all') {
          condition = condition & b.category.equals(category);
        }

        // Governorate filter
        if (governorate != null && governorate != 'all') {
          condition = condition & b.governorate.equals(governorate);
        }

        return condition;
      });

    selectQuery = selectQuery
      ..orderBy([(b) => OrderingTerm.asc(b.fullName)])
      ..limit(limit, offset: offset);

    return await selectQuery.get();
  }

  // ============================================================================
  // SPECIAL QUERIES - استعلامات خاصة
  // ============================================================================

  /// Count beneficiaries with no recent visits
  Future<int> countBeneficiariesWithNoRecentVisits(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final result = await customSelect(
      '''SELECT COUNT(*) as count 
         FROM beneficiaries b 
         WHERE NOT EXISTS (
           SELECT 1 FROM visits v 
           WHERE v.beneficiary_id = b.id 
           AND v.visit_date >= ?
         )''',
      variables: [Variable.withDateTime(cutoffDate)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries with no recent visits
  Future<List<Beneficiary>> getBeneficiariesWithNoRecentVisits(
    int days, {
    int limit = 50,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final results = await customSelect(
      '''SELECT b.* FROM beneficiaries b 
         WHERE NOT EXISTS (
           SELECT 1 FROM visits v 
           WHERE v.beneficiary_id = b.id 
           AND v.visit_date >= ?
         )
         ORDER BY b.updated_at DESC
         LIMIT ?''',
      variables: [Variable.withDateTime(cutoffDate), Variable.withInt(limit)],
      readsFrom: {beneficiaries},
    ).get();

    return results.map((row) => beneficiaries.map(row.data)).toList();
  }

  /// Count beneficiaries with poor health status
  Future<int> countBeneficiariesWithPoorHealth() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE health_status = ?',
      variables: [Variable.withString('poor')],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries with poor health
  Future<List<Beneficiary>> getBeneficiariesWithPoorHealth({
    int limit = 50,
  }) async {
    return await (select(beneficiaries)
          ..where((b) => b.healthStatus.equals('poor'))
          ..limit(limit))
        .get();
  }

  /// Count beneficiaries with disabilities
  Future<int> countBeneficiariesWithDisabilities() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE has_disability = 1',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries with disabilities
  Future<List<Beneficiary>> getBeneficiariesWithDisabilities({
    int limit = 50,
  }) async {
    return await (select(beneficiaries)
          ..where((b) => b.hasDisability.equals(true))
          ..limit(limit))
        .get();
  }
}
