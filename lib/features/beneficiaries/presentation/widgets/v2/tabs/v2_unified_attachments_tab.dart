import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../attachments/domain/models/pending_attachment.dart';
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

class _MainBeneficiaryAttachmentsSection extends StatelessWidget {
  final String? beneficiaryId;
  final List<File>? pendingFiles;
  final Function(List<File>)? onPendingFilesChanged;
  final BeneficiaryFormControllers? formControllers; // 🆕 Add formControllers

  const _MainBeneficiaryAttachmentsSection({
    this.beneficiaryId,
    this.pendingFiles,
    this.onPendingFilesChanged,
    this.formControllers, // 🆕 Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.folder_special, color: Colors.blue.shade700),
        title: Text(
          'مرفقات المستفيد الرئيسية',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'الهوية، الصور، الوثائق الرسمية',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: beneficiaryId != null && beneficiaryId!.isNotEmpty
                ? AttachmentsSectionEnhanced(
                    beneficiaryId: beneficiaryId!,
                    readOnly: false,
                    showTitle: false,
                  )
                : EnhancedPendingAttachmentsSection(
                    // 🆕 Use enhanced version
                    initialAttachments: formControllers?.pendingAttachments ?? [],
                    onAttachmentsChanged: (attachments) {
                      formControllers?.updatePendingAttachments(attachments);
                    },
                    showTitle: false,
                    requireMetadata: true, // 🆕 Require metadata input
                  ),
          ),
        ],
      ),
    );
  }
}

/// 🪦 قسم مرفقات الوالدين المتوفيين
class _DeceasedParentsAttachmentsSection extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;

  const _DeceasedParentsAttachmentsSection({required this.formControllers});

  @override
  Widget build(BuildContext context) {
    final deceasedCount = formControllers.deceasedMembers.length;

    if (deceasedCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.description, color: Colors.red.shade700),
        title: Text(
          'مرفقات الوالدين المتوفيين',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'شهادات الوفاة والوثائق ($deceasedCount)',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(
                  height: (deceasedCount.clamp(0, 6) * 88).toDouble(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: deceasedCount,
                    itemBuilder: (context, index) {
                      final deceased = formControllers.deceasedMembers[index];
                      final type = deceased['deceasedType'] == 1 ? 'الأب' : 'الأم';
                      final fullName = '${deceased['firstName'] ?? ''} ${deceased['familyName'] ?? ''}';

                      return _AttachmentSubSection(
                        key: ValueKey('deceased_attachments_$index'),
                        title: '$type - $fullName',
                        icon: deceased['deceasedType'] == 1 ? Icons.man : Icons.woman,
                        color: deceased['deceasedType'] == 1 ? Colors.blue : Colors.pink,
                        attachmentTypes: const [
                          'شهادة الوفاة',
                          'بطاقة الهوية',
                          'مستندات أخرى',
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 👶 قسم مرفقات الأيتام
class _OrphansAttachmentsSection extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;

  const _OrphansAttachmentsSection({required this.formControllers});

  @override
  Widget build(BuildContext context) {
    final orphansCount = formControllers.livingMembers.length;

    if (orphansCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.attach_file, color: Colors.green.shade700),
        title: Text(
          'مرفقات الأيتام',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'مرفقات كل يتيم على حدة ($orphansCount)',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(
                  height: (orphansCount.clamp(0, 6) * 88).toDouble(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: orphansCount,
                    itemBuilder: (context, index) {
                      final orphan = formControllers.livingMembers[index];
                      final fullName = '${orphan['firstName'] ?? ''} ${orphan['familyName'] ?? ''}';
                      final gender = orphan['gender'] as int?;
                      final isMale = gender == 1;

                      return _AttachmentSubSection(
                        key: ValueKey('orphan_attachments_$index'),
                        title: fullName,
                        icon: isMale ? Icons.boy : Icons.girl,
                        color: isMale ? Colors.blue : Colors.pink,
                        attachmentTypes: const [
                          'صورة شخصية',
                          'صورة كاملة',
                          'بطاقة الهوية',
                          'شهادة الميلاد',
                          'تقرير طبي',
                          'آخر شهادة دراسية',
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم فرعي للمرفقات
class _AttachmentSubSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> attachmentTypes;

  const _AttachmentSubSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.attachmentTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 16.r,
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // أنواع المرفقات المطلوبة
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: attachmentTypes.map((type) {
              return Chip(
                label: Text(type, style: TextStyle(fontSize: 11.sp)),
                avatar: const Icon(Icons.file_present, size: 16),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // أزرار الإجراءات
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: رفع مرفقات
                },
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('رفع مرفقات'),
              ),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: عرض المرفقات
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('عرض'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
