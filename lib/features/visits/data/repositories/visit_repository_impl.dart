import '../../domain/entities/visit_entity.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_local_datasource.dart';
import '../models/visit_model.dart';
import '../../../../core/error_handling/result.dart';

/// Visit Repository Implementation
class VisitRepositoryImpl implements VisitRepository {
  final VisitLocalDataSource localDataSource;

  const VisitRepositoryImpl(this.localDataSource);

  @override
  Future<Result<void>> createVisit(VisitEntity visit) async {
    try {
      final companion = VisitModel.toDrift(visit);
      await localDataSource.insertVisit(companion);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to create visit: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<VisitEntity>>> getBeneficiaryVisits(
      String beneficiaryId) async {
    try {
      final models = await localDataSource.getBeneficiaryVisits(beneficiaryId);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get beneficiary visits: $e', stackTrace));
    }
  }

  @override
  Future<Result<VisitEntity>> getVisitById(String id) async {
    try {
      final model = await localDataSource.getVisitById(id);
      if (model == null) {
        return Failure(NotFoundFailure('Visit not found with ID: $id'));
      }
      return Success(model.toEntity());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to get visit: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> updateVisit(VisitEntity visit) async {
    try {
      // Convert entity to Drift Visit object for update
      final _ = VisitModel(
        id: visit.id,
        beneficiaryId: visit.beneficiaryId,
        visitDate: visit.visitDate,
        staffName: visit.staffName,
        notes: visit.notes,
        isSubmitted: visit.isSubmitted,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
        syncState: visit.syncState,
      );

      // Note: This needs a Drift Visit object, not a model
      // You may need to add a method in datasource to handle this
      return const Failure(
          UnknownFailure('Update visit needs proper Drift implementation'));
    } catch (e, stackTrace) {
      return Failure(UnknownFailure('Failed to update visit: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteVisit(String id) async {
    try {
      await localDataSource.deleteVisit(id);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to delete visit: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> countBeneficiaryVisits(String beneficiaryId) async {
    try {
      final count = await localDataSource.countBeneficiaryVisits(beneficiaryId);
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to count visits: $e', stackTrace));
    }
  }

  @override
  Future<Result<DateTime>> getLastVisitDate(String beneficiaryId) async {
    try {
      final date = await localDataSource.getLastVisitDate(beneficiaryId);
      if (date == null) {
        return const Failure(NotFoundFailure('No visits found for beneficiary'));
      }
      return Success(date);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get last visit date: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<VisitEntity>>> getRecentVisits({int limit = 20}) async {
    try {
      final models = await localDataSource.getRecentVisits(limit: limit);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get recent visits: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> countVisitsToday() async {
    try {
      final count = await localDataSource.countVisitsToday();
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to count today visits: $e', stackTrace));
    }
  }

  @override
  Future<Result<double>> getAverageVisitsPerDay(int days) async {
    try {
      final average = await localDataSource.getAverageVisitsPerDay(days);
      return Success(average);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure(
          'Failed to calculate average visits: $e', stackTrace));
    }
  }
}
