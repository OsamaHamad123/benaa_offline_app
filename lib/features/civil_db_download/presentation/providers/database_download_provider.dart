import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_download_service.dart';
import '../../domain/entities/download_progress.dart';

/// Download State
class DatabaseDownloadState {
  final DownloadProgress progress;
  final bool isAvailable;
  final int? databaseSize;

  const DatabaseDownloadState({
    required this.progress,
    required this.isAvailable,
    this.databaseSize,
  });

  DatabaseDownloadState copyWith({
    DownloadProgress? progress,
    bool? isAvailable,
    int? databaseSize,
  }) {
    return DatabaseDownloadState(
      progress: progress ?? this.progress,
      isAvailable: isAvailable ?? this.isAvailable,
      databaseSize: databaseSize ?? this.databaseSize,
    );
  }
}

/// Database Download Provider
class DatabaseDownloadNotifier extends StateNotifier<DatabaseDownloadState> {
  final DatabaseDownloadService _downloadService;

  DatabaseDownloadNotifier(this._downloadService)
    : super(
        DatabaseDownloadState(
          progress: DownloadProgress(
            downloadedBytes: 0,
            totalBytes: 0,
            percentage: 0,
            status: DownloadStatus.idle,
          ),
          isAvailable: false,
        ),
      ) {
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    final isAvailable = await _downloadService.isDatabaseAvailable();
    final size = await _downloadService.getDatabaseSize();

    state = state.copyWith(
      isAvailable: isAvailable,
      databaseSize: size > 0 ? size : null,
    );
  }

  Future<void> downloadDatabase(String url) async {
    try {
      await _downloadService.downloadDatabase(
        downloadUrl: url,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);

          if (progress.isComplete) {
            _checkDatabase();
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        progress: DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 0,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void cancelDownload() {
    _downloadService.cancelDownload();
    state = state.copyWith(
      progress: DownloadProgress(
        downloadedBytes: 0,
        totalBytes: 0,
        percentage: 0,
        status: DownloadStatus.cancelled,
      ),
    );
  }

  Future<void> deleteAndRedownload(String url) async {
    await _downloadService.deleteDatabase();
    state = state.copyWith(isAvailable: false, databaseSize: null);
    await downloadDatabase(url);
  }
}

/// Provider
final databaseDownloadServiceProvider = Provider<DatabaseDownloadService>((
  ref,
) {
  return DatabaseDownloadService();
});

final databaseDownloadProvider =
    StateNotifierProvider<DatabaseDownloadNotifier, DatabaseDownloadState>((
      ref,
    ) {
      final service = ref.watch(databaseDownloadServiceProvider);
      return DatabaseDownloadNotifier(service);
    });
