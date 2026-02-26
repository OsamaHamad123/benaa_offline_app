import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_taxonomy_sync_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormTaxonomySyncHelper', () {
    test('returns generic message for null/blank errors', () {
      expect(FormTaxonomySyncHelper.resolveFailureMessage(null), FormTaxonomySyncHelper.genericFailureMessage);
      expect(FormTaxonomySyncHelper.resolveFailureMessage('   '), FormTaxonomySyncHelper.genericFailureMessage);
    });

    test('returns original server error when provided', () {
      const raw = 'Timeout from server';
      expect(FormTaxonomySyncHelper.resolveFailureMessage(raw), raw);
    });
  });
}
