import '../entities/civil_db_status.dart';

/// 📦 Civil Database Repository Interface
///
/// Domain layer - defines contract for civil database operations
abstract class CivilDbRepository {
  /// Check current status of civil registry database
  Future<CivilDbStatus> checkStatus();

  /// Download civil registry database from server
  /// Returns a stream of download progress
  Stream<CivilDbStatus> downloadDatabase(String downloadUrl);

  /// Cancel ongoing download
  Future<void> cancelDownload();

  /// Delete downloaded database (for re-download)
  Future<void> deleteDatabase();

  /// Get local database file path if exists
  Future<String?> getLocalDbPath();
}
