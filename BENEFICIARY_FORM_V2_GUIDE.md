# 🎨 Beneficiary Form V2 - دليل الاستخدام

## ✅ التحسينات المنفذة

### 1. **Responsive Design** 📱
- استخدام `flutter_screenutil` بشكل كامل (`.w`, `.h`, `.r`, `.sp`)
- تصميم يتناسب مع جميع أحجام الشاشات
- استخدام responsive utilities

### 2. **Separated Widgets** 🧩
- فصل كل widget لملف مستقل
- إمكانية إعادة استخدام الـ widgets في صفحات أخرى
- تنظيم واضح: `core/`, `tabs/`, `components/`

### 3. **Modern Icons & Design** ✨
- استخدام `_rounded` variants للأيقونات (Icons.person_rounded)
- Material 3 design system
- Rounded corners في كل المكونات (12.r, 16.r)
- Filled buttons مع تأثيرات حديثة

### 4. **High Performance** ⚡
- `AutomaticKeepAliveClientMixin` للحفاظ على حالة التبويبات
- `const` widgets حيثما أمكن
- Form validation مع `GlobalKey`
- `NeverScrollableScrollPhysics` للـ TabBarView (منع scroll غير ضروري)

### 5. **Clean Architecture** 🏗️
- فصل UI عن Business Logic
- Controllers محلية للنماذج
- State management واضح

---

## 📁 هيكل الملفات

```
lib/features/beneficiaries/presentation/
├── pages/
│   └── beneficiary_form_page_v2.dart       # الصفحة الرئيسية
├── widgets/
│   └── v2/
│       ├── v2_widgets.dart                 # Export file
│       ├── v2_app_bar.dart                 # AppBar مع save indicator
│       ├── v2_confirm_dialog.dart          # Confirmation dialogs
│       ├── v2_loading_indicator.dart       # Loading state
│       ├── v2_error_banner.dart            # Error banner
│       ├── v2_form_actions.dart            # Bottom action buttons
│       ├── tabs/
│       │   ├── v2_basic_info_tab.dart      # معلومات أساسية
│       │   ├── v2_family_info_tab.dart     # معلومات عائلية
│       │   ├── v2_contact_info_tab.dart    # معلومات اتصال
│       │   ├── v2_additional_info_tab.dart # معلومات إضافية
│       │   └── v2_notes_tab.dart           # ملاحظات
│       └── components/
│           ├── v2_custom_text_field.dart   # Text field محسّن
│           ├── v2_dropdown_field.dart      # Dropdown محسّن
│           ├── v2_section_card.dart        # Section wrapper
│           └── v2_switch_tile.dart         # Switch with label
```

---

## 🎯 الـ Widgets المتاحة

### Core Widgets

#### V2BeneficiaryAppBar
```dart
V2BeneficiaryAppBar(
  title: 'إضافة مستفيد',
  canSave: true,
  isSaving: false,
  onSave: () => _handleSave(),
  onDelete: () => _handleDelete(),
)
```

#### V2ConfirmDialog
```dart
showDialog(
  context: context,
  builder: (context) => V2ConfirmDialog(
    title: 'حذف مستفيد',
    message: 'هل أنت متأكد من الحذف؟',
    confirmText: 'حذف',
    cancelText: 'إلغاء',
    isDangerous: true,
    icon: Icons.delete_forever_rounded,
    onConfirm: () => _delete(),
  ),
)
```

#### V2LoadingIndicator
```dart
V2LoadingIndicator(
  message: 'جاري التحميل...',
  size: 40,
)
```

#### V2ErrorBanner
```dart
V2ErrorBanner(
  message: 'حدث خطأ ما',
  onDismiss: () => _clearError(),
  onRetry: () => _retry(),
)
```

#### V2FormActions
```dart
V2FormActions(
  canSave: true,
  isSaving: false,
  onSave: () => _save(),
  onCancel: () => _cancel(),
  onDelete: () => _delete(),
)
```

### Tab Widgets

#### V2BasicInfoTab
```dart
V2BasicInfoTab(
  firstNameController: _firstNameController,
  fatherNameController: _fatherNameController,
  grandfatherNameController: _grandfatherNameController,
  lastNameController: _lastNameController,
  motherNameController: _motherNameController,
  nationalIdController: _nationalIdController,
  birthDateController: _birthDateController,
  selectedGender: _selectedGender,
  onGenderChanged: (value) => setState(() => _selectedGender = value),
  onBirthDateTap: () => _selectDate(context),
)
```

#### V2FamilyInfoTab
```dart
V2FamilyInfoTab(
  selectedMaritalStatus: _selectedMaritalStatus,
  onMaritalStatusChanged: (value) => setState(() => _selectedMaritalStatus = value),
  numberOfChildrenController: _numberOfChildrenController,
  numberOfDependentsController: _numberOfDependentsController,
  spouseNameController: _spouseNameController,
)
```

#### V2ContactInfoTab
```dart
V2ContactInfoTab(
  phoneController: _phoneController,
  addressController: _addressController,
  neighborhoodController: _neighborhoodController,
  cityController: _cityController,
)
```

#### V2AdditionalInfoTab
```dart
V2AdditionalInfoTab(
  selectedEducationLevel: _selectedEducationLevel,
  onEducationLevelChanged: (value) => setState(() => _selectedEducationLevel = value),
  selectedEmploymentStatus: _selectedEmploymentStatus,
  onEmploymentStatusChanged: (value) => setState(() => _selectedEmploymentStatus = value),
  hasDisability: _hasDisability,
  onDisabilityChanged: (value) => setState(() => _hasDisability = value),
  isOrphan: _isOrphan,
  onOrphanChanged: (value) => setState(() => _isOrphan = value),
  disabilityTypeController: _disabilityTypeController,
  incomeController: _incomeController,
)
```

#### V2NotesTab
```dart
V2NotesTab(
  notesController: _notesController,
)
```

### Component Widgets

#### V2CustomTextField
```dart
V2CustomTextField(
  controller: _controller,
  label: 'الاسم',
  hint: 'أدخل الاسم',
  prefixIcon: Icons.person_rounded,
  isRequired: true,
  validator: (value) => value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
  keyboardType: TextInputType.text,
  maxLines: 1,
  readOnly: false,
)
```

#### V2DropdownField
```dart
V2DropdownField<String>(
  value: _selectedValue,
  label: 'الجنس',
  prefixIcon: Icons.wc_rounded,
  isRequired: true,
  onChanged: (value) => setState(() => _selectedValue = value),
  validator: (value) => value == null ? 'الحقل مطلوب' : null,
  items: const [
    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
  ],
)
```

#### V2SectionCard
```dart
V2SectionCard(
  title: 'معلومات أساسية',
  icon: Icons.person_rounded,
  children: [
    V2CustomTextField(...),
    SizedBox(height: 12.h),
    V2CustomTextField(...),
  ],
)
```

#### V2SwitchTile
```dart
V2SwitchTile(
  title: 'من ذوي الاحتياجات الخاصة',
  subtitle: 'يوجد إعاقة',
  value: _hasDisability,
  onChanged: (value) => setState(() => _hasDisability = value),
  icon: Icons.accessible_rounded,
)
```

---

## 🚀 كيفية الاستخدام

### 1. استيراد الـ Widgets
```dart
import '../widgets/v2/v2_widgets.dart';
```

### 2. إنشاء Controllers
```dart
final _firstNameController = TextEditingController();
String? _selectedGender;
bool _hasDisability = false;
```

### 3. استخدام الـ Widgets
```dart
V2BasicInfoTab(
  firstNameController: _firstNameController,
  selectedGender: _selectedGender,
  onGenderChanged: (value) => setState(() => _selectedGender = value),
  ...
)
```

### 4. Form Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      V2CustomTextField(
        controller: _controller,
        validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
      ),
    ],
  ),
)

// عند الحفظ
if (_formKey.currentState!.validate()) {
  // Save logic
}
```

---

## ⚙️ التخصيص

### تغيير الألوان
الـ widgets تستخدم `Theme.of(context).colorScheme` تلقائياً:
- `primary`: اللون الأساسي
- `error`: لون الأخطاء
- `surface`: خلفية
- `surfaceContainerLow`: خلفية الكروت

### تغيير الأحجام
استخدم `.w`, `.h`, `.r`, `.sp` من `flutter_screenutil`:
```dart
fontSize: 16.sp,  // Scaled font size
padding: 12.r,    // Scaled padding
width: 100.w,     // Scaled width
height: 50.h,     // Scaled height
```

### إضافة validators جديدة
```dart
String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'الحقل مطلوب';
  if (!RegExp(r'^09\d{8}$').hasMatch(value)) return 'رقم غير صحيح';
  return null;
}

V2CustomTextField(
  validator: _validatePhone,
  ...
)
```

---

## 🔧 التطوير المستقبلي

### إضافة widget جديد
1. أنشئ ملف في المجلد المناسب (`core/`, `tabs/`, `components/`)
2. استخدم `flutter_screenutil` للأبعاد
3. استخدم `_rounded` icons
4. أضف التصدير في `v2_widgets.dart`

### مثال
```dart
// components/v2_date_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class V2DatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  
  const V2DatePicker({
    super.key,
    required this.controller,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return V2CustomTextField(
      controller: controller,
      label: label,
      prefixIcon: Icons.calendar_today_rounded,
      readOnly: true,
      onTap: () => _showDatePicker(context),
    );
  }
  
  Future<void> _showDatePicker(BuildContext context) async {
    // Implementation
  }
}
```

---

## 📝 Notes

### Performance Tips
- استخدم `const` constructors
- استخدم `AutomaticKeepAliveClientMixin` للتبويبات
- استخدم `NeverScrollableScrollPhysics` للـ TabBarView
- تجنب rebuilds غير ضرورية

### Responsive Tips
- استخدم `.sp` للخطوط
- استخدم `.r` للـ border radius
- استخدم `.w` و `.h` للأبعاد
- اختبر على أحجام شاشات مختلفة

### Accessibility Tips
- أضف labels واضحة
- استخدم semantic colors من theme
- أضف tooltips للأيقونات
- اختبر مع screen readers

---

## ✅ Checklist للإطلاق

- [x] إنشاء جميع الـ widgets الأساسية
- [x] إضافة responsive design
- [x] استخدام modern icons
- [x] تحسين الأداء
- [x] Form validation
- [ ] اختبار على أجهزة مختلفة
- [ ] اختبار accessibility
- [ ] مراجعة الأكواد
- [ ] توثيق API endpoints (إذا لزم)
- [ ] Migration من الصفحة القديمة

---

## 🎉 النتيجة

صفحة **حديثة، responsive، عالية الأداء** مع:
- ✅ تصميم Material 3
- ✅ Responsive على جميع الأحجام
- ✅ Widgets قابلة لإعادة الاستخدام
- ✅ Performance محسّن
- ✅ Code نظيف وموثّق

---

تم التطوير بواسطة GitHub Copilot 🚀
