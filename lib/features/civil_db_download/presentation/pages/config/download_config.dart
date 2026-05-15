/// 📥 Database Download Configuration
class DownloadConfig {
  // DISABLED FOR PUBLIC GITHUB VERSION:
  // Real civil registry database download URLs have been removed.
  // These endpoints were connected to the company's civil registry server.
  // TODO: Replace with a new backend or Firebase Storage URL.
  static const String downloadUrl = 'https://disabled-api.example.com/civil-registry/download';

  // DISABLED FOR PUBLIC GITHUB VERSION:
  // File info URL has been disabled.
  static const String fileInfoUrl = 'https://disabled-api.example.com/civil-registry/info';

  /// Optional: Fallback URLs in case primary fails
  static const List<String> fallbackUrls = [
    // 'https://backup-cdn.com/persons.db.gz',
    // 'https://mirror.example.com/persons.db.gz',
  ];

  /// Expected database size (for validation)
  static const int expectedSizeMB = 420;

  /// Minimum acceptable size (MB) - to detect incomplete downloads
  static const int minAcceptableSizeMB = 100;

  /// SharedPreferences key for skip status
  static const String skipPreferenceKey = 'civil_db_download_skipped';
}
