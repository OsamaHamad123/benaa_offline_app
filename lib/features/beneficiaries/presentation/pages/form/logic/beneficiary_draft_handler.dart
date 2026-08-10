import 'package:flutter/material.dart';
import '../../v2_form_helpers/draft_manager.dart';
import '../../v2_form_helpers/form_controllers.dart';
import 'beneficiary_form_mapper.dart';

/// 🎯 Draft Handler - Manages draft operations
class BeneficiaryDraftHandler {
  /// Auto-save draft (silent, no validation)
  static Future<String?> autoSaveDraft({
    required BeneficiaryFormControllers controllers,
    required int currentTabIndex,
    String? existingDraftId,
    String? beneficiaryId,
  }) async {
    try {
      final formData = BeneficiaryFormMapper.mapControllersToDraftData(
        controllers: controllers,
        currentTabIndex: currentTabIndex,
        beneficiaryId: beneficiaryId,
      );

      // Generate or use existing draft ID
      final draftId = existingDraftId ??
          _generateAutoDraftId(
            nationalId: controllers.nationalIdController.text,
            beneficiaryId: beneficiaryId,
          );

      // Generate draft name
      final firstName = controllers.firstNameController.text;
      final lastName = controllers.lastNameController.text;
      final draftName =
          firstName.isNotEmpty ? 'حفظ تلقائي - $firstName ${lastName.isNotEmpty ? lastName : ""}' : 'مسودة جديدة';

      await DraftManager.saveDraft(
        draftId: draftId,
        formData: {
          'name': draftName,
          'notes': 'آخر تحديث: ${DateTime.now().toString().split('.')[0]}',
          'formData': formData,
          'currentTab': currentTabIndex,
          'beneficiaryId': beneficiaryId,
          'isAutoSaved': true,
        },
      );

      debugPrint('✅ Auto-saved draft successfully: $draftId');
      return draftId;
    } catch (e, stackTrace) {
      debugPrint('❌ Auto-save failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return null; // Silent failure
    }
  }

  /// Save draft manually (with user interaction)
  static Future<bool> saveManualDraft({
    required BeneficiaryFormControllers controllers,
    required int currentTabIndex,
    required String draftName,
    String? draftNotes,
    String? beneficiaryId,
  }) async {
    try {
      final formData = BeneficiaryFormMapper.mapControllersToDraftData(
        controllers: controllers,
        currentTabIndex: currentTabIndex,
        beneficiaryId: beneficiaryId,
      );

      final draftId = 'manual_draft_${DateTime.now().millisecondsSinceEpoch}';

      await DraftManager.saveDraft(
        draftId: draftId,
        formData: {
          'name': draftName,
          'notes': draftNotes ?? '',
          'formData': formData,
          'currentTab': currentTabIndex,
          'beneficiaryId': beneficiaryId,
          'isAutoSaved': false,
        },
      );

      debugPrint('✅ Manual draft saved successfully: $draftId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Manual draft save failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Load draft into controllers
  static Future<bool> loadDraft({
    required String draftId,
    required BeneficiaryFormControllers controllers,
  }) async {
    try {
      final drafts = await DraftManager.getAllDrafts();
      final draft = drafts.firstWhere(
        (d) => d['id'] == draftId,
        orElse: () => {},
      );

      if (draft.isEmpty) {
        debugPrint('❌ Draft not found: $draftId');
        return false;
      }

      BeneficiaryFormMapper.mapDraftDataToControllers(
        draftData: draft,
        controllers: controllers,
      );

      debugPrint('✅ Draft loaded successfully: $draftId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Draft load failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Delete draft
  static Future<bool> deleteDraft(String draftId) async {
    try {
      await DraftManager.deleteDraft(draftId);
      debugPrint('✅ Draft deleted successfully: $draftId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Draft delete failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get all auto-saved drafts
  static Future<List<Map<String, dynamic>>> getAutoSavedDrafts() async {
    try {
      final drafts = await DraftManager.getAllDrafts();
      return drafts.where((d) => d['isAutoSaved'] == true).toList();
    } catch (e) {
      debugPrint('❌ Get auto-saved drafts failed: $e');
      return [];
    }
  }

  /// Get all manual drafts
  static Future<List<Map<String, dynamic>>> getManualDrafts() async {
    try {
      final drafts = await DraftManager.getAllDrafts();
      return drafts.where((d) => d['isAutoSaved'] == false).toList();
    } catch (e) {
      debugPrint('❌ Get manual drafts failed: $e');
      return [];
    }
  }

  /// Check if has any changes worth saving
  static bool hasChangesWorthSaving(BeneficiaryFormControllers controllers) {
    return controllers.firstNameController.text.isNotEmpty || controllers.nationalIdController.text.isNotEmpty;
  }

  /// Generate auto-draft ID
  static String _generateAutoDraftId({
    required String nationalId,
    String? beneficiaryId,
  }) {
    if (beneficiaryId != null) {
      return 'auto_draft_$beneficiaryId';
    }

    if (nationalId.isNotEmpty) {
      return 'auto_draft_$nationalId';
    }

    return 'auto_draft_temp_${DateTime.now().millisecondsSinceEpoch}';
  }
}
