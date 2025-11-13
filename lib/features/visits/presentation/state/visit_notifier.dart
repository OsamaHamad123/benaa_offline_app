import 'package:riverpod/riverpod.dart';
import '../state/visit_state.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/get_beneficiary_visits.dart';

/// Visit Notifier for State Management
class VisitNotifier extends StateNotifier<VisitState> {
  final CreateVisit _createVisit;
  final GetBeneficiaryVisits _getBeneficiaryVisits;

  VisitNotifier({
    required CreateVisit createVisit,
    required GetBeneficiaryVisits getBeneficiaryVisits,
  }) : _createVisit = createVisit,
       _getBeneficiaryVisits = getBeneficiaryVisits,
       super(const VisitState());

  /// Load visits for a beneficiary
  Future<void> loadBeneficiaryVisits(String beneficiaryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final visits = await _getBeneficiaryVisits(beneficiaryId);
      state = state.copyWith(
        visits: visits,
        isLoading: false,
        totalVisits: visits.length,
        lastVisitDate: visits.isNotEmpty ? visits.first.visitDate : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الزيارات: ${e.toString()}',
      );
    }
  }

  /// Create a new visit
  Future<bool> createNewVisit(VisitEntity visit) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _createVisit(visit);

      // Reload visits to update the list
      await loadBeneficiaryVisits(visit.beneficiaryId);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل إنشاء الزيارة: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
