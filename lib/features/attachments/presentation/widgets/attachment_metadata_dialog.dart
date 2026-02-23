import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/attachment_enums.dart';

/// 🆕 Add Attachment Metadata Dialog
///
/// Dialog لإدخال معلومات إضافية عند رفع مرفق
class AttachmentMetadataDialog extends StatefulWidget {
  final String? initialDocumentType;
  final String? initialPersonType;
  final String? initialNotes;

  const AttachmentMetadataDialog({
    super.key,
    this.initialDocumentType,
    this.initialPersonType,
    this.initialNotes,
  });

  @override
  State<AttachmentMetadataDialog> createState() => _AttachmentMetadataDialogState();
}

class _AttachmentMetadataDialogState extends State<AttachmentMetadataDialog> {
  String? _selectedDocumentType;
  String? _selectedPersonType;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDocumentType = widget.initialDocumentType;
    _selectedPersonType = widget.initialPersonType;
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.description_outlined, color: Theme.of(context).primaryColor, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'معلومات المرفق',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Document Type Dropdown
            Text(
              'نوع الوثيقة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentType,
              decoration: InputDecoration(
                hintText: 'اختر نوع الوثيقة',
                prefixIcon: Icon(Icons.file_copy_outlined, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              items: DocumentType.values.map((type) {
                return DropdownMenuItem(
                  value: type.code,
                  child: Text(type.arabicName, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDocumentType = value);
              },
            ),

            SizedBox(height: 16.h),

            // Person Type Dropdown
            Text(
              'الشخص المرتبط',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedPersonType,
              decoration: InputDecoration(
                hintText: 'اختر الشخص',
                prefixIcon: Icon(Icons.person_outline, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              items: AttachmentPersonType.values.map((type) {
                return DropdownMenuItem(
                  value: type.code,
                  child: Text(type.arabicName, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPersonType = value);
              },
            ),

            SizedBox(height: 16.h),

            // Notes TextField
            Text(
              'ملاحظات',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أدخل ملاحظات إضافية (اختياري)',
                prefixIcon: Icon(Icons.note_outlined, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('إلغاء', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'documentType': _selectedDocumentType,
                        'personType': _selectedPersonType,
                        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('حفظ', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
