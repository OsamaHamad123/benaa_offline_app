import 'package:flutter/material.dart';
import 'selectable_chip.dart';

/// 💀 Death Cause Selector
///
/// محدد سبب الوفاة (طبيعية، مرض، حادث، مغدور، أخرى)
class DeathCauseSelector extends StatelessWidget {
  final int? selectedCause;
  final ValueChanged<int> onCauseSelected;

  const DeathCauseSelector({
    required this.selectedCause, required this.onCauseSelected, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سبب الوفاة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            SelectableChip(
              label: 'طبيعية',
              value: 1,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'مرض',
              value: 2,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'حادث',
              value: 4,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'مغدور',
              value: 7,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'أخرى',
              value: 5,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
          ],
        ),
      ],
    );
  }
}
