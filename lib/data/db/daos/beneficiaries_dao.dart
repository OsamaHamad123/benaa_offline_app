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

  /// Count beneficiaries by category (section_id)
  Future<int> countBeneficiariesByCategory(int sectionId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE section_id = ?',
      variables: [Variable.withInt(sectionId)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries count by province (governorate)
  Future<Map<String, int>> getBeneficiariesCountByGovernorate() async {
    final results = await customSelect(
      'SELECT province, COUNT(*) as count FROM beneficiaries WHERE province IS NOT NULL GROUP BY province',
      readsFrom: {beneficiaries},
    ).get();

    return Map.fromEntries(
      results.map(
        (row) => MapEntry(
          row.read<int>('province').toString(),
          row.read<int>('count'),
        ),
      ),
    );
  }

  /// Get beneficiaries with pagination (Performance optimized)
  Future<List<Beneficiary>> getBeneficiariesPaginated({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    int? sectionId,
    int? gender,
  }) async {
    var query = select(beneficiaries)
      ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
      ..limit(limit, offset: offset);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final normalized = searchQuery.toLowerCase();
      query.where(
        (b) =>
            b.fullName.lower().contains(normalized) |
            b.idNumber.cast<String>().contains(searchQuery) |
            (b.fileIdNumber.isNotNull() & b.fileIdNumber.contains(searchQuery)),
      );
    }

    if (sectionId != null) {
      query.where((b) => b.sectionId.equals(sectionId));
    }

    if (gender != null) {
      query.where((b) => b.gender.equals(gender));
    }

    return query.get();
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

  /// Count beneficiaries by governorate (province)
  Future<int> countBeneficiariesByProvince(int province) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE province = ?',
      variables: [Variable.withInt(province)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries count by governorate (province - for geographic distribution)
  Future<Map<int, int>> getBeneficiariesCountByProvince() async {
    final results = await customSelect(
      '''SELECT province, COUNT(*) as count 
         FROM beneficiaries 
         WHERE province IS NOT NULL
         GROUP BY province 
         ORDER BY count DESC''',
      readsFrom: {beneficiaries},
    ).get();

    return {
      for (final row in results)
        row.read<int>('province'): row.read<int>('count'),
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
  Future<Beneficiary?> getBeneficiaryById(int id) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  /// Get beneficiary by server ID
  Future<Beneficiary?> getBeneficiaryByServerId(int serverId) async {
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
    int id,
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
  Future<void> deleteBeneficiary(int id) async {
    await (delete(beneficiaries)..where((b) => b.id.equals(id))).go();
  }

  /// Batch delete beneficiaries (optimized with transaction)
  Future<int> batchDeleteBeneficiaries(List<int> ids) async {
    if (ids.isEmpty) return 0;

    return await transaction(() async {
      int deletedCount = 0;

      // Delete in batches of 100 for optimal performance
      const batchSize = 100;
      for (int i = 0; i < ids.length; i += batchSize) {
        final batch = ids.skip(i).take(batchSize).toList();
        final result = await (delete(
          beneficiaries,
        )..where((b) => b.id.isIn(batch))).go();
        deletedCount += result;
      }

      return deletedCount;
    });
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
    final isNumeric = int.tryParse(query.trim()) != null;

    return await (select(beneficiaries)..where((b) {
          var condition =
              b.fullNameNorm.like('%$normalized%') |
              b.fileIdNumber.like('%$normalized%');

          // إذا كان رقم، ابحث في id_number أيضاً
          if (isNumeric) {
            condition =
                condition | b.idNumber.cast<String>().contains(query.trim());
          }

          return condition;
        }))
        .get();
  }

  /// Advanced search with filters
  Future<List<Beneficiary>> searchBeneficiariesFiltered({
    String query = '',
    int? category,
    int? governorate,
    int limit = 50,
    int offset = 0,
  }) async {
    final normalized = query.trim().toLowerCase();

    var selectQuery = select(beneficiaries);

    selectQuery = selectQuery
      ..where((b) {
        Expression<bool> condition = const Constant(true);

        // Search filter (search in fullName, fileIdNumber, and idNumber)
        if (normalized.isNotEmpty) {
          final isNumeric = int.tryParse(query.trim()) != null;
          var searchCondition =
              b.fullNameNorm.like('%$normalized%') |
              b.fileIdNumber.like('%$normalized%');

          // إذا كان رقم، ابحث في id_number
          if (isNumeric) {
            searchCondition =
                searchCondition |
                b.idNumber.cast<String>().contains(query.trim());
          }

          condition = condition & searchCondition;
        }

        // Category filter (section_id)
        if (category != null) {
          condition = condition & b.sectionId.equals(category);
        } // Province filter
        if (governorate != null) {
          condition = condition & b.province.equals(governorate);
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

  /// Count beneficiaries with poor health status (code 5)
  Future<int> countBeneficiariesWithPoorHealth() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE health_status = ?',
      variables: [Variable.withInt(5)], // 5 = poor health
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get beneficiaries with poor health (health_status code 5 = poor)
  Future<List<Beneficiary>> getBeneficiariesWithPoorHealth({
    int limit = 50,
  }) async {
    return await (select(beneficiaries)
          ..where((b) => b.healthStatus.equals(5)) // 5 = poor health
          ..limit(limit))
        .get();
  }

  /// Count beneficiaries with disabilities (special needs > 0)
  Future<int> countDisabledBeneficiaries() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE number_of_people_with_special_needs > 0',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Alias for countDisabledBeneficiaries (used by dashboard)
  Future<int> countBeneficiariesWithDisabilities() async {
    return countDisabledBeneficiaries();
  }

  /// Get beneficiaries with disabilities (special needs > 0)
  Future<List<Beneficiary>> getBeneficiariesWithDisabilities({
    int limit = 50,
  }) async {
    return await (select(beneficiaries)
          ..where((b) => b.numberOfPeopleWithSpecialNeeds.isBiggerThanValue(0))
          ..limit(limit))
        .get();
  }

  // ============================================================================
  // MAINTENANCE - صيانة
  // ============================================================================

  /// تحديث full_name_norm لجميع السجلات (يُنفذ مرة واحدة بعد التحديث)
  Future<int> updateAllFullNameNorm() async {
    // تحديث جميع السجلات
    await customStatement('''
      UPDATE beneficiaries 
      SET full_name_norm = LOWER(
        TRIM(
          COALESCE(first_name, '') || ' ' || 
          COALESCE(father_name, '') || ' ' || 
          COALESCE(grand_father_name, '') || ' ' || 
          COALESCE(family_name, '')
        )
      )
      WHERE full_name_norm IS NULL 
         OR full_name_norm = '' 
         OR full_name_norm = ' '
    ''');

    // إرجاع عدد السجلات بعد التحديث
    final total = await countBeneficiaries();
    return total;
  }

  /// فحص عدد السجلات التي تحتاج تحديث full_name_norm
  Future<int> countRecordsNeedingFullNameNormUpdate() async {
    final result = await customSelect(
      '''SELECT COUNT(*) as count 
         FROM beneficiaries 
         WHERE full_name_norm IS NULL 
            OR full_name_norm = '' 
            OR full_name_norm = ' ' ''',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }
}
