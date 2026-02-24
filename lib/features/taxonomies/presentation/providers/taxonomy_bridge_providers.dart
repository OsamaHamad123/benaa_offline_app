/// 🌉 Taxonomy Bridge Providers
///
/// يربط نظام التصنيفات الجديد (Clean Architecture) مع
/// Drift Database الموجود للتوافق مع باقي التطبيق
///
/// هذا الملف يوفر providers تستخدم النظام القديم (Drift)
/// مع واجهة النظام الجديد (TaxonomyGroup enum)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart' as drift_db show Taxonomy;
import '../../domain/entities/taxonomy.dart' as domain;
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../../../core/sync/presentation/providers/sync_providers.dart' as sync_providers;

// ═══════════════════════════════════════════════════════════════
// 🌉 Bridge Providers - تربط النظام الجديد مع Drift
// ═══════════════════════════════════════════════════════════════

/// تحويل من Drift Entity إلى Domain Entity
domain.Taxonomy? _convertFromDrift(drift_db.Taxonomy driftTaxonomy) {
  if (driftTaxonomy.code.startsWith('__placeholder__')) {
    return null;
  }

  final normalizedGroupValue = TaxonomyGroup.normalizeValue(driftTaxonomy.group);
  final resolvedGroup = TaxonomyGroup.fromString(normalizedGroupValue);
  if (resolvedGroup == null) {
    return null;
  }

  return domain.Taxonomy(
    id: driftTaxonomy.id,
    group: resolvedGroup,
    code: driftTaxonomy.code,
    label: driftTaxonomy.label,
    parentId: driftTaxonomy.parentId,
    sortOrder: driftTaxonomy.sortOrder,
    isActive: driftTaxonomy.isActive,
    metadata: const {},
    createdAt: driftTaxonomy.updatedAt,
    updatedAt: driftTaxonomy.updatedAt,
    deletedAt: driftTaxonomy.isActive ? null : driftTaxonomy.updatedAt,
  );
}

/// 📦 Categories (فئات المستفيدين)
final bridgeCategoriesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.categoriesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 👫 Genders (الجنس)
final bridgeGendersProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.gendersProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 💒 Marital Statuses (الحالة الاجتماعية)
final bridgeMaritalStatusesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.maritalStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 📚 Education Levels (المستوى التعليمي)
final bridgeEducationLevelsProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.educationLevelsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 🏥 Health Statuses (الحالة الصحية)
final bridgeHealthStatusesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.healthStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 🏠 Housing Types (نوع السكن)
final bridgeHousingTypesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.housingTypesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 🏘️ Housing Statuses (حالة السكن)
final bridgeHousingStatusesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.housingStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 🗺️ Governorates (المحافظات)
final bridgeGovernoratesProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.governoratesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 👪 Relationships (صلة القرابة)
final bridgeRelationshipsProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.relationshipsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

/// 🧩 Sections (القسم)
final bridgeSectionsProvider = StreamProvider<List<domain.Taxonomy>>((ref) {
  return ref.watch(sync_providers.sectionsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
      );
});

// ═══════════════════════════════════════════════════════════════
// 🔗 Generic Group Provider
// ═══════════════════════════════════════════════════════════════

/// Generic provider للحصول على تصنيفات حسب المجموعة
/// يستخدم Drift Database الموجود
final bridgeTaxonomiesByGroupProvider = StreamProvider.family<List<domain.Taxonomy>, TaxonomyGroup>(
  (ref, group) {
    final db = ref.watch(sync_providers.databaseProvider);
    return db.taxonomiesDao.watchByGroup(group.value).map(
          (list) => list.map(_convertFromDrift).whereType<domain.Taxonomy>().toList(),
        );
  },
);

/// Indexed one-shot taxonomy cache for all groups.
/// يقلل استعلامات قاعدة البيانات المتعددة عند بناء شاشات تحتوي عدة Dropdowns.
final bridgeTaxonomiesIndexOnceProvider = FutureProvider<Map<TaxonomyGroup, List<domain.Taxonomy>>>((ref) async {
  final db = ref.read(sync_providers.databaseProvider);
  final allItems = await db.taxonomiesDao.getAllTaxonomies();

  final index = <TaxonomyGroup, List<domain.Taxonomy>>{
    for (final group in TaxonomyGroup.values) group: <domain.Taxonomy>[],
  };

  for (final row in allItems) {
    final taxonomy = _convertFromDrift(row);
    if (taxonomy == null) continue;
    index[taxonomy.group]!.add(taxonomy);
  }

  for (final group in TaxonomyGroup.values) {
    index[group]!.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  return index;
});

/// One-shot provider للحصول على التصنيفات مرة واحدة بدون stream subscription.
/// يقلل الحمل على UI isolate في الشاشات الثقيلة (مثل نموذج إضافة المستفيد).
final bridgeTaxonomiesByGroupOnceProvider =
    FutureProvider.family<List<domain.Taxonomy>, TaxonomyGroup>((ref, group) async {
  final index = await ref.watch(bridgeTaxonomiesIndexOnceProvider.future);
  return index[group] ?? const <domain.Taxonomy>[];
});

/// One-shot provider with equivalent-group fallback (مثل section/category).
///
/// يضمن أن الحقول المعتمدة على مجموعة canonical لا تبقى فارغة إذا البيانات
/// وصلت في مجموعة مكافئة رسمية من السيرفر.
final bridgeTaxonomiesByGroupResolvedOnceProvider =
    FutureProvider.family<List<domain.Taxonomy>, TaxonomyGroup>((ref, group) async {
  final index = await ref.watch(bridgeTaxonomiesIndexOnceProvider.future);

  final direct = index[group] ?? const <domain.Taxonomy>[];
  if (direct.isNotEmpty) {
    return direct;
  }

  final equivalents = equivalentBeneficiaryTaxonomyGroups[group] ?? const <TaxonomyGroup>[];
  for (final equivalent in equivalents) {
    final candidate = index[equivalent] ?? const <domain.Taxonomy>[];
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }

  return direct;
});

/// تتبع محاولة المزامنة التلقائية لكل مجموعة في واجهات الإدخال.
/// الهدف منع تكرار deltaSync عند إعادة بناء نفس الحقل الفارغ.
final bridgeGroupAutoSyncAttemptedProvider = StateProvider.family<bool, TaxonomyGroup>((ref, group) => false);

// ═══════════════════════════════════════════════════════════════
// 🔍 Lookup Providers
// ═══════════════════════════════════════════════════════════════

/// البحث عن تصنيف بالكود
final bridgeTaxonomyByCodeProvider = FutureProvider.family<domain.Taxonomy?, ({TaxonomyGroup group, String code})>(
  (ref, params) async {
    final index = await ref.watch(bridgeTaxonomiesIndexOnceProvider.future);
    final taxonomiesAsync = index[params.group] ?? const <domain.Taxonomy>[];
    try {
      return taxonomiesAsync.firstWhere((t) => t.code == params.code);
    } catch (_) {
      return null;
    }
  },
);

/// البحث عن تصنيف بالمعرف
final bridgeTaxonomyByIdProvider = FutureProvider.family<domain.Taxonomy?, String>(
  (ref, id) async {
    final index = await ref.watch(bridgeTaxonomiesIndexOnceProvider.future);
    // نبحث في كل المجموعات
    for (final group in TaxonomyGroup.values) {
      try {
        final taxonomies = index[group] ?? const <domain.Taxonomy>[];
        final found = taxonomies.where((t) => t.id == id);
        if (found.isNotEmpty) {
          return found.first;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  },
);
