import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/civil_registry_person.dart';
import '../../domain/usecases/fetch_civil_registry_data.dart';
import '../../domain/usecases/autofill_from_civil_registry.dart';
import '../../domain/repositories/civil_registry_repository.dart';

class CivilRegistryLookupTrace {
  final DateTime timestamp;
  final String nationalId;
  final String phase;
  final int? lookupElapsedMs;
  final int? totalElapsedMs;

  const CivilRegistryLookupTrace({
    required this.timestamp,
    required this.nationalId,
    required this.phase,
    this.lookupElapsedMs,
    this.totalElapsedMs,
  });
}

class CivilRegistryLookupDiagnostics {
  static bool enabled = false;
  static const int _maxEvents = 120;
  static final List<CivilRegistryLookupTrace> _events = <CivilRegistryLookupTrace>[];

  static List<CivilRegistryLookupTrace> snapshot() => List.unmodifiable(_events);

  static void clear() {
    _events.clear();
  }

  static void record({
    required String nationalId,
    required String phase,
    int? lookupElapsedMs,
    int? totalElapsedMs,
  }) {
    if (!enabled || !kDebugMode) {
      return;
    }

    _events.add(
      CivilRegistryLookupTrace(
        timestamp: DateTime.now(),
        nationalId: nationalId,
        phase: phase,
        lookupElapsedMs: lookupElapsedMs,
        totalElapsedMs: totalElapsedMs,
      ),
    );

    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }

    debugPrint(
      '[CivilLookup][$phase] id=$nationalId lookup=${lookupElapsedMs ?? '-'}ms total=${totalElapsedMs ?? '-'}ms',
    );
  }
}

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
      lastSearchedNationalId: lastSearchedNationalId ?? this.lastSearchedNationalId,
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
/// ✅ Works safely even if civil registry database is not available.
class CivilRegistryNotifier extends StateNotifier<CivilRegistryState> {
  FetchCivilRegistryDataUseCase? _fetchUseCase;
  final AutofillFromCivilRegistryUseCase autofillUseCase;
  final Ref _ref;
  final FutureProvider<FetchCivilRegistryDataUseCase?> _fetchUseCaseProvider;
  int _requestToken = 0;
  String? _lastRequestedNationalId;
  DateTime? _lastLookupAt;

  CivilRegistryNotifier({
    required FutureProvider<FetchCivilRegistryDataUseCase?> fetchUseCaseProvider,
    required this.autofillUseCase,
    required Ref ref,
  })  : _fetchUseCaseProvider = fetchUseCaseProvider,
        _ref = ref,
        super(const CivilRegistryState());

  /// ✅ Lazy load the fetch use case when needed
  Future<FetchCivilRegistryDataUseCase?> _getFetchUseCase() async {
    if (_fetchUseCase != null) return _fetchUseCase;
    _fetchUseCase = await _ref.read(_fetchUseCaseProvider.future);
    return _fetchUseCase;
  }

  /// Fetch person data by national ID
  Future<void> fetchByNationalId(String nationalId) async {
    final normalizedId = nationalId.trim();
    final bool traceEnabled = CivilRegistryLookupDiagnostics.enabled && kDebugMode;
    final Stopwatch? totalStopwatch = traceEnabled ? (Stopwatch()..start()) : null;

    CivilRegistryLookupDiagnostics.record(
      nationalId: normalizedId,
      phase: 'request_received',
      totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
    );

    if (normalizedId.length != 9) {
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'skipped_invalid_length',
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    // Throttle duplicate lookups for same ID in short bursts.
    final now = DateTime.now();
    if (_lastRequestedNationalId == normalizedId && _lastLookupAt != null) {
      final elapsed = now.difference(_lastLookupAt!);
      if (elapsed < const Duration(milliseconds: 1200)) {
        CivilRegistryLookupDiagnostics.record(
          nationalId: normalizedId,
          phase: 'skipped_throttled',
          totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
        );
        return;
      }
    }

    // Avoid request piling while previous lookup is still running.
    if (state.isLoading) {
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'skipped_loading',
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    // Avoid repeating exactly same request while already successful.
    if (state.lastSearchedNationalId == normalizedId && (state.isSuccess || state.isNotFound)) {
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'skipped_duplicate_result',
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    _lastRequestedNationalId = normalizedId;
    _lastLookupAt = now;

    final int currentToken = ++_requestToken;

    // Get the use case (may be null if database not available)
    final fetchUseCase = await _getFetchUseCase();

    if (fetchUseCase == null) {
      // Database not available
      state = state.copyWith(
        status: CivilRegistryStatus.error,
        errorMessage: 'قاعدة بيانات السجل المدني غير متوفرة. يرجى تحميلها من الإعدادات.',
        errorType: CivilRegistryErrorType.databaseNotAvailable,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'database_not_available',
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    // Emit loading state
    state = state.copyWith(
      status: CivilRegistryStatus.loading,
      lastSearchedNationalId: normalizedId,
    );

    CivilRegistryLookupDiagnostics.record(
      nationalId: normalizedId,
      phase: 'lookup_started',
      totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
    );

    CivilRegistryResult result;
    final Stopwatch? lookupStopwatch = traceEnabled ? (Stopwatch()..start()) : null;
    try {
      // Execute use case with guard timeout to avoid long UI stalls.
      result = await fetchUseCase.execute(normalizedId).timeout(const Duration(seconds: 6));
    } on TimeoutException {
      final int? lookupElapsed = lookupStopwatch?.elapsedMilliseconds;
      if (currentToken != _requestToken) {
        CivilRegistryLookupDiagnostics.record(
          nationalId: normalizedId,
          phase: 'timeout_stale_ignored',
          lookupElapsedMs: lookupElapsed,
          totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
        );
        return;
      }

      state = state.copyWith(
        status: CivilRegistryStatus.error,
        errorMessage: 'انتهت مهلة البحث في السجل المدني. حاول مرة أخرى.',
        errorType: CivilRegistryErrorType.timeout,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'lookup_timeout',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    } catch (_) {
      final int? lookupElapsed = lookupStopwatch?.elapsedMilliseconds;
      if (currentToken != _requestToken) {
        CivilRegistryLookupDiagnostics.record(
          nationalId: normalizedId,
          phase: 'error_stale_ignored',
          lookupElapsedMs: lookupElapsed,
          totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
        );
        return;
      }

      state = state.copyWith(
        status: CivilRegistryStatus.error,
        errorMessage: 'تعذر تنفيذ البحث في السجل المدني حالياً.',
        errorType: CivilRegistryErrorType.unknown,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'lookup_exception',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    final int? lookupElapsed = lookupStopwatch?.elapsedMilliseconds;

    // Ignore stale response if a newer request exists.
    if (currentToken != _requestToken) {
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'response_stale_ignored',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
      return;
    }

    // Update state based on result
    if (result.isSuccess) {
      state = state.copyWith(
        status: CivilRegistryStatus.success,
        person: result.person,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'lookup_success',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
    } else if (result.isNotFound) {
      state = state.copyWith(
        status: CivilRegistryStatus.notFound,
        errorMessage: result.errorMessage,
        errorType: result.errorType,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'lookup_not_found',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
    } else {
      state = state.copyWith(
        status: CivilRegistryStatus.error,
        errorMessage: result.errorMessage,
        errorType: result.errorType,
      );
      CivilRegistryLookupDiagnostics.record(
        nationalId: normalizedId,
        phase: 'lookup_error_result',
        lookupElapsedMs: lookupElapsed,
        totalElapsedMs: totalStopwatch?.elapsedMilliseconds,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _requestToken++;
    _lastRequestedNationalId = null;
    _lastLookupAt = null;
    super.dispose();
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

    state = state.copyWith();
  }

  /// Reset state to initial
  void reset() {
    state = const CivilRegistryState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}
