import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../attachments/domain/models/pending_attachment.dart';
import '../../../../../attachments/presentation/widgets/attachments_section_enhanced.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../form/attachments/enhanced_upload_card.dart';
import '../../form/attachments/organized_attachments_card.dart';

/// 📎 تبويب المرفقات الموحد - المحسّن
///
/// يحتوي على:
/// ✅ نظام رفع محسّن مع اختيار نوع الوثيقة والشخص
/// ✅ عرض منظم للمرفقات حسب الشخص
/// ✅ دعم أنواع مختلفة من الوثائق
class V2UnifiedAttachmentsTab extends ConsumerStatefulWidget {
  final String? beneficiaryId;
  final List<File>? pendingFiles;
  final Function(List<File>)? onPendingFilesChanged;
  final BeneficiaryFormControllers? formControllers;

  const V2UnifiedAttachmentsTab({
    super.key,
    this.beneficiaryId,
    this.pendingFiles,
    this.onPendingFilesChanged,
    this.formControllers,
  });

  @override
  ConsumerState<V2UnifiedAttachmentsTab> createState() => _V2UnifiedAttachmentsTabState();
}

class _V2UnifiedAttachmentsTabState extends ConsumerState<V2UnifiedAttachmentsTab> {
  @override
  Widget build(BuildContext context) {
    // Get available family members for dropdown
    final familyMembers = _getAvailableFamilyMembers();

    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: const ClampingScrollPhysics(),
      children: [
        // 📤 Enhanced Upload Card
        EnhancedUploadAttachmentCard(
          availableFamilyMembers: familyMembers,
          onAttachmentAdded: (attachment) {
            if (widget.formControllers != null) {
              widget.formControllers!.addPendingAttachment(attachment);
            }
          },
        ),

        SizedBox(height: 24.h),

        // 📋 Organized Attachments Display
        if (widget.formControllers != null)
          ValueListenableBuilder<List<PendingAttachment>>(
            valueListenable: widget.formControllers!.pendingAttachmentsNotifier,
            builder: (context, attachments, _) {
              return OrganizedAttachmentsCard(
                attachments: attachments,
                onDelete: (attachment) {
                  widget.formControllers!.removePendingAttachment(attachment);
                },
              );
            },
          ),

        if (widget.beneficiaryId != null && widget.beneficiaryId!.trim().isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'المرفقات المحفوظة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          AttachmentsSectionEnhanced(
            beneficiaryId: widget.beneficiaryId!,
            readOnly: true,
            showTitle: false,
          ),
        ],
      ],
    );
  }

  List<String> _getAvailableFamilyMembers() {
    if (widget.formControllers == null) return [];

    final members = <String>[];

    // Add living members
    for (final member in widget.formControllers!.livingMembers) {
      final name = _getMemberName(member);
      if (name.isNotEmpty) {
        members.add(name);
      }
    }

    // Add deceased members
    for (final member in widget.formControllers!.deceasedMembers) {
      final name = _getMemberName(member);
      if (name.isNotEmpty) {
        members.add('$name (متوفي)');
      }
    }

    return members;
  }

  String _getMemberName(Map<String, dynamic> member) {
    final firstName = member['firstName'] ?? '';
    final lastName = member['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }
}
