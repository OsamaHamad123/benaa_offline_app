import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/civil_registry_person.dart';
import '../../domain/usecases/fetch_civil_registry_data.dart';
import '../../domain/usecases/autofill_from_civil_registry.dart';
import '../../domain/repositories/civil_registry_repository.dart';

/// 🎯 Civil Registry State
///
/// Represents all possible states when fetching civil registry data.
class CivilRegistryState {
  final CivilRegistryStatus status;
  final CivilRegistryPerson? person;
  final String? errorMessage;
  final CivilRegistryErrorType? errorType;
  final String? lastSearchedNationalId;
  final AutofillResult? lastAutofillResult;

  const CivilRegistryState({
    this.status = CivilRegistryStatus.initial,
    this.person,
    this.errorMessage,
    this.errorType,
    this.lastSearchedNationalId,
    this.lastAutofillResult,
  });

  CivilRegistryState copyWith({
    CivilRegistryStatus? status,
    CivilRegistryPerson? person,
    String? errorMessage,
    CivilRegistryErrorType? errorType,
    String? lastSearchedNationalId,
    AutofillResult? lastAutofillResult,
  }) {
    return CivilRegistryState(
      status: status ?? this.status,
      person: person ?? this.person,
      errorMessage: errorMessage,
      errorType: errorType,
      lastSearchedNationalId:
          lastSearchedNationalId ?? this.lastSearchedNationalId,
      lastAutofillResult: lastAutofillResult,
    );
  }

  bool get isLoading => status == CivilRegistryStatus.loading;
  bool get isSuccess => status == CivilRegistryStatus.success;
  bool get isNotFound => status == CivilRegistryStatus.notFound;
  bool get isError => status == CivilRegistryStatus.error;
  bool get hasData => person != null;
}

enum CivilRegistryStatus { initial, loading, success, notFound, error }

/// 🎮 Civil Registry Provider (StateNotifier)
///
/// Manages state for civil registry operations with debouncing and caching.
class CivilRegistryNotifier extends StateNotifier<CivilRegistryState> {
  final FetchCivilRegistryDataUseCase fetchUseCase;
  final AutofillFromCivilRegistryUseCase autofillUseCase;

  CivilRegistryNotifier({
    required this.fetchUseCase,
    required this.autofillUseCase,
  }) : super(const CivilRegistryState());

  /// Fetch person data by national ID
  Future<void> fetchByNationalId(String nationalId) async {
    // Skip if already loading same ID
    if (state.isLoading && state.lastSearchedNationalId == nationalId) {
      return;
    }

    // Emit loading state
    state = state.copyWith(
      status: CivilRegistryStatus.loading,
      lastSearchedNationalId: nationalId,
      errorMessage: null,
      errorType: null,
    );

    // Execute use case
    final result = await fetchUseCase.execute(nationalId);

    // Update state based on result
    if (result.isSuccess) {
      state = state.copyWith(
        status: CivilRegistryStatus.success,
        person: result.person,
      );
    } else if (result.isNotFound) {
      state = state.copyWith(
        status: CivilRegistryStatus.notFound,
        person: null,
        errorMessage: result.errorMessage,
        errorType: result.errorType,
      );
    } else {
      state = state.copyWith(
        status: CivilRegistryStatus.error,
        person: null,
        errorMessage: result.errorMessage,
        errorType: result.errorType,
      );
    }
  }

  /// Autofill form with fetched data
  AutofillResult? autofillForm(dynamic controllers) {
    if (state.person == null) {
      return null;
    }

    final result = autofillUseCase.execute(
      person: state.person!,
      controllers: controllers,
    );

    state = state.copyWith(lastAutofillResult: result);

    return result;
  }

  /// Undo last autofill
  void undoAutofill(dynamic controllers) {
    if (state.lastAutofillResult == null) return;

    autofillUseCase.undo(
      controllers: controllers,
      undoData: state.lastAutofillResult!.undoData,
    );

    state = state.copyWith(lastAutofillResult: null);
  }

  /// Reset state to initial
  void reset() {
    state = const CivilRegistryState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null, errorType: null);
  }
}
