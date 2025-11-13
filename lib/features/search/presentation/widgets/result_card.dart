import 'package:flutter/material.dart';
import '../../domain/entities/civil_person.dart';
import 'person_info_card.dart';

/// بطاقة عرض نتيجة البحث - Clean Architecture
/// Wrapper around PersonInfoCard for backward compatibility
class ResultCard extends StatelessWidget {
  final CivilPerson person;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;

  const ResultCard({
    super.key,
    required this.person,
    required this.onCopy,
    required this.onAddAsBeneficiary,
  });

  @override
  Widget build(BuildContext context) {
    return PersonInfoCard(
      person: person,
      onCopy: onCopy,
      onAddAsBeneficiary: onAddAsBeneficiary,
      expanded: true, // Show all details
    );
  }
}
