import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import 'v2_family_members_tab_redesigned.dart';

/// 👨‍👩‍👧 Family Merged Tab (Family Info + Family Members)
///
/// دمج التبويبات: معلومات العائلة + أفراد العائلة
class V2FamilyMergedTab extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const V2FamilyMergedTab({super.key, required this.formControllers});

  @override
  State<V2FamilyMergedTab> createState() => _V2FamilyMergedTabState();
}

class _V2FamilyMergedTabState extends State<V2FamilyMergedTab>
    with AutomaticKeepAliveClientMixin {
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
  // Valid values for dropdowns
  static const List<String> _validMaritalStatuses = [
    'أعزب',
    'متزوج',
    'مطلق',
    'أرمل',
  ];

  static const List<String> _validRelationships = [
    'ابن',
    'ابنة',
    'أب',
    'أم',
    'أخ',
    'أخت',
    'زوج',
    'زوجة',
    'آخر',
  ];

  String? _validateDropdownValue(String? value, List<String> validValues) {
    if (value == null || value.isEmpty) return null;
    return validValues.contains(value) ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    // Validate dropdown values to prevent crash
    final maritalStatus = _validateDropdownValue(
      widget.formControllers.selectedMaritalStatus,
      _validMaritalStatuses,
    );
    final relationship = _validateDropdownValue(
      widget.formControllers.selectedRelationship,
      _validRelationships,
    );

    return M3SectionCard(
      title: 'معلومات العائلة',
      icon: Icons.family_restroom_rounded,
      headerColor: FormColors.tabGradients[1]![0].withOpacity(0.2),
      children: [
        M3DropdownField<String>(
          value: maritalStatus,
          label: 'الحالة الاجتماعية',
          prefixIcon: Icons.people_alt_rounded,
          isRequired: true,
          onChanged: (value) {
            setState(() {
              widget.formControllers.selectedMaritalStatus = value;
            });
          },
          validator: (value) =>
              value == null ? FormConstants.requiredFieldMessage : null,
          items: const [
            DropdownMenuItem(value: 'أعزب', child: Text('أعزب')),
            DropdownMenuItem(value: 'متزوج', child: Text('متزوج')),
            DropdownMenuItem(value: 'مطلق', child: Text('مطلق')),
            DropdownMenuItem(value: 'أرمل', child: Text('أرمل')),
          ],
        ),
        SizedBox(height: 12.h),
        M3TextField(
          controller: widget.formControllers.numberOfDependentsController,
          label: 'عدد المعالين',
          prefixIcon: Icons.people_outline_rounded,
          keyboardType: TextInputType.number,
          helperText: 'عدد الأشخاص المعتمدين على المستفيد',
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: M3TextField(
                controller: widget.formControllers.numberOfMalesController,
                label: 'عدد الذكور',
                prefixIcon: Icons.man_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: M3TextField(
                controller: widget.formControllers.numberOfFemalesController,
                label: 'عدد الإناث',
                prefixIcon: Icons.woman_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        M3DropdownField<String>(
          value: relationship,
          label: 'صلة القرابة بالمستفيد',
          prefixIcon: Icons.connect_without_contact_rounded,
          onChanged: (value) {
            setState(() {
              widget.formControllers.selectedRelationship = value;
            });
          },
          items: const [
            DropdownMenuItem(value: 'ابن', child: Text('ابن')),
            DropdownMenuItem(value: 'ابنة', child: Text('ابنة')),
            DropdownMenuItem(value: 'أب', child: Text('أب')),
            DropdownMenuItem(value: 'أم', child: Text('أم')),
            DropdownMenuItem(value: 'أخ', child: Text('أخ')),
            DropdownMenuItem(value: 'أخت', child: Text('أخت')),
            DropdownMenuItem(value: 'زوج', child: Text('زوج')),
            DropdownMenuItem(value: 'زوجة', child: Text('زوجة')),
            DropdownMenuItem(value: 'آخر', child: Text('آخر')),
          ],
        ),
      ],
    );
  }
}
