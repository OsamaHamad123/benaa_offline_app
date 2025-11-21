import 'package:flutter/material.dart';
import '../../domain/entities/civil_person.dart';
import 'person_info_card.dart';

/// بطاقة عرض نتيجة البحث - Clean Architecture
/// Wrapper around PersonInfoCard with search highlighting support
class ResultCard extends StatelessWidget {
  final CivilPerson person;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;
  final String? searchQuery; // 🎯 NEW: للتظليل

  const ResultCard({
    super.key,
    required this.person,
    required this.onCopy,
    required this.onAddAsBeneficiary,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // ⚡ RepaintBoundary removed - SliverList handles it automatically
    // Duplicate RepaintBoundary causes performance overhead
    return PersonInfoCard(
      person: person,
      onCopy: onCopy,
      onAddAsBeneficiary: onAddAsBeneficiary,
      expanded: true,
      searchQuery: searchQuery, // 🎯 تمرير الـ query
    );
  }
}
