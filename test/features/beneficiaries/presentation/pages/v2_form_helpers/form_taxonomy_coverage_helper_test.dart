import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_taxonomy_coverage_helper.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormTaxonomyCoverageHelper', () {
    test('formats missing groups warning message with arabic labels', () {
      final message = FormTaxonomyCoverageHelper.formatMissingGroupsMessage(
        const [TaxonomyGroup.category, TaxonomyGroup.section],
      );

      expect(message, contains('الفئات'));
      expect(message, contains('القسم'));
      expect(message, contains('يرجى مزامنة التصنيفات'));
    });
  });
}
