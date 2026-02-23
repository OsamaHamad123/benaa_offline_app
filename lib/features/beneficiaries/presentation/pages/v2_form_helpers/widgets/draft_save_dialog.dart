import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 💾 Draft Save Dialog
///
/// Shows dialog to save form as draft with name/notes
class DraftSaveDialog extends StatefulWidget {
  final String? currentDraftName;
  final String? currentDraftNotes;

  const DraftSaveDialog({
    super.key,
    this.currentDraftName,
    this.currentDraftNotes,
  });

  @override
  State<DraftSaveDialog> createState() => _DraftSaveDialogState();
}

class _DraftSaveDialogState extends State<DraftSaveDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentDraftName ??
          'مسودة ${DateTime.now().toString().split(' ')[0]}',
    );
    _notesController = TextEditingController(text: widget.currentDraftNotes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTabletOrDesktop ? 500 : double.infinity,
          maxHeight: ResponsiveUtils.screenHeight(context) * 0.7,
        ),
        padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.save_outlined,
                  color: theme.colorScheme.primary,
                  size: isTabletOrDesktop ? 28.0 : 24.0,
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  child: Text(
                    'حفظ كمسودة',
                    style: TextStyle(
                      fontSize: isTabletOrDesktop ? 20.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.mediumSpace),

            // Draft Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المسودة',
                hintText: 'أدخل اسم المسودة',
                prefixIcon: const Icon(Icons.edit_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLength: 50,
            ),

            SizedBox(height: ResponsiveUtils.smallSpace),

            // Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أضف ملاحظات عن هذه المسودة',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),

            SizedBox(height: ResponsiveUtils.largeSpace),

            // Info Card
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  SizedBox(width: ResponsiveUtils.smallSpace),
                  Expanded(
                    child: Text(
                      'سيتم حفظ جميع البيانات المدخلة، ويمكنك متابعة التعديل لاحقاً',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveUtils.largeSpace),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTabletOrDesktop ? 18.h : 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: isTabletOrDesktop ? 15.sp : 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'name': _nameController.text.trim(),
                        'notes': _notesController.text.trim(),
                      });
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      'حفظ المسودة',
                      style: TextStyle(
                        fontSize: isTabletOrDesktop ? 15.sp : 14.sp,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTabletOrDesktop ? 18.h : 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
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

/// Show Draft Save Dialog
Future<Map<String, String>?> showDraftSaveDialog(
  BuildContext context, {
  String? currentName,
  String? currentNotes,
}) async {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => DraftSaveDialog(
      currentDraftName: currentName,
      currentDraftNotes: currentNotes,
    ),
  );
}
