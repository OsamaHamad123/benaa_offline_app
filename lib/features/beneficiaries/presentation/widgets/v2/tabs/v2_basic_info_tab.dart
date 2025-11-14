import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_dropdown_field.dart';
import '../components/v2_section_card.dart';

/// Basic information tab
class V2BasicInfoTab extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController fatherNameController;
  final TextEditingController grandfatherNameController;
  final TextEditingController lastNameController;
  final TextEditingController motherNameController;
  final TextEditingController nationalIdController;
  final TextEditingController birthDateController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final VoidCallback onBirthDateTap;

  const V2BasicInfoTab({
    super.key,
    required this.firstNameController,
    required this.fatherNameController,
    required this.grandfatherNameController,
    required this.lastNameController,
    required this.motherNameController,
    required this.nationalIdController,
    required this.birthDateController,
    this.selectedGender,
    required this.onGenderChanged,
    required this.onBirthDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'الاسم الكامل',
          icon: Icons.person_rounded,
          children: [
            V2CustomTextField(
              controller: firstNameController,
              label: 'الاسم الأول',
              prefixIcon: Icons.badge_rounded,
              isRequired: true,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: fatherNameController,
              label: 'اسم الأب',
              prefixIcon: Icons.person_outline_rounded,
              isRequired: true,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: grandfatherNameController,
              label: 'اسم الجد',
              prefixIcon: Icons.person_outline_rounded,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: lastNameController,
              label: 'اللقب',
              prefixIcon: Icons.family_restroom_rounded,
              isRequired: true,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الحقل مطلوب' : null,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: motherNameController,
              label: 'اسم الأم',
              prefixIcon: Icons.face_rounded,
            ),
          ],
        ),
        V2SectionCard(
          title: 'معلومات شخصية',
          icon: Icons.info_rounded,
          children: [
            V2CustomTextField(
              controller: nationalIdController,
              label: 'الرقم الوطني',
              prefixIcon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              maxLength: 11,
              isRequired: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'الحقل مطلوب';
                if (value!.length != 11) return 'يجب أن يكون 11 رقم';
                return null;
              },
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: birthDateController,
              label: 'تاريخ الميلاد',
              prefixIcon: Icons.calendar_today_rounded,
              readOnly: true,
              onTap: onBirthDateTap,
              suffix: IconButton(
                icon: Icon(Icons.event_rounded, size: 20.sp),
                onPressed: onBirthDateTap,
              ),
            ),
            SizedBox(height: 12.h),
            V2DropdownField<String>(
              value: selectedGender,
              label: 'الجنس',
              prefixIcon: Icons.wc_rounded,
              isRequired: true,
              onChanged: onGenderChanged,
              validator: (value) => value == null ? 'الحقل مطلوب' : null,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('ذكر')),
                DropdownMenuItem(value: 'female', child: Text('أنثى')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
