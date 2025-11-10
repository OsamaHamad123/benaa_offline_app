import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/db/drift_database.dart';
import 'widgets/form_field_builders.dart';
import 'utils/auto_save_manager.dart';
import 'utils/tab_progress_calculator.dart';
import 'utils/form_validators.dart';

/// صفحة إضافة/تعديل مستفيد - تصميم فخم وشامل
/// ✨ Material Design 3 with Gradient Headers
/// 🎨 Beautiful UI matching app theme
/// 📱 Fully Responsive
/// ⚡ Zero lag performance
class AddBeneficiaryPageEnhanced extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const AddBeneficiaryPageEnhanced({super.key, this.beneficiaryId});

  @override
  ConsumerState<AddBeneficiaryPageEnhanced> createState() =>
      _AddBeneficiaryPageEnhancedState();
}

class _AddBeneficiaryPageEnhancedState
    extends ConsumerState<AddBeneficiaryPageEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _autoSaveManager = AutoSaveManager();

  // ==================== Controllers ====================
  // المعلومات الأساسية
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNoController = TextEditingController();
  final _associationNameController = TextEditingController();
  final _birthDateController = TextEditingController();

  // معلومات العائلة
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _grandFatherNameController = TextEditingController();
  final _familyNameController = TextEditingController();

  // معلومات الاتصال
  final _phoneNumberController = TextEditingController();
  final _altPhoneNumberController = TextEditingController();
  final _governorateController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _addressBeforeDisplacementController = TextEditingController();

  // معلومات الأسرة
  final _familySizeController = TextEditingController();
  final _numberOfMalesController = TextEditingController();
  final _numberOfFemalesController = TextEditingController();
  final _chronicDiseasesCountController = TextEditingController();
  final _specialNeedsCountController = TextEditingController();

  // ملاحظات
  final _notesController = TextEditingController();

  // ==================== Local State ====================
  String _gender = 'male';
  String _category = 'orphan';
  String _healthStatus = 'good';
  String? _maritalStatus;
  String? _educationLevel;
  bool _hasDisability = false;
  int? _displacementStatus;
  int? _employmentStatus;
  int? _housingStatus;
  int? _housingType;
  int? _requestStatus;
  DateTime? _birthDate;

  bool _isLoading = false;
  int _currentTab = 0;
  bool _hasUnsavedChanges = false;
  DateTime? _lastAutoSave;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadBeneficiary();
    _startAutoSave();
    _setupTextListeners();
  }

  /// إضافة listeners للحقول لتحديث Progress
  void _setupTextListeners() {
    // تحديث UI عند تغيير أي حقل
    final allControllers = [
      _fullNameController,
      _nationalIdController,
      _fileNoController,
      _associationNameController,
      _birthDateController,
      _motherNameController,
      _fatherNameController,
      _grandFatherNameController,
      _familyNameController,
      _phoneNumberController,
      _altPhoneNumberController,
      _governorateController,
      _districtController,
      _addressController,
      _currentAddressController,
      _addressBeforeDisplacementController,
      _familySizeController,
      _numberOfMalesController,
      _numberOfFemalesController,
      _chronicDiseasesCountController,
      _specialNeedsCountController,
      _notesController,
    ];

    for (final controller in allControllers) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  /// بدء الحفظ التلقائي
  void _startAutoSave() {
    final draftId = widget.beneficiaryId ?? 'new';
    _autoSaveManager.startAutoSave(draftId, _collectFormData);
  }

  /// جمع بيانات النموذج للحفظ التلقائي
  Map<String, dynamic> _collectFormData() {
    _hasUnsavedChanges = true;
    _lastAutoSave = DateTime.now();

    return {
      'fullName': _fullNameController.text,
      'nationalId': _nationalIdController.text,
      'fileNo': _fileNoController.text,
      'associationName': _associationNameController.text,
      'birthDate': _birthDateController.text,
      'motherName': _motherNameController.text,
      'fatherName': _fatherNameController.text,
      'grandFatherName': _grandFatherNameController.text,
      'familyName': _familyNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'altPhoneNumber': _altPhoneNumberController.text,
      'governorate': _governorateController.text,
      'district': _districtController.text,
      'address': _addressController.text,
      'currentAddress': _currentAddressController.text,
      'addressBeforeDisplacement': _addressBeforeDisplacementController.text,
      'familySize': _familySizeController.text,
      'numberOfMales': _numberOfMalesController.text,
      'numberOfFemales': _numberOfFemalesController.text,
      'chronicDiseasesCount': _chronicDiseasesCountController.text,
      'specialNeedsCount': _specialNeedsCountController.text,
      'notes': _notesController.text,
      'gender': _gender,
      'category': _category,
      'healthStatus': _healthStatus,
      'maritalStatus': _maritalStatus,
      'educationLevel': _educationLevel,
      'hasDisability': _hasDisability,
      'displacementStatus': _displacementStatus,
      'employmentStatus': _employmentStatus,
      'housingStatus': _housingStatus,
      'housingType': _housingType,
      'requestStatus': _requestStatus,
    };
  }

  /// حساب تقدم كل تاب
  double _calculateTabProgress(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return TabProgressCalculator.calculateBasicInfoProgress(
          fullName: _fullNameController.text,
          nationalId: _nationalIdController.text,
          fileNo: _fileNoController.text,
          governorate: _governorateController.text,
          gender: _gender,
          category: _category,
          associationName: _associationNameController.text,
          birthDate: _birthDateController.text,
          maritalStatus: _maritalStatus,
          educationLevel: _educationLevel,
        );
      case 1:
        return TabProgressCalculator.calculateFamilyProgress(
          motherName: _motherNameController.text,
          fatherName: _fatherNameController.text,
          grandFatherName: _grandFatherNameController.text,
          familyName: _familyNameController.text,
          familySize: _familySizeController.text,
          numberOfMales: _numberOfMalesController.text,
          numberOfFemales: _numberOfFemalesController.text,
        );
      case 2:
        return TabProgressCalculator.calculateLocationProgress(
          phoneNumber: _phoneNumberController.text,
          altPhoneNumber: _altPhoneNumberController.text,
          district: _districtController.text,
          address: _addressController.text,
          currentAddress: _currentAddressController.text,
          addressBeforeDisplacement: _addressBeforeDisplacementController.text,
          displacementStatus: _displacementStatus,
          employmentStatus: _employmentStatus,
          housingStatus: _housingStatus,
          housingType: _housingType,
        );
      case 3:
        return TabProgressCalculator.calculateHealthProgress(
          healthStatus: _healthStatus,
          hasDisability: _hasDisability,
          chronicDiseasesCount: _chronicDiseasesCountController.text,
          specialNeedsCount: _specialNeedsCountController.text,
          requestStatus: _requestStatus,
          notes: _notesController.text,
        );
      default:
        return 0.0;
    }
  }

  Future<void> _loadBeneficiary() async {
    if (widget.beneficiaryId == null) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final beneficiary = await db.getBeneficiaryById(widget.beneficiaryId!);

      if (beneficiary != null && mounted) {
        // المعلومات الأساسية
        _fullNameController.text = beneficiary.fullName;
        _nationalIdController.text = beneficiary.nationalId;
        _fileNoController.text = beneficiary.fileNo;
        _associationNameController.text = beneficiary.associationName ?? '';
        if (beneficiary.birthDate != null) {
          _birthDate = beneficiary.birthDate;
          _birthDateController.text =
              '${beneficiary.birthDate!.year}-${beneficiary.birthDate!.month.toString().padLeft(2, '0')}-${beneficiary.birthDate!.day.toString().padLeft(2, '0')}';
        }

        // معلومات العائلة
        _motherNameController.text = beneficiary.motherName ?? '';
        _fatherNameController.text = beneficiary.fatherName ?? '';
        _grandFatherNameController.text = beneficiary.grandFatherName ?? '';
        _familyNameController.text = beneficiary.familyName ?? '';

        // معلومات الاتصال
        _phoneNumberController.text = beneficiary.phoneNumber ?? '';
        _altPhoneNumberController.text = beneficiary.altPhoneNumber ?? '';
        _governorateController.text = beneficiary.governorate;
        _districtController.text = beneficiary.district ?? '';
        _addressController.text = beneficiary.address ?? '';
        _currentAddressController.text = beneficiary.currentAddress ?? '';
        _addressBeforeDisplacementController.text =
            beneficiary.addressBeforeDisplacement ?? '';

        // معلومات الأسرة
        _familySizeController.text = beneficiary.familySize?.toString() ?? '';
        _numberOfMalesController.text =
            beneficiary.numberOfMales?.toString() ?? '';
        _numberOfFemalesController.text =
            beneficiary.numberOfFemales?.toString() ?? '';
        _chronicDiseasesCountController.text =
            beneficiary.chronicDiseasesCount?.toString() ?? '';
        _specialNeedsCountController.text =
            beneficiary.specialNeedsCount?.toString() ?? '';

        _notesController.text = beneficiary.notes;

        setState(() {
          _gender = beneficiary.gender;
          _category = beneficiary.category;
          _healthStatus = beneficiary.healthStatus ?? 'good';
          _maritalStatus = beneficiary.maritalStatus;
          _educationLevel = beneficiary.educationLevel;
          _hasDisability = beneficiary.hasDisability;
          _displacementStatus = beneficiary.displacementStatus;
          _employmentStatus = beneficiary.employmentStatus;
          _housingStatus = beneficiary.housingStatus;
          _housingType = beneficiary.housingType;
          _requestStatus = beneficiary.requestStatus;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('خطأ في تحميل البيانات: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _autoSaveManager.dispose();
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
    _numberOfMalesController.dispose();
    _numberOfFemalesController.dispose();
    _chronicDiseasesCountController.dispose();
    _specialNeedsCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validation
    if (_fullNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الاسم الكامل');
      _tabController.animateTo(0);
      return;
    }
    if (_nationalIdController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الرقم الوطني');
      _tabController.animateTo(0);
      return;
    }
    if (_fileNoController.text.trim().isEmpty) {
      _showError('الرجاء إدخال رقم الملف');
      _tabController.animateTo(0);
      return;
    }
    if (_governorateController.text.trim().isEmpty) {
      _showError('الرجاء اختيار المحافظة');
      _tabController.animateTo(2);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final isEdit = widget.beneficiaryId != null;
      final now = DateTime.now();

      if (isEdit) {
        // Update
        await db.updateBeneficiaryCompanion(
          widget.beneficiaryId!,
          BeneficiariesCompanion(
            fullName: drift.Value(_fullNameController.text.trim()),
            fullNameNorm: drift.Value(
              _fullNameController.text.trim().toLowerCase(),
            ),
            nationalId: drift.Value(_nationalIdController.text.trim()),
            fileNo: drift.Value(_fileNoController.text.trim()),
            governorate: drift.Value(_governorateController.text.trim()),
            district: drift.Value(_districtController.text.trim()),
            address: drift.Value(_addressController.text.trim()),
            currentAddress: drift.Value(_currentAddressController.text.trim()),
            addressBeforeDisplacement: drift.Value(
              _addressBeforeDisplacementController.text.trim(),
            ),
            phoneNumber: drift.Value(_phoneNumberController.text.trim()),
            altPhoneNumber: drift.Value(_altPhoneNumberController.text.trim()),
            motherName: drift.Value(_motherNameController.text.trim()),
            fatherName: drift.Value(_fatherNameController.text.trim()),
            grandFatherName: drift.Value(
              _grandFatherNameController.text.trim(),
            ),
            familyName: drift.Value(_familyNameController.text.trim()),
            familySize: drift.Value(int.tryParse(_familySizeController.text)),
            numberOfMales: drift.Value(
              int.tryParse(_numberOfMalesController.text),
            ),
            numberOfFemales: drift.Value(
              int.tryParse(_numberOfFemalesController.text),
            ),
            chronicDiseasesCount: drift.Value(
              int.tryParse(_chronicDiseasesCountController.text),
            ),
            specialNeedsCount: drift.Value(
              int.tryParse(_specialNeedsCountController.text),
            ),
            gender: drift.Value(_gender),
            category: drift.Value(_category),
            birthDate: drift.Value(_birthDate),
            maritalStatus: drift.Value(_maritalStatus),
            educationLevel: drift.Value(_educationLevel),
            healthStatus: drift.Value(_healthStatus),
            hasDisability: drift.Value(_hasDisability),
            displacementStatus: drift.Value(_displacementStatus),
            employmentStatus: drift.Value(_employmentStatus),
            housingStatus: drift.Value(_housingStatus),
            housingType: drift.Value(_housingType),
            requestStatus: drift.Value(_requestStatus),
            associationName: drift.Value(
              _associationNameController.text.trim(),
            ),
            notes: drift.Value(_notesController.text.trim()),
            updatedAt: drift.Value(now),
            syncState: const drift.Value('pending'),
          ),
        );
      } else {
        // Insert
        await db.insertBeneficiary(
          BeneficiariesCompanion.insert(
            id: const Uuid().v4(),
            fullName: _fullNameController.text.trim(),
            fullNameNorm: _fullNameController.text.trim().toLowerCase(),
            nationalId: _nationalIdController.text.trim(),
            fileNo: _fileNoController.text.trim(),
            governorate: _governorateController.text.trim(),
            gender: _gender,
            category: _category,
            district: drift.Value(_districtController.text.trim()),
            address: drift.Value(_addressController.text.trim()),
            currentAddress: drift.Value(_currentAddressController.text.trim()),
            addressBeforeDisplacement: drift.Value(
              _addressBeforeDisplacementController.text.trim(),
            ),
            phoneNumber: drift.Value(_phoneNumberController.text.trim()),
            altPhoneNumber: drift.Value(_altPhoneNumberController.text.trim()),
            motherName: drift.Value(_motherNameController.text.trim()),
            fatherName: drift.Value(_fatherNameController.text.trim()),
            grandFatherName: drift.Value(
              _grandFatherNameController.text.trim(),
            ),
            familyName: drift.Value(_familyNameController.text.trim()),
            familySize: drift.Value(int.tryParse(_familySizeController.text)),
            numberOfMales: drift.Value(
              int.tryParse(_numberOfMalesController.text),
            ),
            numberOfFemales: drift.Value(
              int.tryParse(_numberOfFemalesController.text),
            ),
            chronicDiseasesCount: drift.Value(
              int.tryParse(_chronicDiseasesCountController.text),
            ),
            specialNeedsCount: drift.Value(
              int.tryParse(_specialNeedsCountController.text),
            ),
            birthDate: drift.Value(_birthDate),
            maritalStatus: drift.Value(_maritalStatus),
            educationLevel: drift.Value(_educationLevel),
            healthStatus: drift.Value(_healthStatus),
            hasDisability: drift.Value(_hasDisability),
            displacementStatus: drift.Value(_displacementStatus),
            employmentStatus: drift.Value(_employmentStatus),
            housingStatus: drift.Value(_housingStatus),
            housingType: drift.Value(_housingType),
            requestStatus: drift.Value(_requestStatus),
            associationName: drift.Value(
              _associationNameController.text.trim(),
            ),
            notes: drift.Value(_notesController.text.trim()),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        // حذف المسودة بعد الحفظ الناجح
        final draftId = widget.beneficiaryId ?? 'new';
        await _autoSaveManager.deleteDraft(draftId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? '✓ تم تحديث البيانات بنجاح'
                  : '✓ تم إضافة المستفيد بنجاح',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('خطأ في الحفظ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (date != null) {
      setState(() {
        _birthDate = date;
        _birthDateController.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.beneficiaryId != null;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تنبيه'),
            content: const Text(
              'لديك تغييرات لم يتم حفظها. هل تريد المتابعة؟\n\n'
              'تم حفظ مسودة تلقائياً، يمكنك استعادتها لاحقاً.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('الخروج'),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'تعديل مستفيد' : 'إضافة مستفيد جديد',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (isEdit)
              IconButton(
                icon: const Icon(Icons.visibility_rounded),
                tooltip: 'عرض التفاصيل',
                onPressed: () =>
                    context.push('/beneficiaries/${widget.beneficiaryId}'),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.person, size: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('أساسي', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(0),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    icon: const Icon(Icons.family_restroom, size: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('عائلة', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(1),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    icon: const Icon(Icons.location_on, size: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('موقع', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(2),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    icon: const Icon(Icons.health_and_safety, size: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('صحة', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري التحميل...'),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicInfoTab(),
                        _buildFamilyTab(),
                        _buildLocationTab(),
                        _buildHealthTab(),
                      ],
                    ),
                  ),
                  _buildBottomBar(isEdit),
                ],
              ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    final rv = ResponsiveUtils.getValues(context);

    return SingleChildScrollView(
      padding: rv.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'البيانات الشخصية',
            icon: Icons.badge,
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: 'الاسم الكامل *',
                icon: Icons.person,
                hint: 'الاسم الثلاثي أو الرباعي',
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nationalIdController,
                      label: 'الرقم الوطني *',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _fileNoController,
                      label: 'رقم الملف *',
                      icon: Icons.folder,
                    ),
                  ),
                ],
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _birthDateController,
                label: 'تاريخ الميلاد',
                icon: Icons.cake,
                readOnly: true,
                onTap: _selectDate,
                suffix: IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: _selectDate,
                ),
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _gender,
                      label: 'الجنس *',
                      icon: Icons.wc,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('ذكر')),
                        DropdownMenuItem(value: 'female', child: Text('أنثى')),
                      ],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _category,
                      label: 'الفئة *',
                      icon: Icons.category,
                      items: const [
                        DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
                        DropdownMenuItem(value: 'widow', child: Text('أرملة')),
                        DropdownMenuItem(value: 'poor', child: Text('فقير')),
                        DropdownMenuItem(
                          value: 'disabled',
                          child: Text('معاق'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'معلومات إضافية',
            icon: Icons.info_outline,
            children: [
              _buildTextField(
                controller: _associationNameController,
                label: 'اسم الجمعية',
                icon: Icons.business,
              ),
              SizedBox(height: rv.spacing),
              _buildDropdown<String?>(
                value: _maritalStatus,
                label: 'الحالة الاجتماعية',
                icon: Icons.family_restroom,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 'single', child: Text('أعزب')),
                  DropdownMenuItem(value: 'married', child: Text('متزوج')),
                  DropdownMenuItem(value: 'divorced', child: Text('مطلق')),
                  DropdownMenuItem(value: 'widow', child: Text('أرمل')),
                ],
                onChanged: (v) => setState(() => _maritalStatus = v),
              ),
              SizedBox(height: rv.spacing),
              _buildDropdown<String?>(
                value: _educationLevel,
                label: 'المستوى التعليمي',
                icon: Icons.school,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 'illiterate', child: Text('أمي')),
                  DropdownMenuItem(value: 'primary', child: Text('ابتدائي')),
                  DropdownMenuItem(value: 'intermediate', child: Text('متوسط')),
                  DropdownMenuItem(value: 'secondary', child: Text('ثانوي')),
                  DropdownMenuItem(value: 'bachelor', child: Text('بكالوريوس')),
                  DropdownMenuItem(value: 'master', child: Text('ماجستير')),
                  DropdownMenuItem(value: 'phd', child: Text('دكتوراه')),
                ],
                onChanged: (v) => setState(() => _educationLevel = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    final rv = ResponsiveUtils.getValues(context);

    return SingleChildScrollView(
      padding: rv.padding,
      child: Column(
        children: [
          _buildSectionCard(
            title: 'أفراد العائلة',
            icon: Icons.people,
            children: [
              _buildTextField(
                controller: _motherNameController,
                label: 'اسم الأم',
                icon: Icons.person,
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _fatherNameController,
                label: 'اسم الأب',
                icon: Icons.person,
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _grandFatherNameController,
                      label: 'اسم الجد',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _familyNameController,
                      label: 'اسم العائلة',
                      icon: Icons.people_alt,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'تفاصيل الأسرة',
            icon: Icons.family_restroom,
            children: [
              _buildTextField(
                controller: _familySizeController,
                label: 'عدد أفراد الأسرة',
                icon: Icons.group,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _numberOfMalesController,
                      label: 'عدد الذكور',
                      icon: Icons.male,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _numberOfFemalesController,
                      label: 'عدد الإناث',
                      icon: Icons.female,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    final rv = ResponsiveUtils.getValues(context);

    return SingleChildScrollView(
      padding: rv.padding,
      child: Column(
        children: [
          _buildSectionCard(
            title: 'معلومات الاتصال',
            icon: Icons.contact_phone,
            children: [
              _buildTextField(
                controller: _phoneNumberController,
                label: 'رقم الهاتف',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _altPhoneNumberController,
                label: 'رقم هاتف بديل',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'الموقع الحالي',
            icon: Icons.location_city,
            children: [
              _buildTextField(
                controller: _governorateController,
                label: 'المحافظة *',
                icon: Icons.location_on,
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _districtController,
                label: 'القضاء',
                icon: Icons.place,
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _currentAddressController,
                label: 'العنوان الحالي',
                icon: Icons.home,
                maxLines: 2,
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _addressController,
                label: 'العنوان التفصيلي',
                icon: Icons.map,
                maxLines: 3,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'معلومات النزوح',
            icon: Icons.move_to_inbox,
            children: [
              _buildDropdown<int?>(
                value: _displacementStatus,
                label: 'حالة النزوح',
                icon: Icons.info,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 0, child: Text('غير نازح')),
                  DropdownMenuItem(value: 1, child: Text('نازح')),
                  DropdownMenuItem(value: 2, child: Text('عائد')),
                ],
                onChanged: (v) => setState(() => _displacementStatus = v),
              ),
              SizedBox(height: rv.spacing),
              _buildTextField(
                controller: _addressBeforeDisplacementController,
                label: 'العنوان قبل النزوح',
                icon: Icons.history,
                maxLines: 2,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'السكن والتوظيف',
            icon: Icons.work,
            children: [
              _buildDropdown<int?>(
                value: _housingStatus,
                label: 'حالة السكن',
                icon: Icons.home_work,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 0, child: Text('ملك')),
                  DropdownMenuItem(value: 1, child: Text('إيجار')),
                  DropdownMenuItem(value: 2, child: Text('مع العائلة')),
                  DropdownMenuItem(value: 3, child: Text('مخيم')),
                ],
                onChanged: (v) => setState(() => _housingStatus = v),
              ),
              SizedBox(height: rv.spacing),
              _buildDropdown<int?>(
                value: _housingType,
                label: 'نوع السكن',
                icon: Icons.house,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 0, child: Text('بيت')),
                  DropdownMenuItem(value: 1, child: Text('شقة')),
                  DropdownMenuItem(value: 2, child: Text('كرفان')),
                  DropdownMenuItem(value: 3, child: Text('خيمة')),
                ],
                onChanged: (v) => setState(() => _housingType = v),
              ),
              SizedBox(height: rv.spacing),
              _buildDropdown<int?>(
                value: _employmentStatus,
                label: 'حالة توظيف المعيل',
                icon: Icons.work_outline,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 0, child: Text('عاطل')),
                  DropdownMenuItem(value: 1, child: Text('موظف')),
                  DropdownMenuItem(value: 2, child: Text('أعمال حرة')),
                  DropdownMenuItem(value: 3, child: Text('متقاعد')),
                ],
                onChanged: (v) => setState(() => _employmentStatus = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    final rv = ResponsiveUtils.getValues(context);

    return SingleChildScrollView(
      padding: rv.padding,
      child: Column(
        children: [
          _buildSectionCard(
            title: 'الحالة الصحية',
            icon: Icons.health_and_safety,
            children: [
              _buildDropdown<String>(
                value: _healthStatus,
                label: 'الحالة الصحية العامة',
                icon: Icons.favorite,
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('جيدة')),
                  DropdownMenuItem(value: 'fair', child: Text('متوسطة')),
                  DropdownMenuItem(value: 'poor', child: Text('ضعيفة')),
                ],
                onChanged: (v) => setState(() => _healthStatus = v!),
              ),
              SizedBox(height: rv.spacing),
              Container(
                decoration: BoxDecoration(
                  color: _hasDisability
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasDisability
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
                child: CheckboxListTile(
                  value: _hasDisability,
                  onChanged: (v) => setState(() => _hasDisability = v ?? false),
                  title: const Text(
                    'لديه إعاقة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('حدد إذا كان المستفيد من ذوي الإعاقة'),
                  secondary: Icon(
                    Icons.accessible,
                    color: _hasDisability ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _chronicDiseasesCountController,
                      label: 'عدد المصابين بأمراض مزمنة',
                      icon: Icons.medication,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _specialNeedsCountController,
                      label: 'عدد ذوي الاحتياجات الخاصة',
                      icon: Icons.accessibility_new,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'حالة الطلب',
            icon: Icons.assignment,
            children: [
              _buildDropdown<int?>(
                value: _requestStatus,
                label: 'حالة الطلب',
                icon: Icons.pending_actions,
                items: const [
                  DropdownMenuItem(value: null, child: Text('اختر...')),
                  DropdownMenuItem(value: 0, child: Text('قيد المراجعة')),
                  DropdownMenuItem(value: 1, child: Text('مقبول')),
                  DropdownMenuItem(value: 2, child: Text('مرفوض')),
                  DropdownMenuItem(value: 3, child: Text('معلق')),
                ],
                onChanged: (v) => setState(() => _requestStatus = v),
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          _buildSectionCard(
            title: 'ملاحظات',
            icon: Icons.notes,
            children: [
              _buildTextField(
                controller: _notesController,
                label: 'ملاحظات إضافية',
                icon: Icons.note_alt,
                maxLines: 5,
                hint: 'أي معلومات إضافية عن المستفيد...',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return buildSectionCard(
      context: context,
      title: title,
      icon: icon,
      children: children,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return buildTextField(
      controller: controller,
      label: label,
      icon: icon,
      hint: hint,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      suffix: suffix,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return buildDropdown<T>(
      value: value,
      label: label,
      icon: icon,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentTab > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _tabController.animateTo(_currentTab - 1),
                icon: const Icon(Icons.arrow_back),
                label: const Text('السابق'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentTab > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _currentTab < 3
                ? ElevatedButton.icon(
                    onPressed: () => _tabController.animateTo(_currentTab + 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('التالي'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      isEdit ? 'تحديث البيانات' : 'حفظ البيانات',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
