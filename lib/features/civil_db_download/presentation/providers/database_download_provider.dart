import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/notifications/notifications_service.dart';
import '../../data/datasources/database_download_service.dart';
import '../../domain/entities/download_progress.dart';
import '../pages/config/download_config.dart';

/// Download State
class DatabaseDownloadState {
  final DownloadProgress progress;
  final bool isAvailable;
  final bool wasSkipped;
  final int? databaseSize;
  final DateTime? downloadDate;

  const DatabaseDownloadState({
    required this.progress,
    required this.isAvailable,
    this.wasSkipped = false,
    this.databaseSize,
    this.downloadDate,
  });

  /// هل يمكن المتابعة (إما موجود أو تم تخطيه)
  bool get canProceed => isAvailable || wasSkipped;

  DatabaseDownloadState copyWith({
    DownloadProgress? progress,
    bool? isAvailable,
    bool? wasSkipped,
    int? databaseSize,
    DateTime? downloadDate,
  }) {
    return DatabaseDownloadState(
      progress: progress ?? this.progress,
      isAvailable: isAvailable ?? this.isAvailable,
      wasSkipped: wasSkipped ?? this.wasSkipped,
      databaseSize: databaseSize ?? this.databaseSize,
      downloadDate: downloadDate ?? this.downloadDate,
    );
  }

  /// تنسيق حجم الملف للعرض
  String get fileSizeFormatted {
    if (databaseSize == null) return 'غير معروف';

    final bytes = databaseSize!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Default/Initial state
  factory DatabaseDownloadState.initial() {
    return DatabaseDownloadState(
      progress: DownloadProgress(
        downloadedBytes: 0,
        totalBytes: 0,
        percentage: 0,
        status: DownloadStatus.idle,
      ),
      isAvailable: false,
    );
  }
}

/// Database Download Provider - يستخدم StateNotifier مع keepAlive
class DatabaseDownloadNotifier extends StateNotifier<DatabaseDownloadState> {
  final DatabaseDownloadService _downloadService;
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  int _lastNotifiedProgress = -1;

  DatabaseDownloadNotifier(this._downloadService) : super(DatabaseDownloadState.initial()) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    await _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    if (!mounted) return;

    final isAvailable = await _downloadService.isDatabaseAvailable();
    final size = await _downloadService.getDatabaseSize();
    final downloadDate = await _downloadService.getDownloadDate();
    final wasSkipped = _prefs?.getBool(DownloadConfig.skipPreferenceKey) ?? false;

    if (kDebugMode) {
      debugPrint('📊 Database check: isAvailable=$isAvailable, size=$size, wasSkipped=$wasSkipped');
    }

    if (!mounted) return;

    state = state.copyWith(
      isAvailable: isAvailable,
      databaseSize: size > 0 ? size : null,
      downloadDate: downloadDate,
      wasSkipped: wasSkipped,
    );
  }

  /// Public method to refresh database status
  Future<void> checkDatabase() async {
    await _init();
    await _checkDatabase();
  }

  /// تخطي التحميل (مع الحفظ)
  Future<void> skipDownload() async {
    await _init();
    await _prefs?.setBool(DownloadConfig.skipPreferenceKey, true);

    if (!mounted) return;
    state = state.copyWith(wasSkipped: true);

    if (kDebugMode) {
      debugPrint('⏭️ Download skipped and saved');
    }
  }

  /// إلغاء التخطي (عند بدء التحميل)
  Future<void> clearSkipStatus() async {
    await _init();
    await _prefs?.remove(DownloadConfig.skipPreferenceKey);

    if (!mounted) return;
    state = state.copyWith(wasSkipped: false);
  }

  /// تحميل قاعدة البيانات
  Future<void> downloadDatabase(String url) async {
    await _init();
    // عند بدء التحميل، نلغي حالة التخطي
    await clearSkipStatus();
    _lastNotifiedProgress = -1;

    await NotificationsService.requestPermissions();

    try {
      await _downloadService.downloadDatabase(
        downloadUrl: url,
        onProgress: (progress) {
          if (!mounted) return;
          state = state.copyWith(progress: progress);

          _handleCivilDbProgressNotification(progress);

          if (progress.isComplete) {
            _checkDatabase();
          }
        },
      );

      await NotificationsService.showCivilDbDownloadCompleted();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        progress: DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 0,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      );

      await NotificationsService.showCivilDbDownloadFailed(_extractErrorMessage(e));
    }
  }

  /// إلغاء التحميل
  void cancelDownload() {
    _downloadService.cancelDownload();
    final current = state.progress;

    if (!mounted) return;
    state = state.copyWith(
      progress: DownloadProgress(
        downloadedBytes: current.downloadedBytes,
        totalBytes: current.totalBytes,
        percentage: current.percentage,
        status: DownloadStatus.cancelled,
      ),
    );

    NotificationsService.showCivilDbDownloadCancelled();
  }

  /// حذف وإعادة التحميل
  Future<void> deleteAndRedownload(String url) async {
    await _downloadService.deleteDatabase();
    await clearSkipStatus();

    if (!mounted) return;
    state = state.copyWith(isAvailable: false);

    await downloadDatabase(url);
  }

  void _handleCivilDbProgressNotification(DownloadProgress progress) {
    if (progress.status == DownloadStatus.downloading) {
      final roundedProgress = progress.percentage.round();
      if (_lastNotifiedProgress == roundedProgress) {
        return;
      }

      _lastNotifiedProgress = roundedProgress;
      NotificationsService.showCivilDbDownloadProgress(
        percentage: progress.percentage,
        subtitle: '${progress.downloadedSize} / ${progress.totalSize}',
      );
      return;
    }

    if (progress.status == DownloadStatus.extracting) {
      NotificationsService.showCivilDbDownloadProgress(
        percentage: progress.percentage,
        subtitle: 'جاري فك ضغط الملف...',
      );
      return;
    }

    if (progress.status == DownloadStatus.verifying) {
      NotificationsService.showCivilDbDownloadProgress(
        percentage: progress.percentage,
        subtitle: 'جاري التحقق من سلامة قاعدة البيانات...',
      );
      return;
    }

    if (progress.status == DownloadStatus.cancelled) {
      NotificationsService.showCivilDbDownloadCancelled();
      return;
    }

    if (progress.status == DownloadStatus.failed) {
      NotificationsService.showCivilDbDownloadFailed(
        progress.errorMessage ?? 'حدث خطأ أثناء تنزيل السجل المدني.',
      );
    }
  }

  String _extractErrorMessage(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'حدث خطأ أثناء تنزيل السجل المدني.';
    }
    return text;
  }
}

/// Provider for DatabaseDownloadService
final databaseDownloadServiceProvider = Provider<DatabaseDownloadService>((ref) {
  return DatabaseDownloadService();
});

/// Database Download Provider - مع keepAlive لتجنب dispose المبكر
final databaseDownloadProvider = StateNotifierProvider<DatabaseDownloadNotifier, DatabaseDownloadState>((ref) {
  // keepAlive لمنع dispose عند عدم الاستخدام
  ref.keepAlive();

  final service = ref.watch(databaseDownloadServiceProvider);
  return DatabaseDownloadNotifier(service);
});
