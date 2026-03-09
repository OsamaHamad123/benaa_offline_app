import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_controllers.dart';
import '../form_constants.dart';

/// 📋 Final Review Sheet
///
/// Shows a comprehensive review of all form data before saving
class FinalReviewSheet extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;
  final ScrollController scrollController;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const FinalReviewSheet({
    required this.formControllers,
    required this.scrollController,
    required this.onConfirm,
    required this.onEdit,
    super.key,
  });

  String _displayValue(String? raw) {
    final value = raw?.trim() ?? '';
    return value.isEmpty ? '---' : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.preview_rounded,
                    size: 24.sp,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مراجعة البيانات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تحقق من صحة المعلومات قبل الحفظ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onEdit,
                  tooltip: 'إغلاق',
                ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(16.w),
            cacheExtent: 500, // Performance: cache ahead
            children: [
              _buildReadinessSummary(context),

              SizedBox(height: 16.h),

              // Personal Info Section
              _buildSection(context, 'معلومات شخصية', Icons.person_rounded, [
                _buildItem('الاسم الكامل', _getFullName()),
                _buildItem(
                  'الرقم الوطني',
                  formControllers.nationalIdController.text,
                ),
                _buildItem('رقم الملف', formControllers.fileNumberController.text),
                _buildItem(
                  'تاريخ الميلاد',
                  formControllers.birthDateController.text,
                ),
                _buildItem('الجنس', formControllers.selectedGender ?? '---'),
                _buildItem('فئة المستفيد', formControllers.selectedCategory ?? '---'),
                _buildItem('القسم', formControllers.selectedSection ?? '---'),
                _buildItem('حالة الطلب', formControllers.selectedRequestStatus ?? '---'),
                _buildItem('نوع المساعدة', formControllers.selectedAssistanceType ?? '---'),
                _buildItem(
                  'الحالة الاجتماعية',
                  formControllers.selectedMaritalStatus ?? '---',
                ),
                _buildItem('صلة القرابة', formControllers.selectedRelationship ?? '---'),
              ]),

              SizedBox(height: 16.h),

              // Family Section
              _buildSection(
                context,
                'معلومات العائلة',
                Icons.family_restroom_rounded,
                [
                  _buildItem(
                    'عدد الأفراد الأحياء',
                    '${formControllers.livingMembers.length}',
                  ),
                  _buildItem(
                    'عدد المتوفين',
                    '${formControllers.deceasedMembers.length}',
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Contact Section
              _buildSection(context, 'معلومات التواصل', Icons.phone_rounded, [
                _buildItem('الهاتف', formControllers.phoneController.text),
                _buildItem(
                  'هاتف إضافي',
                  formControllers.altPhoneController.text,
                ),
                _buildItem('العنوان', formControllers.addressController.text),
                _buildItem('الحي', formControllers.neighborhoodController.text),
                _buildItem('المدينة', formControllers.selectedCity ?? '---'),
                _buildItem('المحافظة', formControllers.selectedProvince ?? '---'),
              ]),

              SizedBox(height: 16.h),

              _buildSection(context, 'حالات إضافية', Icons.fact_check_rounded, [
                _buildItem('المستوى التعليمي', formControllers.selectedEducationLevel ?? '---'),
                _buildItem('حالة التوظيف', formControllers.selectedEmploymentStatus ?? '---'),
                _buildItem('الحالة الصحية', formControllers.selectedHealthStatus ?? '---'),
                _buildItem('حالة النزوح', formControllers.selectedDisplacementStatus ?? '---'),
                _buildItem('حالة السكن', formControllers.selectedHousingStatus ?? '---'),
                _buildItem('نوع السكن', formControllers.selectedHousingType ?? '---'),
                _buildItem('نوع الإعاقة', formControllers.selectedDisabilityType ?? '---'),
                _buildItem('مصدر الدخل', formControllers.selectedIncomeSource ?? '---'),
                _buildItem('الأمراض المزمنة', _displayValue(formControllers.chronicDiseasesController.text)),
                _buildItem(
                  'عدد ذوي الاحتياجات الخاصة',
                  _displayValue(formControllers.specialNeedsCountController.text),
                ),
              ]),

              SizedBox(height: 16.h),

              // Notes Section
              if (formControllers.notesController.text.isNotEmpty)
                _buildSection(context, 'ملاحظات', Icons.notes_rounded, [
                  _buildItem(
                    '',
                    formControllers.notesController.text,
                    isMultiline: true,
                  ),
                ]),

              SizedBox(height: 80.h), // Space for buttons
            ],
          ),
        ),

        // Footer Buttons
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('تأكيد الحفظ'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadinessSummary(BuildContext context) {
    final theme = Theme.of(context);
    final missingRequiredCount = _missingRequiredFieldsCount();
    final pendingAttachmentsCount = formControllers.pendingAttachments.length;
    final isReadyToSave = missingRequiredCount == 0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isReadyToSave ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            isReadyToSave ? Icons.task_alt_rounded : Icons.error_outline_rounded,
            color: isReadyToSave ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              isReadyToSave
                  ? 'النموذج جاهز للحفظ النهائي • مرفقات جديدة بانتظار الحفظ: $pendingAttachmentsCount'
                  : 'حقول إلزامية ناقصة: $missingRequiredCount • مرفقات جديدة بانتظار الحفظ: $pendingAttachmentsCount',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isReadyToSave ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _missingRequiredFieldsCount() {
    int missingCount = 0;

    if (formControllers.firstNameController.text.trim().isEmpty) missingCount++;
    if (formControllers.fatherNameController.text.trim().isEmpty) missingCount++;
    if (formControllers.lastNameController.text.trim().isEmpty) missingCount++;

    final nationalId = formControllers.nationalIdController.text.trim();
    if (nationalId.isEmpty || nationalId.length != FormConstants.nationalIdLength) {
      missingCount++;
    }

    if (formControllers.selectedGender == null) missingCount++;
    if (formControllers.phoneController.text.trim().isEmpty) missingCount++;

    return missingCount;
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20.sp, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Divider(height: 16.h),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value, {bool isMultiline = false}) {
    final normalizedValue = value.trim();
    final displayValue = normalizedValue.isEmpty ? '---' : normalizedValue;

    if (label.isEmpty) {
      // For notes or multiline content
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          displayValue,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade900),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade900),
              maxLines: isMultiline ? null : 2,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getFullName() {
    final parts = [
      formControllers.firstNameController.text,
      formControllers.fatherNameController.text,
      formControllers.grandfatherNameController.text,
      formControllers.lastNameController.text,
    ].where((e) => e.isNotEmpty);

    return parts.isEmpty ? '---' : parts.join(' ');
  }
}
