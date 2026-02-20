import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../features/taxonomies/taxonomies.dart';
import '../../../pages/v2_form_helpers/civil_registry_lookup_controller.dart';
import '../../../pages/v2_form_helpers/civil_registry_autofill_feedback_helper.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';
import '../../../providers/beneficiary_dependencies.dart';
import '../../../providers/civil_registry_provider.dart';
import '../../autofill_button.dart';
import '../../civil_registry_preview_card.dart';
import '../../civil_registry_required_banner.dart';
import '../../civil_registry_status_indicator.dart';

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
  ConsumerState<V2PersonalInfoMergedTab> createState() => _V2PersonalInfoMergedTabState();
}

class _V2PersonalInfoMergedTabState extends ConsumerState<V2PersonalInfoMergedTab> {
  late final CivilRegistryLookupController _lookupController;

  @override
  void initState() {
    super.initState();
    _lookupController = CivilRegistryLookupController();
    widget.formControllers.nationalIdController.addListener(_onNationalIdChanged);
  }

  @override
  void dispose() {
    widget.formControllers.nationalIdController.removeListener(_onNationalIdChanged);
    _lookupController.dispose();
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.formControllers.nationalIdController.text.trim();
    final canUseCivilRegistry = ref.read(civilRegistryAvailableProvider).value ?? false;

    _lookupController.onNationalIdChanged(
      nationalId: nationalId,
      canUseCivilRegistry: canUseCivilRegistry,
      nationalIdLength: FormConstants.nationalIdLength,
      debounceDuration: FormConstants.civilRegistryDebounce,
      fetchByNationalId: (id) => ref.read(civilRegistryProvider.notifier).fetchByNationalId(id),
      isLookupInProgressForId: () {
        final providerState = ref.read(civilRegistryProvider);
        return providerState.isLoading && providerState.lastSearchedNationalId == nationalId;
      }(),
      resetProvider: () => ref.read(civilRegistryProvider.notifier).reset(),
      requestRebuild: () {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  void _handleAutofill() {
    final result = ref.read(civilRegistryProvider.notifier).autofillForm(widget.formControllers);
    if (result == null) return;

    CivilRegistryAutofillFeedbackHelper.showSuccess(
      context: context,
      message: '✓ تم ملء ${result.filledFieldsCount} حقل بنجاح',
      onCompleted: () {
        _lookupController.onAutofillCompleted(
          requestRebuild: () {
            if (!mounted) return;
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      physics: const ClampingScrollPhysics(),
      cacheExtent: 100,
      children: [
        M3SectionCard(
          title: 'الاسم الكامل',
          icon: Icons.person_rounded,
          headerColor: FormColors.tabGradients[0]![0].withOpacity(0.2),
          children: [
            ResponsiveFormLayout(
              children: [
                M3TextField(
                  controller: widget.formControllers.firstNameController,
                  label: 'الاسم الأول',
                  prefixIcon: Icons.person_rounded,
                  isRequired: true,
                  focusNode: widget.firstFieldFocusNode,
                  validator: (value) => value?.isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                ),
                M3TextField(
                  controller: widget.formControllers.fatherNameController,
                  label: 'اسم الأب',
                  prefixIcon: Icons.person_outline_rounded,
                  isRequired: true,
                  validator: (value) => value?.isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
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
                  validator: (value) => value?.isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
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
                LengthLimitingTextInputFormatter(FormConstants.nationalIdLength),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return FormConstants.requiredFieldMessage;
                if (value!.length != FormConstants.nationalIdLength) {
                  return FormConstants.invalidNationalIdMessage;
                }
                return null;
              },
              helperText: 'يجب أن يكون ${FormConstants.nationalIdLength} أرقام',
            ),
            Consumer(
              builder: (context, ref, _) {
                final civilRegistryAvailable = ref.watch(civilRegistryAvailableProvider);
                final civilRegistryState = ref.watch(civilRegistryProvider);
                final canUseCivilRegistry = civilRegistryAvailable.value ?? false;

                return Column(
                  children: [
                    if (!canUseCivilRegistry) const CivilRegistryRequiredBanner(),
                    if (canUseCivilRegistry && civilRegistryState.status != CivilRegistryStatus.initial)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CivilRegistryStatusIndicator(
                          state: civilRegistryState,
                          onRetry: () {
                            final nationalId = widget.formControllers.nationalIdController.text;
                            if (nationalId.length == FormConstants.nationalIdLength) {
                              ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);
                            }
                          },
                        ),
                      ),
                    if (canUseCivilRegistry &&
                        civilRegistryState.isSuccess &&
                        civilRegistryState.person != null &&
                        _lookupController.showPreview)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: CivilRegistryPreviewCard(
                          person: civilRegistryState.person!,
                          onDismiss: () {
                            _lookupController.dismissPreview(() {
                              if (!mounted) return;
                              setState(() {});
                            });
                          },
                        ),
                      ),
                    if (canUseCivilRegistry &&
                        civilRegistryState.isSuccess &&
                        civilRegistryState.person != null &&
                        !_lookupController.hasAutofilled)
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
                              onPressed: () {
                                _lookupController.togglePreview(() {
                                  if (!mounted) return;
                                  setState(() {});
                                });
                              },
                              icon: Icon(
                                _lookupController.showPreview ? Icons.visibility_off : Icons.visibility,
                                size: 24.sp,
                              ),
                              tooltip: _lookupController.showPreview ? 'إخفاء المعاينة' : 'عرض المعاينة',
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 12.h),
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
                  onChanged: (value) => widget.formControllers.selectedGender = value,
                  validator: (value) => value == null ? FormConstants.requiredFieldMessage : null,
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.category,
              selectedCode: widget.formControllers.selectedCategory,
              onCodeChanged: (value) => widget.formControllers.selectedCategory = value,
              labelText: 'فئة المستفيد',
              isRequired: true,
            ),
            SizedBox(height: 12.h),
            ResponsiveFormLayout(
              children: [
                M3TextField(
                  controller: widget.formControllers.fileNumberController,
                  label: 'رقم الملف',
                  prefixIcon: Icons.folder_rounded,
                  keyboardType: TextInputType.number,
                  helperText: 'رقم ملف المستفيد الرسمي',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedRequestStatus,
                  label: 'حالة الطلب',
                  prefixIcon: Icons.pending_actions_rounded,
                  onChanged: (value) => widget.formControllers.selectedRequestStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'قيد المراجعة', child: Text('قيد المراجعة')),
                    DropdownMenuItem(value: 'مقبول', child: Text('مقبول')),
                    DropdownMenuItem(value: 'مرفوض', child: Text('مرفوض')),
                    DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                  ],
                ),
              ],
            ),
          ],
        ),
        M3SectionCard(
          title: 'معلومات إضافية',
          icon: Icons.info_outline_rounded,
          headerColor: FormColors.tabGradients[0]![1].withOpacity(0.2),
          children: [
            ResponsiveFormLayout(
              children: [
                M3DropdownField<String>(
                  value: widget.formControllers.selectedEducationLevel,
                  label: 'المستوى التعليمي',
                  prefixIcon: Icons.school_rounded,
                  onChanged: (value) => widget.formControllers.selectedEducationLevel = value,
                  items: const [
                    DropdownMenuItem(value: 'أمي', child: Text('أمي')),
                    DropdownMenuItem(value: 'ابتدائي', child: Text('ابتدائي')),
                    DropdownMenuItem(value: 'إعدادي', child: Text('إعدادي')),
                    DropdownMenuItem(value: 'ثانوي', child: Text('ثانوي')),
                    DropdownMenuItem(value: 'جامعي', child: Text('جامعي')),
                    DropdownMenuItem(value: 'دراسات عليا', child: Text('دراسات عليا')),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedEmploymentStatus,
                  label: 'حالة التوظيف',
                  prefixIcon: Icons.work_outline_rounded,
                  onChanged: (value) => widget.formControllers.selectedEmploymentStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'موظف', child: Text('موظف')),
                    DropdownMenuItem(value: 'عاطل', child: Text('عاطل عن العمل')),
                    DropdownMenuItem(value: 'طالب', child: Text('طالب')),
                    DropdownMenuItem(value: 'متقاعد', child: Text('متقاعد')),
                    DropdownMenuItem(value: 'أعمال حرة', child: Text('أعمال حرة')),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHealthStatus,
                  label: 'الحالة الصحية',
                  prefixIcon: Icons.favorite_outline_rounded,
                  onChanged: (value) => widget.formControllers.selectedHealthStatus = value,
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
            M3TextField(
              controller: widget.formControllers.specialNeedsCountController,
              label: 'عدد ذوي الاحتياجات الخاصة',
              prefixIcon: Icons.accessible_rounded,
              keyboardType: TextInputType.number,
              helperText: 'عدد أفراد الأسرة من ذوي الاحتياجات الخاصة',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 12.h),
            ResponsiveFormLayout(
              children: [
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHousingStatus,
                  label: 'حالة السكن',
                  prefixIcon: Icons.home_outlined,
                  onChanged: (value) => widget.formControllers.selectedHousingStatus = value,
                  items: const [
                    DropdownMenuItem(value: 'ملك', child: Text('ملك')),
                    DropdownMenuItem(value: 'إيجار', child: Text('إيجار')),
                    DropdownMenuItem(value: 'سكن مشترك', child: Text('سكن مشترك')),
                    DropdownMenuItem(value: 'آخر', child: Text('آخر')),
                  ],
                ),
                M3DropdownField<String>(
                  value: widget.formControllers.selectedHousingType,
                  label: 'نوع السكن',
                  prefixIcon: Icons.apartment_outlined,
                  onChanged: (value) => widget.formControllers.selectedHousingType = value,
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
