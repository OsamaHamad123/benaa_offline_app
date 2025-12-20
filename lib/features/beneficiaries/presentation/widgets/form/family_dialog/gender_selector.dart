import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 👥 Gender Selector
///
/// محدد الجنس (ذكر/أنثى)
class GenderSelector extends StatelessWidget {
  final int selectedGender;
  final ValueChanged<int> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الجنس *', style: TextStyle(fontSize: 13.0)),
        const SizedBox(height: 8.0),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 1,
              label: Text('ذكر'),
              icon: Icon(Icons.boy, size: 18),
            ),
            ButtonSegment(
              value: 2,
              label: Text('أنثى'),
              icon: Icon(Icons.girl, size: 18),
            ),
          ],
          selected: {selectedGender},
          onSelectionChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged(v.first);
          },
          style: ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }
}
