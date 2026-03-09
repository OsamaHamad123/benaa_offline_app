import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📝 Needs Section Widget
///
/// Displays beneficiary needs and notes
class NeedsSection extends StatelessWidget {
  final dynamic beneficiary;

  const NeedsSection({required this.beneficiary, super.key});

  @override
  Widget build(BuildContext context) {
    final displayNotes = _cleanNotesForDisplay(beneficiary.notes?.toString());

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
            child: Text(
              displayNotes,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _cleanNotesForDisplay(String? raw) {
    final notes = (raw ?? '').trim();
    if (notes.isEmpty) return '---';

    const marker = '\n\n#meta:';
    final markerIndex = notes.lastIndexOf(marker);
    if (markerIndex == -1) {
      return notes;
    }

    final clean = notes.substring(0, markerIndex).trimRight();
    return clean.isEmpty ? '---' : clean;
  }
}
