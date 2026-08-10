import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import 'beneficiary_dependencies_provider.dart';
import '../../../dashboard/domain/usecases/log_activity.dart';
import '../../../dashboard/presentation/providers/activity_providers.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../core/error_handling/result.dart';

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
  final LogActivity? _logActivity;

  BeneficiaryFormNotifier(
    this._createUseCase,
    this._updateUseCase,
    this._getUseCase,
    this._loadFromCivilRegistry, {
    LogActivity? logActivity,
  })  : _logActivity = logActivity,
        super(const BeneficiaryFormState());

  /// Load existing beneficiary by ID
  Future<void> loadBeneficiary(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getUseCase.execute(id);

      if (result is Failure<Beneficiary>) {
        throw Exception(result.error.message);
      }

      final beneficiary = (result as Success<Beneficiary>).value;
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _loadFromCivilRegistry.execute(nationalId);

      if (result is Failure<Map<String, dynamic>>) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على بيانات للرقم الوطني: $nationalId',
        );
        return;
      }

      final data = (result as Success<Map<String, dynamic>>).value;

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
      errorMessage: null,
    );
  }

  /// Save beneficiary
  Future<bool> save() async {
    if (state.beneficiary == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final beneficiary = state.beneficiary!;
      final now = DateTime.now();
      final fullName = beneficiary.fullName;

      if (state.isNew) {
        // Create new
        final createResult = await _createUseCase.execute(
          beneficiary.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: now,
            updatedAt: now,
          ),
        );

        if (createResult is Failure<Beneficiary>) {
          throw Exception(createResult.error.message);
        }

        final created = (createResult as Success<Beneficiary>).value;

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

        final updated = (updateResult as Success<Beneficiary>).value;

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
    state = state.copyWith(errorMessage: null);
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
final beneficiaryFormProvider =
    StateNotifierProvider<BeneficiaryFormNotifier, BeneficiaryFormState>((ref) {
  final dependencies = ref.watch(beneficiaryDependenciesProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);

  return BeneficiaryFormNotifier(
    dependencies.createUseCase,
    dependencies.updateUseCase,
    dependencies.getUseCase,
    dependencies.loadFromCivilRegistryUseCase,
    logActivity: logActivity,
  );
});
