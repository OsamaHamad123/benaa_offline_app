/// 📥 Database Download Configuration
class DownloadConfig {
  /// ⚠️ TODO: Replace with your actual server URL
  ///
  /// Example:
  /// static const downloadUrl = 'https://your-cdn.com/persons.db.gz';
  /// static const downloadUrl = 'https://storage.googleapis.com/your-bucket/persons.db.gz';
  /// static const downloadUrl = 'https://s3.amazonaws.com/your-bucket/persons.db.gz';
  static const String downloadUrl = 'YOUR_SERVER_URL_HERE';

  /// Optional: Fallback URLs in case primary fails
  static const List<String> fallbackUrls = [
    // 'https://backup-cdn.com/persons.db.gz',
    // 'https://mirror.example.com/persons.db.gz',
  ];

  /// Expected database size (for validation)
  static const int expectedSizeMB = 420;

  /// Minimum acceptable size (MB) - to detect incomplete downloads
  static const int minAcceptableSizeMB = 100;
}
