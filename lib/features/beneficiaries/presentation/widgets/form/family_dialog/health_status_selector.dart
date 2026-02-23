import 'package:flutter/material.dart';
import 'selectable_chip.dart';

/// 🏥 Health Status Selector
///
/// محدد الحالة الصحية (سليم، مريض، مزمن، معاق)
class HealthStatusSelector extends StatelessWidget {
  final int? selectedStatus;
  final ValueChanged<int> onStatusSelected;

  const HealthStatusSelector({
    required this.selectedStatus, required this.onStatusSelected, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الحالة الصحية',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            SelectableChip(
              label: 'سليم',
              value: 1,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.green,
            ),
            SelectableChip(
              label: 'مريض',
              value: 2,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.orange,
            ),
            SelectableChip(
              label: 'مزمن',
              value: 3,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.red,
            ),
            SelectableChip(
              label: 'معاق',
              value: 4,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}
