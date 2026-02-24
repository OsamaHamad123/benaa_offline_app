import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../form/review/review_section_card.dart';
import '../../form/review/review_data_row.dart';

/// 📋 Review Tab - مراجعة جميع المعلومات المدخلة
///
/// يعرض جميع البيانات بشكل منظم مع إمكانية التعديل السريع
/// مع زر "حفظ السجل نهائياً" في الأسفل
class V2ReviewTab extends ConsumerWidget {
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onFinalSave;
  final VoidCallback? onEditSection;
  final ValueChanged<int>? onJumpToTab;

  const V2ReviewTab({
    required this.formControllers,
    required this.onFinalSave,
    super.key,
    this.onEditSection,
    this.onJumpToTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requiredFields = _requiredFieldValues();
    final requiredCount = requiredFields.length;
    final filledRequiredCount = requiredFields.values.where((value) => value?.trim().isNotEmpty ?? false).length;
    final missingRequiredFields = requiredFields.entries
        .where((entry) => entry.value?.trim().isNotEmpty != true)
        .map((entry) => entry.key)
        .toList(growable: false);
    final completion = requiredCount == 0 ? 0.0 : filledRequiredCount / requiredCount;
    final taxonomyIndexAsync = ref.watch(bridgeTaxonomiesIndexOnceProvider);
    final taxonomyIndex = taxonomyIndexAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <TaxonomyGroup, List<taxonomy_domain.Taxonomy>>{},
    );
    final unresolvedTaxonomyCount = _countUnresolvedTaxonomySelections(taxonomyIndex);
    final canFinalSave = missingRequiredFields.isEmpty && unresolvedTaxonomyCount == 0;
    final profileStrength = _calculateProfileStrength();
    final profileStrengthColor = switch (profileStrength.$3) {
      _ProfileStrengthLevel.strong => colorScheme.secondary,
      _ProfileStrengthLevel.medium => colorScheme.tertiary,
      _ProfileStrengthLevel.weak => colorScheme.error,
    };

    final basicSectionColor = colorScheme.primary;
    final contactSectionColor = colorScheme.secondary;
    final familySectionColor = colorScheme.tertiary;
    final additionalSectionColor = colorScheme.primary;
    final attachmentsSectionColor = colorScheme.secondary;
    final notesSectionColor = colorScheme.onSurfaceVariant;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      physics: const ClampingScrollPhysics(),
      children: [
        // 🎯 Header Card
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
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

        SizedBox(height: 12.h),

        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rule_folder_outlined, size: 18.sp, color: colorScheme.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'الحقول الأساسية المكتملة: $filledRequiredCount/$requiredCount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: completion,
                    minHeight: 8.h,
                    backgroundColor: colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completion >= 0.8
                          ? colorScheme.primary
                          : completion >= 0.5
                              ? colorScheme.secondary
                              : colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18.sp, color: colorScheme.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Profile Strength: ${profileStrength.$1}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      profileStrength.$2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: profileStrengthColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: profileStrength.$1 / 100,
                    minHeight: 8.h,
                    backgroundColor: colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(profileStrengthColor),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (unresolvedTaxonomyCount > 0) ...[
          SizedBox(height: 10.h),
          Card(
            elevation: 0,
            color: colorScheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'يوجد $unresolvedTaxonomyCount قيمة تصنيف غير محوّلة لاسم واضح. يفضّل مزامنة التصنيفات قبل الحفظ.',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (missingRequiredFields.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Card(
            elevation: 0,
            color: colorScheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report_problem_outlined, color: colorScheme.error, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'لا يمكن الحفظ النهائي قبل إكمال الحقول الأساسية التالية:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ...missingRequiredFields.map(
                    (field) {
                      final targetTab = _tabForRequiredField(field);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.h, right: 28.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '• $field',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
                              ),
                            ),
                            TextButton(
                              onPressed: targetTab == null
                                  ? null
                                  : () {
                                      if (onJumpToTab != null) {
                                        onJumpToTab!(targetTab);
                                      } else {
                                        onEditSection?.call();
                                      }
                                    },
                              child: const Text('إصلاح'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],

        SizedBox(height: 20.h),

        // 📝 البيانات الأساسية
        ReviewSectionCard(
          title: 'البيانات الأساسية',
          icon: Icons.person_rounded,
          color: basicSectionColor,
          onEdit: () {
            if (onJumpToTab != null) {
              onJumpToTab!(0);
            } else {
              onEditSection?.call();
            }
          },
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
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.gender,
                code: formControllers.selectedGender,
              ),
              icon: Icons.wc_rounded,
            ),
            ReviewDataRow(
              label: 'الفئة',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.category,
                code: formControllers.selectedCategory,
              ),
              icon: Icons.category_rounded,
            ),
            ReviewDataRow(
              label: 'حالة الطلب',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.beneficiaryStatus,
                code: formControllers.selectedRequestStatus,
              ),
              icon: Icons.pending_actions_rounded,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 📞 معلومات التواصل
        ReviewSectionCard(
          title: 'معلومات التواصل',
          icon: Icons.contact_phone_rounded,
          color: contactSectionColor,
          onEdit: () {
            if (onJumpToTab != null) {
              onJumpToTab!(2);
            } else {
              onEditSection?.call();
            }
          },
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
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.governorate,
                code: formControllers.selectedProvince,
              ),
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
          color: familySectionColor,
          onEdit: () {
            if (onJumpToTab != null) {
              onJumpToTab!(1);
            } else {
              onEditSection?.call();
            }
          },
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
          color: additionalSectionColor,
          onEdit: () {
            if (onJumpToTab != null) {
              onJumpToTab!(0);
            } else {
              onEditSection?.call();
            }
          },
          children: [
            ReviewDataRow(
              label: 'المستوى التعليمي',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.educationLevel,
                code: formControllers.selectedEducationLevel,
              ),
              icon: Icons.school_rounded,
            ),
            ReviewDataRow(
              label: 'حالة التوظيف',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.employmentStatus,
                code: formControllers.selectedEmploymentStatus,
              ),
              icon: Icons.work_outline_rounded,
            ),
            ReviewDataRow(
              label: 'الحالة الصحية',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.healthStatus,
                code: formControllers.selectedHealthStatus,
              ),
              icon: Icons.favorite_outline_rounded,
            ),
            ReviewDataRow(
              label: 'الأمراض المزمنة',
              value: formControllers.chronicDiseasesController.text,
              icon: Icons.medical_services_outlined,
            ),
            ReviewDataRow(
              label: 'حالة السكن',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.housingStatus,
                code: formControllers.selectedHousingStatus,
              ),
              icon: Icons.home_outlined,
            ),
            ReviewDataRow(
              label: 'نوع السكن',
              value: _resolveTaxonomyLabel(
                index: taxonomyIndex,
                group: TaxonomyGroup.housingType,
                code: formControllers.selectedHousingType,
              ),
              icon: Icons.apartment_outlined,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 📎 المرفقات
        ReviewSectionCard(
          title: 'المرفقات',
          icon: Icons.attach_file_rounded,
          color: attachmentsSectionColor,
          onEdit: () {
            if (onJumpToTab != null) {
              onJumpToTab!(3);
            } else {
              onEditSection?.call();
            }
          },
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
            color: notesSectionColor,
            onEdit: () {
              if (onJumpToTab != null) {
                onJumpToTab!(2);
              } else {
                onEditSection?.call();
              }
            },
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
              colors: canFinalSave
                  ? [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ]
                  : [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: (canFinalSave ? colorScheme.primary : colorScheme.outline).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canFinalSave ? onFinalSave : null,
              borderRadius: BorderRadius.circular(16.r),
              child: Semantics(
                button: true,
                enabled: canFinalSave,
                label: 'حفظ السجل نهائياً',
                hint: canFinalSave ? 'يؤكد حفظ جميع بيانات المستفيد' : 'عطّل الحفظ النهائي لحين إكمال المتطلبات',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        color: canFinalSave ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        size: 28.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        canFinalSave ? 'حفظ السجل نهائياً' : 'أكمل الحقول الأساسية أولاً',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: canFinalSave ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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

  int? _tabForRequiredField(String fieldName) {
    switch (fieldName) {
      case 'الاسم الكامل':
      case 'الرقم الوطني':
      case 'الجنس':
      case 'الفئة':
        return 0;
      case 'رقم الهاتف':
      case 'المحافظة':
      case 'المدينة':
        return 2;
      case 'عدد أفراد الأسرة':
        return 1;
      default:
        return null;
    }
  }

  (int, String, _ProfileStrengthLevel) _calculateProfileStrength() {
    var score = 0;
    var checks = 0;

    bool addCheck(bool pass) {
      checks += 1;
      if (pass) score += 1;
      return pass;
    }

    addCheck(_getFullName() != 'غير محدد');
    addCheck(formControllers.nationalIdController.text.trim().isNotEmpty);
    addCheck(formControllers.phoneController.text.trim().isNotEmpty);
    addCheck(formControllers.selectedProvince?.trim().isNotEmpty == true);
    addCheck(formControllers.selectedCity?.trim().isNotEmpty == true);
    addCheck(formControllers.selectedGender?.trim().isNotEmpty == true);
    addCheck(formControllers.selectedCategory?.trim().isNotEmpty == true);
    addCheck(formControllers.numberOfDependentsController.text.trim().isNotEmpty);
    addCheck(formControllers.pendingAttachments.isNotEmpty);
    addCheck(formControllers.notesController.text.trim().isNotEmpty);

    final percent = checks == 0 ? 0 : ((score / checks) * 100).round();

    if (percent >= 85) {
      return (percent, 'ممتاز', _ProfileStrengthLevel.strong);
    }
    if (percent >= 60) {
      return (percent, 'جيد', _ProfileStrengthLevel.medium);
    }
    return (percent, 'ضعيف', _ProfileStrengthLevel.weak);
  }

  Map<String, String?> _requiredFieldValues() {
    final fullName = _getFullName();
    return <String, String?>{
      'الاسم الكامل': fullName == 'غير محدد' ? null : fullName,
      'الرقم الوطني': formControllers.nationalIdController.text,
      'رقم الهاتف': formControllers.phoneController.text,
      'الجنس': formControllers.selectedGender,
      'الفئة': formControllers.selectedCategory,
      'المحافظة': formControllers.selectedProvince,
      'المدينة': formControllers.selectedCity,
      'عدد أفراد الأسرة': formControllers.numberOfDependentsController.text,
    };
  }

  int _countUnresolvedTaxonomySelections(Map<TaxonomyGroup, List<taxonomy_domain.Taxonomy>> index) {
    final probes = <(TaxonomyGroup group, String? code)>[
      (TaxonomyGroup.gender, formControllers.selectedGender),
      (TaxonomyGroup.category, formControllers.selectedCategory),
      (TaxonomyGroup.beneficiaryStatus, formControllers.selectedRequestStatus),
      (TaxonomyGroup.governorate, formControllers.selectedProvince),
      (TaxonomyGroup.educationLevel, formControllers.selectedEducationLevel),
      (TaxonomyGroup.employmentStatus, formControllers.selectedEmploymentStatus),
      (TaxonomyGroup.healthStatus, formControllers.selectedHealthStatus),
      (TaxonomyGroup.housingStatus, formControllers.selectedHousingStatus),
      (TaxonomyGroup.housingType, formControllers.selectedHousingType),
    ];

    var unresolved = 0;
    for (final probe in probes) {
      final raw = probe.$2?.trim();
      if (raw == null || raw.isEmpty) {
        continue;
      }

      final label = _resolveTaxonomyLabel(index: index, group: probe.$1, code: raw)?.trim();
      if (label == null || label.isEmpty) {
        continue;
      }

      if (label == raw && _looksLikeTaxonomyCode(raw)) {
        unresolved++;
      }
    }

    return unresolved;
  }

  bool _looksLikeTaxonomyCode(String value) {
    return RegExp(r'^\d+$').hasMatch(value) || value.contains('::') || value.contains('_');
  }

  String? _resolveTaxonomyLabel({
    required Map<TaxonomyGroup, List<taxonomy_domain.Taxonomy>> index,
    required TaxonomyGroup group,
    required String? code,
  }) {
    final raw = code?.trim();
    if (raw == null || raw.isEmpty) {
      return code;
    }

    final options = index[group] ?? const <taxonomy_domain.Taxonomy>[];
    for (final item in options) {
      if (item.code == raw || item.id == raw) {
        return item.label;
      }
    }

    return code;
  }
}

enum _ProfileStrengthLevel {
  weak,
  medium,
  strong,
}
