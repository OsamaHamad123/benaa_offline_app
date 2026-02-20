import '../../../../core/error_handling/result.dart';
import '../../../../data/db/daos/file_id_reservation_dao.dart';
import '../../domain/repositories/file_id_reservation_repository.dart';
import '../datasources/file_id_remote_datasource.dart';

/// 🆔 File ID Reservation Repository Implementation
class FileIdReservationRepositoryImpl implements FileIdReservationRepository {
  final FileIdRemoteDataSource remoteDataSource;
  final FileIdReservationDao localDao;

  FileIdReservationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDao,
  });

  @override
  Future<Result<List<int>>> reserveFromRemote(int count) async {
    try {
      final ids = await remoteDataSource.reserveIds(count);
      return Success(ids);
    } catch (e) {
      return Failure(NetworkFailure('Failed to reserve IDs: $e'));
    }
  }

  @override
  Future<Result<void>> saveLocal(List<int> ids) async {
    try {
      await localDao.insertReservedIds(ids);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to save IDs locally: $e'));
    }
  }

  @override
  Future<Result<int?>> getNextAvailableId() async {
    try {
      final id = await localDao.getNextAvailableId();
      return Success(id);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to get next ID: $e'));
    }
  }

  @override
  Future<Result<void>> markAsUsed(int fileId, int beneficiaryId) async {
    try {
      await localDao.markAsUsed(fileId, beneficiaryId);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to mark ID as used: $e'));
    }
  }

  @override
  Future<Result<void>> syncUsedIds() async {
    try {
      final usedRecords = await localDao.getUsedUnsyncedIds();
      if (usedRecords.isEmpty) return const Success(null);

      final ids = usedRecords.map((r) => r.fileId).toList();
      await remoteDataSource.syncUsedIds(ids);

      await localDao.markAsSynced(ids);
      return const Success(null);
    } catch (e) {
      return Failure(NetworkFailure('Failed to sync used IDs: $e'));
    }
  }

  @override
  Future<Result<int>> getAvailableCount() async {
    try {
      final count = await localDao.countAvailable();
      return Success(count);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to count available IDs: $e'));
    }
  }
}
