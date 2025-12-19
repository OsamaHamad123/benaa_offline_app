import 'package:drift/drift.dart';

import '../drift_database.dart';
import '../tables/taxonomies_table.dart';

part 'taxonomies_dao.g.dart';

/// 🗃️ Taxonomy DAO - Data Access Object for Taxonomies
///
/// يوفر عمليات CRUD + عمليات خاصة بالتصنيفات
@DriftAccessor(tables: [Taxonomies])
class TaxonomiesDao extends DatabaseAccessor<AppDatabase>
    with _$TaxonomiesDaoMixin {
  TaxonomiesDao(super.db);

  // ═══════════════════════════════════════════════════════════════════════
  // 📖 READ Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على جميع التصنيفات من مجموعة معينة
  ///
  /// [group] المجموعة ('category', 'marital_status', etc.)
  /// [activeOnly] فقط التصنيفات النشطة (افتراضي: true)
  ///
  /// Returns: قائمة التصنيفات مرتبة حسب sortOrder
  Future<List<Taxonomy>> getByGroup(
    String group, {
    bool activeOnly = true,
  }) async {
    final query = select(taxonomies)
      ..where((t) => t.group.equals(group))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }

    return query.get();
  }

  /// الحصول على تصنيف واحد بال ID
  Future<Taxonomy?> getById(String id) async {
    return (select(
      taxonomies,
    )..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// الحصول على تصنيف واحد بالـ code
  ///
  /// [group] المجموعة
  /// [code] الكود
  Future<Taxonomy?> getByCode(String group, String code) async {
    return (select(taxonomies)
          ..where((t) => t.group.equals(group) & t.code.equals(code)))
        .getSingleOrNull();
  }

  /// الحصول على التصنيفات الفرعية
  ///
  /// [parentId] معرف العنصر الأب
  Future<List<Taxonomy>> getChildren(String parentId) async {
    return (select(taxonomies)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// الحصول على جميع المجموعات الموجودة
  Future<List<String>> getAllGroups() async {
    final query = selectOnly(taxonomies, distinct: true)
      ..addColumns([taxonomies.group]);

    final results = await query.get();
    return results.map((row) => row.read(taxonomies.group)!).toList();
  }

  /// عدد التصنيفات في مجموعة
  Future<int> getCountByGroup(String group) async {
    final query = selectOnly(taxonomies)
      ..addColumns([taxonomies.id.count()])
      ..where(taxonomies.group.equals(group));

    final result = await query.getSingle();
    return result.read(taxonomies.id.count()) ?? 0;
  }

  /// آخر تحديث لمجموعة معينة
  ///
  /// [group] المجموعة
  ///
  /// Returns: تاريخ آخر تحديث (null إذا فارغة)
  Future<DateTime?> getLastUpdate(String group) async {
    final query = selectOnly(taxonomies)
      ..addColumns([taxonomies.updatedAt.max()])
      ..where(taxonomies.group.equals(group));

    final result = await query.getSingleOrNull();
    return result?.read(taxonomies.updatedAt.max());
  }

  /// الحصول على جميع التصنيفات (للنسخ الاحتياطي)
  Future<List<Taxonomy>> getAllTaxonomies() => select(taxonomies).get();

  /// Stream للتصنيفات من مجموعة معينة (reactive)
  Stream<List<Taxonomy>> watchByGroup(String group, {bool activeOnly = true}) {
    final query = select(taxonomies)
      ..where((t) => t.group.equals(group))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }

    return query.watch();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✏️ WRITE Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// إضافة تصنيف واحد
  Future<int> insertTaxonomy(TaxonomiesCompanion taxonomy) {
    return into(taxonomies).insert(taxonomy);
  }

  /// إضافة أو تحديث تصنيف (UPSERT)
  ///
  /// إذا كان ID موجود، يتم التحديث، وإلا يتم الإضافة
  Future<void> upsertTaxonomy(TaxonomiesCompanion taxonomy) {
    return into(taxonomies).insertOnConflictUpdate(taxonomy);
  }

  /// إضافة أو تحديث عدة تصنيفات دفعة واحدة (BULK UPSERT)
  ///
  /// [taxonomiesList] قائمة التصنيفات
  ///
  /// هذه العملية الأساسية للمزامنة من السيرفر
  Future<void> upsertBatch(List<TaxonomiesCompanion> taxonomiesList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(taxonomies, taxonomiesList);
    });
  }

  /// تحديث تصنيف موجود
  Future<bool> updateTaxonomy(Taxonomy taxonomy) {
    return update(taxonomies).replace(taxonomy);
  }

  /// تحديث حالة التفعيل
  Future<int> setActiveStatus(String id, bool isActive) {
    return (update(taxonomies)..where((t) => t.id.equals(id))).write(
      TaxonomiesCompanion(isActive: Value(isActive)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🗑️ DELETE Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// حذف تصنيف واحد
  Future<int> deleteTaxonomy(String id) {
    return (delete(taxonomies)..where((t) => t.id.equals(id))).go();
  }

  /// حذف جميع تصنيفات مجموعة معينة
  ///
  /// [group] المجموعة المراد حذفها
  ///
  /// ⚠️ استخدم بحذر - يستخدم عادة قبل المزامنة الكاملة
  Future<int> deleteByGroup(String group) {
    return (delete(taxonomies)..where((t) => t.group.equals(group))).go();
  }

  /// حذف جميع التصنيفات
  ///
  /// ⚠️ استخدم بحذر - عادة عند إعادة تعيين التطبيق
  Future<int> deleteAll() {
    return delete(taxonomies).go();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 SYNC Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// مزامنة تصنيفات من السيرفر (Replace Strategy)
  ///
  /// [group] المجموعة
  /// [newTaxonomies] التصنيفات الجديدة من السيرفر
  ///
  /// يحذف القديمة ويضيف الجديدة (أفضل للتصنيفات لأنها قليلة)
  Future<void> syncReplaceGroup(
    String group,
    List<TaxonomiesCompanion> newTaxonomies,
  ) async {
    await transaction(() async {
      // 1. حذف القديمة
      await deleteByGroup(group);

      // 2. إضافة الجديدة
      await upsertBatch(newTaxonomies);
    });
  }

  /// مزامنة تصنيفات من السيرفر (Merge Strategy)
  ///
  /// [newTaxonomies] التصنيفات الجديدة من السيرفر
  ///
  /// يدمج مع الموجودة (يحدث الموجودة ويضيف الجديدة)
  Future<void> syncMerge(List<TaxonomiesCompanion> newTaxonomies) async {
    await upsertBatch(newTaxonomies);
  }

  /// التحقق من الحاجة للمزامنة
  ///
  /// [group] المجموعة
  /// [serverLastUpdate] آخر تحديث في السيرفر
  ///
  /// Returns: true إذا كانت البيانات المحلية قديمة
  Future<bool> needsSync(String group, DateTime serverLastUpdate) async {
    final localLastUpdate = await getLastUpdate(group);

    // إذا فارغة محلياً، نحتاج المزامنة
    if (localLastUpdate == null) return true;

    // إذا السيرفر أحدث، نحتاج المزامنة
    return serverLastUpdate.isAfter(localLastUpdate);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔍 SEARCH & FILTER Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// البحث في التصنيفات
  ///
  /// [query] نص البحث
  /// [group] المجموعة (اختياري)
  Future<List<Taxonomy>> search(String query, {String? group}) async {
    final searchQuery = select(taxonomies)
      ..where((t) => t.label.like('%$query%') | t.code.like('%$query%'))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    if (group != null) {
      searchQuery.where((t) => t.group.equals(group));
    }

    return searchQuery.get();
  }

  /// تصفية التصنيفات بشروط متعددة
  ///
  /// [group] المجموعة (اختياري)
  /// [isActive] حالة التفعيل (اختياري)
  /// [hasParent] فقط التي لها أب (اختياري)
  Future<List<Taxonomy>> filter({
    String? group,
    bool? isActive,
    bool? hasParent,
  }) async {
    final query = select(taxonomies)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    if (group != null) {
      query.where((t) => t.group.equals(group));
    }

    if (isActive != null) {
      query.where((t) => t.isActive.equals(isActive));
    }

    if (hasParent != null) {
      if (hasParent) {
        query.where((t) => t.parentId.isNotNull());
      } else {
        query.where((t) => t.parentId.isNull());
      }
    }

    return query.get();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 STATISTICS Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// إحصائيات التصنيفات
  Future<Map<String, int>> getStatistics() async {
    final groups = await getAllGroups();
    final stats = <String, int>{};

    for (final group in groups) {
      stats[group] = await getCountByGroup(group);
    }

    stats['total'] = stats.values.fold(0, (sum, count) => sum + count);

    return stats;
  }
}
