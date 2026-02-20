import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 💾 Draft Manager for Auto-saving Incomplete Forms
///
/// Saves form data locally for later resume
class DraftManager {
  static const String _draftPrefix = 'beneficiary_draft_';
  static const String _draftListKey = 'draft_list';
  static SharedPreferences? _prefsCache;

  static Future<SharedPreferences> _prefs() async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  /// Save form as draft
  static Future<void> saveDraft({
    required String draftId,
    required Map<String, dynamic> formData,
  }) async {
    final prefs = await _prefs();

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
    final prefs = await _prefs();
    final String? draftJson = prefs.getString('$_draftPrefix$draftId');

    if (draftJson == null) return null;

    return json.decode(draftJson) as Map<String, dynamic>;
  }

  /// Delete draft
  static Future<void> deleteDraft(String draftId) async {
    final prefs = await _prefs();

    // Remove draft data
    await prefs.remove('$_draftPrefix$draftId');

    // Update draft list
    final List<String> drafts = prefs.getStringList(_draftListKey) ?? [];
    drafts.remove(draftId);
    await prefs.setStringList(_draftListKey, drafts);
  }

  /// Get all drafts
  static Future<List<Map<String, dynamic>>> getAllDrafts({
    int? limit,
    bool autoSavedOnly = false,
  }) async {
    final prefs = await _prefs();
    final List<String> draftIds = prefs.getStringList(_draftListKey) ?? [];

    final List<Map<String, dynamic>> drafts = [];

    // Iterate from latest to oldest (list appends newest at end).
    final Iterable<String> orderedIds = draftIds.reversed;
    for (final id in orderedIds) {
      final draftJson = prefs.getString('$_draftPrefix$id');
      if (draftJson == null) continue;

      try {
        final draft = json.decode(draftJson) as Map<String, dynamic>;
        if (autoSavedOnly && draft['isAutoSaved'] != true) {
          continue;
        }
        drafts.add(draft);

        if (limit != null && drafts.length >= limit) {
          break;
        }
      } catch (_) {
        continue;
      }
    }

    // Sort by savedAt (newest first)
    drafts.sort((a, b) {
      final aTime = DateTime.tryParse((a['savedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse((b['savedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return drafts;
  }

  /// Check if draft exists
  static Future<bool> hasDraft(String draftId) async {
    final prefs = await _prefs();
    return prefs.containsKey('$_draftPrefix$draftId');
  }

  /// Clear all drafts
  static Future<void> clearAllDrafts() async {
    final prefs = await _prefs();
    final List<String> draftIds = prefs.getStringList(_draftListKey) ?? [];

    for (final id in draftIds) {
      await prefs.remove('$_draftPrefix$id');
    }

    await prefs.remove(_draftListKey);
  }
}
