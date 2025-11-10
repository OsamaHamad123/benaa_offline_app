import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/db/drift_database.dart';

/// صفحة إضافة/تعديل مستفيد - بدون BLoC، Riverpod فقط
/// الأداء: بدون أي lag لأن كل TextField له controller خاص
/// ولا يوجد setState إلا للـ dropdowns فقط
class AddBeneficiaryPageSimple extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const AddBeneficiaryPageSimple({super.key, this.beneficiaryId});

  @override
  ConsumerState<AddBeneficiaryPageSimple> createState() =>
      _AddBeneficiaryPageSimpleState();
}

class _AddBeneficiaryPageSimpleState
    extends ConsumerState<AddBeneficiaryPageSimple> {
  // Controllers - بدون setState
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNoController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _associationNameController = TextEditingController();
  final _familySizeController = TextEditingController();
  final _notesController = TextEditingController();

  // Local state - فقط للـ dropdowns
  String _governorate = 'بغداد';
  String _gender = 'male';
  String _category = 'orphan';
  String _healthStatus = 'good';
  bool _hasDisability = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBeneficiary();
  }

  Future<void> _loadBeneficiary() async {
    if (widget.beneficiaryId == null) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final beneficiary = await db.getBeneficiaryById(widget.beneficiaryId!);

      if (beneficiary != null && mounted) {
        _fullNameController.text = beneficiary.fullName;
        _nationalIdController.text = beneficiary.nationalId;
        _fileNoController.text = beneficiary.fileNo;
        _phoneNumberController.text = beneficiary.phoneNumber ?? '';
        _addressController.text = beneficiary.address ?? '';
        _districtController.text = beneficiary.district ?? '';
        _motherNameController.text = beneficiary.motherName ?? '';
        _fatherNameController.text = beneficiary.fatherName ?? '';
        _associationNameController.text = beneficiary.associationName ?? '';
        _familySizeController.text = beneficiary.familySize.toString();
        _notesController.text = beneficiary.notes;

        setState(() {
          _governorate = beneficiary.governorate;
          _gender = beneficiary.gender;
          _category = beneficiary.category;
          _healthStatus = beneficiary.healthStatus ?? 'good';
          _hasDisability = beneficiary.hasDisability;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
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
    _phoneNumberController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _associationNameController.dispose();
    _familySizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validation
    if (_fullNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الاسم الكامل');
      return;
    }
    if (_nationalIdController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الرقم الوطني');
      return;
    }
    if (_fileNoController.text.trim().isEmpty) {
      _showError('الرجاء إدخال رقم الملف');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final isEdit = widget.beneficiaryId != null;
      final now = DateTime.now();

      if (isEdit) {
        // Update existing
        await db.updateBeneficiaryCompanion(
          widget.beneficiaryId!,
          BeneficiariesCompanion(
            fullName: drift.Value(_fullNameController.text.trim()),
            fullNameNorm: drift.Value(
              _fullNameController.text.trim().toLowerCase(),
            ),
            nationalId: drift.Value(_nationalIdController.text.trim()),
            fileNo: drift.Value(_fileNoController.text.trim()),
            governorate: drift.Value(_governorate),
            gender: drift.Value(_gender),
            category: drift.Value(_category),
            phoneNumber: drift.Value(_phoneNumberController.text.trim()),
            address: drift.Value(_addressController.text.trim()),
            district: drift.Value(_districtController.text.trim()),
            motherName: drift.Value(_motherNameController.text.trim()),
            fatherName: drift.Value(_fatherNameController.text.trim()),
            associationName: drift.Value(
              _associationNameController.text.trim(),
            ),
            familySize: drift.Value(
              int.tryParse(_familySizeController.text) ?? 1,
            ),
            healthStatus: drift.Value(_healthStatus),
            hasDisability: drift.Value(_hasDisability),
            notes: drift.Value(_notesController.text.trim()),
            updatedAt: drift.Value(now),
            syncState: const drift.Value('pending'),
          ),
        );
      } else {
        // Insert new
        await db.insertBeneficiary(
          BeneficiariesCompanion.insert(
            id: const Uuid().v4(),
            fullName: _fullNameController.text.trim(),
            fullNameNorm: _fullNameController.text.trim().toLowerCase(),
            nationalId: _nationalIdController.text.trim(),
            fileNo: _fileNoController.text.trim(),
            governorate: _governorate,
            gender: _gender,
            category: _category,
            phoneNumber: drift.Value(_phoneNumberController.text.trim()),
            address: drift.Value(_addressController.text.trim()),
            district: drift.Value(_districtController.text.trim()),
            motherName: drift.Value(_motherNameController.text.trim()),
            fatherName: drift.Value(_fatherNameController.text.trim()),
            associationName: drift.Value(
              _associationNameController.text.trim(),
            ),
            familySize: drift.Value(
              int.tryParse(_familySizeController.text) ?? 1,
            ),
            healthStatus: drift.Value(_healthStatus),
            hasDisability: drift.Value(_hasDisability),
            notes: drift.Value(_notesController.text.trim()),
            createdAt: now,
            updatedAt: now,
          ),
        );
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: rv.padding,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBasicInfoSection(rv),
                  SizedBox(height: rv.spacing15),
                  _buildContactSection(rv),
                  SizedBox(height: rv.spacing15),
                  _buildFamilySection(rv),
                  SizedBox(height: rv.spacing15),
                  _buildHealthSection(rv),
                  SizedBox(height: rv.spacing15),
                  _buildNotesSection(rv),
                  SizedBox(height: rv.spacing * 2),
                  _buildSaveButton(isEdit),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('المعلومات الأساسية'),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'الاسم الكامل *',
            prefixIcon: Icon(Icons.person),
            helperText: 'الاسم الثلاثي أو الرباعي',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _associationNameController,
          decoration: const InputDecoration(
            labelText: 'اسم الجمعية',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _fileNoController,
                decoration: const InputDecoration(
                  labelText: 'رقم الملف *',
                  prefixIcon: Icon(Icons.folder),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        SizedBox(height: rv.spacing),
        DropdownButtonFormField<String>(
          value: _governorate,
          decoration: const InputDecoration(
            labelText: 'المحافظة *',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'بغداد', child: Text('بغداد')),
            DropdownMenuItem(value: 'البصرة', child: Text('البصرة')),
            DropdownMenuItem(value: 'نينوى', child: Text('نينوى')),
            DropdownMenuItem(value: 'الأنبار', child: Text('الأنبار')),
            DropdownMenuItem(value: 'ديالى', child: Text('ديالى')),
            DropdownMenuItem(value: 'كربلاء', child: Text('كربلاء')),
            DropdownMenuItem(value: 'النجف', child: Text('النجف')),
          ],
          onChanged: (v) => setState(() => _governorate = v!),
        ),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'الجنس *',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'الفئة *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
                  DropdownMenuItem(value: 'widow', child: Text('أرملة')),
                  DropdownMenuItem(value: 'poor', child: Text('فقير')),
                  DropdownMenuItem(value: 'disabled', child: Text('معاق')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات الاتصال'),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _districtController,
          decoration: const InputDecoration(
            labelText: 'القضاء',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'العنوان',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildFamilySection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات العائلة'),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأب',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأم',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _familySizeController,
          decoration: const InputDecoration(
            labelText: 'عدد أفراد الأسرة',
            prefixIcon: Icon(Icons.family_restroom),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildHealthSection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('الحالة الصحية'),
        SizedBox(height: rv.spacing),
        DropdownButtonFormField<String>(
          value: _healthStatus,
          decoration: const InputDecoration(
            labelText: 'الحالة الصحية',
            prefixIcon: Icon(Icons.health_and_safety),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'good', child: Text('جيدة')),
            DropdownMenuItem(value: 'fair', child: Text('متوسطة')),
            DropdownMenuItem(value: 'poor', child: Text('ضعيفة')),
          ],
          onChanged: (v) => setState(() => _healthStatus = v!),
        ),
        SizedBox(height: rv.spacing),
        CheckboxListTile(
          value: _hasDisability,
          onChanged: (v) => setState(() => _hasDisability = v ?? false),
          title: const Text('لديه إعاقة'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildNotesSection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ملاحظات'),
        SizedBox(height: rv.spacing),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'ملاحظات إضافية',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _save,
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
          isEdit ? 'تحديث البيانات' : 'حفظ البيانات',
          style: const TextStyle(fontSize: 16),
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
