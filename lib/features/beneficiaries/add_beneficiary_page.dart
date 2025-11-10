import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
import '../../core/services/taxonomy_service.dart';
import '../../core/services/activity_logger.dart';
import '../../data/db/drift_database.dart';
import '../../core/utils/responsive_utils.dart';

class AddBeneficiaryPage extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const AddBeneficiaryPage({super.key, this.beneficiaryId});

  @override
  ConsumerState<AddBeneficiaryPage> createState() => _AddBeneficiaryPageState();
}

class _AddBeneficiaryPageState extends ConsumerState<AddBeneficiaryPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNoController = TextEditingController();
  final _notesController = TextEditingController();

  // New controllers
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _districtController = TextEditingController();
  final _associationNameController = TextEditingController();

  // Backend fields controllers
  final _grandFatherNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _altPhoneNumberController = TextEditingController();
  final _addressBeforeDisplacementController = TextEditingController();
  final _currentAddressController = TextEditingController();

  String _selectedGovernorate = 'بغداد';
  String _selectedGender = 'male';
  String _selectedCategory = 'orphan';
  DateTime? _birthDate;
  bool _isLoading = false;

  // New fields
  int _familySize = 1;
  String _maritalStatus = 'single';
  String _educationLevel = 'none';
  String _healthStatus = 'good';
  bool _hasDisability = false;

  // Backend additional fields
  int? _displacementStatus;
  int? _numberOfMales;
  int? _numberOfFemales;
  int _chronicDiseasesCount = 0;
  int _specialNeedsCount = 0;
  int? _employmentStatus;
  int? _housingStatus;
  int? _housingType;
  int? _requestStatus;

  @override
  bool get wantKeepAlive => true; // منع rebuild الصفحة

  @override
  void initState() {
    super.initState();
    if (widget.beneficiaryId != null) {
      _loadBeneficiary();
    }
  }

  Future<void> _loadBeneficiary() async {
    setState(() => _isLoading = true);
    try {
      final database = ref.read(databaseProvider);
      final beneficiary = await database.getBeneficiaryById(
        widget.beneficiaryId!,
      );

      if (beneficiary != null && mounted) {
        setState(() {
          _fullNameController.text = beneficiary.fullName;
          _nationalIdController.text = beneficiary.nationalId;
          _fileNoController.text = beneficiary.fileNo;
          _notesController.text = beneficiary.notes;
          _selectedGovernorate = beneficiary.governorate;
          _selectedGender = beneficiary.gender;
          _selectedCategory = beneficiary.category;
          _birthDate = beneficiary.birthDate;

          // Load new fields
          _phoneNumberController.text = beneficiary.phoneNumber ?? '';
          _addressController.text = beneficiary.address ?? '';
          _motherNameController.text = beneficiary.motherName ?? '';
          _fatherNameController.text = beneficiary.fatherName ?? '';
          _districtController.text = beneficiary.district ?? '';
          _associationNameController.text = beneficiary.associationName ?? '';

          // Load backend fields
          _grandFatherNameController.text = beneficiary.grandFatherName ?? '';
          _familyNameController.text = beneficiary.familyName ?? '';
          _altPhoneNumberController.text = beneficiary.altPhoneNumber ?? '';
          _addressBeforeDisplacementController.text =
              beneficiary.addressBeforeDisplacement ?? '';
          _currentAddressController.text = beneficiary.currentAddress ?? '';

          _familySize = beneficiary.familySize ?? 1;
          _maritalStatus = beneficiary.maritalStatus ?? 'single';
          _educationLevel = beneficiary.educationLevel ?? 'none';
          _healthStatus = beneficiary.healthStatus ?? 'good';
          _hasDisability = beneficiary.hasDisability;

          // Load backend numeric fields
          _displacementStatus = beneficiary.displacementStatus;
          _numberOfMales = beneficiary.numberOfMales;
          _numberOfFemales = beneficiary.numberOfFemales;
          _chronicDiseasesCount = beneficiary.chronicDiseasesCount ?? 0;
          _specialNeedsCount = beneficiary.specialNeedsCount ?? 0;
          _employmentStatus = beneficiary.employmentStatus;
          _housingStatus = beneficiary.housingStatus;
          _housingType = beneficiary.housingType;
          _requestStatus = beneficiary.requestStatus;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _fileNoController.dispose();
    _notesController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _districtController.dispose();
    _associationNameController.dispose();
    _grandFatherNameController.dispose();
    _familyNameController.dispose();
    _altPhoneNumberController.dispose();
    _addressBeforeDisplacementController.dispose();
    _currentAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveBeneficiary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final database = ref.read(databaseProvider);
      final now = DateTime.now();
      final fullName = _fullNameController.text.trim();
      final isEdit = widget.beneficiaryId != null;
      final beneficiaryId = isEdit ? widget.beneficiaryId! : const Uuid().v4();

      final beneficiary = BeneficiariesCompanion(
        id: drift.Value(beneficiaryId),
        fullName: drift.Value(fullName),
        fullNameNorm: drift.Value(fullName.toLowerCase()),
        nationalId: drift.Value(_nationalIdController.text.trim()),
        fileNo: drift.Value(_fileNoController.text.trim()),
        governorate: drift.Value(_selectedGovernorate),
        gender: drift.Value(_selectedGender),
        category: drift.Value(_selectedCategory),
        birthDate: drift.Value(_birthDate),
        notes: drift.Value(_notesController.text.trim()),

        // New fields
        phoneNumber: drift.Value(_phoneNumberController.text.trim()),
        address: drift.Value(_addressController.text.trim()),
        motherName: drift.Value(_motherNameController.text.trim()),
        fatherName: drift.Value(_fatherNameController.text.trim()),
        district: drift.Value(_districtController.text.trim()),
        associationName: drift.Value(_associationNameController.text.trim()),

        // Backend fields
        grandFatherName: drift.Value(_grandFatherNameController.text.trim()),
        familyName: drift.Value(_familyNameController.text.trim()),
        altPhoneNumber: drift.Value(_altPhoneNumberController.text.trim()),
        addressBeforeDisplacement: drift.Value(
          _addressBeforeDisplacementController.text.trim(),
        ),
        currentAddress: drift.Value(_currentAddressController.text.trim()),

        familySize: drift.Value(_familySize),
        maritalStatus: drift.Value(_maritalStatus),
        educationLevel: drift.Value(_educationLevel),
        healthStatus: drift.Value(_healthStatus),
        hasDisability: drift.Value(_hasDisability),

        // Backend numeric fields
        displacementStatus: drift.Value(_displacementStatus),
        numberOfMales: drift.Value(_numberOfMales),
        numberOfFemales: drift.Value(_numberOfFemales),
        chronicDiseasesCount: drift.Value(_chronicDiseasesCount),
        specialNeedsCount: drift.Value(_specialNeedsCount),
        employmentStatus: drift.Value(_employmentStatus),
        housingStatus: drift.Value(_housingStatus),
        housingType: drift.Value(_housingType),
        requestStatus: drift.Value(_requestStatus),

        createdAt: widget.beneficiaryId != null
            ? const drift.Value.absent()
            : drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      );

      await database
          .into(database.beneficiaries)
          .insertOnConflictUpdate(beneficiary);

      // Log activity
      if (isEdit) {
        await ActivityLogger.logEdit(beneficiaryId, fullName);
      } else {
        await ActivityLogger.logAdd(beneficiaryId, fullName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'تم تحديث البيانات بنجاح' : 'تم إضافة المستفيد بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ البيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final rv = ResponsiveUtils.getValues(context);
    final isEdit = widget.beneficiaryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل مستفيد' : 'إضافة مستفيد جديد'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'عرض التفاصيل',
              onPressed: () =>
                  context.push('/beneficiaries/${widget.beneficiaryId}'),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'مساعدة',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('نصائح الإدخال'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '📝 الحقول المطلوبة:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• الاسم الكامل\n• الرقم الوطني\n• رقم الملف\n• المحافظة',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '💡 نصائح:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• تأكد من صحة البيانات قبل الحفظ\n• يمكنك التعديل لاحقاً\n• البيانات تُحفظ محلياً أولاً',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('فهمت'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    isEdit ? 'جاري تحميل البيانات...' : 'جاري الحفظ...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: rv.padding,
              // تحسين الأداء
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('المعلومات الأساسية'),
                    SizedBox(height: rv.spacing),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل *',
                        prefixIcon: Icon(Icons.person),
                        helperText: 'الاسم الثلاثي أو الرباعي',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الاسم الكامل';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'الرجاء إدخال اسمين على الأقل';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing),

                    // Association Name
                    TextFormField(
                      controller: _associationNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الجمعية',
                        prefixIcon: Icon(Icons.business),
                        hintText: 'مثال: جمعية البناء الخيرية',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing),

                    // National ID & File No in row
                    ResponsiveBuilder(
                      mobile: (context, constraints) => Column(
                        children: [
                          TextFormField(
                            controller: _nationalIdController,
                            decoration: const InputDecoration(
                              labelText: 'الرقم الوطني *',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: rv.spacing),
                          TextFormField(
                            controller: _fileNoController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الملف *',
                              prefixIcon: Icon(Icons.folder),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      tablet: (context, constraints) => Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nationalIdController,
                              decoration: const InputDecoration(
                                labelText: 'الرقم الوطني *',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _fileNoController,
                              decoration: const InputDecoration(
                                labelText: 'رقم الملف *',
                                prefixIcon: Icon(Icons.folder),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('التصنيف'),
                    SizedBox(height: rv.spacing),

                    // Governorate - ديناميكي من API
                    Consumer(
                      builder: (context, ref, child) {
                        final governoratesAsync = ref.watch(
                          governoratesProvider,
                        );

                        return governoratesAsync.when(
                          data: (governorates) {
                            // التأكد من وجود القيمة المختارة في القائمة
                            if (governorates.isNotEmpty &&
                                !governorates.any(
                                  (g) => g.label == _selectedGovernorate,
                                )) {
                              _selectedGovernorate = governorates.first.label;
                            }

                            return DropdownButtonFormField<String>(
                              value: _selectedGovernorate,
                              decoration: const InputDecoration(
                                labelText: 'المحافظة',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              items: governorates.map((gov) {
                                return DropdownMenuItem(
                                  value: gov.label,
                                  child: Text(gov.label),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  _selectedGovernorate = value!,
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => Text('خطأ: $err'),
                        );
                      },
                    ),
                    SizedBox(height: rv.spacing),

                    // Gender & Category in row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'الجنس',
                              prefixIcon: Icon(Icons.wc),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('ذكر'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('أنثى'),
                              ),
                            ],
                            onChanged: (value) => _selectedGender = value!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final categoriesAsync = ref.watch(
                                categoriesProvider,
                              );

                              return categoriesAsync.when(
                                data: (categories) {
                                  // التأكد من وجود القيمة المختارة
                                  if (categories.isNotEmpty &&
                                      !categories.any(
                                        (c) => c.code == _selectedCategory,
                                      )) {
                                    _selectedCategory = categories.first.code;
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'الفئة',
                                      prefixIcon: Icon(Icons.category),
                                    ),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat.code,
                                        child: Text(cat.label),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        _selectedCategory = value!,
                                  );
                                },
                                loading: () => const LinearProgressIndicator(),
                                error: (err, stack) => Text('خطأ: $err'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing),

                    // Birth Date
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الميلاد',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _birthDate != null
                              ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                              : 'اختر التاريخ',
                          style: TextStyle(
                            color: _birthDate != null ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('معلومات التواصل'),
                    SizedBox(height: rv.spacing),

                    // Phone Number
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '07XXXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(r'^07[0-9]{9}$').hasMatch(value.trim())) {
                            return 'الرقم غير صحيح (يجب أن يبدأ ب07 ويحتوي 11 رقم)';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: rv.spacing),

                    // Address
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'القضاء',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان الكامل',
                        prefixIcon: Icon(Icons.home),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('معلومات العائلة'),
                    SizedBox(height: rv.spacing),

                    // Father & Mother Name in row
                    ResponsiveBuilder(
                      mobile: (context, constraints) => Column(
                        children: [
                          TextFormField(
                            controller: _fatherNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم الأب',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: rv.spacing),
                          TextFormField(
                            controller: _motherNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم الأم',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      tablet: (context, constraints) => Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fatherNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم الأب',
                                prefixIcon: Icon(Icons.person),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _motherNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم الأم',
                                prefixIcon: Icon(Icons.person),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Family Size & Marital Status
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _familySize.toString(),
                            decoration: const InputDecoration(
                              labelText: 'عدد أفراد الأسرة',
                              prefixIcon: Icon(Icons.family_restroom),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                _familySize = int.tryParse(value) ?? 1,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final num = int.tryParse(value);
                                if (num == null || num < 1) {
                                  return 'يجب أن يكون رقم أكبر من 0';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final maritalAsync = ref.watch(
                                maritalStatusesProvider,
                              );

                              return maritalAsync.when(
                                data: (statuses) {
                                  if (statuses.isNotEmpty &&
                                      !statuses.any(
                                        (s) => s.code == _maritalStatus,
                                      )) {
                                    _maritalStatus = statuses.first.code;
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: _maritalStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'الحالة الاجتماعية',
                                      prefixIcon: Icon(Icons.favorite),
                                    ),
                                    items: statuses.map((status) {
                                      return DropdownMenuItem(
                                        value: status.code,
                                        child: Text(status.label),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        _maritalStatus = value!,
                                  );
                                },
                                loading: () => const LinearProgressIndicator(),
                                error: (err, stack) => Text('خطأ: $err'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('المستوى التعليمي والصحي'),
                    SizedBox(height: rv.spacing),

                    // Education & Health Status
                    Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final educationAsync = ref.watch(
                                educationLevelsProvider,
                              );

                              return educationAsync.when(
                                data: (levels) {
                                  if (levels.isNotEmpty &&
                                      !levels.any(
                                        (l) => l.code == _educationLevel,
                                      )) {
                                    _educationLevel = levels.first.code;
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: _educationLevel,
                                    decoration: const InputDecoration(
                                      labelText: 'المستوى التعليمي',
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                    items: levels.map((level) {
                                      return DropdownMenuItem(
                                        value: level.code,
                                        child: Text(level.label),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        _educationLevel = value!,
                                  );
                                },
                                loading: () => const LinearProgressIndicator(),
                                error: (err, stack) => Text('خطأ: $err'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final healthAsync = ref.watch(
                                healthStatusesProvider,
                              );

                              return healthAsync.when(
                                data: (statuses) {
                                  if (statuses.isNotEmpty &&
                                      !statuses.any(
                                        (s) => s.code == _healthStatus,
                                      )) {
                                    _healthStatus = statuses.first.code;
                                  }

                                  return DropdownButtonFormField<String>(
                                    value: _healthStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'الحالة الصحية',
                                      prefixIcon: Icon(Icons.health_and_safety),
                                    ),
                                    items: statuses.map((status) {
                                      return DropdownMenuItem(
                                        value: status.code,
                                        child: Text(status.label),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        _healthStatus = value!,
                                  );
                                },
                                loading: () => const LinearProgressIndicator(),
                                error: (err, stack) => Text('خطأ: $err'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing),

                    // Disability Checkbox
                    CheckboxListTile(
                      value: _hasDisability,
                      onChanged: (value) {
                        setState(() {
                          _hasDisability = value ?? false;
                          if (!_hasDisability) {
                            _specialNeedsCount = 0;
                          }
                        });
                      },
                      title: const Text('لديه إعاقة'),
                      subtitle: const Text(
                        'حدد إذا كان المستفيد لديه أي نوع من الإعاقة',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('معلومات تفصيلية إضافية'),
                    SizedBox(height: rv.spacing),

                    // Grand Father Name & Family Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _grandFatherNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم الجد',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _familyNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم العائلة',
                              prefixIcon: Icon(Icons.family_restroom),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing),

                    // Alternative Phone Number
                    TextFormField(
                      controller: _altPhoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم هاتف بديل',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing),

                    // Current Address & Address Before Displacement
                    TextFormField(
                      controller: _currentAddressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان الحالي',
                        prefixIcon: Icon(Icons.home),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing),

                    TextFormField(
                      controller: _addressBeforeDisplacementController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان قبل النزوح',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: rv.spacing),

                    // Number of Males & Females
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _numberOfMales?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'عدد الذكور',
                              prefixIcon: Icon(Icons.male),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                _numberOfMales = int.tryParse(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _numberOfFemales?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'عدد الإناث',
                              prefixIcon: Icon(Icons.female),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                _numberOfFemales = int.tryParse(value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing),

                    // Chronic Diseases & Special Needs Count
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _chronicDiseasesCount.toString(),
                            decoration: const InputDecoration(
                              labelText: 'عدد الأمراض المزمنة',
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => _chronicDiseasesCount =
                                int.tryParse(value) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _specialNeedsCount.toString(),
                            decoration: const InputDecoration(
                              labelText: 'عدد ذوي الاحتياجات الخاصة',
                              prefixIcon: Icon(Icons.accessible),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            enabled: _hasDisability,
                            onChanged: (value) =>
                                _specialNeedsCount = int.tryParse(value) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing15),

                    _buildSectionTitle('ملاحظات'),
                    SizedBox(height: rv.spacing),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية',
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: rv.spacing * 2),

                    // Save Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveBeneficiary,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          widget.beneficiaryId != null
                              ? 'تحديث البيانات'
                              : 'حفظ البيانات',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
