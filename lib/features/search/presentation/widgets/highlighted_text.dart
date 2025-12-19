import 'package:flutter/material.dart';
import '../../data/datasources/text_normalization_service.dart';

/// 🎨 Highlighted Text Widget - For search result highlighting
///
/// Highlights matching text in search results with proper font inheritance
/// ⚡ OPTIMIZED: Caches normalization and spans to avoid rebuilds
class HighlightedText extends StatefulWidget {
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
  State<HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText> {
  // ⚡ Cache to avoid recalculating on every build
  List<TextSpan>? _cachedSpans;
  String? _lastText;
  String? _lastQuery;

  @override
  void didUpdateWidget(HighlightedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ⚡ Only recalculate if text or query changed
    if (widget.text != oldWidget.text || widget.query != oldWidget.query) {
      _cachedSpans = null;
      _lastText = null;
      _lastQuery = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ Fast path: empty or no highlighting needed
    if (widget.query.isEmpty || widget.text.isEmpty) {
      return Text(widget.text, style: widget.textStyle);
    }

    // ⚡ Use cached spans if available
    if (_cachedSpans != null &&
        _lastText == widget.text &&
        _lastQuery == widget.query) {
      final baseStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
      return RichText(
        text: TextSpan(children: _cachedSpans!, style: baseStyle),
        overflow: widget.overflow ?? TextOverflow.ellipsis,
        maxLines: widget.maxLines ?? 2,
        textDirection: widget.textDirection ?? TextDirection.rtl,
      );
    }

    // ⚡ Calculate and cache spans
    _lastText = widget.text;
    _lastQuery = widget.query;
    _cachedSpans = _buildSpans();

    final baseStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
    return RichText(
      text: TextSpan(children: _cachedSpans!, style: baseStyle),
      overflow: widget.overflow ?? TextOverflow.ellipsis,
      maxLines: widget.maxLines ?? 2,
      textDirection: widget.textDirection ?? TextDirection.rtl,
    );
  }

  /// Build highlighted spans (cached)
  List<TextSpan> _buildSpans() {
    final normalizedText = TextNormalizationService.normalize(widget.text);
    final normalizedQuery = TextNormalizationService.normalize(widget.query);

    // Split query into words for multi-word highlighting
    final queryWords =
        normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();

    if (queryWords.isEmpty) {
      return [TextSpan(text: widget.text, style: widget.textStyle)];
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
      return [TextSpan(text: widget.text, style: widget.textStyle)];
    }

    matches.sort((a, b) => a.start.compareTo(b.start));
    final mergedMatches = _mergeMatches(matches);

    // Build TextSpans
    for (final match in mergedMatches) {
      // Add text before match
      if (currentIndex < match.start) {
        spans.add(
          TextSpan(
            text: widget.text.substring(currentIndex, match.start),
            style: widget.textStyle,
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: widget.text.substring(match.start, match.end),
          style: widget.highlightStyle ??
              (widget.textStyle ?? const TextStyle()).copyWith(
                backgroundColor: Colors.yellow.shade300,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < widget.text.length) {
      spans.add(
        TextSpan(
          text: widget.text.substring(currentIndex),
          style: widget.textStyle,
        ),
      );
    }

    return spans;
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
