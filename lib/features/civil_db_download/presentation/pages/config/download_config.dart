/// 📥 Database Download Configuration
class DownloadConfig {
  /// 🔗 Server Download URL (Admin Only - requires Bearer Token)
  static const String downloadUrl = 'https://palestine.benaadev.org/api/mobile/database/persons-file/download';

  /// 🔗 File Info URL (to get size and metadata)
  static const String fileInfoUrl = 'https://palestine.benaadev.org/api/mobile/database/persons-file/info';

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
