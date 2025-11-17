import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import 'beneficiary_dependencies_provider.dart';

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

  BeneficiaryFormNotifier(
    this._createUseCase,
    this._updateUseCase,
    this._getUseCase,
    this._loadFromCivilRegistry,
  ) : super(const BeneficiaryFormState());

  /// Load existing beneficiary by ID
  Future<void> loadBeneficiary(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final beneficiary = await _getUseCase.execute(id);
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
      final data = await _loadFromCivilRegistry.execute(nationalId);

      if (data == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على بيانات للرقم الوطني: $nationalId',
        );
        return;
      }

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

      if (state.isNew) {
        // Create new
        final created = await _createUseCase.execute(
          beneficiary.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: now,
            updatedAt: now,
          ),
        );
        state = state.copyWith(
          beneficiary: created,
          isSaving: false,
          hasUnsavedChanges: false,
          lastSaved: now,
        );
      } else {
        // Update existing
        final updated = await _updateUseCase.execute(
          beneficiary.copyWith(updatedAt: now),
        );
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
      print('❌ Error saving beneficiary: $e');
      print('📋 Stack trace: $stackTrace');

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
      return BeneficiaryFormNotifier(
        dependencies.createUseCase,
        dependencies.updateUseCase,
        dependencies.getUseCase,
        dependencies.loadFromCivilRegistryUseCase,
      );
    });
