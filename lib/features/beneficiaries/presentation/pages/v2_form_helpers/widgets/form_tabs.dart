import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_additional_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_unified_attachments_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_basic_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_contact_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_members_tab_redesigned.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_notes_tab.dart';
import 'package:flutter/material.dart';
import '../form_controllers.dart';

/// 📋 Form Tab Content with Lazy Loading
///
/// Contains all tab views for the beneficiary form.
/// Uses IndexedStack for lazy loading - tabs remain mounted
class BeneficiaryFormTabs extends StatefulWidget {
  final TabController controller;
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onBirthDateTap;
  final FocusNode firstFieldFocusNode;
  final String? beneficiaryId;

  const BeneficiaryFormTabs({
    required this.controller,
    required this.formControllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
    super.key,
  });

  @override
  State<BeneficiaryFormTabs> createState() => _BeneficiaryFormTabsState();
}

class _BeneficiaryFormTabsState extends State<BeneficiaryFormTabs> {
  final Set<int> _loadedTabs = {0}; // Always load first tab

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _loadedTabs.add(widget.controller.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام IndexedStack للحفاظ على حالة التبويبات + Lazy Loading
    return IndexedStack(
      index: widget.controller.index,
      children: List.generate(7, (index) {
        // Lazy load: only build tabs that have been visited
        if (!_loadedTabs.contains(index)) {
          return const SizedBox.shrink();
        }

        return _buildTabAtIndex(index);
      }),
    );
  }

  Widget _buildTabAtIndex(int index) {
    switch (index) {
      case 0:
        return _buildBasicInfoTab();
      case 1:
        return _buildFamilyInfoTab();
      case 2:
        return _buildContactInfoTab();
      case 3:
        return _buildAdditionalInfoTab();
      case 4:
        return _buildNotesTab();
      case 5:
        return _buildFamilyMembersTab();
      case 6:
        return _buildAttachmentsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoTab() {
    return RepaintBoundary(
      child: V2BasicInfoTab(
        key: const ValueKey('basic_info_tab'),
        firstNameController: widget.formControllers.firstNameController,
        fatherNameController: widget.formControllers.fatherNameController,
        grandfatherNameController: widget.formControllers.grandfatherNameController,
        lastNameController: widget.formControllers.lastNameController,
        motherNameController: widget.formControllers.motherNameController,
        nationalIdController: widget.formControllers.nationalIdController,
        birthDateController: widget.formControllers.birthDateController,
        selectedGender: widget.formControllers.selectedGender,
        onGenderChanged: (value) => widget.formControllers.selectedGender = value,
        onBirthDateTap: widget.onBirthDateTap,
        firstFieldFocusNode: widget.firstFieldFocusNode,
        selectedCategory: widget.formControllers.selectedCategory,
        onCategoryChanged: (value) => widget.formControllers.selectedCategory = value,
        selectedSubCategory: widget.formControllers.selectedSubCategory,
        onSubCategoryChanged: (value) => widget.formControllers.selectedSubCategory = value,
        selectedSubSubCategory: widget.formControllers.selectedSubSubCategory,
        onSubSubCategoryChanged: (value) => widget.formControllers.selectedSubSubCategory = value,
        selectedRelationship: widget.formControllers.selectedRelationship,
        onRelationshipChanged: (value) => widget.formControllers.selectedRelationship = value,
        selectedSection: widget.formControllers.selectedSection,
        onSectionChanged: (value) => widget.formControllers.selectedSection = value,
        formControllers: widget.formControllers, // 🆕 Pass controllers for autofill
      ),
    );
  }

  Widget _buildFamilyInfoTab() {
    return RepaintBoundary(
      child: V2FamilyInfoTab(
        key: const ValueKey('family_info_tab'),
        selectedMaritalStatus: widget.formControllers.selectedMaritalStatus,
        onMaritalStatusChanged: (value) => widget.formControllers.selectedMaritalStatus = value,
        numberOfDependentsController: widget.formControllers.numberOfDependentsController,
        numberOfMalesController: widget.formControllers.numberOfMalesController,
        numberOfFemalesController: widget.formControllers.numberOfFemalesController,
        selectedRelationship: widget.formControllers.selectedRelationship,
        onRelationshipChanged: (value) => widget.formControllers.selectedRelationship = value,
      ),
    );
  }

  Widget _buildContactInfoTab() {
    return RepaintBoundary(
      child: V2ContactInfoTab(
        key: const ValueKey('contact_info_tab'),
        phoneController: widget.formControllers.phoneController,
        altPhoneController: widget.formControllers.altPhoneController,
        addressController: widget.formControllers.addressController,
        neighborhoodController: widget.formControllers.neighborhoodController,
        selectedCity: widget.formControllers.selectedCity,
        onCityChanged: (value) => widget.formControllers.selectedCity = value,
        selectedProvince: widget.formControllers.selectedProvince,
        onProvinceChanged: (value) => widget.formControllers.selectedProvince = value,
        selectedDisplacementStatus: widget.formControllers.selectedDisplacementStatus,
        onDisplacementStatusChanged: (value) => widget.formControllers.selectedDisplacementStatus = value,
        addressBeforeDisplacementController: widget.formControllers.addressBeforeDisplacementController,
      ),
    );
  }

  Widget _buildAdditionalInfoTab() {
    final specialNeedsCount = int.tryParse(widget.formControllers.specialNeedsCountController.text.trim()) ?? 0;

    return RepaintBoundary(
      child: V2AdditionalInfoTab(
        key: const ValueKey('additional_info_tab'),
        selectedEducationLevel: widget.formControllers.selectedEducationLevel,
        onEducationLevelChanged: (value) => widget.formControllers.selectedEducationLevel = value,
        selectedEmploymentStatus: widget.formControllers.selectedEmploymentStatus,
        onEmploymentStatusChanged: (value) => widget.formControllers.selectedEmploymentStatus = value,
        hasDisability: specialNeedsCount > 0,
        onDisabilityChanged: (value) {
          widget.formControllers.specialNeedsCountController.text = value ? '1' : '';
          if (mounted) {
            setState(() {});
          }
        },
        selectedHealthStatus: widget.formControllers.selectedHealthStatus,
        onHealthStatusChanged: (value) => widget.formControllers.selectedHealthStatus = value,
        chronicDiseasesController: widget.formControllers.chronicDiseasesController,
        selectedHousingStatus: widget.formControllers.selectedHousingStatus,
        onHousingStatusChanged: (value) => widget.formControllers.selectedHousingStatus = value,
        selectedHousingType: widget.formControllers.selectedHousingType,
        onHousingTypeChanged: (value) => widget.formControllers.selectedHousingType = value,
        selectedBeneficiaryStatus: widget.formControllers.selectedRequestStatus,
        onBeneficiaryStatusChanged: (value) => widget.formControllers.selectedRequestStatus = value,
      ),
    );
  }

  Widget _buildNotesTab() {
    return RepaintBoundary(
      child: V2NotesTab(
        key: const ValueKey('notes_tab'),
        notesController: widget.formControllers.notesController,
      ),
    );
  }

  Widget _buildFamilyMembersTab() {
    // ✅ التبويب المحسّن لأفراد العائلة (ExpansionTile, const widgets, keys)
    return RepaintBoundary(
      key: const ValueKey('family_members_tab'),
      child: V2FamilyMembersTabRedesigned(
        formControllers: widget.formControllers,
      ),
    );
  }

  Widget _buildAttachmentsTab() {
    // ✅ تبويب المرفقات الموحد (كل المرفقات في مكان واحد)
    return RepaintBoundary(
      child: V2UnifiedAttachmentsTab(
        key: const ValueKey('attachments_tab'),
        beneficiaryId: widget.beneficiaryId,
        pendingFiles: widget.formControllers.pendingAttachmentFiles,
        onPendingFilesChanged: (files) {
          widget.formControllers.updatePendingFiles(files);
        },
        formControllers: widget.formControllers, // ✅ تمرير controllers للوصول لبيانات العائلة
      ),
    );
  }
}
