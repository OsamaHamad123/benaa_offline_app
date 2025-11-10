import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 📋 تكوين حقل نموذج
/// يجمع كل إعدادات TextField في مكان واحد
class FieldConfig {
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool required;

  const FieldConfig({
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.onChanged,
    this.textInputAction,
    this.required = false,
  });

  /// نسخة مع تعديلات
  FieldConfig copyWith({
    String? label,
    IconData? icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
    bool? readOnly,
    VoidCallback? onTap,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    bool? required,
  }) {
    return FieldConfig(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      hint: hint ?? this.hint,
      keyboardType: keyboardType ?? this.keyboardType,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      maxLines: maxLines ?? this.maxLines,
      readOnly: readOnly ?? this.readOnly,
      onTap: onTap ?? this.onTap,
      suffix: suffix ?? this.suffix,
      onChanged: onChanged ?? this.onChanged,
      textInputAction: textInputAction ?? this.textInputAction,
      required: required ?? this.required,
    );
  }

  /// Label مع علامة * للحقول المطلوبة
  String get displayLabel => required ? '$label *' : label;
}

/// 📦 Configs جاهزة للحقول الشائعة
class CommonFieldConfigs {
  // المعلومات الشخصية
  static const fullName = FieldConfig(
    label: 'الاسم الكامل',
    icon: Icons.person,
    hint: 'الاسم الثلاثي أو الرباعي',
    required: true,
  );

  static final nationalId = FieldConfig(
    label: 'الرقم الوطني',
    icon: Icons.credit_card,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    required: true,
  );

  static const fileNo = FieldConfig(
    label: 'رقم الملف',
    icon: Icons.folder,
    required: true,
  );

  static const birthDate = FieldConfig(
    label: 'تاريخ الميلاد',
    icon: Icons.cake,
    readOnly: true,
  );

  static const associationName = FieldConfig(
    label: 'اسم الجمعية',
    icon: Icons.business,
  );

  // معلومات العائلة
  static const motherName = FieldConfig(
    label: 'اسم الأم',
    icon: Icons.person,
    hint: 'الاسم الثلاثي',
  );

  static const fatherName = FieldConfig(
    label: 'اسم الأب',
    icon: Icons.person,
    hint: 'الاسم الثلاثي',
  );

  static const grandFatherName = FieldConfig(
    label: 'اسم الجد',
    icon: Icons.person,
    hint: 'الاسم الثلاثي',
  );

  static const familyName = FieldConfig(
    label: 'اللقب',
    icon: Icons.family_restroom,
  );

  // معلومات الاتصال
  static final phoneNumber = FieldConfig(
    label: 'رقم الهاتف',
    icon: Icons.phone,
    keyboardType: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    hint: '07XXXXXXXXX',
  );

  static final altPhoneNumber = FieldConfig(
    label: 'هاتف بديل',
    icon: Icons.phone_android,
    keyboardType: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static const governorate = FieldConfig(
    label: 'المحافظة',
    icon: Icons.location_city,
    required: true,
  );

  static const district = FieldConfig(label: 'القضاء/المدينة', icon: Icons.map);

  static const address = FieldConfig(
    label: 'العنوان التفصيلي',
    icon: Icons.home,
    maxLines: 2,
  );

  static const currentAddress = FieldConfig(
    label: 'العنوان الحالي',
    icon: Icons.location_on,
    maxLines: 2,
  );

  static const addressBeforeDisplacement = FieldConfig(
    label: 'العنوان قبل النزوح',
    icon: Icons.location_off,
    maxLines: 2,
  );

  // معلومات الأسرة
  static final familySize = FieldConfig(
    label: 'عدد أفراد الأسرة',
    icon: Icons.people,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static final numberOfMales = FieldConfig(
    label: 'عدد الذكور',
    icon: Icons.male,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static final numberOfFemales = FieldConfig(
    label: 'عدد الإناث',
    icon: Icons.female,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  // معلومات صحية
  static final chronicDiseasesCount = FieldConfig(
    label: 'عدد الأمراض المزمنة',
    icon: Icons.medical_services,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static final specialNeedsCount = FieldConfig(
    label: 'عدد ذوي الاحتياجات الخاصة',
    icon: Icons.accessible,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static const notes = FieldConfig(
    label: 'ملاحظات إضافية',
    icon: Icons.note_alt,
    maxLines: 5,
    hint: 'أي معلومات إضافية عن المستفيد...',
  );
}

/// 📋 Dropdown config
class DropdownConfig<T> {
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final bool required;

  const DropdownConfig({
    required this.label,
    required this.icon,
    required this.items,
    this.required = false,
  });

  String get displayLabel => required ? '$label *' : label;
}

/// 📦 Dropdown configs جاهزة
class CommonDropdownConfigs {
  static const gender = DropdownConfig<String>(
    label: 'الجنس',
    icon: Icons.wc,
    required: true,
    items: [
      DropdownMenuItem(value: 'male', child: Text('ذكر')),
      DropdownMenuItem(value: 'female', child: Text('أنثى')),
    ],
  );

  static const category = DropdownConfig<String>(
    label: 'الفئة',
    icon: Icons.category,
    required: true,
    items: [
      DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
      DropdownMenuItem(value: 'widow', child: Text('أرملة')),
      DropdownMenuItem(value: 'poor', child: Text('فقير')),
      DropdownMenuItem(value: 'disabled', child: Text('معاق')),
    ],
  );

  static const maritalStatus = DropdownConfig<String?>(
    label: 'الحالة الاجتماعية',
    icon: Icons.family_restroom,
    items: [
      DropdownMenuItem(value: null, child: Text('غير محدد')),
      DropdownMenuItem(value: 'single', child: Text('أعزب/عزباء')),
      DropdownMenuItem(value: 'married', child: Text('متزوج/ة')),
      DropdownMenuItem(value: 'divorced', child: Text('مطلق/ة')),
      DropdownMenuItem(value: 'widowed', child: Text('أرمل/ة')),
    ],
  );

  static const educationLevel = DropdownConfig<String?>(
    label: 'المستوى التعليمي',
    icon: Icons.school,
    items: [
      DropdownMenuItem(value: null, child: Text('غير محدد')),
      DropdownMenuItem(value: 'none', child: Text('أمي')),
      DropdownMenuItem(value: 'primary', child: Text('ابتدائية')),
      DropdownMenuItem(value: 'secondary', child: Text('متوسطة')),
      DropdownMenuItem(value: 'high_school', child: Text('إعدادية')),
      DropdownMenuItem(value: 'diploma', child: Text('دبلوم')),
      DropdownMenuItem(value: 'bachelor', child: Text('بكالوريوس')),
      DropdownMenuItem(value: 'master', child: Text('ماجستير')),
      DropdownMenuItem(value: 'phd', child: Text('دكتوراه')),
    ],
  );

  static const healthStatus = DropdownConfig<String>(
    label: 'الحالة الصحية العامة',
    icon: Icons.favorite,
    items: [
      DropdownMenuItem(value: 'good', child: Text('جيدة')),
      DropdownMenuItem(value: 'fair', child: Text('متوسطة')),
      DropdownMenuItem(value: 'poor', child: Text('ضعيفة')),
    ],
  );
}
