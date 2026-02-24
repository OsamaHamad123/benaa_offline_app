import 'package:benaa_offline_app/features/taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('beneficiary taxonomy contract coverage', () {
    test('backend documented category slugs resolve to known taxonomy groups', () {
      final unresolved = unresolvedDocumentedCategorySlugs();
      expect(unresolved, isEmpty);
    });

    test('request-statuses maps to beneficiary status group', () {
      final aliases = beneficiaryTaxonomyServerAliases[TaxonomyGroup.beneficiaryStatus] ?? const <String>[];
      expect(aliases.contains('request-statuses'), isTrue);
      expect(TaxonomyGroup.fromString('request-statuses'), TaxonomyGroup.beneficiaryStatus);
    });

    test('essential form groups include gender and document type', () {
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.gender), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.documentType), isTrue);
      expect(essentialBeneficiaryFormTaxonomyGroups.contains(TaxonomyGroup.deathReason), isTrue);
    });

    test('missing essential groups analyzer reports absent groups correctly', () {
      final available = <TaxonomyGroup>{
        TaxonomyGroup.category,
        TaxonomyGroup.governorate,
        TaxonomyGroup.beneficiaryStatus,
      };

      final missing = missingEssentialBeneficiaryFormTaxonomyGroups(available);

      expect(missing.contains(TaxonomyGroup.gender), isTrue);
      expect(missing.contains(TaxonomyGroup.documentType), isTrue);
      expect(missing.contains(TaxonomyGroup.category), isFalse);
      expect(missing.contains(TaxonomyGroup.governorate), isFalse);
    });
  });
}
