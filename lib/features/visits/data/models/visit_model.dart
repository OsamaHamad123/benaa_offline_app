import '../../domain/entities/visit_entity.dart';
import '../../../../data/db/drift_database.dart';
import 'package:drift/drift.dart';

/// Visit Model - extends Visit Entity with fromDrift/toDrift conversion
class VisitModel extends VisitEntity {
  const VisitModel({
    required super.id,
    required super.beneficiaryId,
    required super.visitDate,
    required super.staffName,
    required super.notes,
    required super.isSubmitted,
    required super.createdAt,
    required super.updatedAt,
    required super.syncState,
  });

  /// Convert from Drift Visit to VisitModel
  factory VisitModel.fromDrift(Visit visit) {
    return VisitModel(
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
  }

  /// Convert VisitEntity to Drift VisitsCompanion
  static VisitsCompanion toDrift(VisitEntity entity) {
    return VisitsCompanion.insert(
      id: entity.id,
      beneficiaryId: entity.beneficiaryId,
      visitDate: entity.visitDate,
      staffName: entity.staffName,
      notes: Value(entity.notes),
      isSubmitted: Value(entity.isSubmitted),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncState: Value(entity.syncState),
    );
  }

  /// Convert VisitModel to VisitEntity
  VisitEntity toEntity() => this;
}
