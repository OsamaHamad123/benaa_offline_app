import '../../domain/entities/civil_db_status.dart';
import '../../domain/repositories/civil_db_repository.dart';
import '../datasources/civil_db_manager.dart';

/// 📦 Civil Database Repository Implementation
///
/// Implements the repository interface using CivilDbManager
class CivilDbRepositoryImpl implements CivilDbRepository {
  final CivilDbManager manager;

  const CivilDbRepositoryImpl(this.manager);

  @override
  Future<CivilDbStatus> checkStatus() async {
    return await manager.checkStatus();
  }

  @override
  Stream<CivilDbStatus> downloadDatabase(String downloadUrl) {
    return manager.downloadDatabase(downloadUrl);
  }

  @override
  Future<void> cancelDownload() async {
    await manager.cancelDownload();
  }

  @override
  Future<void> deleteDatabase() async {
    await manager.deleteDatabase();
  }

  @override
  Future<String?> getLocalDbPath() async {
    final isDownloaded = await manager.isDatabaseDownloaded();
    if (!isDownloaded) return null;
    return await manager.getLocalDbPath();
  }
}
