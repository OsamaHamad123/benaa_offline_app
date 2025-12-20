import 'package:equatable/equatable.dart';

/// 🎯 Immutable State for Beneficiary Form
/// Contains all state variables in a clean, testable structure
class BeneficiaryFormState extends Equatable {
  // Loading & Saving States
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final bool isSavingLocked;

  // Form Progress & History
  final bool hasUnsavedChanges;
  final DateTime? lastSaved;
  final int currentTabIndex;

  // Auto-save & Drafts
  final String? autoSaveDraftId;

  // UI Feature Toggles
  final bool showStatistics;
  final bool showTourGuide;
  final bool showFieldHelpers;

  // Form Data Progress
  final int filledFieldsCount;
  final int totalRequiredFields;

  // Current Beneficiary
  final String? beneficiaryId;

  // Error Handling
  final String? errorMessage;

  // Smart Features State
  final Map<String, dynamic>? smartHints;
  final Map<String, dynamic>? fieldDependencies;

  const BeneficiaryFormState({
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.isSavingLocked = false,
    this.hasUnsavedChanges = false,
    this.lastSaved,
    this.currentTabIndex = 0,
    this.autoSaveDraftId,
    this.showStatistics = false,
    this.showTourGuide = false,
    this.showFieldHelpers = false,
    this.filledFieldsCount = 0,
    this.totalRequiredFields =
        8, // firstName, fatherName, grandfatherName, lastName, nationalId, birthDate, phone, address
    this.beneficiaryId,
    this.errorMessage,
    this.smartHints,
    this.fieldDependencies,
  });

  // Initial/Default State
  factory BeneficiaryFormState.initial() => const BeneficiaryFormState();

  // CopyWith method for immutable updates
  BeneficiaryFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    bool? isSavingLocked,
    bool? hasUnsavedChanges,
    DateTime? lastSaved,
    int? currentTabIndex,
    String? autoSaveDraftId,
    bool? showStatistics,
    bool? showTourGuide,
    bool? showFieldHelpers,
    int? filledFieldsCount,
    int? totalRequiredFields,
    String? beneficiaryId,
    String? errorMessage,
    Map<String, dynamic>? smartHints,
    Map<String, dynamic>? fieldDependencies,
  }) {
    return BeneficiaryFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      isSavingLocked: isSavingLocked ?? this.isSavingLocked,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSaved: lastSaved ?? this.lastSaved,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      autoSaveDraftId: autoSaveDraftId ?? this.autoSaveDraftId,
      showStatistics: showStatistics ?? this.showStatistics,
      showTourGuide: showTourGuide ?? this.showTourGuide,
      showFieldHelpers: showFieldHelpers ?? this.showFieldHelpers,
      filledFieldsCount: filledFieldsCount ?? this.filledFieldsCount,
      totalRequiredFields: totalRequiredFields ?? this.totalRequiredFields,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      errorMessage: errorMessage ?? this.errorMessage,
      smartHints: smartHints ?? this.smartHints,
      fieldDependencies: fieldDependencies ?? this.fieldDependencies,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        isDeleting,
        isSavingLocked,
        hasUnsavedChanges,
        lastSaved,
        currentTabIndex,
        autoSaveDraftId,
        showStatistics,
        showTourGuide,
        showFieldHelpers,
        filledFieldsCount,
        totalRequiredFields,
        beneficiaryId,
        errorMessage,
        smartHints,
        fieldDependencies,
      ];
}
