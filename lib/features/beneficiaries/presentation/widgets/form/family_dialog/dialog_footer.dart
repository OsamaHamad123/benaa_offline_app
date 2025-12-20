import 'package:flutter/material.dart';

/// 🎬 Family Dialog Footer
///
/// تذييل نافذة إضافة/تعديل أفراد الأسرة (أزرار إلغاء وحفظ)
class FamilyDialogFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const FamilyDialogFooter({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
  }
}
