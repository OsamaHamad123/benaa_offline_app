import 'dart:async';

import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/civil_registry_lookup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CivilRegistryLookupController', () {
    test('resets state when national id becomes short', () {
      final controller = CivilRegistryLookupController();
      addTearDown(controller.dispose);

      var resetCalled = false;
      var rebuildCalled = false;

      controller.onNationalIdChanged(
        nationalId: '123',
        canUseCivilRegistry: true,
        nationalIdLength: 9,
        debounceDuration: const Duration(milliseconds: 1),
        fetchByNationalId: (_) async {},
        isLookupInProgressForId: false,
        resetProvider: () => resetCalled = true,
        requestRebuild: () => rebuildCalled = true,
      );

      expect(resetCalled, isTrue);
      expect(rebuildCalled, isTrue);
      expect(controller.showPreview, isFalse);
      expect(controller.hasAutofilled, isFalse);
    });

    test('debounces and fetches once for valid id', () async {
      final controller = CivilRegistryLookupController();
      addTearDown(controller.dispose);

      var fetchCount = 0;

      controller.onNationalIdChanged(
        nationalId: '123456789',
        canUseCivilRegistry: true,
        nationalIdLength: 9,
        debounceDuration: const Duration(milliseconds: 20),
        fetchByNationalId: (_) async => fetchCount++,
        isLookupInProgressForId: false,
        resetProvider: () {},
        requestRebuild: () {},
      );

      controller.onNationalIdChanged(
        nationalId: '123456789',
        canUseCivilRegistry: true,
        nationalIdLength: 9,
        debounceDuration: const Duration(milliseconds: 20),
        fetchByNationalId: (_) async => fetchCount++,
        isLookupInProgressForId: false,
        resetProvider: () {},
        requestRebuild: () {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fetchCount, 1);
    });

    test('autofill completion marks state', () async {
      final controller = CivilRegistryLookupController();
      addTearDown(controller.dispose);

      var rebuildCalled = false;
      controller.onAutofillCompleted(
        hideAfter: const Duration(milliseconds: 5),
        requestRebuild: () => rebuildCalled = true,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(rebuildCalled, isTrue);
      expect(controller.hasAutofilled, isTrue);
      expect(controller.showPreview, isFalse);
    });
  });
}
