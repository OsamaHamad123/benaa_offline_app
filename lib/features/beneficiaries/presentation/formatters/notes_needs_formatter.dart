import 'dart:convert';

class NotesNeedsFormattedContent {
  const NotesNeedsFormattedContent({
    required this.notesText,
    required this.needs,
  });

  final String notesText;
  final List<String> needs;
}

class NotesNeedsFormatter {
  static const String _defaultNotes = 'لا توجد ملاحظات مسجلة';

  static const Set<String> _allowedKeys = <String>{
    'notes',
    'needs',
    'caseDescription',
    'recommendations',
    'healthNeeds',
    'housingNeeds',
    'assistanceNeeds',
  };

  static const Set<String> _technicalKeys = <String>{
    'metadata',
    'raw',
    'data.json',
    'debug',
    'syncstatus',
    'createdatlocal',
    'updatedatlocal',
    'internal',
    'payload',
    'json',
  };

  static NotesNeedsFormattedContent format(String? rawInput) {
    final raw = (rawInput ?? '').trim();
    if (raw.isEmpty) {
      return const NotesNeedsFormattedContent(notesText: _defaultNotes, needs: <String>[]);
    }

    final stripped = _stripMetaSuffix(raw);
    final decoded = _tryDecodeJson(stripped);

    if (decoded is Map) {
      final map = decoded.map((k, v) => MapEntry(k.toString(), v));
      return _fromMap(map);
    }

    if (decoded is List) {
      final listNeeds = _extractList(decoded);
      return NotesNeedsFormattedContent(
        notesText: _defaultNotes,
        needs: listNeeds,
      );
    }

    if (_looksLikeJson(stripped)) {
      return const NotesNeedsFormattedContent(notesText: _defaultNotes, needs: <String>[]);
    }

    // Final fallback: plain text — strip any embedded JSON-like fragments first
    final cleanText = _stripEmbeddedJsonFragments(stripped);
    return NotesNeedsFormattedContent(
      notesText: cleanText.isEmpty ? _defaultNotes : cleanText,
      needs: const <String>[],
    );
  }

  static NotesNeedsFormattedContent _fromMap(Map<String, dynamic> source) {
    final sanitized = <String, dynamic>{};
    for (final entry in source.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      if (_isTechnicalKey(key)) continue;
      if (!_allowedKeys.contains(key)) continue;
      sanitized[key] = entry.value;
    }

    final needs = <String>{};
    for (final key in const <String>['needs', 'healthNeeds', 'housingNeeds', 'assistanceNeeds']) {
      final value = sanitized[key];
      needs.addAll(_extractNeeds(value));
    }

    final notesParts = <String>[];
    for (final key in const <String>['notes', 'caseDescription', 'recommendations']) {
      final value = sanitized[key];
      final text = _extractSingleText(value);
      if (text != null && text.isNotEmpty) {
        notesParts.add(text);
      }
    }

    final notesText = notesParts.isEmpty ? _defaultNotes : notesParts.join('\n');

    return NotesNeedsFormattedContent(
      notesText: notesText,
      needs: needs.toList(growable: false),
    );
  }

  static List<String> _extractNeeds(dynamic value) {
    if (value == null) return const <String>[];

    if (value is List) {
      return _extractList(value);
    }

    if (value is Map) {
      final nested = <String>[];
      for (final entry in value.entries) {
        final key = entry.key.toString();
        if (_isTechnicalKey(key)) continue;
        if (!_allowedKeys.contains(key)) continue;
        nested.addAll(_extractNeeds(entry.value));
      }
      return nested;
    }

    if (value is String) {
      return value
          .split(RegExp(r'[\n,،;]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !_isTechnicalKey(e) && !_looksLikeJson(e))
          .toList(growable: false);
    }

    final text = value.toString().trim();
    if (text.isEmpty || _isTechnicalKey(text) || _looksLikeJson(text)) return const <String>[];
    return <String>[text];
  }

  static List<String> _extractList(List<dynamic> values) {
    return values
        .map((e) {
          if (e is Map || e is List) return null;
          final text = e.toString().trim();
          if (text.isEmpty) return null;
          if (_isTechnicalKey(text)) return null;
          if (_looksLikeJson(text)) return null;
          return text;
        })
        .whereType<String>()
        .toList(growable: false);
  }

  static String? _extractSingleText(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty || _isTechnicalKey(text) || _looksLikeJson(text)) return null;
      // Strip any embedded JSON-like fragments before returning
      final clean = _stripEmbeddedJsonFragments(text);
      return clean.isEmpty ? null : clean;
    }
    if (value is List) {
      final list = _extractList(value);
      if (list.isEmpty) return null;
      return list.join('، ');
    }
    if (value is Map) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || _isTechnicalKey(text) || _looksLikeJson(text)) return null;
    return text;
  }

  static dynamic _tryDecodeJson(String value) {
    final trimmed = value.trim();
    if (!_looksLikeJson(trimmed)) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }

  static String _stripMetaSuffix(String value) {
    // Strip everything from the first #meta: marker regardless of leading whitespace/newlines
    final pattern = RegExp(r'[\n\r]+\s*#meta:.*', caseSensitive: false, dotAll: true);
    final match = pattern.firstMatch(value);
    if (match != null) {
      return value.substring(0, match.start).trimRight();
    }
    // Edge case: entire string starts with #meta:
    if (value.trimLeft().toLowerCase().startsWith('#meta:')) return '';
    return value;
  }

  static bool _looksLikeJson(String value) {
    final trimmed = value.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) || (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  static bool _isTechnicalKey(String key) {
    final lower = key.trim().toLowerCase();
    if (_technicalKeys.contains(lower)) return true;
    if (lower.contains('metadata')) return true;
    if (lower.contains('data.json')) return true;
    if (lower.contains('syncstatus')) return true;
    return false;
  }

  /// Removes embedded JSON-like `{...}` and `[...]` blocks from plain text.
  /// Handles one level of nesting, which covers the vast majority of real data.
  static String _stripEmbeddedJsonFragments(String text) {
    if (text.isEmpty) return text;
    // Remove {...} blocks (one level of nesting)
    var result = text.replaceAll(RegExp(r'\{[^{}]*\}'), '');
    // Remove [...] blocks (one level of nesting)
    result = result.replaceAll(RegExp(r'\[[^\[\]]*\]'), '');
    // Remove any leftover #meta: lines (fragments after JSON brace removal)
    result = result.replaceAll(RegExp(r'#meta:[^\n]*', caseSensitive: false), '');
    // Collapse runs of whitespace / extra newlines produced by removal
    result = result.replaceAll(RegExp(r'[ \t]+'), ' ');
    result = result.replaceAll(RegExp(r'\n[ \t]*\n+'), '\n');
    return result.trim();
  }
}
