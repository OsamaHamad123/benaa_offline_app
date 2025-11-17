import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../components/v2_custom_text_field.dart';
import '../components/v2_dropdown_field.dart';
import '../components/v2_section_card.dart';
import '../../../providers/beneficiary_dependencies.dart';
import '../../../providers/civil_registry_provider.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../civil_registry_status_indicator.dart';
import '../../autofill_button.dart';
import '../../civil_registry_preview_card.dart';

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
  final BeneficiaryFormControllers? formControllers; // For autofill

  const V2BasicInfoTab({
    super.key,
    required this.firstNameController,
    required this.fatherNameController,
    required this.grandfatherNameController,
    required this.lastNameController,
    required this.motherNameController,
    required this.nationalIdController,
    required this.birthDateController,
    this.selectedGender,
    required this.onGenderChanged,
    required this.onBirthDateTap,
    this.firstFieldFocusNode,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.formControllers,
  });

  @override
  ConsumerState<V2BasicInfoTab> createState() => _V2BasicInfoTabState();
}

class _V2BasicInfoTabState extends ConsumerState<V2BasicInfoTab> {
  Timer? _debounceTimer;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    widget.nationalIdController.addListener(_onNationalIdChanged);
  }

  @override
  void dispose() {
    widget.nationalIdController.removeListener(_onNationalIdChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.nationalIdController.text;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Reset preview if ID is incomplete
    if (nationalId.length < 9) {
      setState(() => _showPreview = false);
      ref.read(civilRegistryProvider.notifier).reset();
      return;
    }

    // Debounce for 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (nationalId.length == 9) {
        ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);
      }
    });
  }

  void _handleAutofill() {
    if (widget.formControllers == null) return;

    final result = ref
        .read(civilRegistryProvider.notifier)
        .autofillForm(widget.formControllers);

    if (result != null) {
      HapticFeedback.lightImpact();
      setState(() => _showPreview = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(child: Text(result.successMessage)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final civilRegistryState = ref.watch(civilRegistryProvider);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'الاسم الكامل',
          icon: Icons.person_rounded,
          children: [
            V2CustomTextField(
              controller: widget.firstNameController,
              label: 'الاسم الأول',
              prefixIcon: Icons.badge_rounded,
              isRequired: true,
              focusNode: widget.firstFieldFocusNode,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.fatherNameController,
              label: 'اسم الأب',
              prefixIcon: Icons.person_outline_rounded,
              isRequired: true,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
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
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: widget.motherNameController,
              label: 'اسم الأم',
              prefixIcon: Icons.face_rounded,
            ),
          ],
        ),
        V2SectionCard(
          title: 'معلومات شخصية',
          icon: Icons.info_rounded,
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
              validator: (value) {
                if (value?.isEmpty ?? true) return 'الحقل مطلوب';
                if (value!.length != 9) return 'يجب أن يكون 9 أرقام';
                return null;
              },
            ),

            // 🆕 Civil Registry Status Indicator
            if (civilRegistryState.status != CivilRegistryStatus.initial)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: CivilRegistryStatusIndicator(
                  state: civilRegistryState,
                  onRetry: () {
                    final nationalId = widget.nationalIdController.text;
                    if (nationalId.length == 9) {
                      ref
                          .read(civilRegistryProvider.notifier)
                          .fetchByNationalId(nationalId);
                    }
                  },
                ),
              ),

            // 🆕 Preview Card (when data found)
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

            // 🆕 Autofill Button (when data found)
            if (civilRegistryState.isSuccess &&
                civilRegistryState.person != null)
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
                        _showPreview ? Icons.visibility_off : Icons.visibility,
                        size: 24.sp,
                      ),
                      tooltip: _showPreview ? 'إخفاء المعاينة' : 'عرض المعاينة',
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
            V2DropdownField<String>(
              value: widget.selectedGender,
              label: 'الجنس',
              prefixIcon: Icons.wc_rounded,
              isRequired: true,
              onChanged: widget.onGenderChanged,
              validator: (value) => value == null ? 'الحقل مطلوب' : null,
              items: const [
                DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
              ],
            ),
            SizedBox(height: 12.h),
            V2DropdownField<String>(
              value: widget.selectedCategory,
              label: 'فئة المستفيد',
              prefixIcon: Icons.category_rounded,
              isRequired: true,
              onChanged: widget.onCategoryChanged,
              validator: (value) => value == null ? 'الحقل مطلوب' : null,
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
      ],
    );
  }
}
