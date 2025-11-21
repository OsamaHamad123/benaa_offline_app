import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_additional_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_attachments_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_basic_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_contact_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_info_tab.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_members_tab.dart';
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
    super.key,
    required this.controller,
    required this.formControllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
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
        grandfatherNameController:
            widget.formControllers.grandfatherNameController,
        lastNameController: widget.formControllers.lastNameController,
        motherNameController: widget.formControllers.motherNameController,
        nationalIdController: widget.formControllers.nationalIdController,
        birthDateController: widget.formControllers.birthDateController,
        selectedGender: widget.formControllers.selectedGender,
        onGenderChanged: (value) =>
            widget.formControllers.selectedGender = value,
        onBirthDateTap: widget.onBirthDateTap,
        firstFieldFocusNode: widget.firstFieldFocusNode,
        selectedCategory: widget.formControllers.selectedCategory,
        onCategoryChanged: (value) =>
            widget.formControllers.selectedCategory = value,
        formControllers:
            widget.formControllers, // 🆕 Pass controllers for autofill
      ),
    );
  }

  Widget _buildFamilyInfoTab() {
    return RepaintBoundary(
      child: V2FamilyInfoTab(
        key: const ValueKey('family_info_tab'),
        selectedMaritalStatus: widget.formControllers.selectedMaritalStatus,
        onMaritalStatusChanged: (value) =>
            widget.formControllers.selectedMaritalStatus = value,
        numberOfDependentsController:
            widget.formControllers.numberOfDependentsController,
        numberOfMalesController: widget.formControllers.numberOfMalesController,
        numberOfFemalesController:
            widget.formControllers.numberOfFemalesController,
        selectedRelationship: widget.formControllers.selectedRelationship,
        onRelationshipChanged: (value) =>
            widget.formControllers.selectedRelationship = value,
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
        onProvinceChanged: (value) =>
            widget.formControllers.selectedProvince = value,
        selectedDisplacementStatus:
            widget.formControllers.selectedDisplacementStatus,
        onDisplacementStatusChanged: (value) =>
            widget.formControllers.selectedDisplacementStatus = value,
        addressBeforeDisplacementController:
            widget.formControllers.addressBeforeDisplacementController,
      ),
    );
  }

  Widget _buildAdditionalInfoTab() {
    return RepaintBoundary(
      child: V2AdditionalInfoTab(
        key: const ValueKey('additional_info_tab'),
        selectedEducationLevel: widget.formControllers.selectedEducationLevel,
        onEducationLevelChanged: (value) =>
            widget.formControllers.selectedEducationLevel = value,
        selectedEmploymentStatus:
            widget.formControllers.selectedEmploymentStatus,
        onEmploymentStatusChanged: (value) =>
            widget.formControllers.selectedEmploymentStatus = value,
        hasDisability: widget.formControllers.hasDisability,
        onDisabilityChanged: (value) =>
            widget.formControllers.hasDisability = value,
        selectedHealthStatus: widget.formControllers.selectedHealthStatus,
        onHealthStatusChanged: (value) =>
            widget.formControllers.selectedHealthStatus = value,
        chronicDiseasesController:
            widget.formControllers.chronicDiseasesController,
        selectedHousingStatus: widget.formControllers.selectedHousingStatus,
        onHousingStatusChanged: (value) =>
            widget.formControllers.selectedHousingStatus = value,
        selectedHousingType: widget.formControllers.selectedHousingType,
        onHousingTypeChanged: (value) =>
            widget.formControllers.selectedHousingType = value,
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
    // التبويب الجديد لأفراد العائلة التفصيلية
    return RepaintBoundary(
      key: const ValueKey('family_members_tab'),
      child: V2FamilyMembersTab(formControllers: widget.formControllers),
    );
  }

  Widget _buildAttachmentsTab() {
    return RepaintBoundary(
      child: V2AttachmentsTab(
        key: const ValueKey('attachments_tab'),
        beneficiaryId: widget.beneficiaryId,
        pendingFiles: widget.formControllers.pendingAttachmentFiles,
        onPendingFilesChanged: (files) {
          widget.formControllers.updatePendingFiles(files);
        },
      ),
    );
  }
}
