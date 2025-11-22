import 'package:flutter/material.dart';

/// 🎯 Form Constants - تجميع كل القيم الثابتة
///
/// يحتوي على جميع الأرقام السحرية والقيم الثابتة المستخدمة في النموذج

class FormConstants {
  FormConstants._();

  // ⏱️ Timing Constants
  static const civilRegistryDebounce = Duration(milliseconds: 500);
  static const autoSaveDebounce = Duration(seconds: 30);
  static const draftAutoSaveDuration = Duration(seconds: 10);
  static const snackBarDuration = Duration(seconds: 2);
  static const animationDuration = Duration(milliseconds: 300);
  static const fastAnimationDuration = Duration(milliseconds: 150);

  // 📏 Size Constants
  static const nationalIdLength = 9;
  static const maxFileSize = 5 * 1024 * 1024; // 5 MB
  static const maxFilesCount = 10;

  // 🎨 UI Constants
  static const defaultBorderRadius = 12.0;
  static const sectionCardElevation = 2.0;
  static const tabIconSize = 18.0;
  static const fabIconSize = 24.0;

  // 📱 Tab Configuration
  static const totalTabs = 4; // تقليل من 7 إلى 4

  // 🎯 Validation Messages
  static const requiredFieldMessage = '⚠️ الحقل مطلوب';
  static const invalidNationalIdMessage = '⚠️ يجب أن يكون الرقم الوطني 9 أرقام';
  static const invalidPhoneMessage = '⚠️ رقم الهاتف غير صحيح';
  static const invalidEmailMessage = '⚠️ البريد الإلكتروني غير صحيح';
  static const fileSizeExceededMessage = '⚠️ حجم الملف يتجاوز 5 ميغابايت';

  // ✅ Success Messages
  static const saveSuccessMessage = '✅ تم الحفظ بنجاح';
  static const deleteSuccessMessage = '✅ تم الحذف بنجاح';
  static const autofillSuccessMessage =
      '✅ تم ملء الحقول تلقائياً من السجل المدني';
  static const draftSavedMessage = '💾 تم حفظ المسودة';

  // 🔄 Loading Messages
  static const savingMessage = 'جاري الحفظ...';
  static const deletingMessage = 'جاري الحذف...';
  static const loadingMessage = 'جاري التحميل...';
  static const fetchingCivilRegistryMessage =
      'جاري جلب البيانات من السجل المدني...';

  // 🎹 Keyboard Shortcuts
  static const saveShortcut = 'Ctrl+S';
  static const nextTabShortcut = 'Ctrl+Tab';
  static const previousTabShortcut = 'Ctrl+Shift+Tab';
  static const undoShortcut = 'Ctrl+Z';
  static const redoShortcut = 'Ctrl+Y';
  static const newBeneficiaryShortcut = 'Ctrl+N';
}

/// 🎨 Tab Configuration
class TabConfig {
  final String title;
  final String fullTitle;
  final IconData icon;
  final int index;

  const TabConfig({
    required this.title,
    required this.fullTitle,
    required this.icon,
    required this.index,
  });
}

/// 📋 New 4-Tab Structure (Merged from 7 tabs)
class FormTabs {
  FormTabs._();

  static const List<TabConfig> tabs = [
    TabConfig(
      title: 'شخصي',
      fullTitle: 'معلومات شخصية',
      icon: Icons.person_rounded,
      index: 0,
    ),
    TabConfig(
      title: 'العائلة',
      fullTitle: 'معلومات العائلة والأفراد',
      icon: Icons.family_restroom_rounded,
      index: 1,
    ),
    TabConfig(
      title: 'التواصل',
      fullTitle: 'معلومات التواصل والملاحظات',
      icon: Icons.contact_phone_rounded,
      index: 2,
    ),
    TabConfig(
      title: 'المرفقات',
      fullTitle: 'المرفقات والمستندات',
      icon: Icons.attach_file_rounded,
      index: 3,
    ),
  ];
}

/// 📊 Field Dependencies Configuration
class FieldDependency {
  final String triggerField;
  final dynamic triggerValue;
  final List<String> dependentFields;
  final bool showWhenMatched;

  const FieldDependency({
    required this.triggerField,
    required this.triggerValue,
    required this.dependentFields,
    this.showWhenMatched = true,
  });
}

class FormFieldDependencies {
  FormFieldDependencies._();

  static const List<FieldDependency> dependencies = [
    // إذا اختار "يتيم" → يطلب تاريخ وفاة الوالد
    FieldDependency(
      triggerField: 'category',
      triggerValue: 'orphan',
      dependentFields: ['parent_death_date', 'guardian_name'],
    ),

    // إذا اختار "نازح" → يطلب محافظة النزوح
    FieldDependency(
      triggerField: 'category',
      triggerValue: 'displaced',
      dependentFields: [
        'displacement_province',
        'displacement_date',
        'address_before_displacement',
      ],
    ),

    // إذا اختار "متزوج" → يطلب معلومات الزوج/الزوجة
    FieldDependency(
      triggerField: 'marital_status',
      triggerValue: 'متزوج',
      dependentFields: ['spouse_name', 'marriage_date'],
    ),

    // إذا اختار "من ذوي الإعاقة" → يطلب نوع الإعاقة
    FieldDependency(
      triggerField: 'category',
      triggerValue: 'disabled',
      dependentFields: ['disability_type', 'disability_certificate'],
    ),
  ];
}

/// 🎨 Material 3 Color Schemes
class FormColors {
  FormColors._();

  // Tab Colors with gradients
  static final Map<int, List<Color>> tabGradients = {
    0: [Color(0xFF1976D2), Color(0xFF42A5F5)], // Blue - معلومات شخصية
    1: [Color(0xFF7B1FA2), Color(0xFFBA68C8)], // Purple - العائلة
    2: [Color(0xFF388E3C), Color(0xFF66BB6A)], // Green - التواصل
    3: [Color(0xFFE64A19), Color(0xFFFF7043)], // Orange - المرفقات
  };
}
