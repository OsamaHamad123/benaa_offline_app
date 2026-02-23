import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_switch_tile.dart';
import '../components/v2_section_card.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 📱 Responsive utilities
import '../../../../../../features/taxonomies/taxonomies.dart';

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
  final String? selectedBeneficiaryStatus;
  final Function(String?) onBeneficiaryStatusChanged;

  const V2AdditionalInfoTab({
    required this.onEducationLevelChanged, required this.onEmploymentStatusChanged, required this.hasDisability, required this.onDisabilityChanged, required this.onHealthStatusChanged, required this.chronicDiseasesController, required this.onHousingStatusChanged, required this.onHousingTypeChanged, required this.onBeneficiaryStatusChanged, super.key,
    this.selectedEducationLevel,
    this.selectedEmploymentStatus,
    this.selectedHealthStatus,
    this.selectedHousingStatus,
    this.selectedHousingType,
    this.selectedBeneficiaryStatus,
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
            ResponsiveFormLayout(
              children: [
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.educationLevel,
                  selectedCode: selectedEducationLevel,
                  labelText: 'المستوى التعليمي',
                  prefixIcon: Icons.menu_book_rounded,
                  onCodeChanged: onEducationLevelChanged,
                ),
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.employmentStatus,
                  selectedCode: selectedEmploymentStatus,
                  labelText: 'حالة العمل',
                  prefixIcon: Icons.work_rounded,
                  onCodeChanged: onEmploymentStatusChanged,
                ),
              ],
            ),
          ],
        ),
        V2SectionCard(
          title: 'الحالة الصحية',
          icon: Icons.health_and_safety_rounded,
          children: [
            ResponsiveFormLayout(
              children: [
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.healthStatus,
                  selectedCode: selectedHealthStatus,
                  labelText: 'الحالة الصحية',
                  prefixIcon: Icons.favorite_rounded,
                  onCodeChanged: onHealthStatusChanged,
                ),
                V2CustomTextField(
                  controller: chronicDiseasesController,
                  label: 'عدد المصابين بأمراض مزمنة',
                  prefixIcon: Icons.medication_rounded,
                  keyboardType: TextInputType.number,
                  hint: 'عدد أفراد الأسرة المصابين',
                ),
              ],
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
            ResponsiveFormLayout(
              children: [
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.housingStatus,
                  selectedCode: selectedHousingStatus,
                  labelText: 'حالة السكن',
                  prefixIcon: Icons.house_rounded,
                  onCodeChanged: onHousingStatusChanged,
                ),
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.housingType,
                  selectedCode: selectedHousingType,
                  labelText: 'نوع السكن',
                  prefixIcon: Icons.apartment_rounded,
                  onCodeChanged: onHousingTypeChanged,
                ),
              ],
            ),
          ],
        ),
        V2SectionCard(
          title: 'حالة المستفيد',
          icon: Icons.verified_user_rounded,
          children: [
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.beneficiaryStatus,
              selectedCode: selectedBeneficiaryStatus,
              labelText: 'حالة المستفيد',
              prefixIcon: Icons.flag_rounded,
              onCodeChanged: onBeneficiaryStatusChanged,
            ),
          ],
        ),
      ],
    );
  }
}
