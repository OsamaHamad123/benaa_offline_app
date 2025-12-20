import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../pages/v2_form_helpers/form_controllers.dart';

/// 📋 Review Tab - مراجعة جميع المعلومات المدخلة
///
/// يعرض جميع البيانات بشكل منظم مع إمكانية التعديل السريع
/// مع زر "حفظ السجل نهائياً" في الأسفل
class V2ReviewTab extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onFinalSave;
  final VoidCallback? onEditSection;

  const V2ReviewTab({
    super.key,
    required this.formControllers,
    required this.onFinalSave,
    this.onEditSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      physics: const ClampingScrollPhysics(),
      children: [
        // 🎯 Header Card
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Icon(
                  Icons.fact_check_rounded,
                  size: 48.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(height: 12.h),
                Text(
                  'مراجعة جميع المعلومات المدخلة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'يرجى التأكد من صحة جميع البيانات قبل الحفظ النهائي',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // 📝 البيانات الأساسية
        ReviewSectionCard(
          title: 'البيانات الأساسية',
          icon: Icons.person_rounded,
          color: const Color(0xFF1976D2),
          onEdit: onEditSection,
          children: [
            ReviewDataRow(
              label: 'الاسم الكامل',
              value: _getFullName(),
              icon: Icons.badge_rounded,
            ),
            ReviewDataRow(
              label: 'الرقم الوطني',
              value: formControllers.nationalIdController.text,
              icon: Icons.credit_card_rounded,
            ),
            ReviewDataRow(
              label: 'رقم الملف',
              value: formControllers.fileNumberController.text,
              icon: Icons.folder_rounded,
            ),
            ReviewDataRow(
              label: 'تاريخ الميلاد',
              value: formControllers.birthDateController.text,
              icon: Icons.cake_rounded,
            ),
            ReviewDataRow(
              label: 'الجنس',
              value: formControllers.selectedGender,
              icon: Icons.wc_rounded,
            ),
            ReviewDataRow(
              label: 'الفئة',
              value: formControllers.selectedCategory,
              icon: Icons.category_rounded,
            ),
            ReviewDataRow(
              label: 'حالة الطلب',
              value: formControllers.selectedRequestStatus,
              icon: Icons.pending_actions_rounded,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 📞 معلومات التواصل
        ReviewSectionCard(
          title: 'معلومات التواصل',
          icon: Icons.contact_phone_rounded,
          color: const Color(0xFF388E3C),
          onEdit: onEditSection,
          children: [
            ReviewDataRow(
              label: 'رقم الهاتف',
              value: formControllers.phoneController.text,
              icon: Icons.phone_rounded,
            ),
            ReviewDataRow(
              label: 'رقم هاتف بديل',
              value: formControllers.altPhoneController.text,
              icon: Icons.phone_android_rounded,
            ),
            ReviewDataRow(
              label: 'العنوان',
              value: formControllers.addressController.text,
              icon: Icons.location_on_rounded,
            ),
            ReviewDataRow(
              label: 'الحي',
              value: formControllers.neighborhoodController.text,
              icon: Icons.place_rounded,
            ),
            ReviewDataRow(
              label: 'المحافظة',
              value: formControllers.selectedProvince,
              icon: Icons.public_rounded,
            ),
            ReviewDataRow(
              label: 'المدينة',
              value: formControllers.selectedCity,
              icon: Icons.location_city_rounded,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 👨‍👩‍👧‍👦 معلومات العائلة
        ReviewSectionCard(
          title: 'معلومات العائلة',
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF7B1FA2),
          onEdit: onEditSection,
          children: [
            ReviewDataRow(
              label: 'عدد أفراد الأسرة',
              value: formControllers.numberOfDependentsController.text,
              icon: Icons.groups_rounded,
            ),
            ReviewDataRow(
              label: 'عدد الذكور',
              value: formControllers.numberOfMalesController.text,
              icon: Icons.man_rounded,
            ),
            ReviewDataRow(
              label: 'عدد الإناث',
              value: formControllers.numberOfFemalesController.text,
              icon: Icons.woman_rounded,
            ),
            ReviewDataRow(
              label: 'عدد ذوي الاحتياجات الخاصة',
              value: formControllers.specialNeedsCountController.text,
              icon: Icons.accessible_rounded,
            ),
            if (formControllers.livingMembers.isNotEmpty)
              ReviewDataRow(
                label: 'أفراد الأسرة المسجلين',
                value: '${formControllers.livingMembers.length} فرد',
                icon: Icons.people_rounded,
              ),
          ],
        ),

        SizedBox(height: 16.h),

        // 🏥 معلومات إضافية
        ReviewSectionCard(
          title: 'معلومات إضافية',
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFE64A19),
          onEdit: onEditSection,
          children: [
            ReviewDataRow(
              label: 'المستوى التعليمي',
              value: formControllers.selectedEducationLevel,
              icon: Icons.school_rounded,
            ),
            ReviewDataRow(
              label: 'حالة التوظيف',
              value: formControllers.selectedEmploymentStatus,
              icon: Icons.work_outline_rounded,
            ),
            ReviewDataRow(
              label: 'الحالة الصحية',
              value: formControllers.selectedHealthStatus,
              icon: Icons.favorite_outline_rounded,
            ),
            ReviewDataRow(
              label: 'الأمراض المزمنة',
              value: formControllers.chronicDiseasesController.text,
              icon: Icons.medical_services_outlined,
            ),
            ReviewDataRow(
              label: 'حالة السكن',
              value: formControllers.selectedHousingStatus,
              icon: Icons.home_outlined,
            ),
            ReviewDataRow(
              label: 'نوع السكن',
              value: formControllers.selectedHousingType,
              icon: Icons.apartment_outlined,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 📎 المرفقات
        ReviewSectionCard(
          title: 'المرفقات',
          icon: Icons.attach_file_rounded,
          color: const Color(0xFF0288D1),
          onEdit: onEditSection,
          children: [
            ReviewDataRow(
              label: 'الوثائق المرفقة',
              value: formControllers.pendingAttachments.isNotEmpty
                  ? '${formControllers.pendingAttachments.length} وثيقة'
                  : 'لا يوجد مرفقات',
              icon: Icons.cloud_upload_rounded,
            ),
            if (formControllers.pendingAttachments.isNotEmpty)
              ...formControllers.pendingAttachments.map(
                (attachment) => Padding(
                  padding: EdgeInsets.only(right: 32.w, top: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_rounded,
                        size: 16.sp,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          attachment.documentType ?? 'وثيقة',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 16.h),

        // 📝 الملاحظات
        if (formControllers.notesController.text.isNotEmpty)
          ReviewSectionCard(
            title: 'الملاحظات',
            icon: Icons.note_rounded,
            color: const Color(0xFF616161),
            onEdit: onEditSection,
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  formControllers.notesController.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: 24.h),

        // 💾 زر الحفظ النهائي
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50),
                const Color(0xFF66BB6A),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFinalSave,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'حفظ السجل نهائياً',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 32.h),
      ],
    );
  }

  String _getFullName() {
    final parts = [
      formControllers.firstNameController.text,
      formControllers.fatherNameController.text,
      formControllers.grandfatherNameController.text,
      formControllers.lastNameController.text,
    ].where((s) => s.isNotEmpty).toList();

    return parts.isEmpty ? 'غير محدد' : parts.join(' ');
  }
}

/// 📦 Review Section Card Widget
class ReviewSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final VoidCallback? onEdit;

  const ReviewSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_rounded, size: 20.sp),
                    color: color,
                    onPressed: onEdit,
                    tooltip: 'تعديل',
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 Review Data Row Widget
class ReviewDataRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;

  const ReviewDataRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayValue = value?.isEmpty ?? true ? 'غير محدد' : value!;
    final isEmpty = value?.isEmpty ?? true;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20.sp,
              color: isEmpty ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.primary,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmpty ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.onSurface,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
