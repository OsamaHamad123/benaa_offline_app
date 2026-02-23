import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  group('DraftSaveCoordinator', () {
    late DraftSaveCoordinator coordinator;
    late BeneficiaryFormControllers controllers;

    setUp(() {
      coordinator = const DraftSaveCoordinator();
      controllers = BeneficiaryFormControllers();
    });

    tearDown(() {
      controllers.dispose();
    });

    test('ensureAutoSaveDraftId returns existing id when provided', () {
      final id = coordinator.ensureAutoSaveDraftId(
        currentDraftId: 'existing_id',
        beneficiaryId: 'beneficiary_1',
        nationalId: '12345678901',
        now: DateTime(2026),
      );

      expect(id, equals('existing_id'));
    });

    test('ensureAutoSaveDraftId prefers beneficiary id over national id', () {
      final id = coordinator.ensureAutoSaveDraftId(
        currentDraftId: null,
        beneficiaryId: 'beneficiary_1',
        nationalId: '12345678901',
        now: DateTime(2026),
      );

      expect(id, equals('beneficiary_1'));
    });

    test('buildAutoDraftName returns default when first name is empty', () {
      controllers.lastNameController.text = 'العلي';

      final name = coordinator.buildAutoDraftName(controllers);

      expect(name, equals('مسودة جديدة'));
    });

    test('buildAutoDraftName includes first and last names', () {
      controllers.firstNameController.text = 'محمد';
      controllers.lastNameController.text = 'العلي';

      final name = coordinator.buildAutoDraftName(controllers);

      expect(name, equals('حفظ تلقائي - محمد العلي'));
    });

    test('buildDraftEnvelope includes isAutoSaved only when enabled', () {
      final autoEnvelope = coordinator.buildDraftEnvelope(
        name: 'Auto Draft',
        notes: 'n',
        formData: {'firstName': 'A'},
        currentTab: 2,
        beneficiaryId: 'b1',
        isAutoSaved: true,
      );

      final manualEnvelope = coordinator.buildDraftEnvelope(
        name: 'Manual Draft',
        notes: 'n',
        formData: {'firstName': 'A'},
        currentTab: 2,
        beneficiaryId: 'b1',
      );

      expect(autoEnvelope['isAutoSaved'], isTrue);
      expect(manualEnvelope.containsKey('isAutoSaved'), isFalse);
    });

    test('buildAutoSaveFormData contains extended save fields', () {
      controllers.selectedEmploymentStatus = '2';
      controllers.selectedCategory = '1';
      controllers.hasDisability = true;

      final data = coordinator.buildAutoSaveFormData(controllers);

      expect(data, containsPair('employmentStatus', '2'));
      expect(data, containsPair('category', '1'));
      expect(data, containsPair('hasDisability', true));
    });

    test('buildManualSaveFormData keeps manual payload minimal', () {
      controllers.selectedEmploymentStatus = '2';
      final data = coordinator.buildManualSaveFormData(controllers);

      expect(data.containsKey('employmentStatus'), isFalse);
      expect(data.containsKey('educationLevel'), isTrue);
    });
  });
}
