import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

import 'document_type_selector.dart';
import '../../../../../attachments/domain/models/pending_attachment.dart';

/// 📎 Enhanced Upload Attachment Card
///
/// كارد رفع المرفقات المحسّن مع اختيار نوع الوثيقة والشخص
class EnhancedUploadAttachmentCard extends StatefulWidget {
  final List<String> availableFamilyMembers;
  final ValueChanged<PendingAttachment> onAttachmentAdded;

  const EnhancedUploadAttachmentCard({
    required this.availableFamilyMembers,
    required this.onAttachmentAdded,
    super.key,
  });

  @override
  State<EnhancedUploadAttachmentCard> createState() => _EnhancedUploadAttachmentCardState();
}

class _EnhancedUploadAttachmentCardState extends State<EnhancedUploadAttachmentCard> {
  String? _selectedDocumentType;
  String? _selectedPersonType;
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final candidate = File(result.files.single.path!);
        if (!candidate.existsSync()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ الملف غير متاح، يرجى اختيار ملف آخر'),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = candidate;
        });
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

  Future<void> _uploadAttachment() async {
    if (_selectedFile == null || _selectedDocumentType == null || _selectedPersonType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى اختيار الملف ونوع الوثيقة والشخص'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isSelectedFileUnavailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الملف غير متاح، اختر ملفًا صالحًا قبل الرفع'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final attachment = PendingAttachment(
      file: _selectedFile!,
      documentType: _selectedDocumentType,
      personType: _selectedPersonType,
      personId: _selectedPersonType == 'file_owner' ? null : _selectedPersonType,
    );

    widget.onAttachmentAdded(attachment);

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    // Reset form
    setState(() {
      _selectedFile = null;
      _selectedDocumentType = null;
      _selectedPersonType = null;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('✅ تم إضافة المرفق بنجاح'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _safeSelectedFileName() {
    final selectedFile = _selectedFile;
    if (selectedFile == null) return 'ملف غير متاح';

    final path = selectedFile.path.trim();
    if (path.isEmpty) return 'ملف غير متاح';
    if (_isSelectedFileUnavailable()) return 'ملف غير متاح';

    final segments = path.split(RegExp(r'[\\/]'));
    final last = segments.isNotEmpty ? segments.last.trim() : '';
    return last.isEmpty ? 'ملف غير متاح' : last;
  }

  String _safeSelectedFileSizeKb() {
    final selectedFile = _selectedFile;
    if (selectedFile == null) return '-';

    try {
      if (!selectedFile.existsSync()) return '-';
      return (selectedFile.lengthSync() / 1024).toStringAsFixed(1);
    } catch (_) {
      return '-';
    }
  }

  bool _isSelectedFileUnavailable() {
    final selectedFile = _selectedFile;
    if (selectedFile == null) return true;
    try {
      final path = selectedFile.path.trim();
      if (path.isEmpty) return true;
      return !selectedFile.existsSync();
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    color: colorScheme.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'إضافة مرفق جديد',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // اختر نوع الوثيقة
            DocumentTypeSelector(
              selectedType: _selectedDocumentType,
              onChanged: (value) {
                setState(() => _selectedDocumentType = value);
              },
              isRequired: true,
            ),

            SizedBox(height: 16.h),

            // اختر الشخص
            PersonTypeSelector(
              selectedPerson: _selectedPersonType,
              onChanged: (value) {
                setState(() => _selectedPersonType = value);
              },
              availablePersons: widget.availableFamilyMembers,
            ),

            SizedBox(height: 16.h),

            // Choose File Button
            if (_selectedFile == null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('اختر ملف'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              )
            else
              // Selected File Display
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      color: colorScheme.primary,
                      size: 32.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _safeSelectedFileName(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _isSelectedFileUnavailable() ? 'ملف غير متاح' : '${_safeSelectedFileSizeKb()} KB',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isSelectedFileUnavailable() ? colorScheme.error : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() => _selectedFile = null);
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20.h),

            // Upload Button
            if (_isUploading) ...[
              const LinearProgressIndicator(),
              SizedBox(height: 8.h),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isUploading ? null : _uploadAttachment,
                icon: _isUploading
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(_isUploading ? 'جاري الرفع...' : 'رفع المرفق'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Hint Text
            Text(
              '💡 الملفات المدعومة: PDF, JPG, PNG • الحد الأقصى: 5 ميغابايت',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
