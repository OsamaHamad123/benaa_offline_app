import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 💾 Draft Manager for Auto-saving Incomplete Forms
///
/// Saves form data locally for later resume
class DraftManager {
  static const String _draftPrefix = 'beneficiary_draft_';
  static const String _draftListKey = 'draft_list';

  /// Save form as draft
  static Future<void> saveDraft({
    required String draftId,
    required Map<String, dynamic> formData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Add timestamp
    formData['savedAt'] = DateTime.now().toIso8601String();
    formData['draftId'] = draftId;

    // Save draft data
    await prefs.setString('$_draftPrefix$draftId', json.encode(formData));

    // Update draft list
    final List<String> drafts = prefs.getStringList(_draftListKey) ?? [];
    if (!drafts.contains(draftId)) {
      drafts.add(draftId);
      await prefs.setStringList(_draftListKey, drafts);
    }
  }

  /// Load draft by ID
  static Future<Map<String, dynamic>?> loadDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftJson = prefs.getString('$_draftPrefix$draftId');

    if (draftJson == null) return null;

    return json.decode(draftJson) as Map<String, dynamic>;
  }

  /// Delete draft
  static Future<void> deleteDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove draft data
    await prefs.remove('$_draftPrefix$draftId');

    // Update draft list
    final List<String> drafts = prefs.getStringList(_draftListKey) ?? [];
    drafts.remove(draftId);
    await prefs.setStringList(_draftListKey, drafts);
  }

  /// Get all drafts
  static Future<List<Map<String, dynamic>>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> draftIds = prefs.getStringList(_draftListKey) ?? [];

    final List<Map<String, dynamic>> drafts = [];
    for (final id in draftIds) {
      final draft = await loadDraft(id);
      if (draft != null) {
        drafts.add(draft);
      }
    }

    // Sort by savedAt (newest first)
    drafts.sort((a, b) {
      final aTime = DateTime.parse(a['savedAt'] as String);
      final bTime = DateTime.parse(b['savedAt'] as String);
      return bTime.compareTo(aTime);
    });

    return drafts;
  }

  /// Check if draft exists
  static Future<bool> hasDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_draftPrefix$draftId');
  }

  /// Clear all drafts
  static Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> draftIds = prefs.getStringList(_draftListKey) ?? [];

    for (final id in draftIds) {
      await prefs.remove('$_draftPrefix$id');
    }

    await prefs.remove(_draftListKey);
  }
}
