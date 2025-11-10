import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/separated_flex.dart';
import '../../data/db/drift_database.dart';
import 'widgets/form_field_builders.dart';
import 'widgets/attachments_section.dart';
import 'utils/auto_save_manager.dart';
import 'utils/tab_progress_calculator.dart';
import 'utils/smart_validators.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadBeneficiary();
    _startAutoSave();
    _setupTextListeners();
  }

  /// إضافة listeners للحقول لتحديث Progress
  Timer? _debouncedSaveTimer;

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
        if (mounted) {
          setState(() => _hasUnsavedChanges = true);

          // Debounced Auto-Save: حفظ بعد 3 ثواني من التوقف عن الكتابة
          _debouncedSaveTimer?.cancel();
          _debouncedSaveTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && _hasUnsavedChanges) {
              _autoSaveDraft();
            }
          });
        }
      });
    }
  }

  /// حفظ مسودة تلقائي
  Future<void> _autoSaveDraft() async {
    final draftId = widget.beneficiaryId ?? 'draft_${const Uuid().v4()}';
    final data = _collectFormData();

    // حفظ في SharedPreferences أو قاعدة بيانات مؤقتة
    await _autoSaveManager.saveDraft(draftId, data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('تم الحفظ التلقائي'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          width: 200,
        ),
      );
    }
  }

  /// بدء الحفظ التلقائي
  void _startAutoSave() {
    final draftId = widget.beneficiaryId ?? 'new';
    _autoSaveManager.startAutoSave(draftId, _collectFormData);
  }

  /// معالج تغيير البطاقة الوطنية - Smart Validation & Auto-Fill
  Timer? _nationalIdDebounceTimer;
  void _onNationalIdChanged(String value) {
    setState(() => _hasUnsavedChanges = true);

    // Cancel previous timer
    _nationalIdDebounceTimer?.cancel();

    // Debounce for 1 second
    _nationalIdDebounceTimer = Timer(const Duration(seconds: 1), () async {
      if (value.isEmpty) return;

      // 1. Validate Iraqi National ID
      final validationError = SmartValidators.validateIraqiNationalId(value);
      if (validationError != null) {
        if (mounted) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠ $validationError'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 2. Extract info from National ID
      final info = SmartValidators.extractInfoFromNationalId(value);
      if (info != null) {
        // Show confirmation dialog for auto-fill
        final shouldAutoFill = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.blue),
                SizedBox(width: 8),
                Text('تعبئة تلقائية'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم استخراج المعلومات التالية من البطاقة الوطنية:'),
                const SizedBox(height: 16),
                _buildInfoRow('المحافظة', info['governorate'] ?? ''),
                _buildInfoRow(
                  'تاريخ الميلاد',
                  info['birthDate']?.toString().substring(0, 10) ?? '',
                ),
                _buildInfoRow('الجنس', info['gender'] ?? ''),
                _buildInfoRow('العمر', '${info['age']} سنة'),
                const SizedBox(height: 16),
                const Text(
                  'هل تريد استخدام هذه البيانات؟',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('لا'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نعم، استخدم البيانات'),
              ),
            ],
          ),
        );

        if (shouldAutoFill == true && mounted) {
          HapticFeedback.mediumImpact();
          setState(() {
            // Auto-fill governorate
            if (info['governorate'] != null) {
              _governorateController.text = info['governorate']!;
            }

            // Auto-fill birth date
            if (info['birthDate'] != null) {
              _birthDate = info['birthDate']!;
              _birthDateController.text =
                  '${info['birthDate']!.year}-${info['birthDate']!.month.toString().padLeft(2, '0')}-${info['birthDate']!.day.toString().padLeft(2, '0')}';
            }

            // Auto-fill gender
            if (info['gender'] == 'ذكر') {
              _gender = 'male';
            } else if (info['gender'] == 'أنثى') {
              _gender = 'female';
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ تم تعبئة البيانات تلقائياً'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }

      // 3. Check for duplicates
      _checkDuplicateBeneficiary(value);
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// فحص التكرار في قاعدة البيانات
  Future<void> _checkDuplicateBeneficiary(String nationalId) async {
    try {
      final database = ref.read(databaseProvider);

      // Query all beneficiaries and search manually
      final allBeneficiaries = await database.getAllBeneficiaries();
      final existing = allBeneficiaries.firstWhere(
        (b) => b.nationalId == nationalId,
        orElse: () => throw StateError('Not found'),
      );

      if (existing.id != widget.beneficiaryId) {
        if (mounted) {
          HapticFeedback.heavyImpact();
          final action = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text('مستفيد موجود مسبقاً'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('يوجد مستفيد مسجل بنفس الرقم الوطني:'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاسم: ${existing.fullName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('رقم الملف: ${existing.fileNo}'),
                        Text('الرقم الوطني: ${existing.nationalId}'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  child: const Text('عرض المستفيد'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, 'continue'),
                  child: const Text('متابعة رغم ذلك'),
                ),
              ],
            ),
          );

          if (action == 'cancel') {
            _nationalIdController.clear();
          } else if (action == 'view') {
            // Navigate to beneficiary details
            if (mounted) {
              context.push('/beneficiaries/${existing.id}');
            }
          }
        }
      }
    } catch (e) {
      // No duplicate found or error - silent fail
    }
  }

  /// Smart validation لحجم العائلة
  void _validateFamilySize(String value) {
    setState(() => _hasUnsavedChanges = true);

    if (_familySizeController.text.isEmpty) return;
    if (_numberOfMalesController.text.isEmpty &&
        _numberOfFemalesController.text.isEmpty)
      return;

    // Validate family size logic
    final error = SmartValidators.validateFamilySize(
      familySize: _familySizeController.text,
      numberOfMales: _numberOfMalesController.text,
      numberOfFemales: _numberOfFemalesController.text,
    );

    if (error != null) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠ $error'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// جمع بيانات النموذج للحفظ التلقائي
  Map<String, dynamic> _collectFormData() {
    _hasUnsavedChanges = true;

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
      case 4:
        // Attachments tab progress - always 100% if there are any attachments
        return 1.0; // Can be enhanced later to check actual attachment count
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
    _debouncedSaveTimer?.cancel();
    _nationalIdDebounceTimer?.cancel();
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
        final newBeneficiaryId = const Uuid().v4();
        await db.insertBeneficiary(
          BeneficiariesCompanion.insert(
            id: newBeneficiaryId,
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

        // Update attachments with the new beneficiary ID
        final tempBeneficiaryId =
            widget.beneficiaryId ?? 'temp_${const Uuid().v4()}';
        if (tempBeneficiaryId.startsWith('temp_')) {
          await _updateAttachmentsBeneficiaryId(
            db,
            tempBeneficiaryId,
            newBeneficiaryId,
          );
        }
      }

      if (mounted) {
        // حذف المسودة بعد الحفظ الناجح
        final draftId = widget.beneficiaryId ?? 'new';
        await _autoSaveManager.deleteDraft(draftId);

        _showSuccess(
          isEdit ? 'تم تحديث البيانات بنجاح' : 'تم إضافة المستفيد بنجاح',
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

  /// Update attachments beneficiary ID from temp to real ID
  Future<void> _updateAttachmentsBeneficiaryId(
    AppDatabase db,
    String oldBeneficiaryId,
    String newBeneficiaryId,
  ) async {
    try {
      final attachments = await db.getBeneficiaryAttachments(oldBeneficiaryId);
      debugPrint(
        '📎 Updating ${attachments.length} attachments from $oldBeneficiaryId to $newBeneficiaryId',
      );

      for (final attachment in attachments) {
        await (db.update(
          db.attachments,
        )..where((tbl) => tbl.id.equals(attachment.id))).write(
          AttachmentsCompanion(beneficiaryId: drift.Value(newBeneficiaryId)),
        );
      }

      debugPrint('✅ Successfully updated all attachments');
    } catch (e) {
      debugPrint('❌ Error updating attachments: $e');
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact(); // اهتزاز قوي للأخطاء
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

  void _showSuccess(String message) {
    HapticFeedback.mediumImpact(); // اهتزاز متوسط للنجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
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

  /// مسح QR Code من البطاقة الوطنية
  Future<void> _scanNationalIdQR() async {
    HapticFeedback.selectionClick();

    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('مسح البطاقة الوطنية'),
            backgroundColor: Colors.black,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );

    if (scanned != null && mounted) {
      HapticFeedback.mediumImpact();

      // استخراج الرقم الوطني من QR
      // عادة QR البطاقة العراقية يحتوي على بيانات متعددة
      // نستخرج الأرقام فقط (11-12 رقم)
      final numbers = scanned.replaceAll(RegExp(r'[^0-9]'), '');

      if (numbers.length >= 11 && numbers.length <= 12) {
        setState(() {
          _nationalIdController.text = numbers;
        });

        // تشغيل validation و auto-fill
        _onNationalIdChanged(numbers);

        _showSuccess('تم قراءة البطاقة الوطنية بنجاح');
      } else {
        _showError('لم يتم التعرف على رقم البطاقة الوطنية');
      }
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
                isScrollable: true, // ✅ Make scrollable to prevent overflow
                tabAlignment: TabAlignment.start, // ✅ Align tabs to start
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 22),
                        const SizedBox(height: 4),
                        const Text('أساسي', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(0),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.family_restroom, size: 22),
                        const SizedBox(height: 4),
                        const Text('عائلة', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(1),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 22),
                        const SizedBox(height: 4),
                        const Text('موقع', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(2),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.health_and_safety, size: 22),
                        const SizedBox(height: 4),
                        const Text('صحة', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(3),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file, size: 22),
                        const SizedBox(height: 4),
                        const Text('مرفقات', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 2),
                        TabProgressIndicator(
                          progress: _calculateTabProgress(4),
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
                        _buildAttachmentsTab(),
                      ],
                    ),
                  ),
                  _buildBottomBar(isEdit),
                ],
              ),
        floatingActionButton: _buildFloatingActionButton(isEdit),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  /// FAB عائم للحفظ السريع مع animation
  Widget _buildFloatingActionButton(bool isEdit) {
    return AnimatedScale(
      scale: _isLoading ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _save,
        icon: const Icon(Icons.save_rounded),
        label: Text(isEdit ? 'حفظ التعديلات' : 'حفظ'),
        tooltip: isEdit ? 'حفظ التعديلات' : 'حفظ المستفيد',
        elevation: 8,
        heroTag: 'save_beneficiary',
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
          buildSectionCard(
            context: context,
            title: 'البيانات الشخصية',
            icon: Icons.badge,
            children: [
              buildTextField(
                controller: _fullNameController,
                label: 'الاسم الكامل *',
                icon: Icons.person,
                hint: 'الاسم الثلاثي أو الرباعي',
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: buildTextField(
                      controller: _nationalIdController,
                      label: 'الرقم الوطني *',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onNationalIdChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _scanNationalIdQR,
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'مسح QR Code',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: buildTextField(
                      controller: _fileNoController,
                      label: 'رقم الملف *',
                      icon: Icons.folder,
                    ),
                  ),
                ],
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
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
                    child: buildDropdown<String>(
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
                    child: buildDropdown<String>(
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
          buildSectionCard(
            context: context,
            title: 'معلومات إضافية',
            icon: Icons.info_outline,
            children: [
              buildTextField(
                controller: _associationNameController,
                label: 'اسم الجمعية',
                icon: Icons.business,
              ),
              SizedBox(height: rv.spacing),
              buildDropdown<String?>(
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
              buildDropdown<String?>(
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
          buildSectionCard(
            context: context,
            title: 'أفراد العائلة',
            icon: Icons.people,
            children: [
              buildTextField(
                controller: _motherNameController,
                label: 'اسم الأم',
                icon: Icons.person,
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
                controller: _fatherNameController,
                label: 'اسم الأب',
                icon: Icons.person,
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: _grandFatherNameController,
                      label: 'اسم الجد',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(
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
          buildSectionCard(
            context: context,
            title: 'تفاصيل الأسرة',
            icon: Icons.family_restroom,
            children: [
              buildTextField(
                controller: _familySizeController,
                label: 'عدد أفراد الأسرة',
                icon: Icons.group,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _validateFamilySize,
              ),
              SizedBox(height: rv.spacing),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: _numberOfMalesController,
                      label: 'عدد الذكور',
                      icon: Icons.male,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) =>
                          _validateFamilySize(_familySizeController.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(
                      controller: _numberOfFemalesController,
                      label: 'عدد الإناث',
                      icon: Icons.female,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) =>
                          _validateFamilySize(_familySizeController.text),
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
          buildSectionCard(
            context: context,
            title: 'معلومات الاتصال',
            icon: Icons.contact_phone,
            children: [
              buildTextField(
                controller: _phoneNumberController,
                label: 'رقم الهاتف',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
                controller: _altPhoneNumberController,
                label: 'رقم هاتف بديل',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          buildSectionCard(
            context: context,
            title: 'الموقع الحالي',
            icon: Icons.location_city,
            children: [
              buildTextField(
                controller: _governorateController,
                label: 'المحافظة *',
                icon: Icons.location_on,
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
                controller: _districtController,
                label: 'القضاء',
                icon: Icons.place,
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
                controller: _currentAddressController,
                label: 'العنوان الحالي',
                icon: Icons.home,
                maxLines: 2,
              ),
              SizedBox(height: rv.spacing),
              buildTextField(
                controller: _addressController,
                label: 'العنوان التفصيلي',
                icon: Icons.map,
                maxLines: 3,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          buildSectionCard(
            context: context,
            title: 'معلومات النزوح',
            icon: Icons.move_to_inbox,
            children: [
              buildDropdown<int?>(
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
              buildTextField(
                controller: _addressBeforeDisplacementController,
                label: 'العنوان قبل النزوح',
                icon: Icons.history,
                maxLines: 2,
              ),
            ],
          ),
          SizedBox(height: rv.spacing15),
          buildSectionCard(
            context: context,
            title: 'السكن والتوظيف',
            icon: Icons.work,
            children: [
              buildDropdown<int?>(
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
              buildDropdown<int?>(
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
              buildDropdown<int?>(
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
          buildSectionCard(
            context: context,
            title: 'الحالة الصحية',
            icon: Icons.health_and_safety,
            children: [
              buildDropdown<String>(
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
                    child: buildTextField(
                      controller: _chronicDiseasesCountController,
                      label: 'عدد المصابين بأمراض مزمنة',
                      icon: Icons.medication,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(
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
          buildSectionCard(
            context: context,
            title: 'حالة الطلب',
            icon: Icons.assignment,
            children: [
              buildDropdown<int?>(
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
          buildSectionCard(
            context: context,
            title: 'ملاحظات',
            icon: Icons.notes,
            children: [
              buildTextField(
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

  Widget _buildAttachmentsTab() {
    final rv = ResponsiveUtils.getValues(context);

    return SingleChildScrollView(
      padding: rv.padding,
      child: AttachmentsSection(
        beneficiaryId: widget.beneficiaryId ?? 'temp_${const Uuid().v4()}',
        loadFromDatabase: widget.beneficiaryId != null,
      ),
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
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
            child: _currentTab < 4
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
