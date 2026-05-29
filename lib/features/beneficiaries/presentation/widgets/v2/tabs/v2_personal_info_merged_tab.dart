import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../features/taxonomies/taxonomies.dart';
import '../../../../../../features/taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../../../../../core/analytics/ux_flow_analytics.dart';
import '../../../../../../core/utils/debouncer.dart';
import '../../../pages/v2_form_helpers/civil_registry_lookup_controller.dart';
import '../../../pages/v2_form_helpers/civil_registry_autofill_feedback_helper.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/personal_profile_validator.dart';
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
  final VoidCallback? onRequestNextTab;

  const V2PersonalInfoMergedTab({
    required this.formControllers,
    required this.onBirthDateTap,
    super.key,
    this.firstFieldFocusNode,
    this.onRequestNextTab,
  });

  @override
  ConsumerState<V2PersonalInfoMergedTab> createState() => _V2PersonalInfoMergedTabState();
}

class _V2PersonalInfoMergedTabState extends ConsumerState<V2PersonalInfoMergedTab> {
  late final CivilRegistryLookupController _lookupController;
  final Throttler _uiRefreshThrottler = Throttler(interval: const Duration(milliseconds: 120));
  Timer? _deferredSecondarySectionsTimer;
  bool _secondarySectionsReady = false;
  bool _nationalIdAutoAdvanced = false;
  bool _quickHintVisible = true; // dismissed after user taps close
  bool _hasUserStartedEditing = false; // show validation status only after editing starts

  @override
  void initState() {
    super.initState();
    _lookupController = CivilRegistryLookupController();
    widget.formControllers.nationalIdController.addListener(_onNationalIdChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deferredSecondarySectionsTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _requestUiRefresh(() => _secondarySectionsReady = true);
      });
    });
  }

  @override
  void dispose() {
    widget.formControllers.nationalIdController.removeListener(_onNationalIdChanged);
    _deferredSecondarySectionsTimer?.cancel();
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
        _requestUiRefresh();
      },
    );
  }

  void _requestUiRefresh([VoidCallback? mutate]) {
    _uiRefreshThrottler(() {
      if (!mounted) return;
      setState(() {
        mutate?.call();
      });
    });
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
            _requestUiRefresh();
          },
        );
      },
    );
  }

  void _showNextTabHint() {
    final onRequestNextTab = widget.onRequestNextTab;
    if (onRequestNextTab == null || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: const Text('تم إنهاء إدخال هذا القسم. جاهز للانتقال للتبويب التالي؟'),
        action: SnackBarAction(
          label: 'التالي',
          onPressed: onRequestNextTab,
        ),
      ),
    );
  }

  Widget _orderedField(double order, Widget child) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: child,
    );
  }

  Widget _buildServerFileIdField() {
    return M3TextField(
      controller: widget.formControllers.fileNumberController,
      label: 'رقم الملف',
      prefixIcon: Icons.folder_rounded,
      readOnly: true,
      keyboardType: TextInputType.number,
      helperText: 'يُحجز تلقائياً من السيرفر',
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildQuickStartHint(BuildContext context, {required bool canUseCivilRegistry}) {
    if (!_quickHintVisible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 4.w, 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, size: 16.sp, color: colorScheme.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              canUseCivilRegistry
                  ? 'أدخل الرقم الوطني (9 أرقام) للتعبئة التلقائية من السجل المدني.'
                  : 'أدخل الرقم الوطني أولاً ثم أكمل الاسم والحقول الأساسية.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
            onPressed: () => _requestUiRefresh(() => _quickHintVisible = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalValidationStatus(
    BuildContext context, {
    required List<String> criticalIssues,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReady = criticalIssues.isEmpty;
    final toneColor = isReady ? colorScheme.primary : colorScheme.error;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isReady
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isReady ? colorScheme.primary.withValues(alpha: 0.4) : colorScheme.error.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isReady ? Icons.verified_outlined : Icons.error_outline_rounded,
            size: 16.sp,
            color: toneColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: isReady
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المدخلات الحرجة مكتملة. يمكنك المتابعة لباقي الحقول بثقة.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      if (widget.onRequestNextTab != null) ...[
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              UxFlowAnalytics.trackBeneficiaryPersonalQuickNext(
                                source: 'critical_status_ready',
                              );
                              widget.onRequestNextTab?.call();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('انتقل لتبويب العائلة'),
                          ),
                        ),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحقق سريع قبل المتابعة:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        criticalIssues.join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _onNationalIdInputChanged(String value) {
    final digits = value.trim();
    if (!_hasUserStartedEditing && digits.isNotEmpty) {
      _requestUiRefresh(() => _hasUserStartedEditing = true);
    }
    if (digits.length == FormConstants.nationalIdLength) {
      if (_nationalIdAutoAdvanced) {
        return;
      }
      _nationalIdAutoAdvanced = true;
      UxFlowAnalytics.trackBeneficiaryPersonalAutoAdvance(
        field: 'national_id',
        inputLength: digits.length,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FocusScope.of(context).nextFocus();
      });
      return;
    }
    _nationalIdAutoAdvanced = false;
  }

  @override
  Widget build(BuildContext context) {
    final taxonomyIndexAsync = ref.watch(bridgeTaxonomiesIndexOnceProvider);
    final canUseCivilRegistry = ref.watch(civilRegistryAvailableProvider).value ?? false;
    final taxonomyReady = taxonomyIndexAsync.hasValue;
    final specialNeedsCount = int.tryParse(widget.formControllers.specialNeedsCountController.text.trim()) ?? 0;
    final hasSpecialNeeds = specialNeedsCount > 0;
    final hasEmploymentStatus = widget.formControllers.selectedEmploymentStatus?.trim().isNotEmpty ?? false;
    final hasCategory = widget.formControllers.selectedCategory?.trim().isNotEmpty ?? false;
    final validation = PersonalProfileValidator.evaluate(widget.formControllers);
    final criticalIssues = validation.criticalIssues;

    List<Taxonomy> optionsFor(TaxonomyGroup group) {
      final index = taxonomyIndexAsync.asData?.value;
      if (index == null) return const <Taxonomy>[];

      final direct = index[group] ?? const <Taxonomy>[];
      if (direct.isNotEmpty) {
        return direct;
      }

      final equivalents = equivalentBeneficiaryTaxonomyGroups[group] ?? const <TaxonomyGroup>[];
      for (final equivalentGroup in equivalents) {
        final equivalentItems = index[equivalentGroup] ?? const <Taxonomy>[];
        if (equivalentItems.isNotEmpty) {
          return equivalentItems;
        }
      }

      return direct;
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        physics: const ClampingScrollPhysics(),
        cacheExtent: 24,
        children: [
          _buildQuickStartHint(context, canUseCivilRegistry: canUseCivilRegistry),
          if (_hasUserStartedEditing) _buildCriticalValidationStatus(context, criticalIssues: criticalIssues),
          M3SectionCard(
            title: 'الهوية والسجل المدني',
            icon: Icons.credit_card_rounded,
            headerColor: FormColors.tabGradients[0]![0].withValues(alpha: 0.2),
            children: [
              _orderedField(
                10,
                M3TextField(
                  controller: widget.formControllers.nationalIdController,
                  label: 'الرقم الوطني',
                  prefixIcon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  maxLength: FormConstants.nationalIdLength,
                  isRequired: true,
                  focusNode: widget.firstFieldFocusNode,
                  textInputAction: TextInputAction.next,
                  onChanged: _onNationalIdInputChanged,
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
                                _requestUiRefresh();
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
                                ),
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                onPressed: () {
                                  _lookupController.togglePreview(() {
                                    _requestUiRefresh();
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
                  _orderedField(
                    20,
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
                  ),
                  _orderedField(
                    30,
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.gender,
                      preloadedOptions: optionsFor(TaxonomyGroup.gender),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedGender,
                      onCodeChanged: (value) => widget.formControllers.selectedGender = value,
                      labelText: 'الجنس',
                      isRequired: true,
                      prefixIcon: Icons.wc_rounded,
                      autoSyncOnEmpty: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _orderedField(
                40,
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.category,
                  preloadedOptions: optionsFor(TaxonomyGroup.category),
                  enabled: taxonomyReady,
                  selectedCode: widget.formControllers.selectedCategory,
                  onCodeChanged: (value) => widget.formControllers.selectedCategory = value,
                  labelText: 'فئة المستفيد',
                  isRequired: true,
                  autoSyncOnEmpty: true,
                ),
              ),
              SizedBox(height: 12.h),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(top: 8.h),
                  shape: Border.all(color: Colors.transparent, width: 0),
                  collapsedShape: Border.all(color: Colors.transparent, width: 0),
                  title: Text(
                    'حقول إدارية إضافية (اختياري)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'افتحها عند الحاجة فقط لتقليل ازدحام الإدخال',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  children: [
                    ResponsiveFormLayout(
                      children: [
                        _buildServerFileIdField(),
                        TaxonomyBridgeDropdown(
                          group: TaxonomyGroup.beneficiaryStatus,
                          preloadedOptions: optionsFor(TaxonomyGroup.beneficiaryStatus),
                          enabled: taxonomyReady,
                          selectedCode: widget.formControllers.selectedRequestStatus,
                          onCodeChanged: (value) => widget.formControllers.selectedRequestStatus = value,
                          labelText: 'حالة الطلب',
                          prefixIcon: Icons.pending_actions_rounded,
                          autoSyncOnEmpty: true,
                        ),
                        TaxonomyBridgeDropdown(
                          group: TaxonomyGroup.assistanceType,
                          preloadedOptions: optionsFor(TaxonomyGroup.assistanceType),
                          enabled: taxonomyReady,
                          selectedCode: widget.formControllers.selectedAssistanceType,
                          onCodeChanged: (value) => widget.formControllers.selectedAssistanceType = value,
                          labelText: 'نوع المساعدة',
                          prefixIcon: Icons.handshake_rounded,
                          isRequired: hasCategory,
                        ),
                        TaxonomyBridgeDropdown(
                          group: TaxonomyGroup.guaranteeType,
                          preloadedOptions: optionsFor(TaxonomyGroup.guaranteeType),
                          enabled: taxonomyReady,
                          selectedCode: widget.formControllers.selectedGuaranteeType,
                          onCodeChanged: (value) => widget.formControllers.selectedGuaranteeType = value,
                          labelText: 'نوع الضمان',
                          prefixIcon: Icons.verified_rounded,
                        ),
                        TaxonomyBridgeDropdown(
                          group: TaxonomyGroup.section,
                          preloadedOptions: optionsFor(TaxonomyGroup.section),
                          enabled: taxonomyReady,
                          selectedCode: widget.formControllers.selectedSection,
                          onCodeChanged: (value) => widget.formControllers.selectedSection = value,
                          labelText: 'القسم',
                          prefixIcon: Icons.account_tree_rounded,
                          autoSyncOnEmpty: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          M3SectionCard(
            title: 'الاسم الكامل',
            icon: Icons.person_rounded,
            headerColor: FormColors.tabGradients[0]![0].withValues(alpha: 0.2),
            children: [
              ResponsiveFormLayout(
                children: [
                  _orderedField(
                    50,
                    M3TextField(
                      controller: widget.formControllers.firstNameController,
                      label: 'الاسم الأول',
                      prefixIcon: Icons.person_rounded,
                      isRequired: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.trim().isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                    ),
                  ),
                  _orderedField(
                    60,
                    M3TextField(
                      controller: widget.formControllers.fatherNameController,
                      label: 'اسم الأب',
                      prefixIcon: Icons.person_outline_rounded,
                      isRequired: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.trim().isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ResponsiveFormLayout(
                children: [
                  _orderedField(
                    70,
                    M3TextField(
                      controller: widget.formControllers.grandfatherNameController,
                      label: 'اسم الجد',
                      prefixIcon: Icons.elderly_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  _orderedField(
                    80,
                    M3TextField(
                      controller: widget.formControllers.lastNameController,
                      label: 'اللقب',
                      prefixIcon: Icons.family_restroom_rounded,
                      isRequired: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.trim().isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _orderedField(
                90,
                M3TextField(
                  controller: widget.formControllers.motherNameController,
                  label: 'اسم الأم',
                  prefixIcon: Icons.face_rounded,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _showNextTabHint(),
                ),
              ),
            ],
          ),
          if (_secondarySectionsReady)
            M3SectionCard(
              title: 'معلومات إضافية',
              icon: Icons.info_outline_rounded,
              headerColor: FormColors.tabGradients[0]![1].withValues(alpha: 0.2),
              children: [
                ResponsiveFormLayout(
                  children: [
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.educationLevel,
                      preloadedOptions: optionsFor(TaxonomyGroup.educationLevel),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedEducationLevel,
                      onCodeChanged: (value) => widget.formControllers.selectedEducationLevel = value,
                      labelText: 'المستوى التعليمي',
                      prefixIcon: Icons.school_rounded,
                    ),
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.employmentStatus,
                      preloadedOptions: optionsFor(TaxonomyGroup.employmentStatus),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedEmploymentStatus,
                      onCodeChanged: (value) => widget.formControllers.selectedEmploymentStatus = value,
                      labelText: 'حالة التوظيف',
                      prefixIcon: Icons.work_outline_rounded,
                    ),
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.healthStatus,
                      preloadedOptions: optionsFor(TaxonomyGroup.healthStatus),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedHealthStatus,
                      onCodeChanged: (value) => widget.formControllers.selectedHealthStatus = value,
                      labelText: 'الحالة الصحية',
                      prefixIcon: Icons.favorite_outline_rounded,
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _showNextTabHint(),
                  helperText: 'عدد أفراد الأسرة من ذوي الاحتياجات الخاصة',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (hasSpecialNeeds && (widget.formControllers.selectedDisabilityType?.trim().isNotEmpty != true)) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'يرجى تحديد نوع الإعاقة لأن عدد ذوي الاحتياجات الخاصة أكبر من صفر',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                SizedBox(height: 12.h),
                ResponsiveFormLayout(
                  children: [
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.housingStatus,
                      preloadedOptions: optionsFor(TaxonomyGroup.housingStatus),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedHousingStatus,
                      onCodeChanged: (value) => widget.formControllers.selectedHousingStatus = value,
                      labelText: 'حالة السكن',
                      prefixIcon: Icons.home_outlined,
                    ),
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.housingType,
                      preloadedOptions: optionsFor(TaxonomyGroup.housingType),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedHousingType,
                      onCodeChanged: (value) => widget.formControllers.selectedHousingType = value,
                      labelText: 'نوع السكن',
                      prefixIcon: Icons.apartment_outlined,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ResponsiveFormLayout(
                  children: [
                    TaxonomyBridgeDropdown(
                      group: TaxonomyGroup.disabilityType,
                      preloadedOptions: optionsFor(TaxonomyGroup.disabilityType),
                      enabled: taxonomyReady,
                      selectedCode: widget.formControllers.selectedDisabilityType,
                      onCodeChanged: (value) => widget.formControllers.selectedDisabilityType = value,
                      labelText: 'نوع الإعاقة',
                      prefixIcon: Icons.accessible_forward_rounded,
                      isRequired: hasSpecialNeeds,
                      autoSyncOnEmpty: true,
                    ),
                    if (hasEmploymentStatus)
                      TaxonomyBridgeDropdown(
                        group: TaxonomyGroup.incomeSource,
                        preloadedOptions: optionsFor(TaxonomyGroup.incomeSource),
                        enabled: taxonomyReady,
                        selectedCode: widget.formControllers.selectedIncomeSource,
                        onCodeChanged: (value) => widget.formControllers.selectedIncomeSource = value,
                        labelText: 'مصدر الدخل',
                        prefixIcon: Icons.account_balance_wallet_outlined,
                        autoSyncOnEmpty: true,
                      ),
                  ],
                ),
              ],
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: const LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}
