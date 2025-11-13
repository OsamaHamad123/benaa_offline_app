/// 📊 Civil Database Status Entity
///
/// Domain entity representing the state of civil registry database
enum CivilDbStatusType {
  /// Database not downloaded yet
  notDownloaded,

  /// Database is being downloaded
  downloading,

  /// Database downloaded and ready
  ready,

  /// Database needs update
  needsUpdate,

  /// Download failed
  error,
}

/// Civil Database Status
class CivilDbStatus {
  final CivilDbStatusType status;
  final String? filePath;
  final int? fileSize;
  final double? downloadProgress;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const CivilDbStatus({
    required this.status,
    this.filePath,
    this.fileSize,
    this.downloadProgress,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Check if database is ready to use
  bool get isReady => status == CivilDbStatusType.ready;

  /// Check if download is in progress
  bool get isDownloading => status == CivilDbStatusType.downloading;

  /// Check if there's an error
  bool get hasError => status == CivilDbStatusType.error;

  /// Copy with modifications
  CivilDbStatus copyWith({
    CivilDbStatusType? status,
    String? filePath,
    int? fileSize,
    double? downloadProgress,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return CivilDbStatus(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'CivilDbStatus(status: $status, progress: $downloadProgress)';
  }
}
