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
  final VoidCallback? onRequestNextTab;
  final FocusNode? firstFieldFocusNode;

  const V2FamilyMergedTab({required this.formControllers, super.key, this.onRequestNextTab, this.firstFieldFocusNode});

  @override
  State<V2FamilyMergedTab> createState() => _V2FamilyMergedTabState();
}

class _V2FamilyMergedTabState extends State<V2FamilyMergedTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        physics: const ClampingScrollPhysics(), // ⚡ Smooth scroll
        cacheExtent: 100, // ⚡ Reduce repaints
        children: [
          // 👨‍👩‍👦 Family Information Section
          _FamilyInfoSection(
            formControllers: widget.formControllers,
            onRequestNextTab: widget.onRequestNextTab,
            firstFieldFocusNode: widget.firstFieldFocusNode,
          ),

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
      ),
    );
  }
}

/// Separate stateful widget for family info to isolate rebuilds
class _FamilyInfoSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;
  final VoidCallback? onRequestNextTab;
  final FocusNode? firstFieldFocusNode;

  const _FamilyInfoSection({required this.formControllers, this.onRequestNextTab, this.firstFieldFocusNode});

  @override
  State<_FamilyInfoSection> createState() => _FamilyInfoSectionState();
}

class _FamilyInfoSectionState extends State<_FamilyInfoSection> {
  Widget _orderedField(double order, Widget child) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: child,
    );
  }

  void _showNextTabHint() {
    final onRequestNextTab = widget.onRequestNextTab;
    if (onRequestNextTab == null || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: const Text('تم إنهاء إدخال معلومات العائلة. المتابعة للتبويب التالي؟'),
        action: SnackBarAction(
          label: 'التالي',
          onPressed: onRequestNextTab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'معلومات العائلة',
      icon: Icons.family_restroom_rounded,
      headerColor: FormColors.tabGradients[1]![0].withOpacity(0.2),
      children: [
        ResponsiveFormLayout(
          children: [
            _orderedField(
              10,
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
            ),
            _orderedField(
              20,
              M3TextField(
                controller: widget.formControllers.numberOfDependentsController,
                label: 'عدد المعالين',
                prefixIcon: Icons.people_outline_rounded,
                keyboardType: TextInputType.number,
                focusNode: widget.firstFieldFocusNode,
                helperText: 'عدد الأشخاص المعتمدين على المستفيد',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ResponsiveFormLayout(
          children: [
            _orderedField(
              30,
              M3TextField(
                controller: widget.formControllers.numberOfMalesController,
                label: 'عدد الذكور',
                prefixIcon: Icons.man_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            _orderedField(
              40,
              M3TextField(
                controller: widget.formControllers.numberOfFemalesController,
                label: 'عدد الإناث',
                prefixIcon: Icons.woman_rounded,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _showNextTabHint(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _orderedField(
          50,
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
        ),
      ],
    );
  }
}
