import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../attachments/presentation/widgets/attachments_section_enhanced.dart';

/// 📎 Attachments Section Widget
///
/// Displays beneficiary attachments
class AttachmentsSection extends StatelessWidget {
  final String beneficiaryId;

  const AttachmentsSection({required this.beneficiaryId, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file_outlined,
              color: colorScheme.primary,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'المرفقات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: AttachmentsSectionEnhanced(
              beneficiaryId: beneficiaryId,
            ),
          ),
        ),
      ],
    );
  }
}
