import 'package:flutter/material.dart';
import 'document_card.dart';

/// 📄 Document Type Selector for Family Members
///
/// محدد نوع الوثيقة (شهادة وفاة، إفادة شهيد)
class DocumentTypeSelector extends StatelessWidget {
  final int? selectedType;
  final ValueChanged<int> onTypeSelected;

  const DocumentTypeSelector({
    required this.selectedType, required this.onTypeSelected, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الوثيقة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: DocumentCard(
                label: 'شهادة وفاة',
                icon: Icons.description,
                value: 1,
                groupValue: selectedType,
                onTap: onTypeSelected,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: DocumentCard(
                label: 'إفادة شهيد',
                icon: Icons.military_tech,
                value: 2,
                groupValue: selectedType,
                onTap: onTypeSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
