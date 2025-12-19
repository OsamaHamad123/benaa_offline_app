import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 🎱 Responsive
import '../../../providers/beneficiary_dependencies.dart';
import '../../../providers/civil_registry_provider.dart';
import '../../civil_registry_status_indicator.dart';
import '../../autofill_button.dart';
import '../../civil_registry_preview_card.dart';

/// 👤 Personal Info Merged Tab (Basic + Additional Info)
///
/// دمج التبويبات: أساسي + إضافي
class V2PersonalInfoMergedTab extends ConsumerStatefulWidget {
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onBirthDateTap;
  final FocusNode? firstFieldFocusNode;

  const V2PersonalInfoMergedTab({
    super.key,
    required this.formControllers,
    required this.onBirthDateTap,
    this.firstFieldFocusNode,
  });

  @override
  ConsumerState<V2PersonalInfoMergedTab> createState() =>
      _V2PersonalInfoMergedTabState();
}

class _V2PersonalInfoMergedTabState
    extends ConsumerState<V2PersonalInfoMergedTab> {
  Timer? _debounceTimer;
  bool _showPreview = false;
  bool _hasAutofilled = false;

  @override
  void initState() {
    super.initState();
    widget.formControllers.nationalIdController.addListener(
      _onNationalIdChanged,
    );
  }

  @override
  void dispose() {
    widget.formControllers.nationalIdController.removeListener(
      _onNationalIdChanged,
    );
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.formControllers.nationalIdController.text;

    _debounceTimer?.cancel();

    if (nationalId.length < FormConstants.nationalIdLength) {
      setState(() {
        _showPreview = false;
        _hasAutofilled = false; // Reset when ID changes
      });
      ref.read(civilRegistryProvider.notifier).reset();
      return;
    }

    _debounceTimer = Timer(FormConstants.civilRegistryDebounce, () {
      if (nationalId.length == FormConstants.nationalIdLength) {
        ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);
      }
    });
  }

  void _handleAutofill() {
    final result = ref
        .read(civilRegistryProvider.notifier)
        .autofillForm(widget.formControllers);

    if (result != null) {
      HapticFeedback.lightImpact();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '✓ تم ملء ${result.filledFieldsCount} حقل بنجاح',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Hide preview card and button after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showPreview = false;
            _hasAutofilled = true; // Mark as autofilled to hide button
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ DON'T watch provider in build - causes rebuild on every keystroke!
    // Use Consumer below only where needed

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      physics: const ClampingScrollPhysics(), // ⚡ Smooth scroll
      cacheExtent: 100, // ⚡ Reduce repaints
      children: [
        // 📋 Basic Information Section
        M3SectionCard(
          title: 'الاسم الكامل',
          icon: Icons.person_rounded,
          headerColor: FormColors.tabGradients[0]![0].withOpacity(0.2),
          children: [
            // 📱 Responsive: 1 column mobile, 2 columns tablet+
            ResponsiveFormLayout(
              children: [
                M3TextField(
                  controller: widget.formControllers.firstNameController,
                  label: 'الاسم الأول',
                  prefixIcon: Icons.person_rounded,
                  isRequired: true,
                  focusNode: widget.firstFieldFocusNode,
                  validator: (value) => value?.isEmpty ?? true
                      ? FormConstants.requiredFieldMessage
                      : null,
                ),
                M3TextField(
                  controller: widget.formControllers.fatherNameController,
                  label: 'اسم الأب',
                  prefixIcon: Icons.person_outline_rounded,
                  isRequired: true,
                  validator: (value) => value?.isEmpty ?? true
                      ? FormConstants.requiredFieldMessage
                      : null,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ResponsiveFormLayout(
              children: [
                M3TextField(
                  controller: widget.formControllers.grandfatherNameController,
                  label: 'اسم الجد',
                  prefixIcon: Icons.elderly_rounded,
                ),
                M3TextField(
                  controller: widget.formControllers.lastNameController,
                  label: 'اللقب',
                  prefixIcon: Icons.family_restroom_rounded,
                  isRequired: true,
                  validator: (value) => value?.isEmpty ?? true
                      ? FormConstants.requiredFieldMessage
                      : null,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            M3TextField(
              controller: widget.formControllers.motherNameController,
              label: 'اسم الأم',
              prefixIcon: Icons.face_rounded,
            ),
          ],
        ),

        // 🆔 Identity & Civil Registry Section
        M3SectionCard(
          title: 'الهوية والسجل المدني',
          icon: Icons.credit_card_rounded,
          headerColor: FormColors.tabGradients[0]![0].withOpacity(0.2),
          children: [
            M3TextField(
              controller: widget.formControllers.nationalIdController,
              label: 'الرقم الوطني',
              prefixIcon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              maxLength: FormConstants.nationalIdLength,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  FormConstants.nationalIdLength,
                ),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return FormConstants.requiredFieldMessage;
                }
                if (value!.length != FormConstants.nationalIdLength) {
                  return FormConstants.invalidNationalIdMessage;
                }
                return null;
              },
              helperText: 'يجب أن يكون ${FormConstants.nationalIdLength} أرقام',
            ),

            // Civil Registry widgets wrapped in Consumer to prevent rebuilding entire tab
            Consumer(
              builder: (context, ref, _) {
                final civilRegistryState = ref.watch(civilRegistryProvider);

                return Column(
                  children: [
                    // Civil Registry Status
                    if (civilRegistryState.status !=
                        CivilRegistryStatus.initial)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CivilRegistryStatusIndicator(
                          state: civilRegistryState,
                          onRetry: () {
                            final nationalId = widget
                                .formControllers.nationalIdController.text;
                            if (nationalId.length ==
                                FormConstants.nationalIdLength) {
                              ref
                                  .read(civilRegistryProvider.notifier)
                                  .fetchByNationalId(nationalId);
                            }
                          },
                        ),
                      ),

                    // Preview Card
                    if (civilRegistryState.isSuccess &&
                        civilRegistryState.person != null &&
                        _showPreview)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CivilRegistryPreviewCard(
                          person: civilRegistryState.person!,
                          onDismiss: () => setState(() => _showPreview = false),
                        ),
                      ),

                    // Autofill Button - Only show if not yet autofilled
                    if (civilRegistryState.isSuccess &&
                        civilRegistryState.person != null &&
                        !_hasAutofilled)
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: AutofillButton(
                                onPressed: _handleAutofill,
                                isEnabled: true,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _showPreview = !_showPreview),
                              icon: Icon(
                                _showPreview
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 24.sp,
                              ),
                              tooltip: _showPreview
                                  ? 'إخفاء المعاينة'
                                  : 'عرض المعاينة',
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),

            SizedBox(height: 12.h),
            // 📱 Responsive Layout: 1 column mobile, 2 columns tablet
            ResponsiveFormLayout(
              children: [
                M3TextField(
                  controller: widget.formControllers.birthDateController,
                  label: 'تاريخ الميلاد',
                  prefixIcon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: widget.onBirthDateTap,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.event_rounded, size: 20.sp),
                    onPressed: widget.onBirthDateTap,
                  ),
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedGender,
                  label: 'الجنس',
                  prefixIcon: Icons.wc_rounded,
                  isRequired: true,
                  onChanged: (value) =>
                      widget.formControllers.selectedGender = value,
                  validator: (value) =>
                      value == null ? FormConstants.requiredFieldMessage : null,
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            M3DropdownField<String>(
              value: widget.formControllers.selectedCategory,
              label: 'فئة المستفيد',
              prefixIcon: Icons.category_rounded,
              isRequired: true,
              onChanged: (value) =>
                  widget.formControllers.selectedCategory = value,
              validator: (value) =>
                  value == null ? FormConstants.requiredFieldMessage : null,
              items: const [
                DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
                DropdownMenuItem(value: 'poor', child: Text('فقير')),
                DropdownMenuItem(value: 'displaced', child: Text('نازح')),
                DropdownMenuItem(value: 'widow', child: Text('أرملة')),
                DropdownMenuItem(
                  value: 'disabled',
                  child: Text('من ذوي الإعاقة'),
                ),
                DropdownMenuItem(value: 'other', child: Text('أخرى')),
              ],
            ),
          ],
        ),

        // 🎓 Additional Information Section
        M3SectionCard(
          title: 'معلومات إضافية',
          icon: Icons.info_outline_rounded,
          headerColor: FormColors.tabGradients[0]![1].withOpacity(0.2),
          children: [
            // 📱 Responsive Layout
            ResponsiveFormLayout(
              children: [
                M3DropdownField<String>(
                  value: widget.formControllers.selectedEducationLevel,
                  label: 'المستوى التعليمي',
                  prefixIcon: Icons.school_rounded,
                  onChanged: (value) =>
                      widget.formControllers.selectedEducationLevel = value,
                  items: const [
                    DropdownMenuItem(value: 'أمي', child: Text('أمي')),
                    DropdownMenuItem(value: 'ابتدائي', child: Text('ابتدائي')),
                    DropdownMenuItem(value: 'إعدادي', child: Text('إعدادي')),
                    DropdownMenuItem(value: 'ثانوي', child: Text('ثانوي')),
                    DropdownMenuItem(value: 'جامعي', child: Text('جامعي')),
                    DropdownMenuItem(
                      value: 'دراسات عليا',
                      child: Text('دراسات عليا'),
                    ),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedEmploymentStatus,
                  label: 'حالة التوظيف',
                  prefixIcon: Icons.work_outline_rounded,
                  onChanged: (value) =>
                      widget.formControllers.selectedEmploymentStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'موظف', child: Text('موظف')),
                    DropdownMenuItem(
                      value: 'عاطل',
                      child: Text('عاطل عن العمل'),
                    ),
                    DropdownMenuItem(value: 'طالب', child: Text('طالب')),
                    DropdownMenuItem(value: 'متقاعد', child: Text('متقاعد')),
                    DropdownMenuItem(
                      value: 'أعمال حرة',
                      child: Text('أعمال حرة'),
                    ),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHealthStatus,
                  label: 'الحالة الصحية',
                  prefixIcon: Icons.favorite_outline_rounded,
                  onChanged: (value) =>
                      widget.formControllers.selectedHealthStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'جيدة', child: Text('جيدة')),
                    DropdownMenuItem(value: 'متوسطة', child: Text('متوسطة')),
                    DropdownMenuItem(value: 'سيئة', child: Text('سيئة')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            M3TextField(
              controller: widget.formControllers.chronicDiseasesController,
              label: 'الأمراض المزمنة',
              prefixIcon: Icons.medical_services_outlined,
              maxLines: 3,
              helperText: 'أدخل الأمراض المزمنة إن وجدت',
            ),
            SizedBox(height: 12.h),
            // 📱 Responsive Layout - معلومات السكن
            ResponsiveFormLayout(
              children: [
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHousingStatus,
                  label: 'حالة السكن',
                  prefixIcon: Icons.home_outlined,
                  onChanged: (value) =>
                      widget.formControllers.selectedHousingStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'ملك', child: Text('ملك')),
                    DropdownMenuItem(value: 'إيجار', child: Text('إيجار')),
                    DropdownMenuItem(
                      value: 'سكن مشترك',
                      child: Text('سكن مشترك'),
                    ),
                    DropdownMenuItem(value: 'آخر', child: Text('آخر')),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHousingType,
                  label: 'نوع السكن',
                  prefixIcon: Icons.apartment_outlined,
                  onChanged: (value) =>
                      widget.formControllers.selectedHousingType = value,
                  items: const [
                    DropdownMenuItem(value: 'شقة', child: Text('شقة')),
                    DropdownMenuItem(value: 'بيت', child: Text('بيت')),
                    DropdownMenuItem(value: 'غرفة', child: Text('غرفة')),
                    DropdownMenuItem(value: 'خيمة', child: Text('خيمة')),
                    DropdownMenuItem(value: 'آخر', child: Text('آخر')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
