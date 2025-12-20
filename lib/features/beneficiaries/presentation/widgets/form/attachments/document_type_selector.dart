import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Document Type Selector Widget
///
/// Dropdown منظم لاختيار نوع الوثيقة من قائمة محددة مسبقاً
/// حسب تصميم الموقع
class DocumentTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;
  final String? label;
  final bool isRequired;

  const DocumentTypeSelector({
    super.key,
    this.selectedType,
    required this.onChanged,
    this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: label ?? 'نوع الوثيقة ${isRequired ? '*' : ''}',
        prefixIcon: const Icon(Icons.description_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      items: _documentTypes.map((type) {
        return DropdownMenuItem(
          value: type.value,
          child: Row(
            children: [
              Icon(type.icon, size: 20.sp),
              SizedBox(width: 8.w),
              Text(type.label),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired ? (value) => value == null ? 'يرجى اختيار نوع الوثيقة' : null : null,
    );
  }

  /// قائمة أنواع الوثائق المتاحة (من الموقع)
  static final List<DocumentTypeItem> _documentTypes = [
    DocumentTypeItem(
      value: 'death_certificate',
      label: 'شهادة الوفاة',
      icon: Icons.person_off_rounded,
    ),
    DocumentTypeItem(
      value: 'national_id',
      label: 'إفادة شهيد',
      icon: Icons.military_tech_rounded,
    ),
    DocumentTypeItem(
      value: 'id_card',
      label: 'صورة الهوية',
      icon: Icons.credit_card_rounded,
    ),
    DocumentTypeItem(
      value: 'guardianship_letter',
      label: 'حجة الوصاية',
      icon: Icons.gavel_rounded,
    ),
    DocumentTypeItem(
      value: 'medical_report',
      label: 'تقرير طبي',
      icon: Icons.medical_information_rounded,
    ),
    DocumentTypeItem(
      value: 'custody_letter',
      label: 'إقرار الحضانة',
      icon: Icons.family_restroom_rounded,
    ),
    DocumentTypeItem(
      value: 'rent_receipt',
      label: 'حضر إيرات',
      icon: Icons.receipt_long_rounded,
    ),
    DocumentTypeItem(
      value: 'orphan_care',
      label: 'حجة اعالة يتيم',
      icon: Icons.child_care_rounded,
    ),
    DocumentTypeItem(
      value: 'birth_certificate',
      label: 'شهادة الميلاد',
      icon: Icons.cake_rounded,
    ),
    DocumentTypeItem(
      value: 'recent_certificate',
      label: 'آخر شهادة حصل عليها',
      icon: Icons.school_rounded,
    ),
    DocumentTypeItem(
      value: 'test',
      label: 'test',
      icon: Icons.science_rounded,
    ),
    DocumentTypeItem(
      value: 'personal_photo',
      label: 'صور شخصية',
      icon: Icons.photo_camera_rounded,
    ),
    DocumentTypeItem(
      value: 'other_documents',
      label: 'أوراق ثبوتية أخرى',
      icon: Icons.file_copy_rounded,
    ),
    DocumentTypeItem(
      value: 'welfare_agency',
      label: 'وكالة في شؤون الولاية',
      icon: Icons.business_rounded,
    ),
    DocumentTypeItem(
      value: 'transfer_document',
      label: 'حجة ترمل',
      icon: Icons.document_scanner_rounded,
    ),
    DocumentTypeItem(
      value: 'parenthood_document',
      label: 'حجة ولاية',
      icon: Icons.family_restroom_rounded,
    ),
    DocumentTypeItem(
      value: 'long_form_id',
      label: 'صورة طويلة',
      icon: Icons.badge_rounded,
    ),
    DocumentTypeItem(
      value: 'wallet_photo',
      label: 'صورة محفظة',
      icon: Icons.photo_album_rounded,
    ),
  ];
}

/// 📋 Document Type Item Model
class DocumentTypeItem {
  final String value;
  final String label;
  final IconData icon;

  const DocumentTypeItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// 👤 Person Type Selector (صاحب الملف / أفراد الأسرة / المتوفين)
class PersonTypeSelector extends StatelessWidget {
  final String? selectedPerson;
  final ValueChanged<String?> onChanged;
  final List<String> availablePersons;
  final String? label;

  const PersonTypeSelector({
    super.key,
    this.selectedPerson,
    required this.onChanged,
    required this.availablePersons,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: selectedPerson,
      decoration: InputDecoration(
        labelText: label ?? 'اختر الشخص *',
        prefixIcon: const Icon(Icons.person_pin_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      items: [
        const DropdownMenuItem(
          value: 'file_owner',
          child: Row(
            children: [
              Icon(Icons.account_circle_rounded),
              SizedBox(width: 8),
              Text('صاحب الملف'),
            ],
          ),
        ),
        if (availablePersons.isNotEmpty)
          const DropdownMenuItem(
            value: 'divider_family',
            enabled: false,
            child: Divider(),
          ),
        ...availablePersons.map((person) {
          return DropdownMenuItem(
            value: person,
            child: Row(
              children: [
                const Icon(Icons.family_restroom_rounded),
                SizedBox(width: 8.w),
                Expanded(child: Text(person)),
              ],
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
