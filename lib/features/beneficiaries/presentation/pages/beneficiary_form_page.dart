import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/beneficiary_form_provider.dart';
import '../widgets/widgets.dart';

/// 🆕 Beneficiary Form Page - Clean Architecture
///
/// Refactored from 1729 lines to ~250 lines
/// Uses Clean Architecture with separated widgets
class BeneficiaryFormPage extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const BeneficiaryFormPage({super.key, this.beneficiaryId});

  @override
  ConsumerState<BeneficiaryFormPage> createState() =>
      _BeneficiaryFormPageState();
}

class _BeneficiaryFormPageState extends ConsumerState<BeneficiaryFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNoController = TextEditingController();
  final _associationNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _grandFatherNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _altPhoneNumberController = TextEditingController();
  final _governorateController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _addressBeforeDisplacementController = TextEditingController();
  final _familySizeController = TextEditingController();
  final _numMalesController = TextEditingController();
  final _numFemalesController = TextEditingController();
  final _numChildrenController = TextEditingController();
  final _numElderlyController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _supportSourceController = TextEditingController();
  final _supportAmountController = TextEditingController();
  final _assetsDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (widget.beneficiaryId != null) {
      // Load existing beneficiary
      ref
          .read(beneficiaryFormProvider.notifier)
          .loadBeneficiary(widget.beneficiaryId!);
    } else {
      // Create new beneficiary
      ref.read(beneficiaryFormProvider.notifier).createNew();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _fileNoController.dispose();
    _associationNameController.dispose();
    _birthDateController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _grandFatherNameController.dispose();
    _familyNameController.dispose();
    _phoneNumberController.dispose();
    _altPhoneNumberController.dispose();
    _governorateController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _currentAddressController.dispose();
    _addressBeforeDisplacementController.dispose();
    _familySizeController.dispose();
    _numMalesController.dispose();
    _numFemalesController.dispose();
    _numChildrenController.dispose();
    _numElderlyController.dispose();
    _monthlyIncomeController.dispose();
    _supportSourceController.dispose();
    _supportAmountController.dispose();
    _assetsDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncControllersToState() {
    final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
    if (beneficiary == null) return;

    _fullNameController.text = beneficiary.fullName;
    _nationalIdController.text = beneficiary.nationalId;
    _fileNoController.text = beneficiary.fileNo ?? '';
    _associationNameController.text = beneficiary.associationName ?? '';
    _birthDateController.text =
        beneficiary.birthDate?.toString().split(' ')[0] ?? '';
    _motherNameController.text = beneficiary.motherName ?? '';
    _fatherNameController.text = beneficiary.fatherName ?? '';
    _grandFatherNameController.text = beneficiary.grandFatherName ?? '';
    _familyNameController.text = beneficiary.familyName ?? '';
    _phoneNumberController.text = beneficiary.phoneNumber ?? '';
    _altPhoneNumberController.text = beneficiary.altPhoneNumber ?? '';
    _governorateController.text = beneficiary.governorate ?? '';
    _districtController.text = beneficiary.district ?? '';
    _addressController.text = beneficiary.address ?? '';
    _currentAddressController.text = beneficiary.currentAddress ?? '';
    _addressBeforeDisplacementController.text =
        beneficiary.addressBeforeDisplacement ?? '';
    _familySizeController.text = beneficiary.familySize?.toString() ?? '';
    _numMalesController.text = beneficiary.numberOfMales?.toString() ?? '';
    _numFemalesController.text = beneficiary.numberOfFemales?.toString() ?? '';
    _numChildrenController.text =
        beneficiary.chronicDiseasesCount?.toString() ?? '';
    _numElderlyController.text =
        beneficiary.specialNeedsCount?.toString() ?? '';
    _notesController.text = beneficiary.notes ?? '';
  }

  void _updateBeneficiaryFromControllers() {
    ref
        .read(beneficiaryFormProvider.notifier)
        .updateField(
          (b) => b.copyWith(
            fullName: _fullNameController.text,
            nationalId: _nationalIdController.text,
            fileNo: _fileNoController.text.isEmpty
                ? null
                : _fileNoController.text,
            associationName: _associationNameController.text.isEmpty
                ? null
                : _associationNameController.text,
            motherName: _motherNameController.text.isEmpty
                ? null
                : _motherNameController.text,
            fatherName: _fatherNameController.text.isEmpty
                ? null
                : _fatherNameController.text,
            grandFatherName: _grandFatherNameController.text.isEmpty
                ? null
                : _grandFatherNameController.text,
            familyName: _familyNameController.text.isEmpty
                ? null
                : _familyNameController.text,
            phoneNumber: _phoneNumberController.text.isEmpty
                ? null
                : _phoneNumberController.text,
            altPhoneNumber: _altPhoneNumberController.text.isEmpty
                ? null
                : _altPhoneNumberController.text,
            governorate: _governorateController.text.isEmpty
                ? null
                : _governorateController.text,
            district: _districtController.text.isEmpty
                ? null
                : _districtController.text,
            address: _addressController.text.isEmpty
                ? null
                : _addressController.text,
            currentAddress: _currentAddressController.text.isEmpty
                ? null
                : _currentAddressController.text,
            addressBeforeDisplacement:
                _addressBeforeDisplacementController.text.isEmpty
                ? null
                : _addressBeforeDisplacementController.text,
            familySize: int.tryParse(_familySizeController.text),
            numberOfMales: int.tryParse(_numMalesController.text),
            numberOfFemales: int.tryParse(_numFemalesController.text),
            chronicDiseasesCount: int.tryParse(_numChildrenController.text),
            specialNeedsCount: int.tryParse(_numElderlyController.text),
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ),
        );
  }

  Future<void> _handleSave() async {
    _updateBeneficiaryFromControllers();
    final success = await ref.read(beneficiaryFormProvider.notifier).save();

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
      context.pop();
    }
  }

  void _handleCancel() {
    final hasChanges = ref.read(beneficiaryFormProvider).hasUnsavedChanges;

    if (hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تحذير'),
          content: const Text('لديك تغييرات غير محفوظة. هل تريد المتابعة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('متابعة'),
            ),
          ],
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
      builder: (context) => DeleteConfirmationDialog(
        beneficiaryName: beneficiary.fullName,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement delete
      context.pop();
    }
  }

  void _handleQRScan() {
    showDialog(
      context: context,
      builder: (context) => QRScannerDialog(
        onScanned: (code) {
          _nationalIdController.text = code;
          _updateBeneficiaryFromControllers();
        },
      ),
    );
  }

  Future<void> _handleDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _birthDateController.text = date.toString().split(' ')[0];
      ref
          .read(beneficiaryFormProvider.notifier)
          .updateField((b) => b.copyWith(birthDate: date));
    }
  }

  void _handleCivilRegistryLoad() {
    showDialog(
      context: context,
      builder: (context) => CivilDataLoaderDialog(
        onLoad: (nationalId) {
          ref
              .read(beneficiaryFormProvider.notifier)
              .loadFromCivilRegistry(nationalId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficiaryFormProvider);
    final beneficiary = state.beneficiary;

    // Sync controllers when beneficiary changes
    if (beneficiary != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncControllersToState();
      });
    }

    return Scaffold(
      appBar: BeneficiaryAppBar(
        title: widget.beneficiaryId == null ? 'إضافة مستفيد' : 'تعديل مستفيد',
        canSave: state.canSave,
        isSaving: state.isSaving,
        onSave: _handleSave,
        onDelete: widget.beneficiaryId != null ? _handleDelete : null,
        progressWidget: AutoSaveIndicator(
          isSaving: state.isSaving,
          lastSaved: state.lastSaved,
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress and Civil Registry Loader
                if (beneficiary != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FormProgressIndicator(
                            beneficiary: beneficiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CivilDataLoaderButton(
                          onPressed: _handleCivilRegistryLoad,
                          isLoading: state.isLoading,
                        ),
                      ],
                    ),
                  ),
                ],

                // Tabs
                BeneficiaryTabNavigation(
                  controller: _tabController,
                  tabs: const [
                    TabData(label: 'أساسي', icon: Icons.person),
                    TabData(label: 'العائلة', icon: Icons.family_restroom),
                    TabData(label: 'التواصل', icon: Icons.phone),
                    TabData(label: 'إضافي', icon: Icons.more_horiz),
                    TabData(label: 'ملاحظات', icon: Icons.note),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: beneficiary == null
                      ? const Center(child: Text('جاري التحميل...'))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            BasicInfoTab(
                              fullNameController: _fullNameController,
                              nationalIdController: _nationalIdController,
                              fileNoController: _fileNoController,
                              associationNameController:
                                  _associationNameController,
                              birthDateController: _birthDateController,
                              gender: beneficiary.gender,
                              category: beneficiary.category,
                              birthDate: beneficiary.birthDate,
                              onGenderChanged: (gender) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(gender: gender),
                                    );
                              },
                              onCategoryChanged: (category) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(category: category),
                                    );
                              },
                              onScanQR: _handleQRScan,
                              onSelectDate: _handleDatePicker,
                            ),
                            FamilyInfoTab(
                              motherNameController: _motherNameController,
                              fatherNameController: _fatherNameController,
                              grandFatherNameController:
                                  _grandFatherNameController,
                              familyNameController: _familyNameController,
                              familySizeController: _familySizeController,
                              numMalesController: _numMalesController,
                              numFemalesController: _numFemalesController,
                              numChildrenController: _numChildrenController,
                              numElderlyController: _numElderlyController,
                              hasPwd: beneficiary.hasDisability,
                              hasChronicallyIll:
                                  (beneficiary.chronicDiseasesCount ?? 0) > 0,
                              onHasPwdChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(hasDisability: value),
                                    );
                              },
                              onHasChronicallyIllChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(
                                        chronicDiseasesCount: value ? 1 : 0,
                                      ),
                                    );
                              },
                            ),
                            ContactInfoTab(
                              phoneNumberController: _phoneNumberController,
                              altPhoneNumberController:
                                  _altPhoneNumberController,
                              governorateController: _governorateController,
                              districtController: _districtController,
                              addressController: _addressController,
                              currentAddressController:
                                  _currentAddressController,
                              addressBeforeDisplacementController:
                                  _addressBeforeDisplacementController,
                            ),
                            AdditionalInfoTab(
                              maritalStatus: beneficiary.maritalStatus,
                              educationLevel: beneficiary.educationLevel,
                              healthStatus: beneficiary.healthStatus,
                              displacementStatus:
                                  beneficiary.displacementStatus,
                              employmentStatus: beneficiary.employmentStatus,
                              housingStatus: beneficiary.housingStatus,
                              housingType: beneficiary.housingType,
                              monthlyIncomeController: _monthlyIncomeController,
                              hasFinancialSupport: false,
                              supportSourceController: _supportSourceController,
                              supportAmountController: _supportAmountController,
                              hasAssets: false,
                              assetsDescriptionController:
                                  _assetsDescriptionController,
                              onMaritalStatusChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(maritalStatus: value),
                                    );
                              },
                              onEducationLevelChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(educationLevel: value),
                                    );
                              },
                              onHealthStatusChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(healthStatus: value),
                                    );
                              },
                              onDisplacementStatusChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) =>
                                          b.copyWith(displacementStatus: value),
                                    );
                              },
                              onEmploymentStatusChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) =>
                                          b.copyWith(employmentStatus: value),
                                    );
                              },
                              onHousingStatusChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(housingStatus: value),
                                    );
                              },
                              onHousingTypeChanged: (value) {
                                ref
                                    .read(beneficiaryFormProvider.notifier)
                                    .updateField(
                                      (b) => b.copyWith(housingType: value),
                                    );
                              },
                              onHasFinancialSupportChanged: (value) {
                                // TODO: Add to entity if needed
                              },
                              onHasAssetsChanged: (value) {
                                // TODO: Add to entity if needed
                              },
                            ),
                            NotesTab(notesController: _notesController),
                          ],
                        ),
                ),

                // Error message
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            ref
                                .read(beneficiaryFormProvider.notifier)
                                .clearError();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: FormActions(
        canSave: state.canSave,
        isSaving: state.isSaving,
        isNew: state.isNew,
        onSave: _handleSave,
        onCancel: _handleCancel,
        onDelete: widget.beneficiaryId != null ? _handleDelete : null,
      ),
    );
  }
}
