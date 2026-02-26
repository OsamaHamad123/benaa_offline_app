import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_guard_helper.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormSaveGuardHelper', () {
    test('returns true when no missing groups', () async {
      final result = await FormSaveGuardHelper.ensureTaxonomyCoverage(
        currentMissingGroups: const <TaxonomyGroup>[],
        refreshCoverage: () async {},
        onWarning: (_) {},
      );

      expect(result, isTrue);
    });

    test('returns false and emits warning when groups are missing', () async {
      String? warningMessage;

      final result = await FormSaveGuardHelper.ensureTaxonomyCoverage(
        currentMissingGroups: const [TaxonomyGroup.category],
        refreshCoverage: () async {},
        onWarning: (message) => warningMessage = message,
      );

      expect(result, isFalse);
      expect(warningMessage, isNotNull);
      expect(warningMessage, contains('الفئات'));
    });
  });
}
