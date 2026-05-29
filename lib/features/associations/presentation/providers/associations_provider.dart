import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import 'dart:developer' as developer;
import '../../domain/entities/association.dart';
import '../../domain/entities/representative.dart';
import '../../domain/usecases/get_all_active_associations.dart';
import '../../domain/usecases/get_association_by_id.dart';
import '../../domain/usecases/create_association.dart';
import '../../domain/usecases/update_association.dart';
import '../../domain/usecases/delete_association.dart';
import '../../domain/usecases/get_all_representatives.dart';
import '../../domain/usecases/create_representative.dart';
import '../../domain/usecases/search_associations.dart';
import '../../data/repositories/association_repository_impl.dart';
import '../../../../core/error_handling/result.dart';
import '../../domain/repositories/association_repository.dart';
import '../../data/dev/cedar_associations_seed.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// Association Repository Provider
final associationRepositoryProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return AssociationRepositoryImpl(database);
});

/// Use Cases Providers
final getAllActiveAssociationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return GetAllActiveAssociationsUseCase(repository);
});

final getAssociationByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return GetAssociationByIdUseCase(repository);
});

final createAssociationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return CreateAssociationUseCase(repository);
});

final updateAssociationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return UpdateAssociationUseCase(repository);
});

final deleteAssociationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return DeleteAssociationUseCase(repository);
});

final getAllRepresentativesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return GetAllRepresentativesUseCase(repository);
});

final createRepresentativeUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return CreateRepresentativeUseCase(repository);
});

final searchAssociationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return SearchAssociationsUseCase(repository);
});

final cedarAssociationsSeederProvider = Provider<CedarAssociationsSeeder>((ref) {
  final repository = ref.watch(associationRepositoryProvider);
  return CedarAssociationsSeeder(repository);
});

// ============================================================================
// STATE NOTIFIER
// ============================================================================

/// Associations State
class AssociationsState {
  final List<Association> associations;
  final List<Representative> representatives;
  final bool isLoading;
  final String? errorMessage;

  const AssociationsState({
    this.associations = const [],
    this.representatives = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AssociationsState copyWith({
    List<Association>? associations,
    List<Representative>? representatives,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AssociationsState(
      associations: associations ?? this.associations,
      representatives: representatives ?? this.representatives,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Associations State Notifier
class AssociationsNotifier extends StateNotifier<AssociationsState> {
  AssociationsNotifier(this._ref) : super(const AssociationsState());

  final Ref _ref;

  // ============================================================================
  // ASSOCIATIONS
  // ============================================================================

  /// تحميل جميع الجمعيات النشطة
  Future<void> loadAssociations() async {
    state = state.copyWith(isLoading: true);

    final useCase = _ref.read(getAllActiveAssociationsUseCaseProvider);
    final result = await useCase.execute();

    switch (result) {
      case Success(value: final associations):
        state = state.copyWith(
          associations: associations,
          isLoading: false,
        );
      case Failure(error: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// البحث عن جمعيات
  Future<void> searchAssociations(String query) async {
    state = state.copyWith(isLoading: true);

    final useCase = _ref.read(searchAssociationsUseCaseProvider);
    final result = await useCase.execute(query);

    switch (result) {
      case Success(value: final associations):
        state = state.copyWith(
          associations: associations,
          isLoading: false,
        );
      case Failure(error: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// إضافة جمعية جديدة
  Future<bool> createAssociation(AssociationParams params) async {
    state = state.copyWith(isLoading: true);

    final useCase = _ref.read(createAssociationUseCaseProvider);
    final result = await useCase.execute(params);

    switch (result) {
      case Success(value: final association):
        state = state.copyWith(
          associations: [...state.associations, association],
          isLoading: false,
        );
        return true;
      case Failure(error: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// تحديث جمعية
  Future<bool> updateAssociation(Association association) async {
    state = state.copyWith(isLoading: true);

    final useCase = _ref.read(updateAssociationUseCaseProvider);
    final result = await useCase.execute(association);

    switch (result) {
      case Success(value: final updatedAssociation):
        final updatedList =
            state.associations.map((a) => a.id == updatedAssociation.id ? updatedAssociation : a).toList();

        state = state.copyWith(
          associations: updatedList,
          isLoading: false,
        );
        return true;
      case Failure(error: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// حذف جمعية
  Future<bool> deleteAssociation(String id) async {
    state = state.copyWith(isLoading: true);

    final useCase = _ref.read(deleteAssociationUseCaseProvider);
    final result = await useCase.execute(id);

    switch (result) {
      case Success():
        final updatedList = state.associations.where((a) => a.id != id).toList();

        state = state.copyWith(
          associations: updatedList,
          isLoading: false,
        );
        return true;
      case Failure(error: final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  Future<CedarAssociationsSeedResult> seedCedarAssociations({bool force = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final seeder = _ref.read(cedarAssociationsSeederProvider);

    final result = await seeder.seedCedarAssociations(force: force);
    await loadAssociations();

    developer.log('[CedarAssociations] list refreshed', name: 'CedarAssociations');

    state = state.copyWith(isLoading: false);
    return result;
  }

  // ============================================================================
  // REPRESENTATIVES
  // ============================================================================

  /// تحميل جميع المندوبين
  Future<void> loadRepresentatives() async {
    final useCase = _ref.read(getAllRepresentativesUseCaseProvider);
    final result = await useCase.execute();

    if (result case Success(value: final representatives)) {
      state = state.copyWith(representatives: representatives);
    }
  }

  /// إضافة مندوب جديد
  Future<Representative?> createRepresentative(String name) async {
    final useCase = _ref.read(createRepresentativeUseCaseProvider);
    final result = await useCase.execute(name);

    switch (result) {
      case Success(value: final representative):
        state = state.copyWith(
          representatives: [...state.representatives, representative],
        );
        return representative;
      case Failure(error: final failure):
        state = state.copyWith(errorMessage: failure.message);
        return null;
    }
  }
}

/// Associations State Provider
final associationsProvider = StateNotifierProvider<AssociationsNotifier, AssociationsState>((ref) {
  return AssociationsNotifier(ref);
});
