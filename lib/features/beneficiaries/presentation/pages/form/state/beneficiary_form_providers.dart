import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'beneficiary_form_state.dart';
import 'beneficiary_form_notifier.dart';

/// 🎯 Main Form State Provider
/// Use this provider to access and mutate form state
final beneficiaryFormStateProvider = StateNotifierProvider.autoDispose<BeneficiaryFormNotifier, BeneficiaryFormState>(
  (ref) => BeneficiaryFormNotifier(),
);

// ==================== Computed/Derived Providers ====================

/// Loading state selector (optimized)
final isLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.isLoading));
});

/// Saving state selector (optimized)
final isSavingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.isSaving));
});

/// Has unsaved changes selector (optimized)
final hasUnsavedChangesProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.hasUnsavedChanges));
});

/// Form progress percentage (computed)
final formProgressProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(beneficiaryFormStateProvider);
  if (state.totalRequiredFields == 0) return 0.0;
  return (state.filledFieldsCount / state.totalRequiredFields).clamp(0.0, 1.0);
});

/// Can save (derived state)
final canSaveProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(beneficiaryFormStateProvider);
  return !state.isSaving && !state.isLoading && !state.isSavingLocked && state.hasUnsavedChanges;
});

/// Last saved formatted text
final lastSavedTextProvider = Provider.autoDispose<String?>((ref) {
  final lastSaved = ref.watch(
    beneficiaryFormStateProvider.select((state) => state.lastSaved),
  );

  if (lastSaved == null) return null;

  final now = DateTime.now();
  final difference = now.difference(lastSaved);

  if (difference.inMinutes < 1) {
    return 'الآن';
  } else if (difference.inMinutes < 60) {
    return 'منذ ${difference.inMinutes} دقيقة';
  } else if (difference.inHours < 24) {
    return 'منذ ${difference.inHours} ساعة';
  } else {
    return 'منذ ${difference.inDays} يوم';
  }
});

/// Show statistics toggle
final showStatisticsProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.showStatistics));
});

/// Show tour guide toggle
final showTourGuideProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.showTourGuide));
});

/// Error message provider
final formErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(beneficiaryFormStateProvider.select((state) => state.errorMessage));
});
