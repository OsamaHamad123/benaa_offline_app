import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/sync/mobile_sync_service.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../../domain/entities/attachment.dart';
import '../../../sync/presentation/providers/mobile_sync_operations_providers.dart';
import '../providers/attachments_provider.dart';

enum _AttachmentTypeFilter {
  all,
  image,
  pdf,
  other,
}

final _attachmentsTypeFilterProvider =
    StateProvider.family<_AttachmentTypeFilter, String>((ref, beneficiaryId) => _AttachmentTypeFilter.all);

final _attachmentsRenderLimitProvider = StateProvider.family<int, String>((ref, beneficiaryId) => 80);

const int _attachmentsRenderStep = 80;

/// 📎 Enhanced Attachments Section Widget - Clean Architecture V2
class AttachmentsSectionEnhanced extends ConsumerWidget {
  final String beneficiaryId;
  final bool readOnly;
  final bool showTitle;

  const AttachmentsSectionEnhanced({
    required this.beneficiaryId,
    super.key,
    this.readOnly = false,
    this.showTitle = true,
  });

  bool _isRefUsable(WidgetRef ref) {
    try {
      ref.read(attachmentsProvider(beneficiaryId));
      return true;
    } on StateError {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attachmentsProvider(beneficiaryId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) _buildHeader(context, ref, state),
        if (showTitle) SizedBox(height: 12.h),
        _buildContent(context, ref, state),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AttachmentsState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.attach_file_outlined, color: colorScheme.primary, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'المرفقات${state.attachments.isNotEmpty ? ' (${state.attachments.length})' : ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.cloud_download_outlined, size: 20.sp),
          tooltip: 'إعادة التحميل من السيرفر',
          onPressed: state.isLoading
              ? null
              : () {
                  _resyncAttachmentsFromServer(context, ref);
                },
        ),
        if (!readOnly && state.attachments.isNotEmpty)
          IconButton(
            icon: Icon(Icons.refresh, size: 20.sp),
            tooltip: 'تحديث',
            onPressed: () {
              ref.read(attachmentsProvider(beneficiaryId).notifier).loadAttachments(beneficiaryId);
            },
          ),
      ],
    );
  }

  Future<void> _resyncAttachmentsFromServer(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;

    final fileIdNumber = await _resolveFileIdNumberForSync(ref);
    if (fileIdNumber == null || fileIdNumber.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تعذر تحديد file_id_number لهذا المستفيد'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري إعادة التحميل من السيرفر للملف $fileIdNumber...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      final syncResult = await _syncRecordByFileIdWithRetry(ref, fileIdNumber);

      if (!_isRefUsable(ref)) return;
      await ref.read(attachmentsProvider(beneficiaryId).notifier).loadAttachments(beneficiaryId);

      if (!context.mounted) return;
      final ok = syncResult.success;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'تم تحديث المرفقات من السيرفر بنجاح'
                : 'اكتملت إعادة التحميل مع مشكلة: ${syncResult.error ?? 'غير معروفة'}',
          ),
          backgroundColor: ok ? colorScheme.secondary : colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت إعادة التحميل من السيرفر: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<MobileSyncResult> _syncRecordByFileIdWithRetry(WidgetRef ref, String fileIdNumber) async {
    final syncByFileId = ref.read(mobileSyncRecordByFileIdUseCaseProvider);

    MobileSyncResult? lastResult;
    Object? lastError;
    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final result = await syncByFileId(fileIdNumber);
        lastResult = result;

        if (result.success) {
          return result;
        }

        if (attempt < maxAttempts) {
          final delay = Duration(milliseconds: 350 * (1 << (attempt - 1)) + (attempt * 120));
          await Future.delayed(delay);
          continue;
        }

        return result;
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          final delay = Duration(milliseconds: 350 * (1 << (attempt - 1)) + (attempt * 120));
          await Future.delayed(delay);
          continue;
        }
      }
    }

    if (lastResult != null) {
      return lastResult;
    }

    return MobileSyncResult(
      success: false,
      recordsSynced: 0,
      recordsFailed: 1,
      error: lastError?.toString() ?? 'syncRecordByFileId failed after retries',
    );
  }

  Future<String?> _resolveFileIdNumberForSync(WidgetRef ref) async {
    final db = ref.read(databaseProvider);

    final localId = await BeneficiaryIdentityResolver.resolveLocalBeneficiaryId(
      database: db,
      beneficiaryId: beneficiaryId,
    );

    if (localId != null) {
      final beneficiary = await (db.select(db.beneficiaries)..where((b) => b.id.equals(localId))).getSingleOrNull();
      final fileId = beneficiary?.fileIdNumber?.trim();
      if (fileId != null && fileId.isNotEmpty) {
        return fileId;
      }

      final fallback = beneficiary?.originalFileIdFromExcel?.trim();
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
    }

    final raw = beneficiaryId.trim();
    if (raw.isNotEmpty) {
      return raw;
    }

    return null;
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AttachmentsState state,
  ) {
    if (state.isLoading) {
      return _buildLoading(context);
    }

    if (state.errorMessage != null) {
      return _buildError(context, ref, state.errorMessage!);
    }

    if (state.attachments.isEmpty) {
      return _buildEmpty(context, ref);
    }

    return _buildAttachmentsList(context, ref, state);
  }

  Widget _buildLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 12.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: colorScheme.error),
            SizedBox(height: 12.h),
            Text(
              error,
              style: TextStyle(color: colorScheme.error, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(attachmentsProvider(beneficiaryId).notifier).loadAttachments(beneficiaryId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file_outlined,
              size: 64.sp,
              color: colorScheme.outline,
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد مرفقات',
              style: TextStyle(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!readOnly) ...[
              SizedBox(height: 8.h),
              Text(
                'اضغط على الزر أدناه لإضافة مرفقات',
                style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurfaceVariant),
              ),
              SizedBox(height: 16.h),
              _buildAddButton(context, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsList(
    BuildContext context,
    WidgetRef ref,
    AttachmentsState state,
  ) {
    final attachments = state.attachments;
    final selectedFilter = ref.watch(_attachmentsTypeFilterProvider(beneficiaryId));
    final filteredAttachments = _filterAttachmentsByType(attachments, selectedFilter);
    final currentRenderLimit = ref.watch(_attachmentsRenderLimitProvider(beneficiaryId));
    final limitedAttachments = filteredAttachments.length > currentRenderLimit
        ? filteredAttachments.take(currentRenderLimit).toList(growable: false)
        : filteredAttachments;
    final notifier = ref.read(attachmentsProvider(beneficiaryId).notifier);
    final groupedAttachments = _groupAttachmentsForDisplay(limitedAttachments);
    final hasMoreToRender = filteredAttachments.length > limitedAttachments.length;

    final allCount = attachments.length;

    return Column(
      children: [
        if (!readOnly) ...[
          _buildAddButton(context, ref),
          SizedBox(height: 16.h),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(context, ref, _AttachmentTypeFilter.all, attachments),
              SizedBox(width: 6.w),
              _buildFilterChip(context, ref, _AttachmentTypeFilter.image, attachments),
              SizedBox(width: 6.w),
              _buildFilterChip(context, ref, _AttachmentTypeFilter.pdf, attachments),
              SizedBox(width: 6.w),
              _buildFilterChip(context, ref, _AttachmentTypeFilter.other, attachments),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'المعروض: ${limitedAttachments.length}/${filteredAttachments.length} • الإجمالي: $allCount • المجموعات: ${groupedAttachments.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        if (hasMoreToRender) ...[
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                final notifierLimit = ref.read(_attachmentsRenderLimitProvider(beneficiaryId).notifier);
                notifierLimit.state = currentRenderLimit + _attachmentsRenderStep;
              },
              icon: const Icon(Icons.expand_more),
              label: Text('عرض المزيد (+$_attachmentsRenderStep)'),
            ),
          ),
        ],
        if (currentRenderLimit > _attachmentsRenderStep && limitedAttachments.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ref.read(_attachmentsRenderLimitProvider(beneficiaryId).notifier).state = _attachmentsRenderStep;
              },
              child: const Text('إعادة طي القائمة'),
            ),
          ),
        ],
        SizedBox(height: 8.h),
        ...groupedAttachments.asMap().entries.map((groupEntry) {
          final group = groupEntry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: groupEntry.key == groupedAttachments.length - 1 ? 0 : 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_shared_outlined,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          group.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Text(
                        '${group.items.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemCount: group.items.length,
                  itemBuilder: (context, index) {
                    final attachment = group.items[index];
                    return _EnhancedAttachmentCard(
                      attachment: attachment,
                      isResolving: state.resolvingAttachmentIds.contains(attachment.id),
                      resolutionError: state.attachmentErrors[attachment.id],
                      isCompressed: notifier.isCompressedAttachment(attachment),
                      resolvedPath: (state.resolvedAttachmentPaths ?? const <String, String>{})[attachment.id],
                      onTap: () => _openAttachment(context, ref, attachment),
                      onPrimaryAction: () => _openAttachment(context, ref, attachment),
                      onShare: () => _shareAttachment(context, ref, attachment),
                      onDelete: readOnly ? null : () => _deleteAttachment(context, ref, attachment),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<Attachment> _filterAttachmentsByType(
    List<Attachment> attachments,
    _AttachmentTypeFilter filter,
  ) {
    if (filter == _AttachmentTypeFilter.all) {
      return attachments;
    }

    return attachments.where((attachment) {
      switch (filter) {
        case _AttachmentTypeFilter.all:
          return true;
        case _AttachmentTypeFilter.image:
          return attachment.type == AttachmentType.image;
        case _AttachmentTypeFilter.pdf:
          return attachment.type == AttachmentType.pdf;
        case _AttachmentTypeFilter.other:
          return attachment.type == AttachmentType.other;
      }
    }).toList(growable: false);
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    _AttachmentTypeFilter filter,
    List<Attachment> attachments,
  ) {
    final selected = ref.watch(_attachmentsTypeFilterProvider(beneficiaryId)) == filter;
    final label = _filterLabel(filter);
    final count = _filterAttachmentsByType(attachments, filter).length;

    return ChoiceChip(
      selected: selected,
      label: Text('$label ($count)'),
      onSelected: (_) {
        ref.read(_attachmentsTypeFilterProvider(beneficiaryId).notifier).state = filter;
      },
      visualDensity: VisualDensity.compact,
    );
  }

  String _filterLabel(_AttachmentTypeFilter filter) {
    switch (filter) {
      case _AttachmentTypeFilter.all:
        return 'الكل';
      case _AttachmentTypeFilter.image:
        return 'صور';
      case _AttachmentTypeFilter.pdf:
        return 'PDF';
      case _AttachmentTypeFilter.other:
        return 'أخرى';
    }
  }

  List<({String label, List<Attachment> items})> _groupAttachmentsForDisplay(List<Attachment> attachments) {
    final groups = <String, ({String label, List<Attachment> items})>{};

    for (final attachment in attachments) {
      final personType = (attachment.personType ?? '').trim();
      final personId = (attachment.personId ?? '').trim();
      final documentType = (attachment.documentType ?? '').trim();

      final personLabel = _personTypeLabel(personType.isEmpty ? 'unknown' : personType);
      final personToken = personType.isNotEmpty ? personType : 'unknown';
      final personIdToken = personId.isNotEmpty ? personId : 'none';
      final documentToken = documentType.isNotEmpty ? documentType.toLowerCase() : 'untyped';
      final groupKey = '$personToken::$personIdToken::$documentToken';

      final groupLabel = [
        if (personLabel.isNotEmpty) personLabel,
        if (personId.isNotEmpty) personId,
        documentType.isNotEmpty ? documentType : 'غير مصنف',
      ].join(' • ');

      final existing = groups[groupKey];
      if (existing == null) {
        groups[groupKey] = (label: groupLabel, items: <Attachment>[attachment]);
      } else {
        existing.items.add(attachment);
      }
    }

    final output = groups.values.toList(growable: false)..sort((a, b) => a.label.compareTo(b.label));

    for (final group in output) {
      group.items.sort((a, b) {
        final byUpdated = b.updatedAt.compareTo(a.updatedAt);
        if (byUpdated != 0) return byUpdated;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    return output;
  }

  String _personTypeLabel(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'file_owner':
        return 'صاحب الملف';
      case 'family_member':
        return 'فرد عائلة';
      case 'deceased_member':
        return 'متوفى';
      case 'deceased_father':
        return 'الأب المتوفى';
      case 'deceased_mother':
        return 'الأم المتوفية';
      default:
        return 'غير محدد';
    }
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showAddOptions(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('إضافة مرفق'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _showAddOptions(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'إضافة مرفق',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
                title: const Text('التقاط صورة'),
                subtitle: const Text('استخدام الكاميرا'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromCamera(context, ref);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: colorScheme.secondary,
                    size: 24.sp,
                  ),
                ),
                title: const Text('اختيار من المعرض'),
                subtitle: const Text('اختيار صورة أو أكثر'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromGallery(context, ref);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: colorScheme.error,
                    size: 24.sp,
                  ),
                ),
                title: const Text('اختيار ملف PDF'),
                subtitle: const Text('تحديد ملف أو أكثر'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addPdfFile(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImageFromCamera(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null && context.mounted) {
      await _addAttachment(context, ref, File(image.path));
    }
  }

  Future<void> _addImageFromGallery(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty && context.mounted) {
      for (final image in images) {
        await _addAttachment(context, ref, File(image.path));
      }
    }
  }

  Future<void> _addPdfFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty && context.mounted) {
      for (final file in result.files) {
        if (file.path != null) {
          await _addAttachment(context, ref, File(file.path!));
        }
      }
    }
  }

  Future<void> _addAttachment(
    BuildContext context,
    WidgetRef ref,
    File file,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_isRefUsable(ref)) return;
    final notifier = ref.read(attachmentsProvider(beneficiaryId).notifier);

    // Show loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              const Text('جاري إضافة المرفق...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final success = await notifier.addAttachment(
      beneficiaryId: beneficiaryId,
      sourceFile: file,
    );

    if (!_isRefUsable(ref)) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? colorScheme.onSecondary : colorScheme.onError,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(success ? '✓ تمت إضافة المرفق بنجاح' : '✗ فشل إضافة المرفق'),
            ],
          ),
          backgroundColor: success ? colorScheme.secondary : colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteAttachment(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.tertiary,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل تريد حذف "${attachment.fileName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (!_isRefUsable(ref)) return;
      final notifier = ref.read(attachmentsProvider(beneficiaryId).notifier);
      final success = await notifier.deleteAttachment(attachment.id);

      if (!_isRefUsable(ref)) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? colorScheme.onSecondary : colorScheme.onError,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(success ? '✓ تم حذف المرفق بنجاح' : '✗ فشل حذف المرفق'),
              ],
            ),
            backgroundColor: success ? colorScheme.secondary : colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openAttachment(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final file = await _resolveAttachmentFile(context, ref, attachment);
    if (file == null || !context.mounted) {
      return;
    }

    await OpenFile.open(file.path);
  }

  Future<File?> _resolveAttachmentFile(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_isRefUsable(ref)) return null;
    final notifier = ref.read(attachmentsProvider(beneficiaryId).notifier);
    notifier.clearAttachmentError(attachment.id);

    final file = await notifier.resolveAttachmentFile(
      attachment,
      allowRemoteFetch: true,
    );
    if (!_isRefUsable(ref)) return null;
    if (file != null && file.existsSync()) {
      return file;
    }

    if (context.mounted && _isRefUsable(ref)) {
      final state = ref.read(attachmentsProvider(beneficiaryId));
      final message = state.attachmentErrors[attachment.id] ??
          ((attachment.serverUrl != null && attachment.serverUrl!.trim().isNotEmpty)
              ? 'تعذر تنزيل المرفق عند الطلب. تأكد من الإنترنت أو أعد المزامنة.'
              : 'الملف غير متوفر محلياً');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: colorScheme.onError, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: colorScheme.error,
        ),
      );
    }

    return null;
  }

  Future<void> _shareAttachment(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    if (!_isRefUsable(ref)) return;
    final file = await _resolveAttachmentFile(context, ref, attachment);
    if (file == null) {
      return;
    }

    await Share.shareXFiles([XFile(file.path)], subject: attachment.fileName);
  }
}

/// Enhanced Attachment Card Widget
class _EnhancedAttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final bool isResolving;
  final bool isCompressed;
  final String? resolutionError;
  final String? resolvedPath;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;
  final VoidCallback onShare;
  final VoidCallback? onDelete;

  const _EnhancedAttachmentCard({
    required this.attachment,
    required this.isResolving,
    required this.isCompressed,
    required this.resolutionError,
    required this.resolvedPath,
    required this.onTap,
    required this.onPrimaryAction,
    required this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileStatus = _fileSourceStatus(context);
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: isResolving ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: _buildThumbnail(context),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFileName(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _buildTag(
                          icon: Icons.description_outlined,
                          label: attachment.type.arabicLabel,
                          background: _getTypeColor(context).withValues(alpha: 0.12),
                          foreground: _getTypeColor(context),
                        ),
                        _buildTag(
                          icon: Icons.storage,
                          label: attachment.fileSizeReadable,
                          background: colorScheme.surfaceContainerHighest,
                          foreground: colorScheme.onSurfaceVariant,
                        ),
                        if (attachment.documentType != null && attachment.documentType!.trim().isNotEmpty)
                          _buildTag(
                            icon: Icons.badge_outlined,
                            label: attachment.documentType!.trim(),
                            background: colorScheme.primaryContainer,
                            foreground: colorScheme.onPrimaryContainer,
                          ),
                        if (attachment.personType != null && attachment.personType!.trim().isNotEmpty)
                          _buildTag(
                            icon: Icons.person_outline,
                            label: _personTypeLabel(attachment.personType!),
                            background: colorScheme.secondaryContainer,
                            foreground: colorScheme.onSecondaryContainer,
                          ),
                        if (attachment.personId != null && attachment.personId!.trim().isNotEmpty)
                          _buildTag(
                            icon: Icons.tag,
                            label: attachment.personId!.trim(),
                            background: colorScheme.surfaceContainerHighest,
                            foreground: colorScheme.onSurfaceVariant,
                          ),
                        _buildTag(
                          icon: fileStatus.$1,
                          label: fileStatus.$2,
                          background: fileStatus.$3,
                          foreground: fileStatus.$4,
                        ),
                        if (isCompressed)
                          _buildTag(
                            icon: Icons.folder_zip,
                            label: 'ZIP',
                            background: colorScheme.tertiaryContainer,
                            foreground: colorScheme.onTertiaryContainer,
                          ),
                      ],
                    ),
                    if (resolutionError != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        resolutionError!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                children: [
                  IconButton(
                    onPressed: isResolving ? null : onPrimaryAction,
                    icon: Icon(_primaryActionIcon(), size: 20.sp),
                    tooltip: _primaryActionLabel(),
                  ),
                  IconButton(
                    onPressed: isResolving ? null : onShare,
                    icon: Icon(Icons.share, size: 20.sp),
                    tooltip: 'مشاركة',
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: isResolving ? null : onDelete,
                      icon: Icon(Icons.delete_outline, size: 20.sp, color: colorScheme.error),
                      tooltip: 'حذف',
                    ),
                ],
              ),
              if (isResolving)
                Padding(
                  padding: EdgeInsets.only(top: 6.h, right: 2.w),
                  child: SizedBox(
                    width: 18.sp,
                    height: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (attachment.isImage) {
      final preferredPath = resolvedPath ?? attachment.thumbnailPath ?? attachment.filePath;
      final preferredFile = File(preferredPath);

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: colorScheme.surfaceContainer,
        child: Image.file(
          preferredFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) {
            final remoteUrl = _toRemoteUrl(attachment.serverUrl) ?? _toRemoteUrl(attachment.filePath);
            if (remoteUrl != null && !_looksLikeZipReference(remoteUrl)) {
              return _buildIcon(context, Icons.cloud_off_outlined, colorScheme.onSurfaceVariant);
            }
            if (isResolving) {
              return Container(
                color: colorScheme.surfaceContainer,
                child: Center(
                  child: SizedBox(
                    width: 18.sp,
                    height: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              );
            }
            return _buildIcon(context, Icons.image_not_supported_outlined, colorScheme.onSurfaceVariant);
          },
        ),
      );
    } else if (attachment.isPdf) {
      return _buildIcon(context, Icons.picture_as_pdf, colorScheme.error);
    } else {
      return _buildIcon(context, Icons.insert_drive_file, colorScheme.onSurfaceVariant);
    }
  }

  Widget _buildIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, size: 48.sp, color: color),
      ),
    );
  }

  Color _getTypeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (attachment.type) {
      case AttachmentType.image:
        return colorScheme.secondary;
      case AttachmentType.pdf:
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getFileName() {
    if (attachment.fileName.length > 60) {
      return '${attachment.fileName.substring(0, 57)}...';
    }
    return attachment.fileName;
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String? _toRemoteUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final value = raw.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${ApiConfig.defaultBaseUrl}$value';
    }
    if (value.startsWith('api/') || value.startsWith('storage/') || value.startsWith('uploads/')) {
      return '${ApiConfig.defaultBaseUrl}/$value';
    }
    return null;
  }

  bool _looksLikeZipReference(String value) {
    final lower = value.toLowerCase();
    return lower.contains('.zip!') || lower.contains('.zip?') || lower.endsWith('.zip');
  }

  String _personTypeLabel(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'file_owner':
        return 'صاحب الملف';
      case 'family_member':
        return 'فرد عائلة';
      case 'deceased_member':
        return 'متوفى';
      case 'deceased_father':
        return 'الأب المتوفى';
      case 'deceased_mother':
        return 'الأم المتوفية';
      default:
        return raw.trim();
    }
  }

  (IconData, String, Color, Color) _fileSourceStatus(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localPath = (resolvedPath ?? attachment.thumbnailPath ?? attachment.filePath).trim();
    final looksLocal = localPath.isNotEmpty &&
        !localPath.startsWith('http://') &&
        !localPath.startsWith('https://') &&
        !localPath.startsWith('/api/') &&
        !localPath.startsWith('api/');

    if (looksLocal) {
      return (
        Icons.check_circle_outline,
        'محلي',
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      );
    }

    final remoteUrl = _toRemoteUrl(attachment.serverUrl) ?? _toRemoteUrl(attachment.filePath);
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return (
        Icons.cloud_outlined,
        'عن بُعد',
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      );
    }

    return (
      Icons.error_outline,
      'غير متاح',
      colorScheme.errorContainer,
      colorScheme.onErrorContainer,
    );
  }

  IconData _primaryActionIcon() {
    final localPath = (resolvedPath ?? attachment.thumbnailPath ?? attachment.filePath).trim();
    final looksLocal = localPath.isNotEmpty &&
        !localPath.startsWith('http://') &&
        !localPath.startsWith('https://') &&
        !localPath.startsWith('/api/') &&
        !localPath.startsWith('api/');
    if (looksLocal) {
      return Icons.open_in_new;
    }

    final remoteUrl = _toRemoteUrl(attachment.serverUrl) ?? _toRemoteUrl(attachment.filePath);
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Icons.download_outlined;
    }

    return Icons.open_in_new;
  }

  String _primaryActionLabel() {
    final localPath = (resolvedPath ?? attachment.thumbnailPath ?? attachment.filePath).trim();
    final looksLocal = localPath.isNotEmpty &&
        !localPath.startsWith('http://') &&
        !localPath.startsWith('https://') &&
        !localPath.startsWith('/api/') &&
        !localPath.startsWith('api/');
    if (looksLocal) {
      return 'فتح';
    }

    final remoteUrl = _toRemoteUrl(attachment.serverUrl) ?? _toRemoteUrl(attachment.filePath);
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return 'تنزيل';
    }

    return 'فتح';
  }
}
