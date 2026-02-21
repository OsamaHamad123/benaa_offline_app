/// 🌉 Taxonomy Bridge Providers
///
/// يربط نظام التصنيفات الجديد (Clean Architecture) مع
/// Drift Database الموجود للتوافق مع باقي التطبيق
///
/// هذا الملف يوفر providers تستخدم النظام القديم (Drift)
/// مع واجهة النظام الجديد (TaxonomyGroup enum)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../../../core/sync/presentation/providers/sync_providers.dart' as sync_providers;

// ═══════════════════════════════════════════════════════════════
// 🌉 Bridge Providers - تربط النظام الجديد مع Drift
// ═══════════════════════════════════════════════════════════════

/// تحويل من Drift Entity إلى Domain Entity
Taxonomy? _convertFromDrift(dynamic driftTaxonomy) {
  final normalizedGroupValue = TaxonomyGroup.normalizeValue(driftTaxonomy.group?.toString());
  final resolvedGroup = TaxonomyGroup.fromString(normalizedGroupValue);
  if (resolvedGroup == null) {
    return null;
  }

  return Taxonomy(
    id: driftTaxonomy.id?.toString() ?? '',
    group: resolvedGroup,
    code: driftTaxonomy.code ?? '',
    label: driftTaxonomy.label ?? '',
    labelEn: driftTaxonomy.labelEn,
    parentId: driftTaxonomy.parentId?.toString(),
    sortOrder: driftTaxonomy.sortOrder ?? 0,
    isActive: driftTaxonomy.isActive ?? true,
    description: driftTaxonomy.description,
    color: driftTaxonomy.color,
    icon: driftTaxonomy.icon,
    createdAt: driftTaxonomy.createdAt ?? DateTime.now(),
    updatedAt: driftTaxonomy.updatedAt ?? DateTime.now(),
    deletedAt: driftTaxonomy.deletedAt,
  );
}

/// 📦 Categories (فئات المستفيدين)
final bridgeCategoriesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.categoriesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 👫 Genders (الجنس)
final bridgeGendersProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.gendersProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 💒 Marital Statuses (الحالة الاجتماعية)
final bridgeMaritalStatusesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.maritalStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 📚 Education Levels (المستوى التعليمي)
final bridgeEducationLevelsProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.educationLevelsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 🏥 Health Statuses (الحالة الصحية)
final bridgeHealthStatusesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.healthStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 🏠 Housing Types (نوع السكن)
final bridgeHousingTypesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.housingTypesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 🏘️ Housing Statuses (حالة السكن)
final bridgeHousingStatusesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.housingStatusesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 🗺️ Governorates (المحافظات)
final bridgeGovernoratesProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.governoratesProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 👪 Relationships (صلة القرابة)
final bridgeRelationshipsProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.relationshipsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

/// 🧩 Sections (القسم)
final bridgeSectionsProvider = StreamProvider<List<Taxonomy>>((ref) {
  return ref.watch(sync_providers.sectionsProvider.stream).map(
        (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
      );
});

// ═══════════════════════════════════════════════════════════════
// 🔗 Generic Group Provider
// ═══════════════════════════════════════════════════════════════

/// Generic provider للحصول على تصنيفات حسب المجموعة
/// يستخدم Drift Database الموجود
final bridgeTaxonomiesByGroupProvider = StreamProvider.family<List<Taxonomy>, TaxonomyGroup>(
  (ref, group) {
    final db = ref.watch(sync_providers.databaseProvider);
    return db.taxonomiesDao.watchByGroup(group.value).map(
          (list) => list.map(_convertFromDrift).whereType<Taxonomy>().toList(),
        );
  },
);

/// One-shot provider للحصول على التصنيفات مرة واحدة بدون stream subscription.
/// يقلل الحمل على UI isolate في الشاشات الثقيلة (مثل نموذج إضافة المستفيد).
final bridgeTaxonomiesByGroupOnceProvider = FutureProvider.family<List<Taxonomy>, TaxonomyGroup>((ref, group) async {
  final db = ref.read(sync_providers.databaseProvider);
  final items = await db.taxonomiesDao.getByGroup(group.value);
  return items.map(_convertFromDrift).whereType<Taxonomy>().toList();
});

// ═══════════════════════════════════════════════════════════════
// 🔍 Lookup Providers
// ═══════════════════════════════════════════════════════════════

/// البحث عن تصنيف بالكود
final bridgeTaxonomyByCodeProvider = FutureProvider.family<Taxonomy?, ({TaxonomyGroup group, String code})>(
  (ref, params) async {
    final taxonomiesAsync = await ref.watch(bridgeTaxonomiesByGroupOnceProvider(params.group).future);
    try {
      return taxonomiesAsync.firstWhere((t) => t.code == params.code);
    } catch (_) {
      return null;
    }
  },
);

/// البحث عن تصنيف بالمعرف
final bridgeTaxonomyByIdProvider = FutureProvider.family<Taxonomy?, String>(
  (ref, id) async {
    // نبحث في كل المجموعات
    for (final group in TaxonomyGroup.values) {
      try {
        final taxonomies = await ref.watch(bridgeTaxonomiesByGroupOnceProvider(group).future);
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
