import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';

class FamilyDeceasedForm extends ConsumerStatefulWidget {
  final int beneficiaryId;
  final FamilyDeceased? existingDeceased;
  final VoidCallback onSaved;

  const FamilyDeceasedForm({
    super.key,
    required this.beneficiaryId,
    this.existingDeceased,
    required this.onSaved,
  });

  @override
  ConsumerState<FamilyDeceasedForm> createState() => _FamilyDeceasedFormState();
}

class _FamilyDeceasedFormState extends ConsumerState<FamilyDeceasedForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _deathCauseController;
  late TextEditingController _ageController;
  late TextEditingController _notesController;

  String? _selectedRelationship;
  String? _selectedGender;
  DateTime? _deathDate;

  final List<String> _relationships = [
    'أب',
    'أم',
    'ابن',
    'ابنة',
    'أخ',
    'أخت',
    'جد',
    'جدة',
    'عم',
    'عمة',
    'خال',
    'خالة',
    'زوج',
    'زوجة',
    'آخر',
  ];

  @override
  void initState() {
    super.initState();
    final deceased = widget.existingDeceased;
    _nameController = TextEditingController(text: deceased?.fullName);
    _deathCauseController = TextEditingController(text: deceased?.deathCause);
    _ageController = TextEditingController(
      text: deceased?.ageAtDeath?.toString(),
    );
    _notesController = TextEditingController(text: deceased?.notes);
    _selectedRelationship = deceased?.relationship;
    _selectedGender = deceased?.gender;
    _deathDate = deceased?.deathDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deathCauseController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDeathDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deathDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _deathDate = picked);
    }
  }

  Future<void> _saveDeceased() async {
    if (!_formKey.currentState!.validate()) return;

    final database = ref.read(databaseProvider);
    final dao = database.familyDeceasedDao;

    final companion = FamilyDeceasedTableCompanion(
      id: widget.existingDeceased != null
          ? drift.Value(widget.existingDeceased!.id)
          : const drift.Value.absent(),
      beneficiaryId: drift.Value(widget.beneficiaryId),
      fullName: drift.Value(_nameController.text.trim()),
      relationship: drift.Value(_selectedRelationship!),
      gender: drift.Value(_selectedGender ?? 'male'),
      deathDate: drift.Value(_deathDate),
      deathCause: drift.Value(_deathCauseController.text.trim()),
      ageAtDeath: _ageController.text.isNotEmpty
          ? drift.Value(int.tryParse(_ageController.text))
          : const drift.Value(null),
      notes: drift.Value(_notesController.text.trim()),
      syncState: const drift.Value('pending'),
      serverId: const drift.Value(null),
      lastSyncedAt: const drift.Value(null),
      createdAt: widget.existingDeceased != null
          ? drift.Value(widget.existingDeceased!.createdAt)
          : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
    );

    try {
      if (widget.existingDeceased != null) {
        final updateCompanion = FamilyDeceasedTableCompanion(
          id: drift.Value(widget.existingDeceased!.id),
          fullName: drift.Value(_nameController.text.trim()),
          relationship: drift.Value(_selectedRelationship!),
          gender: drift.Value(_selectedGender ?? 'male'),
          deathDate: drift.Value(_deathDate),
          deathCause: drift.Value(_deathCauseController.text.trim()),
          ageAtDeath: _ageController.text.isNotEmpty
              ? drift.Value(int.tryParse(_ageController.text))
              : const drift.Value(null),
          notes: drift.Value(_notesController.text.trim()),
          updatedAt: drift.Value(DateTime.now()),
        );
        await (database.update(database.familyDeceasedTable)
              ..where((t) => t.id.equals(widget.existingDeceased!.id)))
            .write(updateCompanion);
      } else {
        await dao.addDeceased(companion);
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
          widget.existingDeceased != null
              ? 'تعديل بيانات متوفى'
              : 'إضافة متوفى',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDeceased),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // الاسم الكامل
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // صلة القرابة
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'صلة القرابة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items: _relationships.map((rel) {
                return DropdownMenuItem(value: rel, child: Text(rel));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedRelationship = value),
              validator: (value) {
                if (value == null) return 'الرجاء اختيار صلة القرابة';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الجنس
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'الجنس',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('ذكر')),
                DropdownMenuItem(value: 'female', child: Text('أنثى')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),

            // تاريخ الوفاة
            InkWell(
              onTap: _selectDeathDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الوفاة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _deathDate != null
                      ? '${_deathDate!.year}-${_deathDate!.month.toString().padLeft(2, '0')}-${_deathDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر التاريخ',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // سبب الوفاة
            TextFormField(
              controller: _deathCauseController,
              decoration: const InputDecoration(
                labelText: 'سبب الوفاة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // العمر عند الوفاة
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'العمر عند الوفاة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                suffixText: 'سنة',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 0 || age > 150) {
                    return 'الرجاء إدخال عمر صحيح (0-150)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ملاحظات
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: _saveDeceased,
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
}
