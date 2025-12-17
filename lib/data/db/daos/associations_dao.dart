import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/associations_table.dart';

part 'associations_dao.g.dart';

/// 🏢 Associations Data Access Object
///
/// يحتوي على جميع عمليات CRUD والاستعلامات الخاصة بالجمعيات ومندوبيهم
@DriftAccessor(tables: [Associations, AssociationRepresentatives])
class AssociationsDao extends DatabaseAccessor<AppDatabase> with _$AssociationsDaoMixin {
  AssociationsDao(super.db);

  // ============================================================================
  // ASSOCIATIONS OPERATIONS
  // ============================================================================

  /// الحصول على جميع الجمعيات النشطة
  Future<List<Association>> getAllActiveAssociations() async {
    return await (select(associations)
          ..where((a) => a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.name)]))
        .get();
  }

  /// الحصول على جميع الجمعيات (نشطة + معطلة)
  Future<List<Association>> getAllAssociations() async {
    return await (select(associations)..orderBy([(a) => OrderingTerm.asc(a.name)])).get();
  }

  /// الحصول على جمعية بواسطة ID
  Future<Association?> getAssociationById(String id) async {
    return await (select(associations)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// البحث عن جمعيات بواسطة الاسم
  Future<List<Association>> searchAssociations(String query) async {
    final normalized = query.trim().toLowerCase();
    return await (select(associations)
          ..where(
            (a) => a.name.lower().like('%$normalized%') | a.shortName.lower().like('%$normalized%'),
          )
          ..orderBy([(a) => OrderingTerm.asc(a.name)]))
        .get();
  }

  /// إضافة جمعية جديدة
  Future<void> addAssociation(AssociationsCompanion association) async {
    await into(associations).insert(association);
  }

  /// تحديث بيانات جمعية
  Future<bool> updateAssociation(AssociationsCompanion association) async {
    return await (update(associations)..where((a) => a.id.equals(association.id.value))).write(association) > 0;
  }

  /// حذف جمعية (Soft Delete - تعطيل فقط)
  Future<int> deactivateAssociation(String id) async {
    return await (update(associations)..where((a) => a.id.equals(id))).write(
      AssociationsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// حذف جمعية نهائياً (Hard Delete - استخدام حذر!)
  Future<int> deleteAssociation(String id) async {
    return await (delete(associations)..where((a) => a.id.equals(id))).go();
  }

  /// عدد الجمعيات النشطة
  Future<int> getActiveAssociationsCount() async {
    final query = selectOnly(associations)
      ..addColumns([associations.id.count()])
      ..where(associations.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(associations.id.count()) ?? 0;
  }

  /// الحصول على جمعيات تحتاج مزامنة
  Future<List<Association>> getAssociationsNeedingSync() async {
    return await (select(associations)..where((a) => a.syncState.equals('pending'))).get();
  }

  /// تحديث حالة المزامنة
  Future<int> updateSyncState({
    required String id,
    required String syncState,
    int? serverId,
  }) async {
    return await (update(associations)..where((a) => a.id.equals(id))).write(
      AssociationsCompanion(
        syncState: Value(syncState),
        serverId: serverId != null ? Value(serverId) : const Value.absent(),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // REPRESENTATIVES OPERATIONS
  // ============================================================================

  /// الحصول على جميع المندوبين
  Future<List<Representative>> getAllRepresentatives() async {
    return await (select(associationRepresentatives)..orderBy([(r) => OrderingTerm.asc(r.name)])).get();
  }

  /// الحصول على مندوب بواسطة ID
  Future<Representative?> getRepresentativeById(String id) async {
    return await (select(associationRepresentatives)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// البحث عن مندوب بواسطة الاسم
  Future<List<Representative>> searchRepresentatives(String query) async {
    final normalized = query.trim().toLowerCase();
    return await (select(associationRepresentatives)
          ..where((r) => r.name.lower().like('%$normalized%'))
          ..orderBy([(r) => OrderingTerm.asc(r.name)]))
        .get();
  }

  /// إضافة مندوب جديد
  Future<void> addRepresentative(
    AssociationRepresentativesCompanion representative,
  ) async {
    await into(associationRepresentatives).insert(representative);
  }

  /// تحديث بيانات مندوب
  Future<bool> updateRepresentative(AssociationRepresentativesCompanion representative) async {
    return await (update(associationRepresentatives)..where((r) => r.id.equals(representative.id.value)))
            .write(representative) >
        0;
  }

  /// حذف مندوب
  Future<int> deleteRepresentative(String id) async {
    return await (delete(associationRepresentatives)..where((r) => r.id.equals(id))).go();
  }

  /// عدد المندوبين
  Future<int> getRepresentativesCount() async {
    final query = selectOnly(associationRepresentatives)..addColumns([associationRepresentatives.id.count()]);
    final result = await query.getSingle();
    return result.read(associationRepresentatives.id.count()) ?? 0;
  }

  // ============================================================================
  // JOIN OPERATIONS (الجمعية مع المندوب)
  // ============================================================================

  /// الحصول على جمعية مع معلومات المندوب
  Future<AssociationWithRepresentative?> getAssociationWithRepresentative(
    String associationId,
  ) async {
    final query = select(associations).join([
      leftOuterJoin(
        associationRepresentatives,
        associationRepresentatives.id.equalsExp(associations.representativeId),
      ),
    ])
      ..where(associations.id.equals(associationId));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return AssociationWithRepresentative(
      association: result.readTable(associations),
      representative: result.readTableOrNull(associationRepresentatives),
    );
  }

  /// الحصول على جميع الجمعيات مع معلومات المندوبين
  Future<List<AssociationWithRepresentative>> getAllAssociationsWithReps() async {
    final query = select(associations).join([
      leftOuterJoin(
        associationRepresentatives,
        associationRepresentatives.id.equalsExp(associations.representativeId),
      ),
    ])
      ..where(associations.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(associations.name)]);

    final results = await query.get();

    return results.map((row) {
      return AssociationWithRepresentative(
        association: row.readTable(associations),
        representative: row.readTableOrNull(associationRepresentatives),
      );
    }).toList();
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

/// كائن مساعد للجمعية مع المندوب
class AssociationWithRepresentative {
  final Association association;
  final Representative? representative;

  const AssociationWithRepresentative({
    required this.association,
    this.representative,
  });

  String get representativeName => representative?.name ?? 'لا يوجد';
}
