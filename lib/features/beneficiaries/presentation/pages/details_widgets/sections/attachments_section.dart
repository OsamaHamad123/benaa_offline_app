import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../attachments/presentation/widgets/attachments_section_enhanced.dart';

/// 📎 Attachments Section Widget
///
/// Displays beneficiary attachments
class AttachmentsSection extends StatelessWidget {
  final String beneficiaryId;

  const AttachmentsSection({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file_outlined,
              color: Colors.blueGrey,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'المرفقات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
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
            child: AttachmentsSectionEnhanced(
              beneficiaryId: beneficiaryId,
              readOnly: false,
            ),
          ),
        ),
      ],
    );
  }
}
