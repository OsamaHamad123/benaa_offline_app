import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../components/v2_section_card.dart';
import '../../../../utils/attachments_manager.dart';

/// Attachments tab for beneficiary form
class V2AttachmentsTab extends StatefulWidget {
  final String? beneficiaryId;
  final List<BeneficiaryAttachment> initialAttachments;
  final Function(List<BeneficiaryAttachment>) onAttachmentsChanged;

  const V2AttachmentsTab({
    super.key,
    this.beneficiaryId,
    this.initialAttachments = const [],
    required this.onAttachmentsChanged,
  });

  @override
  State<V2AttachmentsTab> createState() => _V2AttachmentsTabState();
}

class _V2AttachmentsTabState extends State<V2AttachmentsTab> {
  final List<BeneficiaryAttachment> _attachments = [];
  final List<File> _pendingFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _attachments.addAll(widget.initialAttachments);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _addFile(File(image.path));
      }
    } catch (e) {
      _showError('فشل في اختيار الصورة');
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _addFile(File(result.files.single.path!));
      }
    } catch (e) {
      _showError('فشل في اختيار الملف');
    }
  }

  Future<void> _addFile(File file) async {
    setState(() => _isUploading = true);

    try {
      // Validate file size
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        _showError('حجم الملف يتجاوز 10 ميجابايت');
        setState(() => _isUploading = false);
        return;
      }

      // Add to pending files
      _pendingFiles.add(file);
      widget.onAttachmentsChanged(_attachments);

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                const Text('تمت إضافة الملف'),
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
    } catch (e) {
      setState(() => _isUploading = false);
      _showError('فشل في إضافة الملف');
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
      widget.onAttachmentsChanged(_attachments);
    });
  }

  void _removePendingFile(int index) {
    setState(() {
      _pendingFiles.removeAt(index);
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        // Info Card
        V2SectionCard(
          title: 'المرفقات',
          icon: Icons.attach_file_rounded,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'يمكنك إضافة صور أو ملفات PDF (الحد الأقصى: 10 ميجابايت)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Add Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt_rounded, size: 20.sp),
                  label: const Text('كاميرا'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library_rounded, size: 20.sp),
                  label: const Text('معرض'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickPDF,
                  icon: Icon(Icons.picture_as_pdf_rounded, size: 20.sp),
                  label: const Text('PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading Indicator
        if (_isUploading)
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 8.h),
                  Text(
                    'جاري معالجة الملف...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Pending Files
        if (_pendingFiles.isNotEmpty)
          V2SectionCard(
            title: 'ملفات جديدة (${_pendingFiles.length})',
            icon: Icons.hourglass_empty_rounded,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemCount: _pendingFiles.length,
                itemBuilder: (context, index) {
                  final file = _pendingFiles[index];
                  final isImage =
                      file.path.toLowerCase().endsWith('.jpg') ||
                      file.path.toLowerCase().endsWith('.jpeg') ||
                      file.path.toLowerCase().endsWith('.png');

                  return Stack(
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
                          child: isImage
                              ? Image.file(file, fit: BoxFit.cover)
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
                        top: 4.h,
                        right: 4.w,
                        child: InkWell(
                          onTap: () => _removePendingFile(index),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

        // Existing Attachments
        if (_attachments.isNotEmpty)
          V2SectionCard(
            title: 'المرفقات المحفوظة (${_attachments.length})',
            icon: Icons.folder_rounded,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final attachment = _attachments[index];

                  return Stack(
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
                        top: 4.h,
                        right: 4.w,
                        child: InkWell(
                          onTap: () => _removeAttachment(index),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

        // Empty State
        if (_attachments.isEmpty && _pendingFiles.isEmpty && !_isUploading)
          Padding(
            padding: EdgeInsets.all(32.r),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 64.sp,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد مرفقات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'اضغط على الأزرار أعلاه لإضافة صور أو ملفات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
