import 'package:benaa_offline_app/features/taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiredBeneficiaryTaxonomyGroups', () {
    test('contains mandatory binding groups for form safety', () {
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.assistanceType), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.beneficiaryStatus), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.relationship), isTrue);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.category), isFalse);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.section), isFalse);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.gender), isFalse);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.disabilityType), isFalse);
      expect(requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.incomeSource), isFalse);
    });

    test('has no duplicate groups', () {
      final asSet = requiredBeneficiaryTaxonomyGroups.toSet();
      expect(asSet.length, requiredBeneficiaryTaxonomyGroups.length);
    });

    test('keeps minimum required baseline size', () {
      expect(requiredBeneficiaryTaxonomyGroups.length, greaterThanOrEqualTo(10));
    });
  });

  group('essentialBeneficiaryFormTaxonomyGroups', () {
    test('contains full form groups including attachments and family taxonomies', () {
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.gender), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.category), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.documentType), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.deathReason), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.disabilityType), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.incomeSource), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.sponsorshipType), isTrue);
    });

    test('has no duplicate groups', () {
      final asSet = essentialBeneficiaryFormTaxonomyGroups.toSet();
      expect(asSet.length, essentialBeneficiaryFormTaxonomyGroups.length);
    });
  });
}
