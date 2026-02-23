import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../core/error_handling/result.dart';
import '../../../../data/db/drift_database.dart';
import '../../domain/entities/association.dart' as domain;
import '../../domain/entities/representative.dart' as domain;
import '../../domain/repositories/association_repository.dart';

/// 🏢 Association Repository Implementation
class AssociationRepositoryImpl implements AssociationRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  AssociationRepositoryImpl(this.database);

  // ============================================================================
  // ASSOCIATIONS
  // ============================================================================

  @override
  Future<Result<List<domain.Association>>> getAllActiveAssociations() async {
    try {
      final associations =
          await database.associationsDao.getAllActiveAssociations();
      return Success(associations.map(_mapToDomain).toList());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل جلب الجمعيات', stackTrace));
    }
  }

  @override
  Future<Result<List<domain.Association>>> getAllAssociations() async {
    try {
      final associations = await database.associationsDao.getAllAssociations();
      return Success(associations.map(_mapToDomain).toList());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل جلب الجمعيات', stackTrace));
    }
  }

  @override
  Future<Result<domain.Association>> getAssociationById(String id) async {
    try {
      final association = await database.associationsDao.getAssociationById(id);

      if (association == null) {
        return const Failure(NotFoundFailure('الجمعية غير موجودة'));
      }

      return Success(_mapToDomain(association));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل جلب الجمعية', stackTrace));
    }
  }

  @override
  Future<Result<List<domain.Association>>> searchAssociations(
      String query) async {
    try {
      final associations =
          await database.associationsDao.searchAssociations(query);
      return Success(associations.map(_mapToDomain).toList());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل البحث عن الجمعيات', stackTrace));
    }
  }

  @override
  Future<Result<domain.Association>> createAssociation(
    AssociationParams params,
  ) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final companion = AssociationsCompanion(
        id: drift.Value(id),
        name: drift.Value(params.name.trim()),
        shortName: drift.Value(params.shortName?.trim()),
        phone: drift.Value(params.phone.trim()),
        email: drift.Value(params.email?.trim()),
        bankName: drift.Value(params.bankName.trim()),
        accountNumber: drift.Value(params.accountNumber.trim()),
        swiftCode: drift.Value(params.swiftCode?.trim()),
        bankPhone: drift.Value(params.bankPhone?.trim()),
        accountCurrency: drift.Value(params.accountCurrency),
        representativeId: drift.Value(params.representativeId),
        isActive: drift.Value(params.isActive),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      );

      await database.associationsDao.addAssociation(companion);

      // Get the created association
      final result = await database.associationsDao.getAssociationById(id);
      if (result == null) {
        return const Failure(DatabaseFailure('فشل إنشاء الجمعية'));
      }

      return Success(_mapToDomain(result));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل إضافة الجمعية: $e', stackTrace));
    }
  }

  @override
  Future<Result<domain.Association>> updateAssociation(
    domain.Association association,
  ) async {
    try {
      final companion = AssociationsCompanion(
        id: drift.Value(association.id),
        name: drift.Value(association.name),
        shortName: drift.Value(association.shortName),
        phone: drift.Value(association.phone),
        email: drift.Value(association.email),
        bankName: drift.Value(association.bankName),
        accountNumber: drift.Value(association.accountNumber),
        swiftCode: drift.Value(association.swiftCode),
        bankPhone: drift.Value(association.bankPhone),
        accountCurrency: drift.Value(association.accountCurrency),
        representativeId: drift.Value(association.representativeId),
        isActive: drift.Value(association.isActive),
        createdAt: drift.Value(association.createdAt),
        updatedAt: drift.Value(DateTime.now()),
        syncState: const drift.Value('pending'),
      );

      final success =
          await database.associationsDao.updateAssociation(companion);

      if (!success) {
        return const Failure(DatabaseFailure('فشل تحديث الجمعية'));
      }

      return Success(association.copyWith(updatedAt: DateTime.now()));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل تحديث الجمعية: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> deactivateAssociation(String id) async {
    try {
      await database.associationsDao.deactivateAssociation(id);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل تعطيل الجمعية', stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteAssociation(String id) async {
    try {
      await database.associationsDao.deleteAssociation(id);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل حذف الجمعية', stackTrace));
    }
  }

  @override
  Future<Result<int>> getActiveAssociationsCount() async {
    try {
      final count = await database.associationsDao.getActiveAssociationsCount();
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل حساب الجمعيات', stackTrace));
    }
  }

  // ============================================================================
  // REPRESENTATIVES
  // ============================================================================

  @override
  Future<Result<List<domain.Representative>>> getAllRepresentatives() async {
    try {
      final reps = await database.associationsDao.getAllRepresentatives();
      return Success(reps.map(_mapRepToDomain).toList());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل جلب المندوبين', stackTrace));
    }
  }

  @override
  Future<Result<domain.Representative>> getRepresentativeById(String id) async {
    try {
      final rep = await database.associationsDao.getRepresentativeById(id);

      if (rep == null) {
        return const Failure(NotFoundFailure('المندوب غير موجود'));
      }

      return Success(_mapRepToDomain(rep));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل جلب المندوب', stackTrace));
    }
  }

  @override
  Future<Result<List<domain.Representative>>> searchRepresentatives(
    String query,
  ) async {
    try {
      final reps = await database.associationsDao.searchRepresentatives(query);
      return Success(reps.map(_mapRepToDomain).toList());
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل البحث عن المندوبين', stackTrace));
    }
  }

  @override
  Future<Result<domain.Representative>> createRepresentative(
      String name) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final companion = AssociationRepresentativesCompanion(
        id: drift.Value(id),
        name: drift.Value(name.trim()),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      );

      await database.associationsDao.addRepresentative(companion);

      final result = await database.associationsDao.getRepresentativeById(id);
      if (result == null) {
        return const Failure(DatabaseFailure('فشل إنشاء المندوب'));
      }

      return Success(_mapRepToDomain(result));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل إضافة المندوب: $e', stackTrace));
    }
  }

  @override
  Future<Result<domain.Representative>> updateRepresentative(
    domain.Representative rep,
  ) async {
    try {
      final companion = AssociationRepresentativesCompanion(
        id: drift.Value(rep.id),
        name: drift.Value(rep.name),
        createdAt: drift.Value(rep.createdAt),
        updatedAt: drift.Value(DateTime.now()),
        syncState: const drift.Value('pending'),
      );

      final success =
          await database.associationsDao.updateRepresentative(companion);

      if (!success) {
        return const Failure(DatabaseFailure('فشل تحديث المندوب'));
      }

      return Success(rep.copyWith(updatedAt: DateTime.now()));
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل تحديث المندوب: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteRepresentative(String id) async {
    try {
      await database.associationsDao.deleteRepresentative(id);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('فشل حذف المندوب', stackTrace));
    }
  }

  // ============================================================================
  // MAPPERS
  // ============================================================================

  domain.Association _mapToDomain(Association db) {
    return domain.Association(
      id: db.id,
      name: db.name,
      shortName: db.shortName,
      phone: db.phone,
      email: db.email,
      bankName: db.bankName,
      accountNumber: db.accountNumber,
      swiftCode: db.swiftCode,
      bankPhone: db.bankPhone,
      accountCurrency: db.accountCurrency ?? 'IQD',
      representativeId: db.representativeId ?? '',
      isActive: db.isActive,
      createdAt: db.createdAt,
      updatedAt: db.updatedAt,
    );
  }

  domain.Representative _mapRepToDomain(Representative db) {
    return domain.Representative(
      id: db.id,
      name: db.name,
      createdAt: db.createdAt,
      updatedAt: db.updatedAt,
    );
  }
}
