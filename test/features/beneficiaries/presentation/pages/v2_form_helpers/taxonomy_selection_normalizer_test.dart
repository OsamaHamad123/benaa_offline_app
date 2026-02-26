import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/taxonomy_selection_normalizer.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxonomySelectionNormalizer', () {
    final now = DateTime(2026, 2, 26);
    final options = <Taxonomy>[
      Taxonomy(
        id: '1',
        group: TaxonomyGroup.relationship,
        code: '9',
        label: 'ابن',
        createdAt: now,
        updatedAt: now,
      ),
      Taxonomy(
        id: '2',
        group: TaxonomyGroup.relationship,
        code: '10',
        label: 'ابنة',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('resolves by code', () {
      final resolved = TaxonomySelectionNormalizer.resolveTaxonomyCode(
        rawValue: '10',
        taxonomies: options,
      );

      expect(resolved, '10');
    });

    test('resolves by label', () {
      final resolved = TaxonomySelectionNormalizer.resolveTaxonomyCode(
        rawValue: 'ابن',
        taxonomies: options,
      );

      expect(resolved, '9');
    });

    test('keeps raw value when no match exists', () {
      final resolved = TaxonomySelectionNormalizer.resolveTaxonomyCode(
        rawValue: 'relationship::99',
        taxonomies: options,
      );

      expect(resolved, 'relationship::99');
    });
  });
}
