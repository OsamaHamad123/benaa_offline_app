import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../components/v2_custom_text_field.dart';
import '../../../../../../features/taxonomies/taxonomies.dart'; // 🏷️ Taxonomy System
import '../../../pages/v2_form_helpers/widgets/enhanced_section_widgets.dart'; // 🎨
import '../../../pages/v2_form_helpers/civil_registry_lookup_controller.dart';
import '../../../pages/v2_form_helpers/civil_registry_autofill_feedback_helper.dart';
import '../../../providers/beneficiary_dependencies.dart';
import '../../../providers/civil_registry_provider.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../../../../core/validation/field_validators.dart'; // 📋 Unified validators
import '../../../pages/v2_form_helpers/smart_helpers.dart'; // 🧠 Smart suggestions
import '../../../pages/v2_form_helpers/widgets/smart_widgets.dart'; // 💡 Smart widgets
import '../../civil_registry_status_indicator.dart';
import '../../autofill_button.dart';
import '../../civil_registry_preview_card.dart';
import '../../civil_registry_required_banner.dart';

/// Basic information tab with Civil Registry Integration
class V2BasicInfoTab extends ConsumerStatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController fatherNameController;
  final TextEditingController grandfatherNameController;
  final TextEditingController lastNameController;
  final TextEditingController motherNameController;
  final TextEditingController nationalIdController;
  final TextEditingController birthDateController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final VoidCallback onBirthDateTap;
  final FocusNode? firstFieldFocusNode;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final String? selectedRelationship;
  final Function(String?) onRelationshipChanged;
  final String? selectedSection;
  final Function(String?) onSectionChanged;
  final BeneficiaryFormControllers? formControllers; // For autofill

  const V2BasicInfoTab({
    required this.firstNameController,
    required this.fatherNameController,
    required this.grandfatherNameController,
    required this.lastNameController,
    required this.motherNameController,
    required this.nationalIdController,
    required this.birthDateController,
    required this.onGenderChanged,
    required this.onBirthDateTap,
    required this.onCategoryChanged,
    required this.onRelationshipChanged,
    required this.onSectionChanged,
    super.key,
    this.selectedGender,
    this.firstFieldFocusNode,
    this.selectedCategory,
    this.selectedRelationship,
    this.selectedSection,
    this.formControllers,
  });

  @override
  ConsumerState<V2BasicInfoTab> createState() => _V2BasicInfoTabState();
}

class _V2BasicInfoTabState extends ConsumerState<V2BasicInfoTab> {
  late final CivilRegistryLookupController _lookupController;
  bool _dismissedSuggestion = false; // Track if user dismissed suggestion

  String? _resolveSuggestedCategoryCode(String suggestion) {
    final categoriesAsync = ref.read(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category),
    );
    final categories = categoriesAsync.asData?.value ?? const <Taxonomy>[];
    if (categories.isEmpty) {
      return null;
    }

    final normalizedSuggestion = suggestion.trim().toLowerCase();

    for (final taxonomy in categories) {
      final code = taxonomy.code.trim().toLowerCase();
      final label = taxonomy.label.trim().toLowerCase();
      if (normalizedSuggestion.contains(label) ||
          normalizedSuggestion.contains(code) ||
          label.contains(normalizedSuggestion)) {
        return taxonomy.code;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _lookupController = CivilRegistryLookupController();
    widget.nationalIdController.addListener(_onNationalIdChanged);
  }

  @override
  void dispose() {
    widget.nationalIdController.removeListener(_onNationalIdChanged);
    _lookupController.dispose();
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.nationalIdController.text.trim();
    final canUseCivilRegistry = ref.read(civilRegistryAvailableProvider).value ?? false;

    _lookupController.onNationalIdChanged(
      nationalId: nationalId,
      canUseCivilRegistry: canUseCivilRegistry,
      nationalIdLength: 9,
      debounceDuration: const Duration(milliseconds: 500),
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
    if (widget.formControllers == null) return;

    final result = ref.read(civilRegistryProvider.notifier).autofillForm(widget.formControllers);

    if (result != null) {
      CivilRegistryAutofillFeedbackHelper.showSuccess(
        context: context,
        message: result.successMessage,
        duration: const Duration(seconds: 2),
        onCompleted: () {
          _lookupController.onAutofillCompleted(
            hideAfter: Duration.zero,
            requestRebuild: () {
              if (!mounted) return;
              setState(() {});
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final civilRegistryAvailable = ref.watch(civilRegistryAvailableProvider);
    final canUseCivilRegistry = civilRegistryAvailable.value ?? false;
    final civilRegistryState = ref.watch(civilRegistryProvider);

    // Check completion status
    final isNameComplete = widget.firstNameController.text.trim().isNotEmpty &&
        widget.fatherNameController.text.trim().isNotEmpty &&
        widget.lastNameController.text.trim().isNotEmpty;

    final requiresGender = requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.gender);
    final requiresCategory = requiredBeneficiaryTaxonomyGroups.contains(TaxonomyGroup.category);
    final isPersonalInfoComplete = widget.nationalIdController.text.length == 9 &&
      (!requiresGender || widget.selectedGender != null) &&
      (!requiresCategory || widget.selectedCategory != null);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        AnimatedSectionCard(
          title: 'الاسم الكامل',
          icon: Icons.person_rounded,
          isComplete: isNameComplete,
          children: [
            V2CustomTextField(
              controller: widget.firstNameController,
              label: 'الاسم الأول',
              prefixIcon: Icons.badge_rounded,
              isRequired: true,
              focusNode: widget.firstFieldFocusNode,
              validator: (value) => FieldValidators.validateArabicName(value, 'الاسم الأول'),
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.fatherNameController,
              label: 'اسم الأب',
              prefixIcon: Icons.person_outline_rounded,
              isRequired: true,
              validator: (value) => FieldValidators.validateArabicName(value, 'اسم الأب'),
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.grandfatherNameController,
              label: 'اسم الجد',
              prefixIcon: Icons.person_outline_rounded,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.lastNameController,
              label: 'اللقب',
              prefixIcon: Icons.family_restroom_rounded,
              isRequired: true,
              validator: (value) => FieldValidators.validateArabicName(value, 'اللقب'),
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.motherNameController,
              label: 'اسم الأم',
              prefixIcon: Icons.face_rounded,
            ),
          ],
        ),
        AnimatedSectionCard(
          title: 'معلومات شخصية',
          icon: Icons.info_rounded,
          isComplete: isPersonalInfoComplete,
          children: [
            V2CustomTextField(
              controller: widget.nationalIdController,
              label: 'الرقم الوطني',
              prefixIcon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              maxLength: 9,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              validator: FieldValidators.validateNationalId,
            ),

            if (!canUseCivilRegistry) const CivilRegistryRequiredBanner(),

            // 🆕 Civil Registry Status Indicator
            if (canUseCivilRegistry && civilRegistryState.status != CivilRegistryStatus.initial)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: CivilRegistryStatusIndicator(
                  state: civilRegistryState,
                  onRetry: () {
                    final nationalId = widget.nationalIdController.text;
                    if (nationalId.length == 9) {
                      ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);
                    }
                  },
                ),
              ),

            // 🆕 Preview Card (when data found)
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

            // 🆕 Autofill Button (when data found)
            if (canUseCivilRegistry && civilRegistryState.isSuccess && civilRegistryState.person != null)
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

            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.birthDateController,
              label: 'تاريخ الميلاد',
              prefixIcon: Icons.calendar_today_rounded,
              readOnly: true,
              onTap: widget.onBirthDateTap,
              suffix: IconButton(
                icon: Icon(Icons.event_rounded, size: 20.sp),
                onPressed: widget.onBirthDateTap,
              ),
            ),
            SizedBox(height: 12.h),
            // 🏷️ الجنس - من نظام التصنيفات
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.gender,
              selectedCode: widget.selectedGender,
              onCodeChanged: widget.onGenderChanged,
              labelText: 'الجنس',
              isRequired: requiresGender,
              autoSyncOnEmpty: true,
            ),
            SizedBox(height: 12.h),
            // 🏷️ فئة المستفيد - من نظام التصنيفات
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.category,
              selectedCode: widget.selectedCategory,
              onCodeChanged: widget.onCategoryChanged,
              labelText: 'فئة المستفيد',
              isRequired: requiresCategory,
              autoSyncOnEmpty: true,
            ),
            SizedBox(height: 12.h),
            // 🏷️ صلة القرابة - من نظام التصنيفات
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.relationship,
              selectedCode: widget.selectedRelationship,
              onCodeChanged: widget.onRelationshipChanged,
              labelText: 'صلة القرابة',
              prefixIcon: Icons.connect_without_contact_rounded,
              autoSyncOnEmpty: true,
            ),
            SizedBox(height: 12.h),
            // 🏷️ القسم - من نظام التصنيفات
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.section,
              selectedCode: widget.selectedSection,
              onCodeChanged: widget.onSectionChanged,
              labelText: 'القسم',
              prefixIcon: Icons.business_center_rounded,
              autoSyncOnEmpty: true,
            ),
            SizedBox(height: 12.h),
            // 🆕 المستخدم المدخل للبيانات (Created By User)
            if (widget.formControllers != null)
              V2CustomTextField(
                controller: widget.formControllers!.createdByUserController,
                label: 'المستخدم المدخل للبيانات',
                prefixIcon: Icons.person_pin_rounded,
              ),

            // 🧠 Smart Category Suggestion
            if (widget.formControllers != null && !_dismissedSuggestion)
              Builder(
                builder: (context) {
                  final suggestion = CategorySuggester.suggestCategory(
                    widget.formControllers!,
                  );

                  if (suggestion == null || widget.selectedCategory != null) {
                    return const SizedBox.shrink();
                  }

                  final reason = CategorySuggester.getSuggestionReason(
                    widget.formControllers!,
                    suggestion,
                  );

                  return Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: SmartSuggestionsCard(
                      suggestion: 'الفئة المقترحة: $suggestion',
                      description: reason,
                      icon: Icons.lightbulb_outline_rounded,
                      onApply: () {
                        HapticFeedback.lightImpact();
                        final categoryValue = _resolveSuggestedCategoryCode(
                          suggestion,
                        );

                        if (categoryValue != null) {
                          widget.onCategoryChanged(categoryValue);
                          setState(() => _dismissedSuggestion = true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تعذر مطابقة الفئة المقترحة مع تصنيفات السيرفر الحالية',
                              ),
                            ),
                          );
                        }
                      },
                      onDismiss: () {
                        setState(() => _dismissedSuggestion = true);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
