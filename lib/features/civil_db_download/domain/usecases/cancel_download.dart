import '../repositories/civil_db_repository.dart';

/// ❌ Cancel Download Use Case
///
/// Use case to cancel ongoing database download
class CancelDownloadUseCase {
  final CivilDbRepository repository;

  const CancelDownloadUseCase(this.repository);

  /// Execute the use case
  Future<void> call() async {
    await repository.cancelDownload();
  }
}
