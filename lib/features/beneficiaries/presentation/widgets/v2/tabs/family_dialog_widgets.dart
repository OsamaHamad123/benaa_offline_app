import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 📦 Shared Widgets for Family Member Dialogs
///
/// Widgets قابلة لإعادة الاستخدام لتقليل التكرار

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Name Fields Row
// ═══════════════════════════════════════════════════════════════════════════

class NameFieldsSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController thirdNameController;
  final TextEditingController familyNameController;
  final FocusNode? firstNameFocus;
  final FocusNode? secondNameFocus;
  final FocusNode? thirdNameFocus;
  final FocusNode? familyNameFocus;

  const NameFieldsSection({
    super.key,
    required this.firstNameController,
    required this.secondNameController,
    required this.thirdNameController,
    required this.familyNameController,
    this.firstNameFocus,
    this.secondNameFocus,
    this.thirdNameFocus,
    this.familyNameFocus,
  });

  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'الاسم الكامل',
      icon: Icons.person_rounded,
      children: [
        ResponsiveFormLayout(
          children: [
            M3TextField(
              controller: firstNameController,
              label: 'الاسم الأول',
              prefixIcon: Icons.person_rounded,
              isRequired: true,
              focusNode: firstNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
            M3TextField(
              controller: secondNameController,
              label: 'اسم الأب',
              prefixIcon: Icons.person_outline_rounded,
              focusNode: secondNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.0),
        ResponsiveFormLayout(
          children: [
            M3TextField(
              controller: thirdNameController,
              label: 'اسم الجد',
              prefixIcon: Icons.elderly_rounded,
              focusNode: thirdNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
            M3TextField(
              controller: familyNameController,
              label: 'اللقب',
              prefixIcon: Icons.family_restroom_rounded,
              isRequired: true,
              focusNode: familyNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🆔 National ID Field with Civil Registry
// ═══════════════════════════════════════════════════════════════════════════

class NationalIdWithCivilRegistry extends StatelessWidget {
  final TextEditingController nationalIdController;
  final bool isFetching;
  final String? statusMessage;
  final VoidCallback onFetch;
  final ValueChanged<String> onChanged;
  final bool hideButtonAfterFetch;

  const NationalIdWithCivilRegistry({
    super.key,
    required this.nationalIdController,
    required this.isFetching,
    required this.statusMessage,
    required this.onFetch,
    required this.onChanged,
    this.hideButtonAfterFetch = false,
  });

  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'الرقم الوطني',
      icon: Icons.badge_rounded,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: M3TextField(
                controller: nationalIdController,
                label: 'الرقم الوطني',
                prefixIcon: Icons.badge,
                keyboardType: TextInputType.number,
                maxLength: 9,
                isRequired: true,
                onChanged: onChanged,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'مطلوب';
                  if (v!.length != 9) return '9 أرقام';
                  return null;
                },
              ),
            ),
            if (!hideButtonAfterFetch) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: FilledButton.tonalIcon(
                    onPressed: isFetching ? null : onFetch,
                    icon: isFetching
                        ? const SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search, size: 18.0),
                    label: const Text('بحث', style: TextStyle(fontSize: 11.0)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: 12.0),
          CivilRegistryStatus(message: statusMessage!),
        ],
      ],
    );
  }
}

class CivilRegistryStatus extends StatelessWidget {
  final String message;

  const CivilRegistryStatus({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.contains('✅');

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            size: 18.0,
            color: isSuccess ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 👥 Gender Selector
// ═══════════════════════════════════════════════════════════════════════════

class GenderSelector extends StatelessWidget {
  final int selectedGender;
  final ValueChanged<int> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الجنس *', style: TextStyle(fontSize: 13.0)),
        SizedBox(height: 8.0),
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
          selected: {selectedGender},
          onSelectionChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged(v.first);
          },
          style: ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📅 Date Picker Field
// ═══════════════════════════════════════════════════════════════════════════

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.icon = Icons.calendar_today,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) onDateSelected(date);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(icon, size: 20, color: iconColor),
        ),
        child: Text(
          selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'اضغط للاختيار',
          style: TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏥 Health Status Chips
// ═══════════════════════════════════════════════════════════════════════════

class HealthStatusSelector extends StatelessWidget {
  final int? selectedStatus;
  final ValueChanged<int> onStatusSelected;

  const HealthStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة الصحية',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            SelectableChip(
              label: 'سليم',
              value: 1,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.green,
            ),
            SelectableChip(
              label: 'مريض',
              value: 2,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.orange,
            ),
            SelectableChip(
              label: 'مزمن',
              value: 3,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.red,
            ),
            SelectableChip(
              label: 'معاق',
              value: 4,
              groupValue: selectedStatus,
              onTap: onStatusSelected,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💀 Death Cause Chips
// ═══════════════════════════════════════════════════════════════════════════

class DeathCauseSelector extends StatelessWidget {
  final int? selectedCause;
  final ValueChanged<int> onCauseSelected;

  const DeathCauseSelector({
    super.key,
    required this.selectedCause,
    required this.onCauseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سبب الوفاة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            SelectableChip(
              label: 'طبيعية',
              value: 1,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'مرض',
              value: 2,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'حادث',
              value: 4,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'مغدور',
              value: 7,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
            SelectableChip(
              label: 'أخرى',
              value: 5,
              groupValue: selectedCause,
              onTap: onCauseSelected,
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📄 Document Type Selector
// ═══════════════════════════════════════════════════════════════════════════

class DocumentTypeSelector extends StatelessWidget {
  final int? selectedType;
  final ValueChanged<int> onTypeSelected;

  const DocumentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الوثيقة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: DocumentCard(
                label: 'شهادة وفاة',
                icon: Icons.description,
                value: 1,
                groupValue: selectedType,
                onTap: onTypeSelected,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: DocumentCard(
                label: 'إفادة شهيد',
                icon: Icons.military_tech,
                value: 2,
                groupValue: selectedType,
                onTap: onTypeSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Reusable Chip Widget
// ═══════════════════════════════════════════════════════════════════════════

class SelectableChip extends StatelessWidget {
  final String label;
  final int value;
  final int? groupValue;
  final ValueChanged<int> onTap;
  final Color? color;

  const SelectableChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final chipColor = color ?? Colors.blue;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? chipColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📄 Document Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class DocumentCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final int? groupValue;
  final ValueChanged<int> onTap;

  const DocumentCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Notes Field
// ═══════════════════════════════════════════════════════════════════════════

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return M3TextField(
      controller: controller,
      label: 'ملاحظات',
      prefixIcon: Icons.note_rounded,
      maxLines: 2,
      maxLength: 200,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎬 Dialog Header
// ═══════════════════════════════════════════════════════════════════════════

class FamilyDialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onClose;

  const FamilyDialogHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎬 Dialog Footer
// ═══════════════════════════════════════════════════════════════════════════

class FamilyDialogFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const FamilyDialogFooter({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('إلغاء'),
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            flex: 2,
            child: ElevatedButton(onPressed: onSave, child: const Text('حفظ')),
          ),
        ],
      ),
    );
  }
}
