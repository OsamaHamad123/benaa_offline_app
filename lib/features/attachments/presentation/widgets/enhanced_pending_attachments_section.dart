import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/pending_attachment.dart';
import 'attachment_metadata_dialog.dart';
import '../../../beneficiaries/presentation/pages/v2_form_helpers/widgets/empty_state_widget.dart' as BeneficiaryEmpty;

/// 📎 Enhanced Pending Attachments Section with Metadata
///
/// نسخة محسّنة تدعم metadata (documentType, personType, notes)
class EnhancedPendingAttachmentsSection extends StatefulWidget {
  final List<PendingAttachment> initialAttachments;
  final Function(List<PendingAttachment>)? onAttachmentsChanged;
  final bool showTitle;
  final bool requireMetadata; // إجبار إدخال metadata

  const EnhancedPendingAttachmentsSection({
    super.key,
    this.initialAttachments = const [],
    this.onAttachmentsChanged,
    this.showTitle = true,
    this.requireMetadata = false,
  });

  @override
  State<EnhancedPendingAttachmentsSection> createState() => _EnhancedPendingAttachmentsSectionState();
}

class _EnhancedPendingAttachmentsSectionState extends State<EnhancedPendingAttachmentsSection> {
  late List<PendingAttachment> _attachments;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  void _notifyChanges() {
    widget.onAttachmentsChanged?.call(_attachments);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) _buildHeader(context),
        if (widget.showTitle) SizedBox(height: 12.h),
        _buildContent(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.attach_file_outlined, color: Colors.blueGrey, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'المرفقات${_attachments.isNotEmpty ? ' (${_attachments.length})' : ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isUploading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 12.h),
              Text(
                'جاري إضافة الملف...',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_attachments.isEmpty) {
      return BeneficiaryEmpty.EmptyStateWidget.noAttachments(
        onAdd: () => _showAddOptions(context),
      );
    }

    return Column(
      children: [
        _buildAddButton(context),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.75,
          ),
          itemCount: _attachments.length,
          itemBuilder: (context, index) {
            final attachment = _attachments[index];
            return _EnhancedPendingFileCard(
              attachment: attachment,
              onTap: () => _openFile(attachment.file),
              onEdit: () => _editMetadata(index),
              onDelete: () => _deleteFile(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showAddOptions(context),
      icon: Icon(Icons.add, size: 20.sp),
      label: Text('إضافة مرفق', style: TextStyle(fontSize: 14.sp)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _showAddOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue, size: 24.sp),
                ),
                title: const Text('التقاط صورة'),
                subtitle: const Text('استخدام الكاميرا'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.green, size: 24.sp),
                ),
                title: const Text('اختيار من المعرض'),
                subtitle: const Text('تحديد صورة أو أكثر'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 24.sp),
                ),
                title: const Text('اختيار ملف PDF'),
                subtitle: const Text('تحديد ملف أو أكثر'),
                trailing: Icon(Icons.chevron_right, size: 20.sp),
                onTap: () {
                  Navigator.pop(context);
                  _addPdfFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _addFileWithMetadata(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الكاميرا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      for (final image in images) {
        await _addFileWithMetadata(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعرض: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            await _addFileWithMetadata(File(file.path!));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addFileWithMetadata(File file) async {
    setState(() => _isUploading = true);

    try {
      // Validate file size (10 MB max)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024;

      if (fileSize > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حجم الملف يتجاوز 10 ميجابايت'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      // Show metadata dialog if required
      Map<String, dynamic>? metadata;
      if (widget.requireMetadata || mounted) {
        metadata = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => AttachmentMetadataDialog(),
        );

        // User cancelled
        if (metadata == null && widget.requireMetadata) {
          setState(() => _isUploading = false);
          return;
        }
      }

      // Add attachment with metadata
      final attachment = PendingAttachment(
        file: file,
        documentType: metadata?['documentType'],
        personType: metadata?['personType'],
        notes: metadata?['notes'],
      );

      setState(() {
        _attachments.add(attachment);
        _isUploading = false;
      });

      _notifyChanges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                const Text('✓ تمت إضافة الملف'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editMetadata(int index) async {
    final attachment = _attachments[index];

    final metadata = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AttachmentMetadataDialog(
        initialDocumentType: attachment.documentType,
        initialPersonType: attachment.personType,
        initialNotes: attachment.notes,
      ),
    );

    if (metadata != null) {
      setState(() {
        _attachments[index] = attachment.copyWith(
          documentType: metadata['documentType'],
          personType: metadata['personType'],
          notes: metadata['notes'],
        );
      });
      _notifyChanges();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ تم تحديث معلومات المرفق'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
    _notifyChanges();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            const Text('✓ تم حذف الملف'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openFile(File file) async {
    if (await file.exists()) {
      await OpenFile.open(file.path);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الملف غير موجود'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Enhanced Pending File Card with Metadata Indicators
class _EnhancedPendingFileCard extends StatelessWidget {
  final PendingAttachment attachment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EnhancedPendingFileCard({
    required this.attachment,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(attachment.file.path);
    final extension = path.extension(fileName).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png'].contains(extension);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // File preview
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
                    child: isImage
                        ? Image.file(
                            attachment.file,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFileIcon(extension),
                          )
                        : _buildFileIcon(extension),
                  ),
                ),

                // Metadata indicators
                if (attachment.documentType != null || attachment.personType != null || attachment.notes != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(11.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (attachment.documentType != null) Icon(Icons.description, size: 12.sp, color: Colors.blue),
                        if (attachment.personType != null) Icon(Icons.person, size: 12.sp, color: Colors.blue),
                        if (attachment.notes != null) Icon(Icons.note, size: 12.sp, color: Colors.blue),
                      ],
                    ),
                  ),

                // File name
                Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Text(
                    fileName,
                    style: TextStyle(fontSize: 10.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          Positioned(
            top: 4.r,
            left: 4.r,
            child: Material(
              color: Colors.blue,
              shape: CircleBorder(),
              child: InkWell(
                onTap: onEdit,
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(Icons.edit, color: Colors.white, size: 14.sp),
                ),
              ),
            ),
          ),

          // Delete button
          Positioned(
            top: 4.r,
            right: 4.r,
            child: Material(
              color: Colors.red,
              shape: CircleBorder(),
              child: InkWell(
                onTap: onDelete,
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String extension) {
    IconData icon;
    Color color;

    if (extension == '.pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      icon = Icons.image;
      color = Colors.blue;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(icon, size: 48.sp, color: color),
      ),
    );
  }
}
