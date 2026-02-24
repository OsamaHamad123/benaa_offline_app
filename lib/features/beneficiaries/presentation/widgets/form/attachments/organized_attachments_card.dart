import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../attachments/domain/models/pending_attachment.dart';
import '../../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// 📋 Organized Attachments Display Card
///
/// عرض المرفقات منظمة حسب الشخص والنوع
class OrganizedAttachmentsCard extends StatelessWidget {
  final List<PendingAttachment> attachments;
  final ValueChanged<PendingAttachment>? onDelete;

  const OrganizedAttachmentsCard({
    required this.attachments,
    super.key,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return _EmptyState();
    }

    // تنظيم المرفقات حسب الشخص
    final organizedAttachments = _organizeAttachments(attachments);

    return Column(
      children: organizedAttachments.entries.map((entry) {
        return _PersonAttachmentsSection(
          personName: entry.key,
          attachments: entry.value,
          onDelete: onDelete,
        );
      }).toList(),
    );
  }

  Map<String, List<PendingAttachment>> _organizeAttachments(
    List<PendingAttachment> attachments,
  ) {
    final Map<String, List<PendingAttachment>> organized = {};

    for (final attachment in attachments) {
      final key = _getPersonKey(attachment);
      organized.putIfAbsent(key, () => []);
      organized[key]!.add(attachment);
    }

    return organized;
  }

  String _getPersonKey(PendingAttachment attachment) {
    if (attachment.personType == 'file_owner') {
      return 'وثائق صاحب الملف';
    }

    final personId = attachment.personId?.trim();
    if (personId != null && personId.isNotEmpty) {
      return 'وثائق $personId';
    }

    final personType = attachment.personType?.trim();
    if (personType != null && personType.isNotEmpty) {
      return 'وثائق $personType';
    } else {
      return 'وثائق أخرى';
    }
  }
}

/// 📦 Person Attachments Section
class _PersonAttachmentsSection extends StatelessWidget {
  final String personName;
  final List<PendingAttachment> attachments;
  final ValueChanged<PendingAttachment>? onDelete;

  const _PersonAttachmentsSection({
    required this.personName,
    required this.attachments,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_rounded,
                  color: colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    personName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${attachments.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Attachments List
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: attachments.map((attachment) {
                return _AttachmentListTile(
                  attachment: attachment,
                  onDelete: onDelete != null ? () => onDelete!(attachment) : null,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 📄 Attachment List Tile
class _AttachmentListTile extends ConsumerWidget {
  final PendingAttachment attachment;
  final VoidCallback? onDelete;

  const _AttachmentListTile({
    required this.attachment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileUnavailable = _isFileUnavailable();
    final fileName = _safeFileName();
    final fileSize = _safeFileSizeKb();
    final taxonomyAsync = ref.watch(
      bridgeTaxonomyByCodeProvider(
        (
          group: TaxonomyGroup.documentType,
          code: attachment.documentType?.trim() ?? '',
        ),
      ),
    );
    final documentTypeLabel = taxonomyAsync.maybeWhen(
      data: (taxonomy) => taxonomy?.label,
      orElse: () => null,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _getFileColor(fileName, colorScheme).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getFileIcon(fileName),
              color: _getFileColor(fileName, colorScheme),
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentTypeLabel ?? _getDocumentTypeLabel(attachment.documentType),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      size: 14.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        fileName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      fileUnavailable ? 'ملف غير متاح' : '$fileSize KB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fileUnavailable ? colorScheme.error : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          if (onDelete != null) ...[
            SizedBox(width: 8.w),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
              color: colorScheme.error,
              iconSize: 20.sp,
              tooltip: 'حذف',
            ),
          ],
        ],
      ),
    );
  }

  String _safeFileName() {
    final path = attachment.file.path.trim();
    if (path.isEmpty) return 'ملف غير متاح';
    if (_isFileUnavailable()) return 'ملف غير متاح';

    final segments = path.split(RegExp(r'[\\/]'));
    final last = segments.isNotEmpty ? segments.last.trim() : '';
    return last.isEmpty ? 'ملف غير متاح' : last;
  }

  String _safeFileSizeKb() {
    try {
      if (!attachment.file.existsSync()) return '-';
      final bytes = attachment.file.lengthSync();
      return (bytes / 1024).toStringAsFixed(1);
    } catch (_) {
      return '-';
    }
  }

  bool _isFileUnavailable() {
    try {
      final path = attachment.file.path.trim();
      if (path.isEmpty) return true;
      return !attachment.file.existsSync();
    } catch (_) {
      return true;
    }
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String fileName, ColorScheme colorScheme) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return colorScheme.error;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }

  String _getDocumentTypeLabel(String? type) {
    if (type == null) return 'وثيقة';

    final value = type.trim();
    if (value.isEmpty) return 'وثيقة';
    return value;
  }
}

/// ⚪ Empty State Widget
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد مرفقات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'قم بإضافة مرفقات جديدة باستخدام الكارد أعلاه',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
