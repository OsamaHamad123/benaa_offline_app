import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const V2AdditionalInfoTab({
    super.key,
    this.selectedEducationLevel,
    required this.onEducationLevelChanged,
    this.selectedEmploymentStatus,
    required this.onEmploymentStatusChanged,
    required this.hasDisability,
    required this.onDisabilityChanged,
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
            V2SwitchTile(
              title: 'من ذوي الاحتياجات الخاصة',
              subtitle: hasDisability ? 'يوجد إعاقة' : 'لا يوجد إعاقة',
              value: hasDisability,
              onChanged: onDisabilityChanged,
              icon: Icons.accessible_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
