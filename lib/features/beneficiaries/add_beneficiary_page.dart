import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
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
          _familySize = beneficiary.familySize ?? 1;
          _maritalStatus = beneficiary.maritalStatus ?? 'single';
          _educationLevel = beneficiary.educationLevel ?? 'none';
          _healthStatus = beneficiary.healthStatus ?? 'good';
          _hasDisability = beneficiary.hasDisability;
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

      final beneficiary = BeneficiariesCompanion(
        id: widget.beneficiaryId != null
            ? drift.Value(widget.beneficiaryId!)
            : drift.Value(const Uuid().v4()),
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
        familySize: drift.Value(_familySize),
        maritalStatus: drift.Value(_maritalStatus),
        educationLevel: drift.Value(_educationLevel),
        healthStatus: drift.Value(_healthStatus),
        hasDisability: drift.Value(_hasDisability),

        createdAt: widget.beneficiaryId != null
            ? const drift.Value.absent()
            : drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      );

      await database
          .into(database.beneficiaries)
          .insertOnConflictUpdate(beneficiary);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات بنجاح'),
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
    super.build(context); // ضروري لـ AutomaticKeepAliveClientMixin

    // ⚡ Performance: حساب القيم مرة واحدة فقط
    final rv = ResponsiveUtils.getValues(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.beneficiaryId != null ? 'تعديل مستفيد' : 'إضافة مستفيد جديد',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الاسم الكامل';
                        }
                        return null;
                      },
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

                    // Governorate
                    DropdownButtonFormField<String>(
                      value: _selectedGovernorate,
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'بغداد', child: Text('بغداد')),
                        DropdownMenuItem(
                          value: 'البصرة',
                          child: Text('البصرة'),
                        ),
                        DropdownMenuItem(value: 'نينوى', child: Text('نينوى')),
                        DropdownMenuItem(
                          value: 'الأنبار',
                          child: Text('الأنبار'),
                        ),
                        DropdownMenuItem(value: 'ديالى', child: Text('ديالى')),
                        DropdownMenuItem(
                          value: 'كربلاء',
                          child: Text('كربلاء'),
                        ),
                        DropdownMenuItem(value: 'النجف', child: Text('النجف')),
                        DropdownMenuItem(
                          value: 'القادسية',
                          child: Text('القادسية'),
                        ),
                        DropdownMenuItem(value: 'بابل', child: Text('بابل')),
                        DropdownMenuItem(value: 'واسط', child: Text('واسط')),
                        DropdownMenuItem(
                          value: 'صلاح الدين',
                          child: Text('صلاح الدين'),
                        ),
                        DropdownMenuItem(value: 'ميسان', child: Text('ميسان')),
                        DropdownMenuItem(
                          value: 'ذي قار',
                          child: Text('ذي قار'),
                        ),
                        DropdownMenuItem(
                          value: 'المثنى',
                          child: Text('المثنى'),
                        ),
                        DropdownMenuItem(value: 'كركوك', child: Text('كركوك')),
                        DropdownMenuItem(value: 'أربيل', child: Text('أربيل')),
                        DropdownMenuItem(value: 'دهوك', child: Text('دهوك')),
                        DropdownMenuItem(
                          value: 'السليمانية',
                          child: Text('السليمانية'),
                        ),
                      ],
                      onChanged: (value) => _selectedGovernorate = value!,
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
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'الفئة',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'orphan',
                                child: Text('يتيم'),
                              ),
                              DropdownMenuItem(
                                value: 'poor',
                                child: Text('فقير'),
                              ),
                              DropdownMenuItem(
                                value: 'widow',
                                child: Text('أرملة'),
                              ),
                              DropdownMenuItem(
                                value: 'disabled',
                                child: Text('معاق'),
                              ),
                            ],
                            onChanged: (value) => _selectedCategory = value!,
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
                          child: DropdownButtonFormField<String>(
                            value: _maritalStatus,
                            decoration: const InputDecoration(
                              labelText: 'الحالة الاجتماعية',
                              prefixIcon: Icon(Icons.favorite),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'single',
                                child: Text('أعزب'),
                              ),
                              DropdownMenuItem(
                                value: 'married',
                                child: Text('متزوج'),
                              ),
                              DropdownMenuItem(
                                value: 'divorced',
                                child: Text('مطلق'),
                              ),
                              DropdownMenuItem(
                                value: 'widowed',
                                child: Text('أرمل'),
                              ),
                            ],
                            onChanged: (value) => _maritalStatus = value!,
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
                          child: DropdownButtonFormField<String>(
                            value: _educationLevel,
                            decoration: const InputDecoration(
                              labelText: 'المستوى التعليمي',
                              prefixIcon: Icon(Icons.school),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'none',
                                child: Text('بدون تعليم'),
                              ),
                              DropdownMenuItem(
                                value: 'primary',
                                child: Text('ابتدائي'),
                              ),
                              DropdownMenuItem(
                                value: 'secondary',
                                child: Text('متوسط/ثانوي'),
                              ),
                              DropdownMenuItem(
                                value: 'university',
                                child: Text('جامعي'),
                              ),
                            ],
                            onChanged: (value) => _educationLevel = value!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _healthStatus,
                            decoration: const InputDecoration(
                              labelText: 'الحالة الصحية',
                              prefixIcon: Icon(Icons.health_and_safety),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'good',
                                child: Text('جيدة'),
                              ),
                              DropdownMenuItem(
                                value: 'fair',
                                child: Text('متوسطة'),
                              ),
                              DropdownMenuItem(
                                value: 'poor',
                                child: Text('ضعيفة'),
                              ),
                              DropdownMenuItem(
                                value: 'chronic',
                                child: Text('مرض مزمن'),
                              ),
                            ],
                            onChanged: (value) => _healthStatus = value!,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing),

                    // Disability Checkbox
                    CheckboxListTile(
                      value: _hasDisability,
                      onChanged: (value) => _hasDisability = value ?? false,
                      title: const Text('لديه إعاقة'),
                      subtitle: const Text(
                        'حدد إذا كان المستفيد لديه أي نوع من الإعاقة',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBeneficiary,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('حفظ البيانات'),
                      ),
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
