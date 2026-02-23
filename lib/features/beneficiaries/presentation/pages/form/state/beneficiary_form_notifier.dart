import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'beneficiary_form_state.dart';

/// 🎯 State Notifier for Beneficiary Form
/// Handles all state mutations and business logic
class BeneficiaryFormNotifier extends StateNotifier<BeneficiaryFormState> {
  BeneficiaryFormNotifier() : super(BeneficiaryFormState.initial());

  // ==================== Loading States ====================

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setSaving(bool isSaving) {
    state = state.copyWith(isSaving: isSaving);
  }

  void setDeleting(bool isDeleting) {
    state = state.copyWith(isDeleting: isDeleting);
  }

  void setSavingLocked(bool isLocked) {
    state = state.copyWith(isSavingLocked: isLocked);
  }

  // ==================== Form Progress ====================

  void setHasUnsavedChanges(bool hasChanges) {
    state = state.copyWith(hasUnsavedChanges: hasChanges);
  }

  void setLastSaved(DateTime? dateTime) {
    state = state.copyWith(lastSaved: dateTime);
  }

  void setCurrentTab(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  void updateFilledFieldsCount(int count) {
    state = state.copyWith(filledFieldsCount: count);
  }

  // ==================== Auto-save & Drafts ====================

  void setAutoSaveDraftId(String? draftId) {
    state = state.copyWith(autoSaveDraftId: draftId);
  }

  void markAutoSaved() {
    state = state.copyWith(
      lastSaved: DateTime.now(),
      hasUnsavedChanges: false,
    );
  }

  // ==================== UI Features ====================

  void toggleStatistics() {
    state = state.copyWith(showStatistics: !state.showStatistics);
  }

  void toggleTourGuide() {
    state = state.copyWith(showTourGuide: !state.showTourGuide);
  }

  void toggleFieldHelpers() {
    state = state.copyWith(showFieldHelpers: !state.showFieldHelpers);
  }

  void setShowTourGuide(bool show) {
    state = state.copyWith(showTourGuide: show);
  }

  // ==================== Beneficiary Management ====================

  void setBeneficiaryId(String? id) {
    state = state.copyWith(beneficiaryId: id);
  }

  // ==================== Error Handling ====================

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith();
  }

  // ==================== Smart Features ====================

  void updateSmartHints(Map<String, dynamic> hints) {
    state = state.copyWith(smartHints: hints);
  }

  void updateFieldDependencies(Map<String, dynamic> dependencies) {
    state = state.copyWith(fieldDependencies: dependencies);
  }

  // ==================== Reset & Clean ====================

  void reset() {
    state = BeneficiaryFormState.initial();
  }

  void resetUnsavedChanges() {
    state = state.copyWith(hasUnsavedChanges: false);
  }

  // ==================== Complex Operations ====================

  /// Start form initialization
  Future<void> startInitialization() async {
    setLoading(true);
    clearError();
  }

  /// Complete form initialization
  void completeInitialization() {
    setLoading(false);
  }

  /// Handle initialization error
  void handleInitializationError(String error) {
    setLoading(false);
    setError(error);
  }

  /// Start save operation
  Future<void> startSave() async {
    if (state.isSaving || state.isSavingLocked) {
      debugPrint('⚠️ Save blocked: already saving or locked');
      return;
    }

    setSaving(true);
    clearError();
  }

  /// Complete save operation
  void completeSave() {
    setSaving(false);
    setLastSaved(DateTime.now());
    setHasUnsavedChanges(false);
  }

  /// Handle save error
  void handleSaveError(String error) {
    setSaving(false);
    setError(error);
  }

  /// Auto-save complete (silent)
  void completeAutoSave({String? draftId}) {
    if (draftId != null) {
      setAutoSaveDraftId(draftId);
    }
    setLastSaved(DateTime.now());
    // Don't clear unsaved changes for auto-save
  }
}
