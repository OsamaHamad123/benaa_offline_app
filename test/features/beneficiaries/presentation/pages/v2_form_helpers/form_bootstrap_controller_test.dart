import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_manager.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_bootstrap_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BeneficiaryFormBootstrapController', () {
    late BeneficiaryFormBootstrapController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = const BeneficiaryFormBootstrapController();
      await DraftManager.clearAllDrafts();
    });

    test('shouldShowTour returns false when feature disabled', () async {
      final prefs = await SharedPreferences.getInstance();

      final result = await controller.shouldShowTour(
        tourEnabled: false,
        prefs: prefs,
      );

      expect(result, isFalse);
    });

    test('shouldShowTour returns true when enabled and not seen', () async {
      final prefs = await SharedPreferences.getInstance();

      final result = await controller.shouldShowTour(
        tourEnabled: true,
        prefs: prefs,
      );

      expect(result, isTrue);
    });

    test('markTourSeen prevents tour in next check', () async {
      final prefs = await SharedPreferences.getInstance();
      await controller.markTourSeen(prefs);

      final result = await controller.shouldShowTour(
        tourEnabled: true,
        prefs: prefs,
      );

      expect(result, isFalse);
    });

    test('getLatestAutoSavedDraft returns null if user already typed', () async {
      await DraftManager.saveDraft(
        draftId: 'draft_1',
        formData: {
          'name': 'مسودة تلقائية',
          'isAutoSaved': true,
        },
      );

      final draft = await controller.getLatestAutoSavedDraft(
        hasUserInput: true,
      );

      expect(draft, isNull);
    });

    test('getLatestAutoSavedDraft returns latest autosaved draft', () async {
      await DraftManager.saveDraft(
        draftId: 'older',
        formData: {
          'name': 'older',
          'isAutoSaved': true,
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));

      await DraftManager.saveDraft(
        draftId: 'newer',
        formData: {
          'name': 'newer',
          'isAutoSaved': true,
        },
      );

      final draft = await controller.getLatestAutoSavedDraft(
        hasUserInput: false,
      );

      expect(draft, isNotNull);
      expect(draft!['draftId'], 'newer');
    });
  });
}
