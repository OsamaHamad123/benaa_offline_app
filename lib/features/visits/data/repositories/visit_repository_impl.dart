import '../../domain/entities/visit_entity.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_local_datasource.dart';
import '../models/visit_model.dart';

/// Visit Repository Implementation
class VisitRepositoryImpl implements VisitRepository {
  final VisitLocalDataSource localDataSource;

  const VisitRepositoryImpl(this.localDataSource);

  @override
  Future<void> createVisit(VisitEntity visit) async {
    final companion = VisitModel.toDrift(visit);
    await localDataSource.insertVisit(companion);
  }

  @override
  Future<List<VisitEntity>> getBeneficiaryVisits(String beneficiaryId) async {
    final models = await localDataSource.getBeneficiaryVisits(beneficiaryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<VisitEntity?> getVisitById(String id) async {
    final model = await localDataSource.getVisitById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateVisit(VisitEntity visit) async {
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
    throw UnimplementedError('Update visit needs proper Drift implementation');
  }

  @override
  Future<void> deleteVisit(String id) async {
    await localDataSource.deleteVisit(id);
  }

  @override
  Future<int> countBeneficiaryVisits(String beneficiaryId) async {
    return await localDataSource.countBeneficiaryVisits(beneficiaryId);
  }

  @override
  Future<DateTime?> getLastVisitDate(String beneficiaryId) async {
    return await localDataSource.getLastVisitDate(beneficiaryId);
  }

  @override
  Future<List<VisitEntity>> getRecentVisits({int limit = 20}) async {
    final models = await localDataSource.getRecentVisits(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> countVisitsToday() async {
    return await localDataSource.countVisitsToday();
  }

  @override
  Future<double> getAverageVisitsPerDay(int days) async {
    return await localDataSource.getAverageVisitsPerDay(days);
  }
}
