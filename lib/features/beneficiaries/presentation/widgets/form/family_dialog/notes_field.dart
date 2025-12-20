import 'package:flutter/material.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';

/// 📝 Notes Field
///
/// حقل الملاحظات
class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return M3TextField(
      controller: controller,
      label: 'ملاحظات',
      prefixIcon: Icons.note_rounded,
      maxLines: 2,
      maxLength: 200,
    );
  }
}
