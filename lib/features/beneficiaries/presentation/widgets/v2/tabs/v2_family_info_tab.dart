import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_section_card.dart';
import '../../../../../../features/taxonomies/taxonomies.dart';

/// Family information tab
class V2FamilyInfoTab extends StatelessWidget {
  final String? selectedMaritalStatus;
  final Function(String?) onMaritalStatusChanged;
  final TextEditingController numberOfDependentsController;
  final TextEditingController numberOfMalesController;
  final TextEditingController numberOfFemalesController;
  final String? selectedRelationship;
  final Function(String?) onRelationshipChanged;

  const V2FamilyInfoTab({
    super.key,
    this.selectedMaritalStatus,
    required this.onMaritalStatusChanged,
    required this.numberOfDependentsController,
    required this.numberOfMalesController,
    required this.numberOfFemalesController,
    this.selectedRelationship,
    required this.onRelationshipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'الحالة العائلية',
          icon: Icons.family_restroom_rounded,
          children: [
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.maritalStatus,
              selectedCode: selectedMaritalStatus,
              labelText: 'الحالة الاجتماعية',
              prefixIcon: Icons.favorite_rounded,
              onCodeChanged: onMaritalStatusChanged,
            ),
            SizedBox(height: 12.h),
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.relationship,
              selectedCode: selectedRelationship,
              labelText: 'العلاقة بعائل الأسرة',
              prefixIcon: Icons.people_outline_rounded,
              onCodeChanged: onRelationshipChanged,
            ),
          ],
        ),
        V2SectionCard(
          title: 'تفاصيل العائلة',
          icon: Icons.groups_rounded,
          children: [
            V2CustomTextField(
              controller: numberOfDependentsController,
              label: 'حجم العائلة',
              prefixIcon: Icons.groups_rounded,
              keyboardType: TextInputType.number,
              hint: 'إجمالي أفراد الأسرة',
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: numberOfMalesController,
              label: 'عدد الذكور',
              prefixIcon: Icons.male_rounded,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: numberOfFemalesController,
              label: 'عدد الإناث',
              prefixIcon: Icons.female_rounded,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ],
    );
  }
}
