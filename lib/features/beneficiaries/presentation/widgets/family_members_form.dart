import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';

class FamilyMembersForm extends ConsumerStatefulWidget {
  final int beneficiaryId;
  final FamilyMember? existingMember;
  final VoidCallback onSaved;

  const FamilyMembersForm({
    super.key,
    required this.beneficiaryId,
    this.existingMember,
    required this.onSaved,
  });

  @override
  ConsumerState<FamilyMembersForm> createState() => _FamilyMembersFormState();
}

class _FamilyMembersFormState extends ConsumerState<FamilyMembersForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _disabilityTypeController = TextEditingController();
  final _chronicDiseaseTypeController = TextEditingController();

  String? _selectedRelationship;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEducation;
  String? _selectedOccupation;
  String? _selectedHealthStatus;
  DateTime? _birthDate;
  bool _hasDisability = false;
  bool _hasChronicDisease = false;
  bool _livesWithBeneficiary = true;

  final List<String> _relationships = [
    'ابن',
    'ابنة',
    'زوج',
    'زوجة',
    'أب',
    'أم',
    'أخ',
    'أخت',
    'جد',
    'جدة',
    'حفيد',
    'حفيدة',
    'عم',
    'عمة',
    'خال',
    'خالة',
    'آخر',
  ];

  final List<String> _maritalStatuses = ['أعزب', 'متزوج', 'مطلق', 'أرمل'];

  final List<String> _educationLevels = [
    'أمي',
    'ابتدائي',
    'إعدادي',
    'ثانوي',
    'دبلوم',
    'بكالوريوس',
    'ماجستير',
    'دكتوراه',
  ];

  final List<String> _healthStatuses = ['جيدة', 'متوسطة', 'سيئة'];

  @override
  void initState() {
    super.initState();
    final member = widget.existingMember;
    if (member != null) {
      _nameController.text = member.fullName;
      _nationalIdController.text = member.nationalId ?? '';
      _ageController.text = member.age?.toString() ?? '';
      _phoneController.text = member.phone ?? '';
      _disabilityTypeController.text = member.disabilityType ?? '';
      _chronicDiseaseTypeController.text = member.chronicDiseaseType ?? '';
      _selectedRelationship = member.relationship;
      _selectedGender = member.gender;
      _selectedMaritalStatus = member.maritalStatus;
      _selectedEducation = member.educationLevel;
      _selectedOccupation = member.occupation;
      _selectedHealthStatus = member.healthStatus;
      _birthDate = member.birthDate;
      _hasDisability = member.hasDisability;
      _hasChronicDisease = member.hasChronicDisease;
      _livesWithBeneficiary = member.livesWithBeneficiary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _disabilityTypeController.dispose();
    _chronicDiseaseTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        // حساب العمر تلقائياً
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    final database = ref.read(databaseProvider);
    final dao = database.familyMembersDao;

    final companion = FamilyMembersTableCompanion(
      id: widget.existingMember != null
          ? drift.Value(widget.existingMember!.id)
          : const drift.Value.absent(),
      beneficiaryId: drift.Value(widget.beneficiaryId),
      fullName: drift.Value(_nameController.text.trim()),
      relationship: drift.Value(_selectedRelationship!),
      gender: drift.Value(_selectedGender ?? 'male'),
      nationalId: drift.Value(_nationalIdController.text.trim()),
      birthDate: drift.Value(_birthDate),
      age: _ageController.text.isNotEmpty
          ? drift.Value(int.tryParse(_ageController.text))
          : const drift.Value(null),
      maritalStatus: drift.Value(_selectedMaritalStatus),
      educationLevel: drift.Value(_selectedEducation),
      occupation: drift.Value(_selectedOccupation),
      healthStatus: drift.Value(_selectedHealthStatus),
      hasDisability: drift.Value(_hasDisability),
      disabilityType: drift.Value(_disabilityTypeController.text.trim()),
      hasChronicDisease: drift.Value(_hasChronicDisease),
      chronicDiseaseType: drift.Value(
        _chronicDiseaseTypeController.text.trim(),
      ),
      livesWithBeneficiary: drift.Value(_livesWithBeneficiary),
      phone: drift.Value(_phoneController.text.trim()),
      syncState: const drift.Value('pending'),
      serverId: const drift.Value(null),
      lastSyncedAt: const drift.Value(null),
      createdAt: widget.existingMember != null
          ? drift.Value(widget.existingMember!.createdAt)
          : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
    );

    try {
      if (widget.existingMember != null) {
        final updateCompanion = FamilyMembersTableCompanion(
          id: drift.Value(widget.existingMember!.id),
          fullName: drift.Value(_nameController.text.trim()),
          relationship: drift.Value(_selectedRelationship!),
          gender: drift.Value(_selectedGender ?? 'male'),
          nationalId: drift.Value(_nationalIdController.text.trim()),
          birthDate: drift.Value(_birthDate),
          age: _ageController.text.isNotEmpty
              ? drift.Value(int.tryParse(_ageController.text))
              : const drift.Value(null),
          maritalStatus: drift.Value(_selectedMaritalStatus),
          educationLevel: drift.Value(_selectedEducation),
          occupation: drift.Value(_selectedOccupation),
          healthStatus: drift.Value(_selectedHealthStatus),
          hasDisability: drift.Value(_hasDisability),
          disabilityType: drift.Value(_disabilityTypeController.text.trim()),
          hasChronicDisease: drift.Value(_hasChronicDisease),
          chronicDiseaseType: drift.Value(
            _chronicDiseaseTypeController.text.trim(),
          ),
          livesWithBeneficiary: drift.Value(_livesWithBeneficiary),
          phone: drift.Value(_phoneController.text.trim()),
          updatedAt: drift.Value(DateTime.now()),
        );
        await (database.update(database.familyMembersTable)
              ..where((t) => t.id.equals(widget.existingMember!.id)))
            .write(updateCompanion);
      } else {
        await dao.addMember(companion);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الحفظ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMember != null ? 'تعديل بيانات فرد' : 'إضافة فرد',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveMember),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // المعلومات الأساسية
            _buildSectionHeader('المعلومات الأساسية'),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'صلة القرابة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items: _relationships
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRelationship = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('ذكر')),
                      DropdownMenuItem(value: 'female', child: Text('أنثى')),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nationalIdController,
                    decoration: const InputDecoration(
                      labelText: 'الرقم الوطني',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الميلاد',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر التاريخ',
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'العمر',
                      border: OutlineInputBorder(),
                      suffixText: 'سنة',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'الهاتف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // المعلومات الاجتماعية
            _buildSectionHeader('المعلومات الاجتماعية'),

            DropdownButtonFormField<String>(
              value: _selectedMaritalStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة الاجتماعية',
                border: OutlineInputBorder(),
              ),
              items: _maritalStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMaritalStatus = v),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedEducation,
              decoration: const InputDecoration(
                labelText: 'المستوى التعليمي',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: _educationLevels
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEducation = v),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _selectedOccupation,
              decoration: const InputDecoration(
                labelText: 'المهنة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              onChanged: (v) => _selectedOccupation = v,
            ),
            const SizedBox(height: 24),

            // المعلومات الصحية
            _buildSectionHeader('المعلومات الصحية'),

            DropdownButtonFormField<String>(
              value: _selectedHealthStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة الصحية',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              items: _healthStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedHealthStatus = v),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('يعاني من إعاقة'),
              value: _hasDisability,
              onChanged: (v) => setState(() => _hasDisability = v),
            ),
            if (_hasDisability)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _disabilityTypeController,
                  decoration: const InputDecoration(
                    labelText: 'نوع الإعاقة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            SwitchListTile(
              title: const Text('يعاني من مرض مزمن'),
              value: _hasChronicDisease,
              onChanged: (v) => setState(() => _hasChronicDisease = v),
            ),
            if (_hasChronicDisease)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _chronicDiseaseTypeController,
                  decoration: const InputDecoration(
                    labelText: 'نوع المرض المزمن',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // معلومات السكن
            _buildSectionHeader('معلومات السكن'),

            SwitchListTile(
              title: const Text('يعيش مع المستفيد'),
              value: _livesWithBeneficiary,
              onChanged: (v) => setState(() => _livesWithBeneficiary = v),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _saveMember,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
