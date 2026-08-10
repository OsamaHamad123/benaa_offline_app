import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
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
    final id = await db.into(db.beneficiaries).insert(companion);
    final data = await (db.select(
      db.beneficiaries,
    )..where((b) => b.id.equals(id)))
        .getSingle();

    // Log activity
    await _logActivity(
      beneficiaryId: id.toString(),
      activityType: 'create',
      description: 'تم إضافة مستفيد جديد: ${data.fullName}',
    );

    return BeneficiaryModel.fromDrift(data);
  }

  /// Update beneficiary
  Future<BeneficiaryModel> update(
    int id,
    BeneficiariesCompanion companion,
  ) async {
    await (db.update(
      db.beneficiaries,
    )..where((b) => b.id.equals(id)))
        .write(companion);
    final data = await (db.select(
      db.beneficiaries,
    )..where((b) => b.id.equals(id)))
        .getSingle();

    // Log activity
    await _logActivity(
      beneficiaryId: id.toString(),
      activityType: 'update',
      description: 'تم تحديث بيانات المستفيد: ${data.fullName}',
    );

    return BeneficiaryModel.fromDrift(data);
  }

  /// Get beneficiary by ID
  Future<BeneficiaryModel?> getById(int id) async {
    final query = db.select(db.beneficiaries)..where((b) => b.id.equals(id));
    final data = await query.getSingleOrNull();
    return data != null ? BeneficiaryModel.fromDrift(data) : null;
  }

  /// Get beneficiary by National ID
  ///
  /// لا نبتلع الأخطاء: إرجاع null يجب أن يعني "لا يوجد مستفيد" فقط، وليس
  /// "فشل الاستعلام". ابتلاع الخطأ سابقاً كان يجعل فشلاً عابراً أثناء فحص
  /// التكرار يبدو كأن الرقم الوطني غير موجود فيُسمح بإنشاء رقم مكرّر.
  Future<BeneficiaryModel?> getByNationalId(int nationalId) async {
    final query = db.select(db.beneficiaries)
      ..where((b) => b.idNumber.equals(nationalId));
    final data = await query.getSingleOrNull();
    return data != null ? BeneficiaryModel.fromDrift(data) : null;
  }

  /// Delete beneficiary
  Future<void> delete(int id) async {
    await (db.delete(db.beneficiaries)..where((b) => b.id.equals(id))).go();
  }

  /// List beneficiaries with filters
  Future<List<BeneficiaryModel>> list({
    String? searchQuery,
    int? category,
    int? gender,
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
            b.fileIdNumber.like('%$searchQuery%'),
      );
    }

    if (category != null) {
      query.where((b) => b.sectionId.equals(category));
    }

    if (gender != null) {
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
  Future<int> count({int? category}) async {
    final countExpr = db.beneficiaries.id.count();

    var query = db.selectOnly(db.beneficiaries)..addColumns([countExpr]);

    if (category != null) {
      query.where(db.beneficiaries.sectionId.equals(category));
    }

    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final total = await count();
    final orphans = await count(category: 1); // TODO: Use actual category codes
    final poor = await count(category: 2);
    final displaced = await count(category: 3);

    // Count by gender
    final countExpr = db.beneficiaries.id.count();
    final malesQuery = db.selectOnly(db.beneficiaries)
      ..addColumns([countExpr])
      ..where(db.beneficiaries.gender.equals(1)); // 1 = male
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

  /// Log activity helper
  Future<void> _logActivity({
    required String beneficiaryId,
    required String activityType,
    required String description,
  }) async {
    const uuid = Uuid();
    await db.trackingDao.addActivity(
      ActivitiesCompanion.insert(
        id: uuid.v4(),
        beneficiaryId: beneficiaryId,
        userId: 'current_user', // TODO: Get from auth
        activityType: activityType,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }
}
