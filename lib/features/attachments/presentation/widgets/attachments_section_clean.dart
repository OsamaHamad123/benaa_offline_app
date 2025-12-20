import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../../domain/entities/attachment.dart';
import '../providers/attachments_provider.dart';

/// 📎 Attachments Section Widget - Clean Architecture
class AttachmentsSectionClean extends ConsumerWidget {
  final String beneficiaryId;
  final bool readOnly;

  const AttachmentsSectionClean({
    super.key,
    required this.beneficiaryId,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attachmentsProvider(beneficiaryId));

    if (state.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (state.errorMessage != null) {
      return _buildError(context, state.errorMessage!);
    }

    if (state.attachments.isEmpty) {
      return _buildEmpty(context, ref);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add button
        if (!readOnly) _buildAddButton(context, ref),
        if (!readOnly) SizedBox(height: 12.h),

        // Attachments grid
        _buildAttachmentsGrid(context, ref, state.attachments),
      ],
    );
  }

  Widget _buildError(BuildContext context, String error) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
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
              SizedBox(height: 16.h),
              _buildAddButton(context, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'إضافة مرفق جديد',
      hint: 'اضغط لاختيار الكاميرا، المعرض، أو ملف PDF',
      button: true,
      child: OutlinedButton.icon(
        onPressed: () => _showAddOptions(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('إضافة مرفق'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsGrid(
    BuildContext context,
    WidgetRef ref,
    List<Attachment> attachments,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return _AttachmentCard(
          attachment: attachment,
          onTap: () => _openAttachment(context, attachment),
          onDelete: readOnly
              ? null
              : () => _deleteAttachment(context, ref, attachment),
        );
      },
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromCamera(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromGallery(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('اختيار ملف PDF'),
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
    final success = await notifier.addAttachment(
      beneficiaryId: beneficiaryId,
      sourceFile: file,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✓ تم إضافة المرفق بنجاح' : '✗ فشل إضافة المرفق',
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
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${attachment.fileName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
            content: Text(
              success ? '✓ تم حذف المرفق بنجاح' : '✗ فشل حذف المرفق',
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
        const SnackBar(
          content: Text('الملف غير موجود'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Attachment Card Widget
class _AttachmentCard extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _AttachmentCard({
    required this.attachment,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildThumbnail(),
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                ),
              ),
            ),
          // File info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.type.arabicLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    attachment.fileSizeReadable,
                    style: TextStyle(color: Colors.white70, fontSize: 9.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (attachment.isImage) {
      final thumbnailFile = attachment.thumbnailPath != null
          ? File(attachment.thumbnailPath!)
          : File(attachment.filePath);

      return Image.file(
        thumbnailFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            _buildIcon(Icons.broken_image, Colors.red),
      );
    } else if (attachment.isPdf) {
      return _buildIcon(Icons.picture_as_pdf, Colors.red);
    } else {
      return _buildIcon(Icons.insert_drive_file, Colors.grey);
    }
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Center(
      child: Icon(icon, size: 48.sp, color: color),
    );
  }
}
