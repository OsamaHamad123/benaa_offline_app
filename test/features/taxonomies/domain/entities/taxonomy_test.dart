import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';

void main() {
  group('Taxonomy Entity', () {
    late Taxonomy taxonomy;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      taxonomy = Taxonomy(
        id: 'test_id',
        group: TaxonomyGroup.governorate,
        code: 'BGD',
        label: 'بغداد',
        labelEn: 'Baghdad',
        sortOrder: 1,
        description: 'العاصمة',
        color: '#FF0000',
        icon: 'location_city',
        metadata: const {'population': 8000000},
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should create a valid taxonomy', () {
      expect(taxonomy.id, 'test_id');
      expect(taxonomy.group, TaxonomyGroup.governorate);
      expect(taxonomy.code, 'BGD');
      expect(taxonomy.label, 'بغداد');
      expect(taxonomy.labelEn, 'Baghdad');
      expect(taxonomy.isActive, true);
    });

    test('isDeleted should return false when deletedAt is null', () {
      expect(taxonomy.isDeleted, false);
    });

    test('isDeleted should return true when deletedAt is set', () {
      final deletedTaxonomy = taxonomy.copyWith(deletedAt: DateTime.now());
      expect(deletedTaxonomy.isDeleted, true);
    });

    test('hasParent should return false when parentId is null', () {
      expect(taxonomy.hasParent, false);
    });

    test('hasParent should return true when parentId is set', () {
      final childTaxonomy = taxonomy.copyWith(parentId: 'parent_123');
      expect(childTaxonomy.hasParent, true);
    });

    test('hasParent should return false when parentId is empty', () {
      final childTaxonomy = taxonomy.copyWith(parentId: '');
      expect(childTaxonomy.hasParent, false);
    });

    test('fullId should combine group prefix and code', () {
      expect(taxonomy.fullId, 'gov_BGD');
    });

    test('copyWith should create a new taxonomy with updated values', () {
      final updated = taxonomy.copyWith(
        label: 'بغداد الجديدة',
        isActive: false,
      );

      expect(updated.label, 'بغداد الجديدة');
      expect(updated.isActive, false);
      // Other values should remain the same
      expect(updated.id, taxonomy.id);
      expect(updated.code, taxonomy.code);
      expect(updated.group, taxonomy.group);
    });

    test('copyWith without arguments should return identical taxonomy', () {
      final copy = taxonomy.copyWith();
      expect(copy, taxonomy);
    });

    test('two taxonomies with same values should be equal', () {
      final taxonomy2 = Taxonomy(
        id: 'test_id',
        group: TaxonomyGroup.governorate,
        code: 'BGD',
        label: 'بغداد',
        labelEn: 'Baghdad',
        sortOrder: 1,
        description: 'العاصمة',
        color: '#FF0000',
        icon: 'location_city',
        metadata: const {'population': 8000000},
        createdAt: now,
        updatedAt: now,
      );

      expect(taxonomy, taxonomy2);
    });

    test('toString should return readable format', () {
      expect(taxonomy.toString(), 'Taxonomy(governorate.BGD: بغداد)');
    });
  });

  group('TaxonomyStatistics', () {
    test('should create valid statistics', () {
      final stats = TaxonomyStatistics(
        totalCount: 100,
        activeCount: 80,
        inactiveCount: 20,
        countByGroup: const {
          TaxonomyGroup.governorate: 18,
          TaxonomyGroup.category: 10,
        },
        lastSyncTime: DateTime.now(),
      );

      expect(stats.totalCount, 100);
      expect(stats.activeCount, 80);
      expect(stats.inactiveCount, 20);
      expect(stats.countByGroup[TaxonomyGroup.governorate], 18);
    });
  });

  group('TaxonomySyncResult', () {
    test('should create sync result with counts', () {
      final result = TaxonomySyncResult(
        success: true,
        addedCount: 10,
        updatedCount: 5,
        deletedCount: 2,
        syncTime: DateTime.now(),
        message: 'تمت المزامنة بنجاح',
      );

      expect(result.success, true);
      expect(result.addedCount, 10);
      expect(result.updatedCount, 5);
      expect(result.deletedCount, 2);
      expect(result.totalChanges, 17);
    });

    test('hasChanges should return true when there are changes', () {
      final result = TaxonomySyncResult(
        success: true,
        addedCount: 5,
        updatedCount: 0,
        deletedCount: 0,
        syncTime: DateTime.now(),
      );

      expect(result.hasChanges, true);
    });

    test('hasChanges should return false when no changes', () {
      final result = TaxonomySyncResult(
        success: true,
        addedCount: 0,
        updatedCount: 0,
        deletedCount: 0,
        syncTime: DateTime.now(),
      );

      expect(result.hasChanges, false);
    });

    test('success factory should create successful result', () {
      final result = TaxonomySyncResult.success(
        addedCount: 3,
        updatedCount: 2,
        deletedCount: 1,
      );

      expect(result.success, true);
      expect(result.addedCount, 3);
      expect(result.totalChanges, 6);
    });

    test('failure factory should create failed result', () {
      final result = TaxonomySyncResult.failure('Connection error');

      expect(result.success, false);
      expect(result.message, 'Connection error');
      expect(result.hasChanges, false);
    });
  });
}
