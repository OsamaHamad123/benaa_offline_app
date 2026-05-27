import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import 'beneficiary_dependencies_provider.dart';
import '../../../dashboard/domain/usecases/log_activity.dart';
import '../../../dashboard/presentation/providers/activity_providers.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../core/error_handling/result.dart';
import '../../../sync/presentation/providers/file_id_providers.dart';
import '../../../sync/services/file_id_service.dart';

/// 🎯 Beneficiary Form State
class BeneficiaryFormState {
  final Beneficiary? beneficiary;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool hasUnsavedChanges;
  final DateTime? lastSaved;

  const BeneficiaryFormState({
    this.beneficiary,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.hasUnsavedChanges = false,
    this.lastSaved,
  });

  BeneficiaryFormState copyWith({
    Beneficiary? beneficiary,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? hasUnsavedChanges,
    DateTime? lastSaved,
  }) {
    return BeneficiaryFormState(
      beneficiary: beneficiary ?? this.beneficiary,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  bool get isNew => beneficiary == null || beneficiary!.id.isEmpty;
  bool get canSave => !isLoading && !isSaving && beneficiary != null;
}

/// 📝 Beneficiary Form Notifier
class BeneficiaryFormNotifier extends StateNotifier<BeneficiaryFormState> {
  final CreateBeneficiaryUseCase _createUseCase;
  final UpdateBeneficiaryUseCase _updateUseCase;
  final GetBeneficiaryUseCase _getUseCase;
  final LoadFromCivilRegistryUseCase _loadFromCivilRegistry;
  final FileIdService _fileIdService;
  final LogActivity? _logActivity;

  BeneficiaryFormNotifier(
    this._createUseCase,
    this._updateUseCase,
    this._getUseCase,
    this._loadFromCivilRegistry,
    this._fileIdService, {
    LogActivity? logActivity,
  })  : _logActivity = logActivity,
        super(const BeneficiaryFormState());

  /// Load existing beneficiary by ID
  Future<void> loadBeneficiary(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _getUseCase.execute(id);

      if (result is Failure<Beneficiary>) {
        throw Exception(result.error.message);
      }
      if (result is! Success<Beneficiary>) {
        throw Exception('Unexpected repository result type: ${result.runtimeType}');
      }
      final beneficiary = result.value;
      state = state.copyWith(
        beneficiary: beneficiary,
        isLoading: false,
        hasUnsavedChanges: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل بيانات المستفيد: ${e.toString()}',
      );
    }
  }

  /// Create new empty beneficiary
  void createNew() {
    final now = DateTime.now();
    state = state.copyWith(
      beneficiary: Beneficiary(
        id: '', // Will be generated on save
        fullName: '',
        nationalId: '',
        gender: Gender.male,
        category: BeneficiaryCategory.poor,
        createdAt: now,
        updatedAt: now,
      ),
      hasUnsavedChanges: false,
    );
  }

  /// Load data from civil registry
  Future<void> loadFromCivilRegistry(String nationalId) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _loadFromCivilRegistry.execute(nationalId);

      if (result is Failure<Map<String, dynamic>>) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على بيانات للرقم الوطني: $nationalId',
        );
        return;
      }

      if (result is! Success<Map<String, dynamic>>) {
        throw Exception('Unexpected repository result type: ${result.runtimeType}');
      }

      final data = result.value;

      // Update current beneficiary with civil registry data
      final updated = state.beneficiary?.copyWith(
        fullName: data['fullName'] as String?,
        nationalId: nationalId,
        motherName: data['motherName'] as String?,
        birthDate: data['birthDate'] as DateTime?,
        gender: _parseGender(data['gender'] as String?),
        governorate: data['governorate'] as String?,
        district: data['district'] as String?,
        address: data['address'] as String?,
      );

      state = state.copyWith(
        beneficiary: updated,
        isLoading: false,
        hasUnsavedChanges: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل بيانات السجل المدني: ${e.toString()}',
      );
    }
  }

  /// Update beneficiary field
  void updateField(Beneficiary Function(Beneficiary) updater) {
    if (state.beneficiary == null) return;

    final updated = updater(state.beneficiary!);
    state = state.copyWith(
      beneficiary: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Save beneficiary
  Future<bool> save() async {
    if (state.beneficiary == null) return false;

    state = state.copyWith(isSaving: true);

    var attemptedFileNumberForDiagnostics = '';
    var assignedBeforePersistence = false;
    var persistedLocalEntity = false;

    try {
      final beneficiary = state.beneficiary!;
      final now = DateTime.now();
      final fullName = beneficiary.fullName;

      if (state.isNew) {
        var attemptedFileNumber = '';
        var duplicateCheckStatus = 'handled_in_form_layer';
        var validationStatus = 'passed';
        var localSaveStatus = 'not_started';

        final poolSnapshot = await _fileIdService.getLocalPoolSnapshot();
        final hasFileNumberPool = poolSnapshot != null;
        var availableFileNumbers = poolSnapshot?.available ?? 0;

        // 🆔 Allocate official file number from local offline-first pool.
        var fileNumber = await _fileIdService.getNextFileNumber();

        if (fileNumber == null || fileNumber.trim().isEmpty) {
          await _fileIdService.forceReserve();
          fileNumber = await _fileIdService.getNextFileNumber();
        }

        if (fileNumber == null || fileNumber.trim().isEmpty) {
          validationStatus = 'blocked_no_file_number';
          localSaveStatus = 'blocked';
          DebugLogger.warning('File ID reservation unavailable. Blocking beneficiary save.');
          DebugLogger.warning('Save failed before file number assignment.');
          DebugLogger.warning(
            '[BeneficiarySave] summary hasFileNumberPool=$hasFileNumberPool availableFileNumbers=$availableFileNumbers attemptedFileNumber=$attemptedFileNumber duplicateCheckStatus=$duplicateCheckStatus validationStatus=$validationStatus localSaveStatus=$localSaveStatus',
          );
          Sentry.addBreadcrumb(
            Breadcrumb(
              category: 'beneficiary.save',
              message: 'Save blocked: missing reserved file ID',
              level: SentryLevel.warning,
            ),
          );
          final reasonMessage = await _fileIdService.buildNoFileIdSaveMessage();
          state = state.copyWith(
            isSaving: false,
            errorMessage: reasonMessage,
          );
          return false;
        }

        attemptedFileNumber = fileNumber;
        attemptedFileNumberForDiagnostics = fileNumber;

        final generatedLocalId = DateTime.now().millisecondsSinceEpoch.toString();
        final generatedLocalIdInt = int.tryParse(generatedLocalId);
        if (generatedLocalIdInt != null) {
          await _fileIdService.assignFileNumberToBeneficiary(
            fileNumber: attemptedFileNumber,
            beneficiaryLocalId: generatedLocalIdInt,
          );
          assignedBeforePersistence = true;
          DebugLogger.info('[BeneficiarySave] file number assigned=$attemptedFileNumber');
        }

        // Create new
        localSaveStatus = 'in_progress';
        final createResult = await _createUseCase.execute(
          beneficiary.copyWith(
            id: generatedLocalId,
            fileNo: fileNumber,
            fileIdNumber: fileNumber,
            createdAt: now,
            updatedAt: now,
          ),
        );

        if (createResult is Failure<Beneficiary>) {
          localSaveStatus = 'failed';
          throw Exception(createResult.error.message);
        }
        if (createResult is! Success<Beneficiary>) {
          localSaveStatus = 'failed';
          throw Exception('Unexpected repository result type: ${createResult.runtimeType}');
        }
        final created = createResult.value;
        persistedLocalEntity = true;
        localSaveStatus = 'success';
        availableFileNumbers = (await _fileIdService.getLocalPoolSnapshot())?.available ?? availableFileNumbers;

        DebugLogger.info('[BeneficiarySave] save completed beneficiaryLocalId=${created.id}');
        DebugLogger.info(
          '[BeneficiarySave] summary hasFileNumberPool=$hasFileNumberPool availableFileNumbers=$availableFileNumbers attemptedFileNumber=$attemptedFileNumber duplicateCheckStatus=$duplicateCheckStatus validationStatus=$validationStatus localSaveStatus=$localSaveStatus',
        );

        // Log activity if available
        final logActivity = _logActivity;
        if (logActivity != null) {
          try {
            await logActivity(
              type: 'beneficiary',
              description: 'تم إضافة مستفيد جديد',
              beneficiaryId: created.id,
              beneficiaryName: fullName,
              metadata: {
                'action': 'create',
                'national_id': created.nationalId,
                'category': created.category.name,
              },
            );
          } catch (e) {
            DebugLogger.error('Failed to log activity', e);
          }
        }

        state = state.copyWith(
          beneficiary: created,
          isSaving: false,
          hasUnsavedChanges: false,
          lastSaved: now,
        );
      } else {
        // Update existing
        final updateResult = await _updateUseCase.execute(
          beneficiary.copyWith(updatedAt: now),
        );

        if (updateResult is Failure<Beneficiary>) {
          throw Exception(updateResult.error.message);
        }
        if (updateResult is! Success<Beneficiary>) {
          throw Exception('Unexpected repository result type: ${updateResult.runtimeType}');
        }
        final updated = updateResult.value;

        // Log activity if available
        final logActivity = _logActivity;
        if (logActivity != null) {
          try {
            await logActivity(
              type: 'beneficiary',
              description: 'تم تحديث بيانات المستفيد',
              beneficiaryId: updated.id,
              beneficiaryName: fullName,
              metadata: {'action': 'update'},
            );
          } catch (e) {
            DebugLogger.error('Failed to log activity', e);
          }
        }

        state = state.copyWith(
          beneficiary: updated,
          isSaving: false,
          hasUnsavedChanges: false,
          lastSaved: now,
        );
      }

      return true;
    } catch (e, stackTrace) {
      if (assignedBeforePersistence && !persistedLocalEntity && attemptedFileNumberForDiagnostics.isNotEmpty) {
        try {
          await _fileIdService.releaseAssignedFileNumber(attemptedFileNumberForDiagnostics);
          DebugLogger.warning(
            '[BeneficiarySave] save failed; file number released=$attemptedFileNumberForDiagnostics',
          );
          DebugLogger.warning('Save failed after file number assignment; number released.');
        } catch (releaseError) {
          DebugLogger.error('Failed to release assigned file number', releaseError);
        }
      } else {
        DebugLogger.warning('Save failed before file number assignment.');
      }

      final poolSnapshot = await _fileIdService.getLocalPoolSnapshot();
      DebugLogger.warning(
        '[BeneficiarySave] summary hasFileNumberPool=${poolSnapshot != null} '
        'availableFileNumbers=${poolSnapshot?.available ?? -1} '
        'attemptedFileNumber=$attemptedFileNumberForDiagnostics '
        'duplicateCheckStatus=handled_in_form_layer '
        'validationStatus=failed '
        'localSaveStatus=failed',
      );

      // Log the error with stack trace
      DebugLogger.error('Error saving beneficiary', e, stackTrace);

      // Report to Sentry
      await Sentry.captureException(e, stackTrace: stackTrace);

      state = state.copyWith(
        isSaving: false,
        errorMessage: 'فشل في حفظ البيانات: ${e.toString()}',
      );
      return false;
    }
  }

  /// Auto-save (debounced save)
  Future<void> autoSave() async {
    if (!state.hasUnsavedChanges || state.isNew) return;
    await save();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith();
  }

  /// Reset form
  void reset() {
    state = const BeneficiaryFormState();
  }

  Gender? _parseGender(String? value) {
    if (value == null) return null;
    try {
      return Gender.values.firstWhere(
        (e) => e.name == value.toLowerCase(),
        orElse: () => Gender.male,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Provider for beneficiary form
final beneficiaryFormProvider = StateNotifierProvider<BeneficiaryFormNotifier, BeneficiaryFormState>((ref) {
  final dependencies = ref.watch(beneficiaryDependenciesProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);
  final fileIdService = ref.watch(fileIdServiceProvider);

  return BeneficiaryFormNotifier(
    dependencies.createUseCase,
    dependencies.updateUseCase,
    dependencies.getUseCase,
    dependencies.loadFromCivilRegistryUseCase,
    fileIdService,
    logActivity: logActivity,
  );
});
