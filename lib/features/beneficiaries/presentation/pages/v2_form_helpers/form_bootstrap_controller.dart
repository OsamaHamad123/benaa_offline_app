import 'package:shared_preferences/shared_preferences.dart';

import 'draft_manager.dart';

/// Handles lightweight bootstrap logic for beneficiary form startup.
class BeneficiaryFormBootstrapController {
  static const String hasSeenTourKey = 'has_seen_form_tour';

  const BeneficiaryFormBootstrapController();

  Future<bool> shouldShowTour({
    required bool tourEnabled,
    required SharedPreferences prefs,
  }) async {
    if (!tourEnabled) {
      return false;
    }

    final hasSeenTour = prefs.getBool(hasSeenTourKey) ?? false;
    return !hasSeenTour;
  }

  Future<void> markTourSeen(SharedPreferences prefs) async {
    await prefs.setBool(hasSeenTourKey, true);
  }

  Future<Map<String, dynamic>?> getLatestAutoSavedDraft({
    required bool hasUserInput,
    int limit = 15,
  }) async {
    if (hasUserInput) {
      return null;
    }

    final drafts = await DraftManager.getAllDrafts(
      limit: limit,
      autoSavedOnly: true,
    );

    if (drafts.isEmpty) {
      return null;
    }

    return drafts.first;
  }
}
