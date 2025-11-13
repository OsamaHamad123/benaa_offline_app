import 'package:drift/drift.dart';
import '../../../../data/db/drift_database.dart';
import '../models/beneficiary_model.dart';

/// 💾 Beneficiary Local Data Source
///
/// Handles all Drift database operations for beneficiaries.
class BeneficiaryLocalDataSource {
  final AppDatabase db;

  const BeneficiaryLocalDataSource(this.db);

  /// Create new beneficiary
  Future<BeneficiaryModel> create(BeneficiariesCompanion companion) async {
    await db.into(db.beneficiaries).insert(companion);
    final data = await (db.select(
      db.beneficiaries,
    )..where((b) => b.id.equals(companion.id.value))).getSingle();
    return BeneficiaryModel.fromDrift(data);
  }

  /// Update beneficiary
  Future<BeneficiaryModel> update(
    String id,
    BeneficiariesCompanion companion,
  ) async {
    await (db.update(
      db.beneficiaries,
    )..where((b) => b.id.equals(id))).write(companion);
    final data = await (db.select(
      db.beneficiaries,
    )..where((b) => b.id.equals(id))).getSingle();
    return BeneficiaryModel.fromDrift(data);
  }

  /// Get beneficiary by ID
  Future<BeneficiaryModel?> getById(String id) async {
    final query = db.select(db.beneficiaries)..where((b) => b.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? BeneficiaryModel.fromDrift(data) : null;
  }

  /// Delete beneficiary
  Future<void> delete(String id) async {
    await (db.delete(db.beneficiaries)..where((b) => b.id.equals(id))).go();
  }

  /// List beneficiaries with filters
  Future<List<BeneficiaryModel>> list({
    String? searchQuery,
    String? category,
    String? gender,
    int? limit,
    int? offset,
  }) async {
    var query = db.select(db.beneficiaries);

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final normalized = _normalizeArabic(searchQuery);
      query.where(
        (b) =>
            b.fullNameNorm.like('%$normalized%') |
            b.nationalId.like('%$searchQuery%') |
            b.phoneNumber.like('%$searchQuery%'),
      );
    }

    if (category != null && category.isNotEmpty) {
      query.where((b) => b.category.equals(category));
    }

    if (gender != null && gender.isNotEmpty) {
      query.where((b) => b.gender.equals(gender));
    }

    // Order by updated date
    query
      ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)])
      ..limit(limit ?? 100, offset: offset ?? 0);

    final results = await query.get();
    return results.map((data) => BeneficiaryModel.fromDrift(data)).toList();
  }

  /// Count beneficiaries
  Future<int> count({String? category}) async {
    final countExpr = db.beneficiaries.id.count();

    var query = db.selectOnly(db.beneficiaries)..addColumns([countExpr]);

    if (category != null && category.isNotEmpty) {
      query.where(db.beneficiaries.category.equals(category));
    }

    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final total = await count();
    final orphans = await count(category: 'orphan');
    final poor = await count(category: 'poor');
    final displaced = await count(category: 'displaced');

    // Count by gender
    final countExpr = db.beneficiaries.id.count();
    final malesQuery = db.selectOnly(db.beneficiaries)
      ..addColumns([countExpr])
      ..where(db.beneficiaries.gender.equals('male'));
    final malesResult = await malesQuery.getSingle();
    final males = malesResult.read(countExpr) ?? 0;

    return {
      'total': total,
      'orphans': orphans,
      'poor': poor,
      'displaced': displaced,
      'males': males,
      'females': total - males,
    };
  }

  /// Normalize Arabic for search
  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase();
  }
}
