import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  const NameFieldsSection({
    super.key,
    required this.firstNameController,
    required this.secondNameController,
    required this.thirdNameController,
    required this.familyNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاسم الكامل',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _CompactTextField(
                controller: firstNameController,
                label: 'الأول *',
                isRequired: true,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _CompactTextField(
                controller: secondNameController,
                label: 'الأب',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _CompactTextField(
                controller: thirdNameController,
                label: 'الجد',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _CompactTextField(
                controller: familyNameController,
                label: 'العائلة *',
                isRequired: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const _CompactTextField({
    required this.controller,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: isRequired
          ? (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null
          : null,
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

  const NationalIdWithCivilRegistry({
    super.key,
    required this.nationalIdController,
    required this.isFetching,
    required this.statusMessage,
    required this.onFetch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني *',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.badge, size: 20),
                ),
                keyboardType: TextInputType.number,
                maxLength: 9,
                onChanged: onChanged,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'مطلوب';
                  if (v!.length != 9) return '9 أرقام';
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: isFetching ? null : onFetch,
                icon: isFetching
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.search, size: 18.sp),
                label: Text('بحث', style: TextStyle(fontSize: 11.sp)),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (statusMessage != null) ...[
          SizedBox(height: 8.h),
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
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: isSuccess ? Colors.green : Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            size: 16.sp,
            color: isSuccess ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 11.sp)),
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
        Text('الجنس *', style: TextStyle(fontSize: 13.sp)),
        SizedBox(height: 8.h),
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
      borderRadius: BorderRadius.circular(8.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(icon, size: 20, color: iconColor),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'اضغط للاختيار',
          style: TextStyle(fontSize: 14.sp),
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
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
            SizedBox(width: 8.w),
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
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
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
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
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
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'ملاحظات',
        border: OutlineInputBorder(),
        isDense: true,
      ),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('إلغاء'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(onPressed: onSave, child: const Text('حفظ')),
          ),
        ],
      ),
    );
  }
}
