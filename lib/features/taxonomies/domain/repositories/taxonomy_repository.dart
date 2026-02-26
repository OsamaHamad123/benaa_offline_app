import 'package:benaa_offline_app/core/error_handling/result.dart';

import '../entities/taxonomy.dart';
import '../entities/taxonomy_group.dart';

/// 📦 Taxonomy Repository Interface
///
/// واجهة Repository للتصنيفات - تتبع مبدأ Dependency Inversion
/// الـ Domain Layer لا تعرف شيء عن التنفيذ الفعلي (API, Database)
abstract class TaxonomyRepository {
  // ===========================
  // 📖 READ OPERATIONS
  // ===========================

  /// الحصول على جميع التصنيفات
  Future<Result<List<Taxonomy>>> getAllTaxonomies();

  /// الحصول على التصنيفات حسب المجموعة
  Future<Result<List<Taxonomy>>> getTaxonomiesByGroup(TaxonomyGroup group);

  /// الحصول على تصنيف واحد بالـ ID
  Future<Result<Taxonomy>> getTaxonomyById(String id);

  /// الحصول على تصنيف بالكود والمجموعة
  Future<Result<Taxonomy>> getTaxonomyByCode(TaxonomyGroup group, String code);

  /// البحث في التصنيفات
  Future<Result<List<Taxonomy>>> searchTaxonomies(String query);

  /// الحصول على التصنيفات الفرعية (children)
  Future<Result<List<Taxonomy>>> getChildTaxonomies(String parentId);

  /// الحصول على إحصائيات التصنيفات
  Future<Result<TaxonomyStatistics>> getStatistics();

  // ===========================
  // ✏️ WRITE OPERATIONS (CRUD)
  // ===========================

  /// إنشاء تصنيف جديد
  Future<Result<Taxonomy>> createTaxonomy(Taxonomy taxonomy);

  /// تحديث تصنيف
  Future<Result<Taxonomy>> updateTaxonomy(Taxonomy taxonomy);

  /// حذف تصنيف (soft delete)
  Future<Result<void>> deleteTaxonomy(String id);

  /// حذف تصنيف نهائياً (hard delete)
  Future<Result<void>> permanentlyDeleteTaxonomy(String id);

  /// استعادة تصنيف محذوف
  Future<Result<Taxonomy>> restoreTaxonomy(String id);

  /// إنشاء أو تحديث مجموعة تصنيفات
  Future<Result<int>> upsertTaxonomies(List<Taxonomy> taxonomies);

  /// إنشاء عدة تصنيفات دفعة واحدة
  Future<Result<List<Taxonomy>>> createTaxonomiesBatch(
    TaxonomyGroup group,
    List<String> names,
  );

  /// تحديث عدة تصنيفات دفعة واحدة (id -> name)
  Future<Result<List<Taxonomy>>> updateTaxonomiesBatch(
    TaxonomyGroup group,
    Map<String, String> updates,
  );

  /// حذف عدة تصنيفات دفعة واحدة
  Future<Result<List<String>>> deleteTaxonomiesBatch(
    TaxonomyGroup group,
    List<String> ids,
  );

  // ===========================
  // 🔄 SYNC OPERATIONS
  // ===========================

  /// مزامنة التصنيفات من السيرفر
  Future<Result<TaxonomySyncResult>> syncFromServer();

  /// مزامنة مجموعة معينة فقط
  Future<Result<TaxonomySyncResult>> syncGroupFromServer(TaxonomyGroup group);

  /// الحصول على آخر وقت مزامنة
  Future<Result<DateTime?>> getLastSyncTime();

  /// تحديث وقت المزامنة
  Future<Result<void>> updateLastSyncTime(DateTime time);

  /// إعادة تعيين التصنيفات (مسح الكل وإعادة التحميل)
  Future<Result<TaxonomySyncResult>> resetAndSync();

  // ===========================
  // 🔍 VALIDATION
  // ===========================

  /// التحقق من وجود تصنيف
  Future<bool> exists(String id);

  /// التحقق من صلاحية كود التصنيف
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId});

  // ===========================
  // 📊 CACHE OPERATIONS
  // ===========================

  /// مسح الكاش المحلي
  Future<Result<void>> clearLocalCache();

  /// تحديث الكاش
  Future<Result<void>> refreshCache();
}

/// 🎯 Taxonomy Filter - فلترة التصنيفات
class TaxonomyFilter {
  /// المجموعة
  final TaxonomyGroup? group;

  /// نشط فقط
  final bool? isActive;

  /// البحث النصي
  final String? searchQuery;

  /// الأب (للتصنيفات الهرمية)
  final String? parentId;

  /// ترتيب
  final TaxonomySortBy sortBy;

  /// اتجاه الترتيب
  final bool ascending;

  /// الحد الأقصى للنتائج
  final int? limit;

  /// التخطي (للـ pagination)
  final int? offset;

  const TaxonomyFilter({
    this.group,
    this.isActive = true,
    this.searchQuery,
    this.parentId,
    this.sortBy = TaxonomySortBy.sortOrder,
    this.ascending = true,
    this.limit,
    this.offset,
  });

  TaxonomyFilter copyWith({
    TaxonomyGroup? group,
    bool? isActive,
    String? searchQuery,
    String? parentId,
    TaxonomySortBy? sortBy,
    bool? ascending,
    int? limit,
    int? offset,
  }) {
    return TaxonomyFilter(
      group: group ?? this.group,
      isActive: isActive ?? this.isActive,
      searchQuery: searchQuery ?? this.searchQuery,
      parentId: parentId ?? this.parentId,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

/// 📊 ترتيب التصنيفات
enum TaxonomySortBy {
  /// ترتيب يدوي
  sortOrder,

  /// أبجدياً
  label,

  /// الكود
  code,

  /// تاريخ الإنشاء
  createdAt,

  /// تاريخ التحديث
  updatedAt,
}
