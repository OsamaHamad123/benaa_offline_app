import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📝 Needs Section Widget
///
/// Displays beneficiary needs and notes
class NeedsSection extends StatelessWidget {
  final dynamic beneficiary;

  const NeedsSection({super.key, required this.beneficiary});

  @override
  Widget build(BuildContext context) {
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
              beneficiary.notes!,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
