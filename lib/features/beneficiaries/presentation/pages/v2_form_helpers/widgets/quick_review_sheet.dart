import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_dimensions.dart';
import '../form_controllers.dart';

/// 📋 Quick Review Bottom Sheet
///
/// Shows summary of all entered data before final save
class QuickReviewSheet extends StatelessWidget {
  final BeneficiaryFormControllers controllers;
  final VoidCallback onConfirm;

  const QuickReviewSheet({
    super.key,
    required this.controllers,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 600.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'مراجعة البيانات',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Section
                  _buildSection(
                    context,
                    title: '👤 المعلومات الأساسية',
                    icon: Icons.person_rounded,
                    items: [
                      _buildItem('الاسم الكامل', _getFullName()),
                      _buildItem(
                        'الرقم الوطني',
                        controllers.nationalIdController.text,
                      ),
                      _buildItem(
                        'تاريخ الميلاد',
                        controllers.birthDateController.text,
                      ),
                      _buildItem(
                        'الجنس',
                        _getGenderText(controllers.selectedGender),
                      ),
                      _buildItem(
                        'الفئة',
                        _getCategoryText(controllers.selectedCategory),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Contact Section
                  _buildSection(
                    context,
                    title: '📞 معلومات التواصل',
                    icon: Icons.contact_phone_rounded,
                    items: [
                      _buildItem(
                        'رقم الهاتف',
                        controllers.phoneController.text,
                      ),
                      _buildItem(
                        'رقم بديل',
                        controllers.altPhoneController.text,
                      ),
                      _buildItem('العنوان', controllers.addressController.text),
                      _buildItem(
                        'الحي',
                        controllers.neighborhoodController.text,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Family Info Section
                  _buildSection(
                    context,
                    title: '👨‍👩‍👧‍👦 معلومات العائلة',
                    icon: Icons.family_restroom_rounded,
                    items: [
                      _buildItem(
                        'عدد المعالين',
                        controllers.numberOfDependentsController.text,
                      ),
                      _buildItem(
                        'عدد الذكور',
                        controllers.numberOfMalesController.text,
                      ),
                      _buildItem(
                        'عدد الإناث',
                        controllers.numberOfFemalesController.text,
                      ),
                      _buildItem(
                        'أفراد العائلة',
                        '${controllers.livingMembers.length} فرد',
                      ),
                      _buildItem(
                        'متوفين',
                        '${controllers.deceasedMembers.length} فرد',
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Attachments Section
                  _buildSection(
                    context,
                    title: '📎 المرفقات',
                    icon: Icons.attach_file_rounded,
                    items: [
                      _buildItem(
                        'عدد الملفات',
                        '${controllers.pendingAttachmentFiles.length} ملف',
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Notes
                  if (controllers.notesController.text.isNotEmpty)
                    _buildSection(
                      context,
                      title: '📝 ملاحظات',
                      icon: Icons.note_rounded,
                      items: [
                        _buildItem(
                          'الملاحظات',
                          controllers.notesController.text,
                          maxLines: 3,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.edit_rounded, size: 18.sp),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusMD,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    icon: Icon(Icons.check_circle_rounded, size: 18.sp),
                    label: const Text('تأكيد الحفظ'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusMD,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppDimensions.borderRadiusMD,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, {int maxLines = 1}) {
    if (value.isEmpty || value == 'null') return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getFullName() {
    final parts = [
      controllers.firstNameController.text,
      controllers.fatherNameController.text,
      controllers.grandfatherNameController.text,
      controllers.lastNameController.text,
    ].where((s) => s.isNotEmpty).toList();

    return parts.isEmpty ? 'غير محدد' : parts.join(' ');
  }

  String _getGenderText(String? gender) {
    if (gender == null || gender.isEmpty) return 'غير محدد';
    return gender == '1' ? 'ذكر' : 'أنثى';
  }

  String _getCategoryText(String? category) {
    if (category == null || category.isEmpty) return 'غير محدد';

    final categories = {
      '1': 'يتيم',
      '2': 'أرملة',
      '3': 'مطلقة',
      '4': 'نازح',
      '5': 'مسن',
      '6': 'ذوي احتياجات خاصة',
      '7': 'أخرى',
    };

    return categories[category] ?? 'غير محدد';
  }
}
