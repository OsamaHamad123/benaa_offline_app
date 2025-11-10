import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;

/// Service لإدارة التصنيفات (Taxonomies)
/// يقوم بجلب التصنيفات من API وحفظها في قاعدة البيانات المحلية
class TaxonomyService {
  final ApiClient apiClient;
  final AppDatabase database;

  TaxonomyService({required this.apiClient, required this.database});

  /// جلب التصنيفات من API وحفظها في قاعدة البيانات
  Future<void> syncTaxonomies() async {
    try {
      // جلب آخر تاريخ تحديث من قاعدة البيانات
      final lastUpdate = await _getLastTaxonomyUpdate();

      // جلب التصنيفات من API
      final taxonomiesData = await apiClient.getTaxonomies(
        updatedAfter: lastUpdate,
      );

      // حفظ التصنيفات في قاعدة البيانات
      await _saveTaxonomies(taxonomiesData);
    } catch (e) {
      throw Exception('فشل في مزامنة التصنيفات: $e');
    }
  }

  /// الحصول على آخر تاريخ تحديث للتصنيفات
  Future<DateTime?> _getLastTaxonomyUpdate() async {
    final result =
        await (database.select(database.taxonomies)
              ..orderBy([(t) => drift.OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();

    return result?.updatedAt;
  }

  /// حفظ التصنيفات في قاعدة البيانات
  Future<void> _saveTaxonomies(List<dynamic> taxonomiesData) async {
    for (final item in taxonomiesData) {
      final taxonomy = TaxonomiesCompanion(
        id: drift.Value(item['id'] ?? _generateId(item)),
        group: drift.Value(item['group'] ?? 'unknown'),
        code: drift.Value(item['code'] ?? ''),
        label: drift.Value(item['label'] ?? ''),
        parentId: drift.Value(item['parent_id']),
        sortOrder: drift.Value(item['sort_order'] ?? 0),
        isActive: drift.Value(item['is_active'] ?? true),
        updatedAt: drift.Value(
          item['updated_at'] != null
              ? DateTime.parse(item['updated_at'])
              : DateTime.now(),
        ),
      );

      await database.into(database.taxonomies).insertOnConflictUpdate(taxonomy);
    }
  }

  /// توليد ID فريد للتصنيف
  String _generateId(dynamic item) {
    final group = item['group'] ?? 'unknown';
    final code = item['code'] ?? DateTime.now().millisecondsSinceEpoch;
    return '${group}_$code';
  }

  /// الحصول على تصنيفات حسب المجموعة (group)
  Future<List<Taxonomy>> getTaxonomiesByGroup(String group) async {
    return await (database.select(database.taxonomies)
          ..where((t) => t.group.equals(group) & t.isActive.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// الحصول على المحافظات
  Future<List<Taxonomy>> getGovernorates() async {
    return await getTaxonomiesByGroup('governorate');
  }

  /// الحصول على الفئات
  Future<List<Taxonomy>> getCategories() async {
    return await getTaxonomiesByGroup('category');
  }

  /// الحصول على الحالات الاجتماعية
  Future<List<Taxonomy>> getMaritalStatuses() async {
    return await getTaxonomiesByGroup('marital_status');
  }

  /// الحصول على المستويات التعليمية
  Future<List<Taxonomy>> getEducationLevels() async {
    return await getTaxonomiesByGroup('education_level');
  }

  /// الحصول على الحالات الصحية
  Future<List<Taxonomy>> getHealthStatuses() async {
    return await getTaxonomiesByGroup('health_status');
  }

  /// تحميل التصنيفات من ملف JSON محلي (للاستخدام الأولي أو Fallback)
  Future<void> loadDefaultTaxonomies() async {
    // يمكن تحميل من assets/data/taxonomies_example.json
    // هذا للاستخدام في حالة عدم وجود اتصال بالإنترنت
    final defaultTaxonomies = _getDefaultTaxonomiesData();
    await _saveTaxonomies(defaultTaxonomies);
  }

  /// البيانات الافتراضية للتصنيفات (Fallback)
  List<Map<String, dynamic>> _getDefaultTaxonomiesData() {
    return [
      // Governorates
      {
        'id': 'gov_bgd',
        'group': 'governorate',
        'code': 'BGD',
        'label': 'بغداد',
        'sort_order': 1,
      },
      {
        'id': 'gov_bsr',
        'group': 'governorate',
        'code': 'BSR',
        'label': 'البصرة',
        'sort_order': 2,
      },
      {
        'id': 'gov_nin',
        'group': 'governorate',
        'code': 'NIN',
        'label': 'نينوى',
        'sort_order': 3,
      },
      {
        'id': 'gov_anb',
        'group': 'governorate',
        'code': 'ANB',
        'label': 'الأنبار',
        'sort_order': 4,
      },
      {
        'id': 'gov_dyl',
        'group': 'governorate',
        'code': 'DYL',
        'label': 'ديالى',
        'sort_order': 5,
      },
      {
        'id': 'gov_krb',
        'group': 'governorate',
        'code': 'KRB',
        'label': 'كربلاء',
        'sort_order': 6,
      },
      {
        'id': 'gov_naj',
        'group': 'governorate',
        'code': 'NAJ',
        'label': 'النجف',
        'sort_order': 7,
      },
      {
        'id': 'gov_bbl',
        'group': 'governorate',
        'code': 'BBL',
        'label': 'بابل',
        'sort_order': 8,
      },

      // Categories
      {
        'id': 'cat_orphan',
        'group': 'category',
        'code': 'orphan',
        'label': 'يتيم',
        'sort_order': 1,
      },
      {
        'id': 'cat_poor',
        'group': 'category',
        'code': 'poor',
        'label': 'فقير',
        'sort_order': 2,
      },
      {
        'id': 'cat_widow',
        'group': 'category',
        'code': 'widow',
        'label': 'أرملة',
        'sort_order': 3,
      },
      {
        'id': 'cat_disabled',
        'group': 'category',
        'code': 'disabled',
        'label': 'معاق',
        'sort_order': 4,
      },

      // Marital Status
      {
        'id': 'mar_single',
        'group': 'marital_status',
        'code': 'single',
        'label': 'أعزب',
        'sort_order': 1,
      },
      {
        'id': 'mar_married',
        'group': 'marital_status',
        'code': 'married',
        'label': 'متزوج',
        'sort_order': 2,
      },
      {
        'id': 'mar_divorced',
        'group': 'marital_status',
        'code': 'divorced',
        'label': 'مطلق',
        'sort_order': 3,
      },
      {
        'id': 'mar_widowed',
        'group': 'marital_status',
        'code': 'widowed',
        'label': 'أرمل',
        'sort_order': 4,
      },

      // Education Levels
      {
        'id': 'edu_none',
        'group': 'education_level',
        'code': 'none',
        'label': 'بدون تعليم',
        'sort_order': 1,
      },
      {
        'id': 'edu_primary',
        'group': 'education_level',
        'code': 'primary',
        'label': 'ابتدائي',
        'sort_order': 2,
      },
      {
        'id': 'edu_intermediate',
        'group': 'education_level',
        'code': 'intermediate',
        'label': 'متوسط',
        'sort_order': 3,
      },
      {
        'id': 'edu_secondary',
        'group': 'education_level',
        'code': 'secondary',
        'label': 'ثانوي',
        'sort_order': 4,
      },
      {
        'id': 'edu_bachelor',
        'group': 'education_level',
        'code': 'bachelor',
        'label': 'بكالوريوس',
        'sort_order': 5,
      },

      // Health Status
      {
        'id': 'health_good',
        'group': 'health_status',
        'code': 'good',
        'label': 'جيدة',
        'sort_order': 1,
      },
      {
        'id': 'health_fair',
        'group': 'health_status',
        'code': 'fair',
        'label': 'متوسطة',
        'sort_order': 2,
      },
      {
        'id': 'health_poor',
        'group': 'health_status',
        'code': 'poor',
        'label': 'ضعيفة',
        'sort_order': 3,
      },
      {
        'id': 'health_chronic',
        'group': 'health_status',
        'code': 'chronic',
        'label': 'مرض مزمن',
        'sort_order': 4,
      },
    ];
  }
}

/// Provider لـ TaxonomyService
final taxonomyServiceProvider = Provider<TaxonomyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final database = ref.watch(databaseProvider);

  return TaxonomyService(apiClient: apiClient, database: database);
});

/// Provider للمحافظات
final governoratesProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final service = ref.watch(taxonomyServiceProvider);
  return await service.getGovernorates();
});

/// Provider للفئات
final categoriesProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final service = ref.watch(taxonomyServiceProvider);
  return await service.getCategories();
});

/// Provider للحالات الاجتماعية
final maritalStatusesProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final service = ref.watch(taxonomyServiceProvider);
  return await service.getMaritalStatuses();
});

/// Provider للمستويات التعليمية
final educationLevelsProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final service = ref.watch(taxonomyServiceProvider);
  return await service.getEducationLevels();
});

/// Provider للحالات الصحية
final healthStatusesProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final service = ref.watch(taxonomyServiceProvider);
  return await service.getHealthStatuses();
});
