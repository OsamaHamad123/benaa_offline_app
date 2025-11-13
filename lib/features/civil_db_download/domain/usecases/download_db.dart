import '../entities/civil_db_status.dart';
import '../repositories/civil_db_repository.dart';

/// ⬇️ Download Database Use Case
///
/// Use case to download civil registry database with progress tracking
class DownloadDbUseCase {
  final CivilDbRepository repository;

  const DownloadDbUseCase(this.repository);

  /// Execute the use case
  /// Returns a stream of download progress
  Stream<CivilDbStatus> call(String downloadUrl) {
    return repository.downloadDatabase(downloadUrl);
  }
}
