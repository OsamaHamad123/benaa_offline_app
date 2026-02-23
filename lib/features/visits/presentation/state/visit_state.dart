import 'package:equatable/equatable.dart';
import '../../domain/entities/visit_entity.dart';

/// Visit State for StateNotifier
class VisitState extends Equatable {
  final List<VisitEntity> visits;
  final bool isLoading;
  final String? errorMessage;
  final int? totalVisits;
  final DateTime? lastVisitDate;

  const VisitState({
    this.visits = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalVisits,
    this.lastVisitDate,
  });

  VisitState copyWith({
    List<VisitEntity>? visits,
    bool? isLoading,
    String? errorMessage,
    int? totalVisits,
    DateTime? lastVisitDate,
    bool clearErrorMessage = false,
  }) {
    return VisitState(
      visits: visits ?? this.visits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      totalVisits: totalVisits ?? this.totalVisits,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
    );
  }

  @override
  List<Object?> get props => [
        visits,
        isLoading,
        errorMessage,
        totalVisits,
        lastVisitDate,
      ];
}
