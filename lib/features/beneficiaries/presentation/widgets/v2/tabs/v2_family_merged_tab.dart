import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 📱 Responsive utilities
import '../../../../../../features/taxonomies/taxonomies.dart';
import 'v2_family_members_tab_redesigned.dart';

/// 👨‍👩‍👧 Family Merged Tab (Family Info + Family Members)
///
/// دمج التبويبات: معلومات العائلة + أفراد العائلة
class V2FamilyMergedTab extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const V2FamilyMergedTab({required this.formControllers, super.key});

  @override
  State<V2FamilyMergedTab> createState() => _V2FamilyMergedTabState();
}

class _V2FamilyMergedTabState extends State<V2FamilyMergedTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      physics: const ClampingScrollPhysics(), // ⚡ Smooth scroll
      cacheExtent: 100, // ⚡ Reduce repaints
      children: [
        // 👨‍👩‍👦 Family Information Section
        _FamilyInfoSection(formControllers: widget.formControllers),

        SizedBox(height: 16.h),

        // 👥 Family Members Section
        M3SectionCard(
          title: 'أفراد العائلة',
          icon: Icons.groups_rounded,
          headerColor: FormColors.tabGradients[1]![1].withOpacity(0.2),
          children: [
            // Embed the family members widget
            V2FamilyMembersTabRedesigned(
              formControllers: widget.formControllers,
            ),
          ],
        ),
      ],
    );
  }
}

/// Separate stateful widget for family info to isolate rebuilds
class _FamilyInfoSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const _FamilyInfoSection({required this.formControllers});

  @override
  State<_FamilyInfoSection> createState() => _FamilyInfoSectionState();
}

class _FamilyInfoSectionState extends State<_FamilyInfoSection> {
  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'معلومات العائلة',
      icon: Icons.family_restroom_rounded,
      headerColor: FormColors.tabGradients[1]![0].withOpacity(0.2),
      children: [
        ResponsiveFormLayout(
          children: [
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.maritalStatus,
              selectedCode: widget.formControllers.selectedMaritalStatus,
              onCodeChanged: (value) {
                setState(() {
                  widget.formControllers.selectedMaritalStatus = value;
                });
              },
              labelText: 'الحالة الاجتماعية',
              prefixIcon: Icons.people_alt_rounded,
              isRequired: true,
            ),
            M3TextField(
              controller: widget.formControllers.numberOfDependentsController,
              label: 'عدد المعالين',
              prefixIcon: Icons.people_outline_rounded,
              keyboardType: TextInputType.number,
              helperText: 'عدد الأشخاص المعتمدين على المستفيد',
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ResponsiveFormLayout(
          children: [
            M3TextField(
              controller: widget.formControllers.numberOfMalesController,
              label: 'عدد الذكور',
              prefixIcon: Icons.man_rounded,
              keyboardType: TextInputType.number,
            ),
            M3TextField(
              controller: widget.formControllers.numberOfFemalesController,
              label: 'عدد الإناث',
              prefixIcon: Icons.woman_rounded,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TaxonomyBridgeDropdown(
          group: TaxonomyGroup.relationship,
          selectedCode: widget.formControllers.selectedRelationship,
          onCodeChanged: (value) {
            setState(() {
              widget.formControllers.selectedRelationship = value;
            });
          },
          labelText: 'صلة القرابة بالمستفيد',
          prefixIcon: Icons.connect_without_contact_rounded,
        ),
      ],
    );
  }
}
