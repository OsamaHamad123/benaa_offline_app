import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/attachment.dart';
import '../providers/attachments_provider.dart';

/// 📎 Enhanced Attachments Section Widget - Clean Architecture V2
class AttachmentsSectionEnhanced extends ConsumerWidget {
  final String beneficiaryId;
  final bool readOnly;
  final bool showTitle;

  const AttachmentsSectionEnhanced({
    super.key,
    required this.beneficiaryId,
    this.readOnly = false,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint(
        '🎨 [AttachmentsSectionEnhanced] Building for: $beneficiaryId',
      );
    }
    final state = ref.watch(attachmentsProvider(beneficiaryId));

    if (kDebugMode) {
      debugPrint(
        '📊 [AttachmentsSectionEnhanced] State - Loading: ${state.isLoading}, Attachments: ${state.attachments.length}, Error: ${state.errorMessage}',
      );
    }

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
    return Row(
      children: [
        Icon(Icons.attach_file_outlined, color: Colors.blueGrey, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'المرفقات${state.attachments.isNotEmpty ? ' (${state.attachments.length})' : ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
          ),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AttachmentsState state,
  ) {
    if (state.isLoading) {
      return _buildLoading();
    }

    if (state.errorMessage != null) {
      return _buildError(context, ref, state.errorMessage!);
    }

    if (state.attachments.isEmpty) {
      return _buildEmpty(context, ref);
    }

    return _buildAttachmentsList(context, ref, state.attachments);
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 12.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 12.h),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد مرفقات',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!readOnly) ...[
              SizedBox(height: 8.h),
              Text(
                'اضغط على الزر أدناه لإضافة مرفقات',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
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
    List<Attachment> attachments,
  ) {
    return Column(
      children: [
        if (!readOnly) ...[
          _buildAddButton(context, ref),
          SizedBox(height: 16.h),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85,
          ),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final attachment = attachments[index];
            return _EnhancedAttachmentCard(
              attachment: attachment,
              onTap: () => _openAttachment(context, attachment),
              onShare: () => _shareAttachment(context, attachment),
              onDelete: readOnly ? null : () => _deleteAttachment(context, ref, attachment),
            );
          },
        ),
      ],
    );
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
                  color: Colors.grey[300],
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.green,
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
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
                child: CircularProgressIndicator(
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

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(success ? '✓ تمت إضافة المرفق بنجاح' : '✗ فشل إضافة المرفق'),
            ],
          ),
          backgroundColor: success ? Colors.green : Colors.red,
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
              color: Colors.orange,
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(attachmentsProvider(beneficiaryId).notifier);
      final success = await notifier.deleteAttachment(attachment.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(success ? '✓ تم حذف المرفق بنجاح' : '✗ فشل حذف المرفق'),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openAttachment(
    BuildContext context,
    Attachment attachment,
  ) async {
    final file = File(attachment.filePath);
    if (await file.exists()) {
      await OpenFile.open(attachment.filePath);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              const Text('الملف غير موجود'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareAttachment(
    BuildContext context,
    Attachment attachment,
  ) async {
    final file = File(attachment.filePath);
    if (await file.exists()) {
      await Share.shareXFiles([
        XFile(attachment.filePath),
      ], subject: attachment.fileName);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الملف غير موجود'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Enhanced Attachment Card Widget
class _EnhancedAttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback? onDelete;

  const _EnhancedAttachmentCard({
    required this.attachment,
    required this.onTap,
    required this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail/Icon
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: _buildThumbnail(context),
                  ),
                  // Delete button
                  if (onDelete != null)
                    Positioned(
                      top: 2.h,
                      right: 2.w,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  // Type badge
                  Positioned(
                    bottom: 2.h,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.85),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        attachment.type.arabicLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section - Fixed height to prevent overflow
            Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      _getFileName(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 9.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            attachment.fileSizeReadable,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: onShare,
                          borderRadius: BorderRadius.circular(6.r),
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            child: Icon(
                              Icons.share,
                              size: 18.sp,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (attachment.isImage) {
      final thumbnailFile =
          attachment.thumbnailPath != null ? File(attachment.thumbnailPath!) : File(attachment.filePath);

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: Image.file(
          thumbnailFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildIcon(Icons.broken_image, Colors.red),
        ),
      );
    } else if (attachment.isPdf) {
      return _buildIcon(Icons.picture_as_pdf, Colors.red);
    } else {
      return _buildIcon(Icons.insert_drive_file, Colors.grey);
    }
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(icon, size: 48.sp, color: color),
      ),
    );
  }

  Color _getTypeColor() {
    switch (attachment.type) {
      case AttachmentType.image:
        return Colors.green;
      case AttachmentType.pdf:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFileName() {
    if (attachment.fileName.length > 20) {
      return '${attachment.fileName.substring(0, 17)}...';
    }
    return attachment.fileName;
  }
}
