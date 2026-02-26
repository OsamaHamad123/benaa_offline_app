class DraftListItem {
  final String draftId;
  final String draftName;
  final DateTime? savedAt;
  final Map<String, dynamic> rawDraft;

  const DraftListItem({
    required this.draftId,
    required this.draftName,
    required this.savedAt,
    required this.rawDraft,
  });
}

class FormDraftsListHelper {
  static List<DraftListItem> normalizeDrafts(List<Map<String, dynamic>> drafts) {
    return drafts.map(_normalizeSingle).whereType<DraftListItem>().toList(growable: false);
  }

  static DraftListItem? _normalizeSingle(Map<String, dynamic> draft) {
    final rawDraftId = draft['draftId']?.toString().trim() ?? '';
    if (rawDraftId.isEmpty) return null;

    final rawName = draft['name']?.toString().trim() ?? '';
    final draftName = rawName.isEmpty ? 'مسودة' : rawName;

    final savedAt = _tryParseDateTime(draft['savedAt']);

    return DraftListItem(
      draftId: rawDraftId,
      draftName: draftName,
      savedAt: savedAt,
      rawDraft: draft,
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
