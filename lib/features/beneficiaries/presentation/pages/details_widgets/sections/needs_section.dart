import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../formatters/notes_needs_formatter.dart';

/// 📝 Needs Section Widget
///
/// Displays beneficiary needs and notes
class NeedsSection extends StatelessWidget {
  final dynamic beneficiary;

  const NeedsSection({required this.beneficiary, super.key});

  @override
  Widget build(BuildContext context) {
    final formatted = NotesNeedsFormatter.format(beneficiary.notes?.toString());
    final notesText = formatted.notesText;
    final needs = formatted.needs;

    final children = [
                Text(
                  'الاحتياجات',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                if (needs.isEmpty)
                  Text(
                    'لا توجد احتياجات مسجلة',
                    style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: needs
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(growable: false),
                  ),
                SizedBox(height: 14.h),
                Text(
                  'ملاحظات',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                if (notesText.isEmpty)
                  Text(
                    'لا توجد ملاحظات مسجلة',
                    style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  )
                else
                  Text(
                    notesText,
                    style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes_outlined, color: Colors.amber, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'الاحتياجات والملاحظات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
