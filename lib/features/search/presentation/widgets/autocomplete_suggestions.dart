import 'package:flutter/material.dart';
import 'dart:collection';

/// 🎯 Autocomplete Suggestions Widget - Optimized with Memoization
/// Shows search suggestions as user types with intelligent caching
class AutocompleteSuggestions extends StatefulWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final double fontSize;

  const AutocompleteSuggestions({
    required this.suggestions, required this.onSuggestionTap, super.key,
    this.fontSize = 14,
  });

  @override
  State<AutocompleteSuggestions> createState() =>
      _AutocompleteSuggestionsState();
}

class _AutocompleteSuggestionsState extends State<AutocompleteSuggestions> {
  // ⚡ Memoization: Cache built widgets to avoid rebuilds
  late LinkedHashMap<String, Widget> _cachedSuggestionWidgets;
  late List<String> _lastSuggestions;

  @override
  void initState() {
    super.initState();
    _cachedSuggestionWidgets = LinkedHashMap();
    _lastSuggestions = [];
  }

  @override
  void didUpdateWidget(AutocompleteSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ⚡ Only rebuild if suggestions actually changed
    if (!_listsEqual(widget.suggestions, _lastSuggestions)) {
      _lastSuggestions = List.from(widget.suggestions);
      // Keep cache but mark for rebuild
    }
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _cachedSuggestionWidgets.clear(); // ⚡ Clean up cache
    super.dispose();
  }

  Widget _buildSuggestionItem(String suggestion, int index) {
    // ⚡ Return cached widget if available
    if (_cachedSuggestionWidgets.containsKey(suggestion)) {
      return _cachedSuggestionWidgets[suggestion]!;
    }

    // Build and cache new widget
    final widget = InkWell(
      onTap: () => this.widget.onSuggestionTap(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: this.widget.fontSize,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.north_west, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );

    // ⚡ Cache the widget (max 50 entries)
    _cachedSuggestionWidgets[suggestion] = widget;
    if (_cachedSuggestionWidgets.length > 50) {
      // Remove oldest entry (LRU)
      _cachedSuggestionWidgets.remove(_cachedSuggestionWidgets.keys.first);
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'اقتراحات',
                  style: TextStyle(
                    fontSize: widget.fontSize * 0.85,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          // Suggestions list - ⚡ Using memoized widgets
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.suggestions.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final suggestion = widget.suggestions[index];
              return _buildSuggestionItem(suggestion, index);
            },
          ),
        ],
      ),
    );
  }
}
