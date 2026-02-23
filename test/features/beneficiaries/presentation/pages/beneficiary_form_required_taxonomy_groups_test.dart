import 'package:benaa_offline_app/features/taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiredBeneficiaryTaxonomyGroups', () {
    test('contains mandatory binding groups for form safety', () {
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.assistanceType), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.beneficiaryStatus), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.section), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.relationship), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.disabilityType), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.incomeSource), isTrue);
    });

    test('has no duplicate groups', () {
      final asSet = requiredBeneficiaryTaxonomyGroups.toSet();
      expect(asSet.length, requiredBeneficiaryTaxonomyGroups.length);
    });

    test('keeps minimum required baseline size', () {
      expect(requiredBeneficiaryTaxonomyGroups.length, greaterThanOrEqualTo(16));
    });
  });
}
