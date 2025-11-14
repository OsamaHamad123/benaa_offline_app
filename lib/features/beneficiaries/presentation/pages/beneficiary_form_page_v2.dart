import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/beneficiary_form_provider.dart';
import '../widgets/v2/v2_widgets.dart';
import '../../utils/attachments_manager.dart';
import '../../domain/entities/beneficiary.dart';

/// 🎨 Beneficiary Form Page V2 - Ultra Responsive & Performant
///
/// Features:
/// ✅ Full responsive with flutter_screenutil
/// ✅ Separated reusable widgets
/// ✅ Modern icons and design
/// ✅ High performance (const widgets, keys, memo)
/// ✅ Clean architecture
class BeneficiaryFormPageV2 extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const BeneficiaryFormPageV2({super.key, this.beneficiaryId});

  @override
  ConsumerState<BeneficiaryFormPageV2> createState() =>
      _BeneficiaryFormPageV2State();
}

class _BeneficiaryFormPageV2State extends ConsumerState<BeneficiaryFormPageV2>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Attachments
  final List<BeneficiaryAttachment> _attachments = [];

  // Text Controllers
  final _firstNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _grandfatherNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _numberOfDependentsController = TextEditingController();
  final _numberOfMalesController = TextEditingController();
  final _numberOfFemalesController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEducationLevel;
  String? _selectedEmploymentStatus;

  // Boolean switches
  bool _hasDisability = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() async {
    if (widget.beneficiaryId != null) {
      await ref
          .read(beneficiaryFormProvider.notifier)
          .loadBeneficiary(widget.beneficiaryId!);

      // Load data into controllers
      final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      if (beneficiary != null) {
        _populateControllers(beneficiary);
      }
    } else {
      ref.read(beneficiaryFormProvider.notifier).createNew();
    }
  }

  void _populateControllers(Beneficiary beneficiary) {
    // Parse full name
    _firstNameController.text = beneficiary.fatherName ?? '';
    _fatherNameController.text = beneficiary.fatherName ?? '';
    _grandfatherNameController.text = beneficiary.grandFatherName ?? '';
    _lastNameController.text = beneficiary.familyName ?? '';
    _motherNameController.text = beneficiary.motherName ?? '';

    _nationalIdController.text = beneficiary.nationalId;
    _birthDateController.text =
        beneficiary.birthDate?.toString().split(' ')[0] ?? '';
    _phoneController.text = beneficiary.phoneNumber ?? '';
    _altPhoneController.text = beneficiary.altPhoneNumber ?? '';
    _addressController.text = beneficiary.address ?? '';
    _neighborhoodController.text = beneficiary.district ?? '';
    _cityController.text = beneficiary.governorate ?? '';
    _numberOfDependentsController.text =
        beneficiary.familySize?.toString() ?? '';
    _numberOfMalesController.text = beneficiary.numberOfMales?.toString() ?? '';
    _numberOfFemalesController.text =
        beneficiary.numberOfFemales?.toString() ?? '';
    _notesController.text = beneficiary.notes ?? '';

    setState(() {
      _selectedGender = beneficiary.gender.name;
      _selectedMaritalStatus = beneficiary.maritalStatus?.name;
      _selectedEducationLevel = beneficiary.educationLevel?.name;
      _selectedEmploymentStatus = beneficiary.employmentStatus?.name;
      _hasDisability = beneficiary.hasDisability;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _grandfatherNameController.dispose();
    _lastNameController.dispose();
    _motherNameController.dispose();
    _nationalIdController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _numberOfDependentsController.dispose();
    _numberOfMalesController.dispose();
    _numberOfFemalesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إكمال الحقول المطلوبة'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    // Build full name
    final fullName = [
      _firstNameController.text.trim(),
      _fatherNameController.text.trim(),
      _grandfatherNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // Parse gender
    final gender = _selectedGender == 'ذكر' ? Gender.male : Gender.female;

    // Create/Update beneficiary
    final now = DateTime.now();
    final beneficiary = Beneficiary(
      id: widget.beneficiaryId ?? '',
      fullName: fullName,
      nationalId: _nationalIdController.text.trim(),
      gender: gender,
      category: BeneficiaryCategory.poor, // Default
      birthDate: _birthDateController.text.isNotEmpty
          ? DateTime.tryParse(_birthDateController.text)
          : null,
      motherName: _motherNameController.text.trim().isEmpty
          ? null
          : _motherNameController.text.trim(),
      fatherName: _fatherNameController.text.trim().isEmpty
          ? null
          : _fatherNameController.text.trim(),
      grandFatherName: _grandfatherNameController.text.trim().isEmpty
          ? null
          : _grandfatherNameController.text.trim(),
      familyName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      altPhoneNumber: _altPhoneController.text.trim().isEmpty
          ? null
          : _altPhoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      district: _neighborhoodController.text.trim().isEmpty
          ? null
          : _neighborhoodController.text.trim(),
      governorate: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      maritalStatus: _selectedMaritalStatus != null
          ? MaritalStatus.values.firstWhere(
              (e) => e.name == _selectedMaritalStatus,
              orElse: () => MaritalStatus.single,
            )
          : null,
      educationLevel: _selectedEducationLevel != null
          ? EducationLevel.values.firstWhere(
              (e) => e.name == _selectedEducationLevel,
              orElse: () => EducationLevel.none,
            )
          : null,
      employmentStatus: _selectedEmploymentStatus != null
          ? EmploymentStatus.values.firstWhere(
              (e) => e.name == _selectedEmploymentStatus,
              orElse: () => EmploymentStatus.unemployed,
            )
          : null,
      hasDisability: _hasDisability,
      familySize: _numberOfDependentsController.text.trim().isEmpty
          ? null
          : int.tryParse(_numberOfDependentsController.text.trim()),
      numberOfMales: _numberOfMalesController.text.trim().isEmpty
          ? null
          : int.tryParse(_numberOfMalesController.text.trim()),
      numberOfFemales: _numberOfFemalesController.text.trim().isEmpty
          ? null
          : int.tryParse(_numberOfFemalesController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.beneficiaryId != null
          ? (ref.read(beneficiaryFormProvider).beneficiary?.createdAt ?? now)
          : now,
      updatedAt: now,
      healthStatus: HealthStatus.good,
    );

    // Update provider with new beneficiary
    ref.read(beneficiaryFormProvider.notifier).updateField((_) => beneficiary);

    final success = await ref.read(beneficiaryFormProvider.notifier).save();

    if (success && mounted) {
      // Save attachments if any
      // TODO: Implement attachment saving

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              const Text('تم الحفظ بنجاح'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      context.pop(true);
    }
  }

  void _handleCancel() {
    final hasChanges = ref.read(beneficiaryFormProvider).hasUnsavedChanges;

    if (hasChanges) {
      showDialog(
        context: context,
        builder: (context) => V2ConfirmDialog(
          title: 'تحذير',
          message: 'لديك تغييرات غير محفوظة. هل تريد المتابعة؟',
          confirmText: 'متابعة',
          cancelText: 'إلغاء',
          isDangerous: true,
          onConfirm: () => context.pop(),
        ),
      );
    } else {
      context.pop();
    }
  }

  Future<void> _handleDelete() async {
    final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
    if (beneficiary == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => V2ConfirmDialog(
        title: 'حذف مستفيد',
        message: 'هل أنت متأكد من حذف "${beneficiary.fullName}"؟',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        isDangerous: true,
        icon: Icons.delete_forever_rounded,
        onConfirm: () {},
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement delete
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final state = ref.watch(beneficiaryFormProvider);
    final notifier = ref.read(beneficiaryFormProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: V2BeneficiaryAppBar(
        title: widget.beneficiaryId == null ? 'إضافة مستفيد' : 'تعديل مستفيد',
        canSave: !state.isSaving,
        isSaving: state.isSaving,
        onSave: _handleSave,
        onDelete: widget.beneficiaryId != null ? _handleDelete : null,
      ),
      body: state.isLoading
          ? const V2LoadingIndicator(message: 'جاري التحميل...')
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Error Banner
                  if (state.errorMessage != null)
                    V2ErrorBanner(
                      message: state.errorMessage!,
                      onDismiss: () => notifier.clearError(),
                    ),

                  // Tab Bar
                  Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(
                          icon: Icon(Icons.person_rounded, size: 20.sp),
                          text: 'أساسي',
                        ),
                        Tab(
                          icon: Icon(
                            Icons.family_restroom_rounded,
                            size: 20.sp,
                          ),
                          text: 'العائلة',
                        ),
                        Tab(
                          icon: Icon(Icons.contact_phone_rounded, size: 20.sp),
                          text: 'التواصل',
                        ),
                        Tab(
                          icon: Icon(
                            Icons.dashboard_customize_rounded,
                            size: 20.sp,
                          ),
                          text: 'إضافي',
                        ),
                        Tab(
                          icon: Icon(Icons.sticky_note_2_rounded, size: 20.sp),
                          text: 'ملاحظات',
                        ),
                        Tab(
                          icon: Icon(Icons.attach_file_rounded, size: 20.sp),
                          text: 'مرفقات',
                        ),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        V2BasicInfoTab(
                          firstNameController: _firstNameController,
                          fatherNameController: _fatherNameController,
                          grandfatherNameController: _grandfatherNameController,
                          lastNameController: _lastNameController,
                          motherNameController: _motherNameController,
                          nationalIdController: _nationalIdController,
                          birthDateController: _birthDateController,
                          selectedGender: _selectedGender,
                          onGenderChanged: (value) =>
                              setState(() => _selectedGender = value),
                          onBirthDateTap: () => _selectDate(context),
                        ),
                        V2FamilyInfoTab(
                          selectedMaritalStatus: _selectedMaritalStatus,
                          onMaritalStatusChanged: (value) =>
                              setState(() => _selectedMaritalStatus = value),
                          numberOfDependentsController:
                              _numberOfDependentsController,
                          numberOfMalesController: _numberOfMalesController,
                          numberOfFemalesController: _numberOfFemalesController,
                        ),
                        V2ContactInfoTab(
                          phoneController: _phoneController,
                          altPhoneController: _altPhoneController,
                          addressController: _addressController,
                          neighborhoodController: _neighborhoodController,
                          cityController: _cityController,
                        ),
                        V2AdditionalInfoTab(
                          selectedEducationLevel: _selectedEducationLevel,
                          onEducationLevelChanged: (value) =>
                              setState(() => _selectedEducationLevel = value),
                          selectedEmploymentStatus: _selectedEmploymentStatus,
                          onEmploymentStatusChanged: (value) =>
                              setState(() => _selectedEmploymentStatus = value),
                          hasDisability: _hasDisability,
                          onDisabilityChanged: (value) =>
                              setState(() => _hasDisability = value),
                        ),
                        V2NotesTab(notesController: _notesController),
                        V2AttachmentsTab(
                          beneficiaryId: widget.beneficiaryId,
                          initialAttachments: _attachments,
                          onAttachmentsChanged: (attachments) {
                            setState(() {
                              _attachments.clear();
                              _attachments.addAll(attachments);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: V2FormActions(
        canSave: !state.isSaving,
        isSaving: state.isSaving,
        onSave: _handleSave,
        onCancel: _handleCancel,
        onDelete: widget.beneficiaryId != null ? _handleDelete : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
