import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_taxonomy_bulk_normalizer.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormTaxonomyBulkNormalizer', () {
    test('normalizes selected category and relationship from labels to codes', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final now = DateTime(2026, 2, 26);
      final index = <TaxonomyGroup, List<Taxonomy>>{
        TaxonomyGroup.category: [
          Taxonomy(
            id: '1',
            group: TaxonomyGroup.category,
            code: '2',
            label: 'فقير',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        TaxonomyGroup.relationship: [
          Taxonomy(
            id: '11',
            group: TaxonomyGroup.relationship,
            code: '11',
            label: 'ابن',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      };

      controllers.selectedCategory = 'فقير';
      controllers.selectedRelationship = 'ابن';

      await FormTaxonomyBulkNormalizer.normalizeAll(
        controllers: controllers,
        taxonomyIndex: index,
      );

      expect(controllers.selectedCategory, '2');
      expect(controllers.selectedRelationship, '11');
    });
  });
}
