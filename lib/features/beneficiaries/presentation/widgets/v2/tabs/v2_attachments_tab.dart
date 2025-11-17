import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/v2_section_card.dart';
import '../../../../../attachments/presentation/widgets/attachments_section_enhanced.dart';
import '../../../../../attachments/presentation/widgets/pending_attachments_section.dart';

/// Attachments tab for beneficiary form
///
/// يستخدم widgets مختلفة بناءً على الحالة:
/// - تعديل مستفيد (له beneficiaryId): AttachmentsSectionEnhanced من DB
/// - إضافة مستفيد جديد: PendingAttachmentsSection لإدارة pending files
class V2AttachmentsTab extends ConsumerWidget {
  final String? beneficiaryId;
  final List<File>? pendingFiles;
  final Function(List<File>)? onPendingFilesChanged;

  const V2AttachmentsTab({
    super.key,
    this.beneficiaryId,
    this.pendingFiles,
    this.onPendingFilesChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return V2SectionCard(
      title: 'المرفقات',
      icon: Icons.attach_file,
      children: [
        if (beneficiaryId != null && beneficiaryId!.isNotEmpty)
          AttachmentsSectionEnhanced(
            beneficiaryId: beneficiaryId!,
            readOnly: false,
            showTitle: false,
          )
        else
          PendingAttachmentsSection(
            initialFiles: pendingFiles ?? [],
            onFilesChanged: onPendingFilesChanged,
            showTitle: false,
          ),
      ],
    );
  }
}
