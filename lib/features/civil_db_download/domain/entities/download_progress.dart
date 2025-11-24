/// 📥 Download Progress Entity
class DownloadProgress {
  final int downloadedBytes;
  final int totalBytes;
  final double percentage;
  final DownloadStatus status;
  final String? errorMessage;

   DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.percentage,
    required this.status,
     
    this.errorMessage,
  });

  bool get isComplete => status == DownloadStatus.completed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get hasError => status == DownloadStatus.failed;

  String get displayPercentage => '${percentage.toStringAsFixed(1)}%';

  String get downloadedSize => _formatBytes(downloadedBytes);
  String get totalSize => _formatBytes(totalBytes);

  String get speedMBps => downloadSpeed != null
      ? '${downloadSpeed!.toStringAsFixed(2)} MB/s'
      : '0 MB/s';

  double? downloadSpeed; // MB per second

  DownloadProgress copyWith({
    int? downloadedBytes,
    int? totalBytes,
    double? percentage,
    DownloadStatus? status,
    String? errorMessage,
    double? downloadSpeed,
  }) {
    return DownloadProgress(
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    )..downloadSpeed = downloadSpeed ?? this.downloadSpeed;
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

enum DownloadStatus {
  idle,
  checking,
  downloading,
  extracting,
  verifying,
  completed,
  failed,
  cancelled,
}
