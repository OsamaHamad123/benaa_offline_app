/// 📘 دليل استخدام AnimatedFormField في التابات
///
/// هذا الملف يوضح كيفية استبدال TextFormField العادي بـ AnimatedFormField
/// لإضافة focus animations جميلة
library;

import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/animated_form_fields.dart';
import 'package:flutter/material.dart';

/// مثال 1: استبدال TextField بسيط
class BeforeAfterExample1 {
  // ❌ قبل - TextField عادي بدون animations
  Widget oldTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'الاسم الكامل',
        prefixIcon: Icon(Icons.person),
        hintText: 'أدخل الاسم',
      ),
      validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
    );
  }

  // ✅ بعد - AnimatedFormField مع focus animation
  Widget newTextField(TextEditingController controller) {
    return AnimatedFormField(
      controller: controller,
      labelText: 'الاسم الكامل',
      prefixIcon: Icons.person,
      hintText: 'أدخل الاسم',
      validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
    );
  }
}

/// مثال 2: حقل مع suffix icon
class BeforeAfterExample2 {
  // ❌ قبل
  Widget oldDateField(TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        prefixIcon: const Icon(Icons.calendar_today),
        suffix: IconButton(icon: const Icon(Icons.event), onPressed: onTap),
      ),
    );
  }

  // ✅ بعد
  Widget newDateField(TextEditingController controller, VoidCallback onTap) {
    return AnimatedFormField(
      controller: controller,
      labelText: 'تاريخ الميلاد',
      prefixIcon: Icons.calendar_today,
      readOnly: true,
      onTap: onTap,
      suffix: IconButton(icon: const Icon(Icons.event), onPressed: onTap),
    );
  }
}

/// مثال 3: حقل متعدد الأسطر
class BeforeAfterExample3 {
  // ❌ قبل
  Widget oldNotesField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'ملاحظات',
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
    );
  }

  // ✅ بعد
  Widget newNotesField(TextEditingController controller) {
    return AnimatedFormField(
      controller: controller,
      labelText: 'ملاحظات',
      prefixIcon: Icons.notes,
      maxLines: 4,
    );
  }
}

/// مثال 4: Dropdown field
class BeforeAfterExample4 {
  // ❌ قبل
  Widget oldDropdown(String? value, ValueChanged<String?>? onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'الفئة',
        prefixIcon: Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
        DropdownMenuItem(value: 'widow', child: Text('أرملة')),
        DropdownMenuItem(value: 'poor', child: Text('فقير')),
      ],
    );
  }

  // ✅ بعد
  Widget newDropdown(String? value, ValueChanged<String?>? onChanged) {
    return AnimatedDropdownField<String>(
      value: value,
      labelText: 'الفئة',
      prefixIcon: Icons.category,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
        DropdownMenuItem(value: 'widow', child: Text('أرملة')),
        DropdownMenuItem(value: 'poor', child: Text('فقير')),
      ],
    );
  }
}

/// مثال 5: حقل رقمي
class BeforeAfterExample5 {
  // ❌ قبل
  Widget oldNumberField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'العمر',
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  // ✅ بعد
  Widget newNumberField(TextEditingController controller) {
    return AnimatedFormField(
      controller: controller,
      labelText: 'العمر',
      prefixIcon: Icons.calendar_today,
      keyboardType: TextInputType.number,
    );
  }
}

/// مثال 6: استخدام كامل في Tab
class PersonalInfoTabExample extends StatefulWidget {
  const PersonalInfoTabExample({super.key});

  @override
  State<PersonalInfoTabExample> createState() => _PersonalInfoTabExampleState();
}

class _PersonalInfoTabExampleState extends State<PersonalInfoTabExample> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _category;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // حقل الاسم مع animation
        AnimatedFormField(
          controller: _nameController,
          labelText: 'الاسم الكامل',
          prefixIcon: Icons.person,
          hintText: 'أدخل الاسم الثلاثي',
          validator: (value) => value?.isEmpty ?? true ? 'الاسم مطلوب' : null,
        ),

        const SizedBox(height: 16),

        // حقل العمر مع animation
        AnimatedFormField(
          controller: _ageController,
          labelText: 'العمر',
          prefixIcon: Icons.cake,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'العمر مطلوب';
            final age = int.tryParse(value!);
            if (age == null || age < 0) return 'أدخل عمر صحيح';
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Dropdown مع animation
        AnimatedDropdownField<String>(
          value: _category,
          labelText: 'الفئة',
          prefixIcon: Icons.category,
          onChanged: (value) => setState(() => _category = value),
          items: const [
            DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
            DropdownMenuItem(value: 'widow', child: Text('أرملة')),
            DropdownMenuItem(value: 'poor', child: Text('فقير')),
          ],
        ),
      ],
    );
  }
}

/// 🎯 خطة الاستبدال في التابات الموجودة
///
/// 1. v2_personal_info_merged_tab.dart:
///    - استبدل M3TextField بـ AnimatedFormField
///    - احتفظ بنفس الـ properties
///
/// 2. v2_family_merged_tab.dart:
///    - استبدل M3TextField بـ AnimatedFormField
///    - استبدل M3DropdownField بـ AnimatedDropdownField
///
/// 3. v2_contact_notes_merged_tab.dart:
///    - استبدل M3TextField بـ AnimatedFormField
///    - maxLines: 4 للملاحظات
///
/// ✅ الفوائد:
/// - Focus animation سلسة (200ms)
/// - Haptic feedback عند التركيز
/// - Border highlight باللون الأزرق
/// - Background color transition
/// - نفس الـ API تماماً
/// - لا breaking changes
