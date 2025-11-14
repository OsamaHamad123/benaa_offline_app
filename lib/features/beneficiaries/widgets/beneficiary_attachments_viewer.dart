import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/attachments_manager.dart';

/// Attachments viewer and manager for beneficiary details page
class BeneficiaryAttachmentsViewer extends StatefulWidget {
  final String beneficiaryId;
  final List<BeneficiaryAttachment> attachments;
  final VoidCallback? onAttachmentsUpdated;

  const BeneficiaryAttachmentsViewer({
    super.key,
    required this.beneficiaryId,
    required this.attachments,
    this.onAttachmentsUpdated,
  });

  @override
  State<BeneficiaryAttachmentsViewer> createState() =>
      _BeneficiaryAttachmentsViewerState();
}

class _BeneficiaryAttachmentsViewerState
    extends State<BeneficiaryAttachmentsViewer> {
  bool _isLoading = false;

  Future<void> _addAttachment(ImageSource? imageSource) async {
    setState(() => _isLoading = true);

    try {
      File? file;

      if (imageSource != null) {
        // Image from camera or gallery
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: imageSource,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          file = File(image.path);
        }
      } else {
        // PDF file
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);
        }
      }

      if (file != null) {
        final attachment = await AttachmentsManager.addAttachment(
          beneficiaryId: widget.beneficiaryId,
          sourceFile: file,
        );

        if (attachment != null && mounted) {
          widget.onAttachmentsUpdated?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  const Text('تمت إضافة المرفق بنجاح'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إضافة المرفق: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAttachment(BeneficiaryAttachment attachment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('حذف مرفق'),
        content: const Text('هل أنت متأكد من حذف هذا المرفق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AttachmentsManager.deleteAttachment(attachment);

      if (success && mounted) {
        widget.onAttachmentsUpdated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حذف المرفق'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, size: 24.sp),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _addAttachment(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, size: 24.sp),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _addAttachment(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded, size: 24.sp),
              title: const Text('اختيار ملف PDF'),
              onTap: () {
                Navigator.pop(context);
                _addAttachment(null);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _viewAttachment(BeneficiaryAttachment attachment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AttachmentViewerPage(attachment: attachment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.all(16.r),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    size: 20.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'المرفقات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Badge(
                  label: Text('${widget.attachments.length}'),
                  child: IconButton(
                    onPressed: _isLoading ? null : _showAddOptions,
                    icon: Icon(Icons.add_circle_outline_rounded, size: 24.sp),
                    tooltip: 'إضافة مرفق',
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Loading
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Grid
            if (!_isLoading && widget.attachments.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemCount: widget.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = widget.attachments[index];

                  return InkWell(
                    onTap: () => _viewAttachment(attachment),
                    onLongPress: () => _deleteAttachment(attachment),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child:
                                attachment.isImage &&
                                    attachment.thumbnailPath != null
                                ? Image.file(
                                    File(attachment.thumbnailPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.picture_as_pdf_rounded,
                                      size: 40.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 4.h,
                          right: 4.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              attachment.fileSizeReadable,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Empty State
            if (!_isLoading && widget.attachments.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48.sp,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'لا توجد مرفقات',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'اضغط على + لإضافة مرفقات',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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
}

/// Full-screen attachment viewer
class _AttachmentViewerPage extends StatelessWidget {
  final BeneficiaryAttachment attachment;

  const _AttachmentViewerPage({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment.fileName),
      ),
      body: Center(
        child: attachment.isImage
            ? InteractiveViewer(child: Image.file(File(attachment.filePath)))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 120.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    attachment.fileName,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    attachment.fileSizeReadable,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ],
              ),
      ),
    );
  }
}
