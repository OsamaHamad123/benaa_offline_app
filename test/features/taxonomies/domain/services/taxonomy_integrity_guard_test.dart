import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/services/taxonomy_integrity_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxonomyIntegrityGuard', () {
    const guard = TaxonomyIntegrityGuard();

    TaxonomyStatistics buildStats(Map<TaxonomyGroup, int> values) {
      final countByGroup = <TaxonomyGroup, int>{
        for (final group in TaxonomyGroup.values) group: values[group] ?? 0,
      };

      final activeCount = countByGroup.values.fold<int>(0, (sum, count) => sum + count);

      return TaxonomyStatistics(
        totalCount: activeCount,
        activeCount: activeCount,
        inactiveCount: 0,
        countByGroup: countByGroup,
      );
    }

    test('assess marks backend payload gap when essential and documented groups are missing', () {
      final stats = buildStats({
        TaxonomyGroup.category: 3,
        TaxonomyGroup.relationship: 2,
      });

      final report = guard.assess(stats);

      expect(report.likelySource, TaxonomyGapSource.backendPayload);
      expect(report.missingEssentialGroups.isNotEmpty, isTrue);
      expect(report.missingDocumentedGroups.isNotEmpty, isTrue);
      expect(report.unresolvedDocumentedSlugs, isEmpty);
    });

    test('buildFallbackTaxonomies seeds critical missing groups', () {
      final stats = buildStats({
        TaxonomyGroup.category: 2,
      });

      final fallbacks = guard.buildFallbackTaxonomies(
        stats: stats,
        existingByGroup: const {},
      );

      final fallbackGroups = fallbacks.map((item) => item.group).toSet();

      expect(fallbackGroups.contains(TaxonomyGroup.gender), isTrue);
      expect(fallbackGroups.contains(TaxonomyGroup.section), isTrue);
      expect(fallbackGroups.contains(TaxonomyGroup.documentType), isTrue);
      expect(fallbacks.every((item) => item.metadata?['is_fallback'] == true), isTrue);
    });

    test('buildFallbackTaxonomies does not override existing group data', () {
      final stats = buildStats({
        TaxonomyGroup.gender: 2,
      });

      final existingGender = Taxonomy(
        id: 'gender::male',
        group: TaxonomyGroup.gender,
        code: 'male',
        label: 'ذكر',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final fallbacks = guard.buildFallbackTaxonomies(
        stats: stats,
        existingByGroup: {
          TaxonomyGroup.gender: [existingGender],
        },
      );

      final hasGenderFallback = fallbacks.any((item) => item.group == TaxonomyGroup.gender);
      expect(hasGenderFallback, isFalse);
    });
  });
}
