import 'package:flutter/material.dart';

/// 🎬 Family Dialog Header
///
/// رأس نافذة إضافة/تعديل أفراد الأسرة
class FamilyDialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onClose;

  const FamilyDialogHeader({
    required this.title, required this.icon, required this.onClose, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }
}
