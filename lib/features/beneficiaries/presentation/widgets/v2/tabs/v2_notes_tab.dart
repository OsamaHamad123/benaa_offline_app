import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_section_card.dart';

/// Notes tab
class V2NotesTab extends StatelessWidget {
  final TextEditingController notesController;

  const V2NotesTab({super.key, required this.notesController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'ملاحظات إضافية',
          icon: Icons.note_alt_rounded,
          children: [
            V2CustomTextField(
              controller: notesController,
              label: 'الملاحظات',
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 8,
              hint: 'أضف أي ملاحظات أو معلومات إضافية هنا...',
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'هذه الملاحظات سرية ومخصصة للاستخدام الداخلي فقط',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
