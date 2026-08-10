import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_beneficiary_details_usecase.dart';
import '../../../domain/usecases/delete_beneficiary_usecase.dart';
import '../../../data/datasources/beneficiary_local_datasource.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../../../core/providers/providers.dart';

/// State: Beneficiary Details State
class BeneficiaryDetailsState {
  final BeneficiaryModel? beneficiary;
  final bool isLoading;
  final String? errorMessage;
  final bool isDeleting;

  BeneficiaryDetailsState({
    this.beneficiary,
    this.isLoading = false,
    this.errorMessage,
    this.isDeleting = false,
  });

  BeneficiaryDetailsState copyWith({
    BeneficiaryModel? beneficiary,
    bool? isLoading,
    String? errorMessage,
    bool? isDeleting,
    bool clearError = false,
  }) {
    return BeneficiaryDetailsState(
      beneficiary: beneficiary ?? this.beneficiary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

/// Notifier: Beneficiary Details Notifier
class BeneficiaryDetailsNotifier
    extends StateNotifier<BeneficiaryDetailsState> {
  final GetBeneficiaryDetailsUseCase _getBeneficiaryDetailsUseCase;
  final DeleteBeneficiaryUseCase _deleteBeneficiaryUseCase;

  BeneficiaryDetailsNotifier(
    this._getBeneficiaryDetailsUseCase,
    this._deleteBeneficiaryUseCase,
  ) : super(BeneficiaryDetailsState());

  /// Load beneficiary details
  Future<void> loadBeneficiary(int beneficiaryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final beneficiary = await _getBeneficiaryDetailsUseCase.execute(
        beneficiaryId,
      );

      state = state.copyWith(beneficiary: beneficiary, isLoading: false);
    } on BeneficiaryNotFoundException {
      state = state.copyWith(
        errorMessage: 'لم يتم العثور على المستفيد',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'خطأ في تحميل البيانات: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Delete beneficiary
  Future<bool> deleteBeneficiary(int beneficiaryId) async {
    state = state.copyWith(isDeleting: true);

    try {
      await _deleteBeneficiaryUseCase.execute(beneficiaryId);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'خطأ في الحذف: ${e.toString()}',
        isDeleting: false,
      );
      return false;
    }
  }

  /// Refresh beneficiary data
  Future<void> refresh(int beneficiaryId) async {
    await loadBeneficiary(beneficiaryId);
  }
}

/// Provider: Beneficiary Details Provider
final beneficiaryDetailsProvider =
    StateNotifierProvider<BeneficiaryDetailsNotifier, BeneficiaryDetailsState>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  final dataSource = BeneficiaryLocalDataSource(database);
  final getBeneficiaryDetailsUseCase = GetBeneficiaryDetailsUseCase(
    dataSource,
  );
  final deleteBeneficiaryUseCase = DeleteBeneficiaryUseCase(dataSource);

  return BeneficiaryDetailsNotifier(
    getBeneficiaryDetailsUseCase,
    deleteBeneficiaryUseCase,
  );
});
