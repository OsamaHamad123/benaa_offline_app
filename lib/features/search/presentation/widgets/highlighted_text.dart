import 'package:flutter/material.dart';
import '../../data/datasources/text_normalization_service.dart';

/// 🎨 Highlighted Text Widget - For search result highlighting
///
/// Highlights matching text in search results with proper font inheritance
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? textStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDirection? textDirection;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.textStyle,
    this.highlightStyle,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || text.isEmpty) {
      return Text(text, style: textStyle);
    }

    final normalizedText = TextNormalizationService.normalize(text);
    final normalizedQuery = TextNormalizationService.normalize(query);

    // Split query into words for multi-word highlighting
    final queryWords = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    if (queryWords.isEmpty) {
      return Text(text, style: textStyle);
    }

    // Build highlight spans
    final spans = <TextSpan>[];
    var currentIndex = 0;
    final matches = <_Match>[];

    // Find all matches for each query word
    for (final word in queryWords) {
      var searchFrom = 0;
      while (true) {
        final index = normalizedText.indexOf(word, searchFrom);
        if (index == -1) break;

        matches.add(_Match(index, index + word.length));
        searchFrom = index + 1;
      }
    }

    // Sort and merge overlapping matches
    if (matches.isEmpty) {
      return Text(text, style: textStyle);
    }

    matches.sort((a, b) => a.start.compareTo(b.start));
    final mergedMatches = _mergeMatches(matches);

    // Build TextSpans
    for (final match in mergedMatches) {
      // Add text before match
      if (currentIndex < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: textStyle,
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style:
              highlightStyle ??
              (textStyle ?? const TextStyle()).copyWith(
                backgroundColor: Colors.yellow.shade300,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: textStyle));
    }

    // Get base style from context or use provided textStyle
    final baseStyle = textStyle ?? DefaultTextStyle.of(context).style;

    return RichText(
      text: TextSpan(children: spans, style: baseStyle),
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 2,
      textDirection: textDirection ?? TextDirection.rtl, // ⚡ Arabic by default
    );
  }

  /// Merge overlapping matches
  List<_Match> _mergeMatches(List<_Match> matches) {
    if (matches.isEmpty) return [];

    final merged = <_Match>[matches.first];

    for (var i = 1; i < matches.length; i++) {
      final current = matches[i];
      final last = merged.last;

      if (current.start <= last.end) {
        // Overlapping - merge
        merged[merged.length - 1] = _Match(
          last.start,
          current.end > last.end ? current.end : last.end,
        );
      } else {
        // Non-overlapping - add new
        merged.add(current);
      }
    }

    return merged;
  }
}

/// Match data class
class _Match {
  final int start;
  final int end;

  _Match(this.start, this.end);
}
