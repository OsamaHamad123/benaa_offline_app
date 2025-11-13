import 'package:flutter/material.dart';
import 'civil_search_widgets.dart';

/// قسم شريط البحث
class SearchBarSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool isSearching;
  final String query;

  const SearchBarSection({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isSearching,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CivilSearchBar(
        controller: controller,
        onChanged: onChanged,
        onClear: onClear,
        isSearching: isSearching,
        query: query,
      ),
    );
  }
}
