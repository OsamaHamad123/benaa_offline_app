import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_dropdown_field.dart';
import '../components/v2_switch_tile.dart';
import '../components/v2_section_card.dart';

/// Additional information tab
class V2AdditionalInfoTab extends StatelessWidget {
  final String? selectedEducationLevel;
  final Function(String?) onEducationLevelChanged;
  final String? selectedEmploymentStatus;
  final Function(String?) onEmploymentStatusChanged;
  final bool hasDisability;
  final Function(bool) onDisabilityChanged;
  final String? selectedHealthStatus;
  final Function(String?) onHealthStatusChanged;
  final TextEditingController chronicDiseasesController;
  final String? selectedHousingStatus;
  final Function(String?) onHousingStatusChanged;
  final String? selectedHousingType;
  final Function(String?) onHousingTypeChanged;

  const V2AdditionalInfoTab({
    super.key,
    this.selectedEducationLevel,
    required this.onEducationLevelChanged,
    this.selectedEmploymentStatus,
    required this.onEmploymentStatusChanged,
    required this.hasDisability,
    required this.onDisabilityChanged,
    this.selectedHealthStatus,
    required this.onHealthStatusChanged,
    required this.chronicDiseasesController,
    this.selectedHousingStatus,
    required this.onHousingStatusChanged,
    this.selectedHousingType,
    required this.onHousingTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'التعليم والعمل',
          icon: Icons.school_rounded,
          children: [
            V2DropdownField<String>(
              value: selectedEducationLevel,
              label: 'المستوى التعليمي',
              prefixIcon: Icons.menu_book_rounded,
              onChanged: onEducationLevelChanged,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('أمي')),
                DropdownMenuItem(value: 'primary', child: Text('ابتدائي')),
                DropdownMenuItem(value: 'intermediate', child: Text('إعدادي')),
                DropdownMenuItem(value: 'secondary', child: Text('ثانوي')),
                DropdownMenuItem(value: 'bachelor', child: Text('جامعي')),
                DropdownMenuItem(value: 'master', child: Text('دراسات عليا')),
              ],
            ),
            SizedBox(height: 12.h),
            V2DropdownField<String>(
              value: selectedEmploymentStatus,
              label: 'حالة العمل',
              prefixIcon: Icons.work_rounded,
              onChanged: onEmploymentStatusChanged,
              items: const [
                DropdownMenuItem(value: 'employed', child: Text('موظف')),
                DropdownMenuItem(
                  value: 'unemployed',
                  child: Text('عاطل عن العمل'),
                ),
                DropdownMenuItem(
                  value: 'selfEmployed',
                  child: Text('أعمال حرة'),
                ),
                DropdownMenuItem(value: 'retired', child: Text('متقاعد')),
                DropdownMenuItem(value: 'student', child: Text('طالب')),
              ],
            ),
          ],
        ),
        V2SectionCard(
          title: 'الحالة الصحية',
          icon: Icons.health_and_safety_rounded,
          children: [
            V2DropdownField<String>(
              value: selectedHealthStatus,
              label: 'الحالة الصحية',
              prefixIcon: Icons.favorite_rounded,
              onChanged: onHealthStatusChanged,
              items: const [
                DropdownMenuItem(value: 'good', child: Text('جيدة')),
                DropdownMenuItem(value: 'moderate', child: Text('متوسطة')),
                DropdownMenuItem(value: 'chronic', child: Text('أمراض مزمنة')),
                DropdownMenuItem(value: 'disability', child: Text('إعاقة')),
                DropdownMenuItem(value: 'poor', child: Text('سيئة')),
              ],
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: chronicDiseasesController,
              label: 'عدد المصابين بأمراض مزمنة',
              prefixIcon: Icons.medication_rounded,
              keyboardType: TextInputType.number,
              hint: 'عدد أفراد الأسرة المصابين',
            ),
            SizedBox(height: 12.h),
            V2SwitchTile(
              title: 'من ذوي الاحتياجات الخاصة',
              subtitle: hasDisability ? 'يوجد إعاقة' : 'لا يوجد إعاقة',
              value: hasDisability,
              onChanged: onDisabilityChanged,
              icon: Icons.accessible_rounded,
            ),
          ],
        ),
        V2SectionCard(
          title: 'السكن',
          icon: Icons.home_rounded,
          children: [
            V2DropdownField<String>(
              value: selectedHousingStatus,
              label: 'حالة السكن',
              prefixIcon: Icons.house_rounded,
              onChanged: onHousingStatusChanged,
              items: const [
                DropdownMenuItem(value: 'owned', child: Text('ملك')),
                DropdownMenuItem(value: 'rented', child: Text('إيجار')),
                DropdownMenuItem(value: 'shared', child: Text('مشترك')),
                DropdownMenuItem(value: 'homeless', child: Text('مشرد')),
                DropdownMenuItem(
                  value: 'withFamily',
                  child: Text('مع العائلة'),
                ),
                DropdownMenuItem(value: 'temporary', child: Text('مؤقت')),
              ],
            ),
            SizedBox(height: 12.h),
            V2DropdownField<String>(
              value: selectedHousingType,
              label: 'نوع السكن',
              prefixIcon: Icons.apartment_rounded,
              onChanged: onHousingTypeChanged,
              items: const [
                DropdownMenuItem(value: 'house', child: Text('منزل')),
                DropdownMenuItem(value: 'apartment', child: Text('شقة')),
                DropdownMenuItem(value: 'room', child: Text('غرفة')),
                DropdownMenuItem(value: 'tent', child: Text('خيمة')),
                DropdownMenuItem(value: 'caravan', child: Text('قافلة')),
                DropdownMenuItem(value: 'shelter', child: Text('مأوى')),
                DropdownMenuItem(value: 'other', child: Text('أخرى')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
