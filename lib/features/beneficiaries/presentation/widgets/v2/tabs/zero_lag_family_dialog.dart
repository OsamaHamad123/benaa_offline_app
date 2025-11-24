import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// ⚡ ZERO LAG - Absolute Maximum Performance
///
/// Radical optimizations:
/// 1. NO ScreenUtil - direct MediaQuery
/// 2. NO decorations during typing
/// 3. Minimal widget tree
/// 4. Immediate keyboard response
class ZeroLagFamilyDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const ZeroLagFamilyDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  ConsumerState<ZeroLagFamilyDialog> createState() =>
      _ZeroLagFamilyDialogState();
}

class _ZeroLagFamilyDialogState extends ConsumerState<ZeroLagFamilyDialog> {
  // Controllers
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _secondNameCtrl;
  late final TextEditingController _thirdNameCtrl;
  late final TextEditingController _familyNameCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _notesCtrl;

  // ValueNotifiers
  late final ValueNotifier<int> _gender;
  late final ValueNotifier<DateTime?> _date;
  late final ValueNotifier<int?> _healthStatus;
  late final ValueNotifier<int?> _deathCause;
  late final ValueNotifier<int?> _docType;
  late final ValueNotifier<File?> _selectedFile;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;

    _firstNameCtrl = TextEditingController(text: m?['firstName']);
    _secondNameCtrl = TextEditingController(text: m?['secondName']);
    _thirdNameCtrl = TextEditingController(text: m?['thirdName']);
    _familyNameCtrl = TextEditingController(text: m?['familyName']);
    _nationalIdCtrl = TextEditingController(
      text: m?['nationalId']?.toString() ?? m?['orphanNationalId']?.toString(),
    );
    _notesCtrl = TextEditingController(text: m?['notes']);

    _gender = ValueNotifier<int>(m?['gender'] ?? 1);
    _date = ValueNotifier<DateTime?>(
      m?['birthDate'] as DateTime? ?? m?['deathDate'] as DateTime?,
    );
    _healthStatus = ValueNotifier<int?>(m?['healthStatus']);
    _deathCause = ValueNotifier<int?>(m?['deathCause']);
    _docType = ValueNotifier<int?>(m?['documentType']);
    _selectedFile = ValueNotifier<File?>(null);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _secondNameCtrl.dispose();
    _thirdNameCtrl.dispose();
    _familyNameCtrl.dispose();
    _nationalIdCtrl.dispose();
    _notesCtrl.dispose();
    _gender.dispose();
    _date.dispose();
    _healthStatus.dispose();
    _deathCause.dispose();
    _docType.dispose();
    _selectedFile.dispose();
    super.dispose();
  }

  /// Pick document file
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        _selectedFile.value = file;
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الملف: $e')));
      }
    }
  }

  void _save() {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _familyNameCtrl.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم الأول والعائلة')),
      );
      return;
    }

    final data = <String, dynamic>{
      'firstName': _firstNameCtrl.text.trim(),
      'secondName': _secondNameCtrl.text.trim(),
      'thirdName': _thirdNameCtrl.text.trim(),
      'familyName': _familyNameCtrl.text.trim(),
      'gender': _gender.value,
      'notes': _notesCtrl.text.trim(),
    };

    if (widget.isDeceased) {
      data.addAll({
        'deceasedType': widget.presetDeceasedType,
        'nationalId': int.tryParse(_nationalIdCtrl.text.trim()),
        'deathDate': _date.value ?? DateTime.now(),
        'deathCause': _deathCause.value ?? 8,
        'documentType': _docType.value,
        'documentFile': _selectedFile.value, // ملف الوثيقة
      });
    } else {
      data.addAll({
        'orphanNationalId': int.tryParse(_nationalIdCtrl.text.trim()),
        'birthDate': _date.value ?? DateTime.now(),
        'age': _date.value != null
            ? DateTime.now().difference(_date.value!).inDays ~/ 365
            : 0,
        'healthStatus': _healthStatus.value ?? 5,
      });
    }

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: size.width > 600 ? 500 : size.width - 32,
        constraints: BoxConstraints(maxHeight: size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isDeceased ? Icons.person_off : Icons.child_care,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isDeceased
                          ? (widget.presetDeceasedType == 1
                                ? 'إضافة أب متوفى'
                                : 'إضافة أم متوفاة')
                          : 'إضافة يتيم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name Fields
                  const Text(
                    'الاسم الكامل',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _FastField(_firstNameCtrl, 'الأول *')),
                      const SizedBox(width: 8),
                      Expanded(child: _FastField(_secondNameCtrl, 'الأب')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _FastField(_thirdNameCtrl, 'الجد')),
                      const SizedBox(width: 8),
                      Expanded(child: _FastField(_familyNameCtrl, 'العائلة *')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  ValueListenableBuilder<int>(
                    valueListenable: _gender,
                    builder: (_, gender, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الجنس *'),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 1,
                              label: Text('ذكر'),
                              icon: Icon(Icons.boy, size: 18),
                            ),
                            ButtonSegment(
                              value: 2,
                              label: Text('أنثى'),
                              icon: Icon(Icons.girl, size: 18),
                            ),
                          ],
                          selected: {gender},
                          onSelectionChanged: (v) {
                            HapticFeedback.selectionClick();
                            _gender.value = v.first;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // National ID
                  _FastField(
                    _nationalIdCtrl,
                    'الرقم الوطني (9 أرقام)',
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),

                  // Date
                  ValueListenableBuilder<DateTime?>(
                    valueListenable: _date,
                    builder: (context, date, _) => InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) _date.value = picked;
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: widget.isDeceased
                              ? 'تاريخ الوفاة'
                              : 'تاريخ الميلاد',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          date != null
                              ? '${date.day}/${date.month}/${date.year}'
                              : 'اضغط للاختيار',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conditional Fields
                  if (widget.isDeceased) ...[
                    ValueListenableBuilder<int?>(
                      valueListenable: _deathCause,
                      builder: (_, cause, __) => _ChipSelector(
                        label: 'سبب الوفاة',
                        options: const {
                          1: 'حرب',
                          2: 'مرض',
                          3: 'حادث',
                          8: 'أخرى',
                        },
                        selected: cause,
                        onSelect: (v) => _deathCause.value = v,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<int?>(
                      valueListenable: _docType,
                      builder: (_, type, __) => _ChipSelector(
                        label: 'نوع الوثيقة',
                        options: const {
                          1: 'شهادة وفاة',
                          2: 'تقرير طبي',
                          3: 'إفادة',
                        },
                        selected: type,
                        onSelect: (v) => _docType.value = v,
                      ),
                    ),
                  ] else ...[
                    ValueListenableBuilder<int?>(
                      valueListenable: _healthStatus,
                      builder: (_, status, __) => _ChipSelector(
                        label: 'الحالة الصحية',
                        options: const {
                          1: 'سليم',
                          2: 'مريض',
                          3: 'مزمن',
                          4: 'معاق',
                          5: 'غير محدد',
                        },
                        selected: status,
                        onSelect: (v) => _healthStatus.value = v,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Document Upload Section
                  if (widget.isDeceased) ...[
                    const Text(
                      'رفع الوثيقة',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<File?>(
                      valueListenable: _selectedFile,
                      builder: (context, file, _) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: file == null
                            ? InkWell(
                                onTap: _pickFile,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'اضغط لرفع الوثيقة (PDF, JPG, PNG)',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      file.path.split('/').last,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade700,
                                    ),
                                    onPressed: () {
                                      _selectedFile.value = null;
                                    },
                                    tooltip: 'حذف',
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ ZERO LAG TextField - Absolute Minimum Overhead
// ═══════════════════════════════════════════════════════════════════════════

class _FastField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int? maxLength;

  const _FastField(
    this.controller,
    this.label, {
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        counterText: '',
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ Fast Chip Selector
// ═══════════════════════════════════════════════════════════════════════════

class _ChipSelector extends StatelessWidget {
  final String label;
  final Map<int, String> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _ChipSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.entries.map((e) {
            final isSelected = selected == e.key;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(e.key);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
