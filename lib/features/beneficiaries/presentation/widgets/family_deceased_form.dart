import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';
import '../../../../core/utils/family_enums.dart';
import '../../../../core/utils/ux_helpers.dart';

class FamilyDeceasedForm extends ConsumerStatefulWidget {
  final int beneficiaryId;
  final FamilyDeceased? existingDeceased;
  final VoidCallback onSaved;
  final int? presetDeceasedType; // لتحديد نوع المتوفى مسبقاً (1=أب، 2=أم)

  const FamilyDeceasedForm({
    super.key,
    required this.beneficiaryId,
    this.existingDeceased,
    required this.onSaved,
    this.presetDeceasedType,
  });

  @override
  ConsumerState<FamilyDeceasedForm> createState() => _FamilyDeceasedFormState();
}

class _FamilyDeceasedFormState extends ConsumerState<FamilyDeceasedForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _thirdNameController;
  late TextEditingController _familyNameController;
  late TextEditingController _nationalIdController;
  late TextEditingController _notesController;

  int? _selectedDeceasedType;
  int? _selectedDeathCause;
  int? _selectedDocumentType;
  DateTime? _deathDate;
  String? _documentPath;

  @override
  void initState() {
    super.initState();
    final deceased = widget.existingDeceased;
    _firstNameController = TextEditingController(text: deceased?.firstName);
    _secondNameController = TextEditingController(text: deceased?.secondName);
    _thirdNameController = TextEditingController(text: deceased?.thirdName);
    _familyNameController = TextEditingController(text: deceased?.familyName);
    _nationalIdController = TextEditingController(
      text: deceased != null ? deceased.nationalId.toString() : '',
    );
    _notesController = TextEditingController(text: deceased?.notes);
    // إذا كان هناك قيمة محددة مسبقاً، استخدمها
    _selectedDeceasedType = widget.presetDeceasedType ?? deceased?.deceasedType;
    _selectedDeathCause = deceased?.deathCause;
    _selectedDocumentType = deceased?.documentType;
    _deathDate = deceased?.deathDate;
    _documentPath = deceased?.documentPath;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
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

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _documentPath = result.files.single.path);
    }
  }

  Future<void> _saveDeceased() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deathDate == null) {
      ToastHelper.showError('الرجاء اختيار تاريخ الوفاة');
      return;
    }

    final database = ref.read(databaseProvider);
    final dao = database.familyDeceasedDao;

    final companion = FamilyDeceasedTableCompanion(
      id: widget.existingDeceased != null ? drift.Value(widget.existingDeceased!.id) : const drift.Value.absent(),
      beneficiaryId: drift.Value(widget.beneficiaryId),
      deceasedType: drift.Value(_selectedDeceasedType!),
      firstName: drift.Value(_firstNameController.text.trim()),
      secondName: _secondNameController.text.trim().isEmpty
          ? const drift.Value(null)
          : drift.Value(_secondNameController.text.trim()),
      thirdName: _thirdNameController.text.trim().isEmpty
          ? const drift.Value(null)
          : drift.Value(_thirdNameController.text.trim()),
      familyName: drift.Value(_familyNameController.text.trim()),
      nationalId: drift.Value(int.parse(_nationalIdController.text.trim())),
      deathDate: drift.Value(_deathDate!),
      deathCause: drift.Value(_selectedDeathCause ?? DeathCause.unknown),
      documentType: _selectedDocumentType != null ? drift.Value(_selectedDocumentType) : const drift.Value(null),
      documentPath: _documentPath != null ? drift.Value(_documentPath) : const drift.Value(null),
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
          deceasedType: drift.Value(_selectedDeceasedType!),
          firstName: drift.Value(_firstNameController.text.trim()),
          secondName: _secondNameController.text.trim().isEmpty
              ? const drift.Value(null)
              : drift.Value(_secondNameController.text.trim()),
          thirdName: _thirdNameController.text.trim().isEmpty
              ? const drift.Value(null)
              : drift.Value(_thirdNameController.text.trim()),
          familyName: drift.Value(_familyNameController.text.trim()),
          nationalId: drift.Value(int.parse(_nationalIdController.text.trim())),
          deathDate: drift.Value(_deathDate!),
          deathCause: drift.Value(_selectedDeathCause ?? DeathCause.unknown),
          documentType: _selectedDocumentType != null ? drift.Value(_selectedDocumentType) : const drift.Value(null),
          documentPath: _documentPath != null ? drift.Value(_documentPath) : const drift.Value(null),
          notes: drift.Value(_notesController.text.trim()),
          updatedAt: drift.Value(DateTime.now()),
        );
        await (database.update(database.familyDeceasedTable)..where((t) => t.id.equals(widget.existingDeceased!.id)))
            .write(updateCompanion);
      } else {
        await dao.addDeceased(companion);
      }

      if (mounted) {
        ToastHelper.showSuccess('تم الحفظ بنجاح');
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError('خطأ في الحفظ: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingDeceased != null ? 'تعديل بيانات متوفى' : 'إضافة متوفى',
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
            // نوع المتوفى (أب/أم) - اخفيه إذا كان محدد مسبقاً
            if (widget.presetDeceasedType == null)
              DropdownButtonFormField<int>(
                value: _selectedDeceasedType,
                decoration: const InputDecoration(
                  labelText: 'نوع المتوفى *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                items: const [
                  DropdownMenuItem(
                    value: DeceasedType.father,
                    child: Text('أب'),
                  ),
                  DropdownMenuItem(
                    value: DeceasedType.mother,
                    child: Text('أم'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedDeceasedType = value),
                validator: (value) {
                  if (value == null) return 'الرجاء اختيار نوع المتوفى';
                  return null;
                },
              ),
            if (widget.presetDeceasedType == null) const SizedBox(height: 16),

            // الاسم الأول
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الأول *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم الأول';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // اسم الأب
            TextFormField(
              controller: _secondNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الأب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // اسم الجد
            TextFormField(
              controller: _thirdNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الجد',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // اسم العائلة
            TextFormField(
              controller: _familyNameController,
              decoration: const InputDecoration(
                labelText: 'اسم العائلة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم العائلة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // رقم الهوية
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'رقم الهوية *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              maxLength: 9,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهوية';
                }
                if (value.trim().length != 9) {
                  return 'رقم الهوية يجب أن يكون 9 أرقام';
                }
                final parsedValue = int.tryParse(value.trim());
                if (parsedValue == null) {
                  return 'رقم الهوية يجب أن يحتوي على أرقام فقط';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // تاريخ الوفاة
            InkWell(
              onTap: _selectDeathDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الوفاة *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _deathDate != null
                      ? '${_deathDate!.year}-${_deathDate!.month.toString().padLeft(2, '0')}-${_deathDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر التاريخ',
                  style: TextStyle(
                    color: _deathDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // سبب الوفاة
            DropdownButtonFormField<int>(
              value: _selectedDeathCause,
              decoration: const InputDecoration(
                labelText: 'سبب الوفاة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
              ),
              items: const [
                DropdownMenuItem(
                  value: DeathCause.natural,
                  child: Text('طبيعية'),
                ),
                DropdownMenuItem(value: DeathCause.disease, child: Text('مرض')),
                DropdownMenuItem(value: DeathCause.sudden, child: Text('فجأة')),
                DropdownMenuItem(
                  value: DeathCause.accident,
                  child: Text('حادث'),
                ),
                DropdownMenuItem(value: DeathCause.other, child: Text('أخرى')),
                DropdownMenuItem(
                  value: DeathCause.suicide,
                  child: Text('انتحار'),
                ),
                DropdownMenuItem(
                  value: DeathCause.murdered,
                  child: Text('مغدور'),
                ),
                DropdownMenuItem(
                  value: DeathCause.unknown,
                  child: Text('غير معروف'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedDeathCause = value),
            ),
            const SizedBox(height: 16),

            // نوع الوثيقة
            DropdownButtonFormField<int>(
              value: _selectedDocumentType,
              decoration: const InputDecoration(
                labelText: 'نوع الوثيقة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              items: const [
                DropdownMenuItem(
                  value: DocumentType.deathCertificate,
                  child: Text('شهادة وفاة'),
                ),
                DropdownMenuItem(
                  value: DocumentType.martyrCertificate,
                  child: Text('إفادة شهيد'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedDocumentType = value),
            ),
            const SizedBox(height: 16),

            // رفع الوثيقة
            OutlinedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _documentPath != null ? 'تم رفع الوثيقة' : 'رفع وثيقة',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: _documentPath != null ? Colors.green : null,
              ),
            ),
            if (_documentPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'الملف: ${_documentPath!.split('/').last}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
