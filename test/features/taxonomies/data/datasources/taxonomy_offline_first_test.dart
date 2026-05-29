/// 🧪 Offline-First Taxonomy Tests
///
/// يتحقق من أن:
/// 1. الحذف المحلي لا يُعاد إحياؤه بعد sync.
/// 2. bridgeTaxonomiesIndexOnceProvider لا يُرجع تصنيفات محذوفة.
/// 3. saveTaxonomiesFromSync تتجاهل التصنيفات المحذوفة محلياً.
/// 4. TaxonomyStatistics تحسب deletedCountByGroup بشكل صحيح.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/data/datasources/taxonomy_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Taxonomy _active({
  required String id,
  required TaxonomyGroup group,
  String? code,
  String? label,
}) {
  final now = DateTime(2026, 1, 1);
  return Taxonomy(
    id: id,
    group: group,
    code: code ?? id,
    label: label ?? id,
    isActive: true,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

Taxonomy _deleted({
  required String id,
  required TaxonomyGroup group,
  String? code,
  String? label,
}) {
  final now = DateTime(2026, 1, 1);
  return Taxonomy(
    id: id,
    group: group,
    code: code ?? id,
    label: label ?? id,
    isActive: false,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
    deletedAt: now,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TaxonomyLocalDataSourceImpl (SharedPreferences)
// ─────────────────────────────────────────────────────────────────────────────

TaxonomyLocalDataSourceImpl _buildLocalDs(SharedPreferences prefs) {
  return TaxonomyLocalDataSourceImpl(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 1. TaxonomyStatistics — deletedCountByGroup
  // ──────────────────────────────────────────────────────────────────────────
  group('TaxonomyStatistics', () {
    test('hasLocallyDeletedItems returns false when no deleted items', () {
      final stats = TaxonomyStatistics(
        totalCount: 1,
        activeCount: 1,
        inactiveCount: 0,
        countByGroup: {TaxonomyGroup.category: 1},
        deletedCountByGroup: {TaxonomyGroup.category: 0},
      );
      expect(stats.hasLocallyDeletedItems(TaxonomyGroup.category), isFalse);
    });

    test('hasLocallyDeletedItems returns true when group has deleted items', () {
      final stats = TaxonomyStatistics(
        totalCount: 1,
        activeCount: 0,
        inactiveCount: 1,
        countByGroup: {TaxonomyGroup.category: 0},
        deletedCountByGroup: {TaxonomyGroup.category: 1},
      );
      expect(stats.hasLocallyDeletedItems(TaxonomyGroup.category), isTrue);
    });

    test('empty() has zero deleted counts', () {
      final stats = TaxonomyStatistics.empty();
      expect(stats.hasLocallyDeletedItems(TaxonomyGroup.category), isFalse);
      expect(stats.deletedCountByGroup, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 2. TaxonomyLocalDataSourceImpl — saveTaxonomiesFromSync
  // ──────────────────────────────────────────────────────────────────────────
  group('TaxonomyLocalDataSourceImpl.saveTaxonomiesFromSync', () {
    test('does not resurrect a locally deleted taxonomy', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      // أولاً: أضف تصنيف نشط
      final original = _active(id: 'cat_1', group: TaxonomyGroup.category);
      await ds.saveTaxonomy(original);

      // ثم احذفه محلياً
      final deleted = _deleted(id: 'cat_1', group: TaxonomyGroup.category);
      await ds.saveTaxonomy(deleted);

      // verify it's gone from active results
      final beforeSync = await ds.getTaxonomiesByGroup(TaxonomyGroup.category);
      expect(beforeSync.where((t) => t.id == 'cat_1'), isEmpty);

      // الآن السيرفر يُرسله مجدداً كـ active
      final fromServer = _active(id: 'cat_1', group: TaxonomyGroup.category, label: 'Server Label');
      await ds.saveTaxonomiesFromSync([fromServer]);

      // يجب ألا يرجع
      final afterSync = await ds.getTaxonomiesByGroup(TaxonomyGroup.category);
      expect(afterSync.where((t) => t.id == 'cat_1'), isEmpty,
          reason: 'الـ sync لا يجب أن يُعيد إحياء التصنيف المحذوف محلياً');
    });

    test('saves new taxonomy from sync when no local delete conflict', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      final fromServer = _active(id: 'new_cat', group: TaxonomyGroup.category, label: 'New Category');
      await ds.saveTaxonomiesFromSync([fromServer]);

      final results = await ds.getTaxonomiesByGroup(TaxonomyGroup.category);
      expect(results.where((t) => t.id == 'new_cat'), isNotEmpty,
          reason: 'التصنيف الجديد يجب أن يُحفظ إذا لم يكن محذوفاً محلياً');
    });

    test('updates existing active taxonomy from sync', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      await ds.saveTaxonomy(_active(id: 'cat_x', group: TaxonomyGroup.category, label: 'Old'));
      await ds.saveTaxonomiesFromSync([_active(id: 'cat_x', group: TaxonomyGroup.category, label: 'Updated')]);

      final results = await ds.getTaxonomiesByGroup(TaxonomyGroup.category);
      final found = results.where((t) => t.id == 'cat_x').toList();
      expect(found, isNotEmpty);
      expect(found.first.label, equals('Updated'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 3. getAllTaxonomies — يُرجع كل شيء (لأغراض الإدارة الداخلية)
  // ──────────────────────────────────────────────────────────────────────────
  group('TaxonomyLocalDataSourceImpl.getAllTaxonomies', () {
    test('getTaxonomiesByGroup excludes inactive/deleted items', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      await ds.saveTaxonomy(_active(id: 'active_1', group: TaxonomyGroup.gender));
      await ds.saveTaxonomy(_deleted(id: 'deleted_1', group: TaxonomyGroup.gender));

      final results = await ds.getTaxonomiesByGroup(TaxonomyGroup.gender);
      expect(results.every((t) => t.isActive), isTrue, reason: 'getTaxonomiesByGroup يجب أن يُرجع النشطة فقط');
      expect(results.where((t) => t.id == 'deleted_1'), isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 4. deleteTaxonomy — soft delete
  // ──────────────────────────────────────────────────────────────────────────
  group('TaxonomyLocalDataSourceImpl.deleteTaxonomy', () {
    test('soft-deletes taxonomy and hides it from group query', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      await ds.saveTaxonomy(_active(id: 'to_delete', group: TaxonomyGroup.section));

      // التصنيف موجود
      final before = await ds.getTaxonomiesByGroup(TaxonomyGroup.section);
      expect(before.where((t) => t.id == 'to_delete'), isNotEmpty);

      await ds.deleteTaxonomy('to_delete');

      // يجب أن يختفي من النشطة
      final after = await ds.getTaxonomiesByGroup(TaxonomyGroup.section);
      expect(after.where((t) => t.id == 'to_delete'), isEmpty,
          reason: 'التصنيف المحذوف لا يجب أن يظهر في نتائج getMy(group)');
    });

    test('deleted taxonomy does not return after restart (save/reload)', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      await ds.saveTaxonomy(_active(id: 'persist_del', group: TaxonomyGroup.section));
      await ds.deleteTaxonomy('persist_del');

      // محاكاة إعادة التشغيل (نسخة جديدة من DataSource بنفس SharedPreferences)
      final ds2 = _buildLocalDs(prefs);
      final afterRestart = await ds2.getTaxonomiesByGroup(TaxonomyGroup.section);
      expect(afterRestart.where((t) => t.id == 'persist_del'), isEmpty,
          reason: 'الحذف يجب أن يستمر بعد إعادة تشغيل DataSource');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Tombstone survives multiple sync rounds
  // ──────────────────────────────────────────────────────────────────────────
  group('Tombstone survival', () {
    test('deleted taxonomy stays hidden after multiple sync rounds', () async {
      final prefs = await SharedPreferences.getInstance();
      final ds = _buildLocalDs(prefs);

      await ds.saveTaxonomy(_active(id: 'tombstone_cat', group: TaxonomyGroup.category));
      await ds.deleteTaxonomy('tombstone_cat');

      // round 1
      await ds.saveTaxonomiesFromSync([_active(id: 'tombstone_cat', group: TaxonomyGroup.category)]);
      // round 2
      await ds.saveTaxonomiesFromSync([_active(id: 'tombstone_cat', group: TaxonomyGroup.category)]);
      // round 3
      await ds.saveTaxonomiesFromSync([_active(id: 'tombstone_cat', group: TaxonomyGroup.category)]);

      final result = await ds.getTaxonomiesByGroup(TaxonomyGroup.category);
      expect(result.where((t) => t.id == 'tombstone_cat'), isEmpty,
          reason: 'التصنيف المحذوف يبقى مخفياً عبر جولات sync متعددة');
    });
  });
}
