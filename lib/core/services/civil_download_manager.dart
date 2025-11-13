import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'civil_database_manager.dart';

/// حالة التحميل
enum DownloadState {
  idle, // جاهز
  downloading, // جاري التحميل
  paused, // متوقف مؤقتاً
  completed, // اكتمل
  failed, // فشل
  verifying, // جاري التحقق
  extracting, // جاري فك الضغط
}

/// معلومات التحميل
class DownloadProgress {
  final DownloadState state;
  final int downloadedBytes;
  final int totalBytes;
  final double speed; // بالبايت/ثانية
  final String? error;
  final DateTime? startTime;
  final DateTime? endTime;

  DownloadProgress({
    this.state = DownloadState.idle,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.speed = 0,
    this.error,
    this.startTime,
    this.endTime,
  });

  double get progress {
    if (totalBytes <= 0) return 0;
    return downloadedBytes / totalBytes;
  }

  String get progressPercent {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  String get downloadedFormatted {
    return _formatBytes(downloadedBytes);
  }

  String get totalFormatted {
    return _formatBytes(totalBytes);
  }

  String get speedFormatted {
    return '${_formatBytes(speed.toInt())}/s';
  }

  Duration? get elapsedTime {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  Duration? get remainingTime {
    if (speed <= 0 || totalBytes <= 0) return null;
    final remaining = totalBytes - downloadedBytes;
    final seconds = remaining / speed;
    return Duration(seconds: seconds.toInt());
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  DownloadProgress copyWith({
    DownloadState? state,
    int? downloadedBytes,
    int? totalBytes,
    double? speed,
    String? error,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return DownloadProgress(
      state: state ?? this.state,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speed: speed ?? this.speed,
      error: error ?? this.error,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Provider لـ Download Manager
final civilDatabaseDownloadProvider =
    StateNotifierProvider<CivilDatabaseDownloadNotifier, DownloadProgress>((
      ref,
    ) {
      return CivilDatabaseDownloadNotifier();
    });

/// مدير تحميل قاعدة بيانات السجل المدني
class CivilDatabaseDownloadNotifier extends StateNotifier<DownloadProgress> {
  CivilDatabaseDownloadNotifier() : super(DownloadProgress());

  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  Timer? _speedTimer;
  int _lastDownloadedBytes = 0;
  DateTime? _lastSpeedCheck;

  /// بدء التحميل
  Future<void> startDownload({
    required String downloadUrl,
    required CivilDatabaseManager dbManager,
    String? expectedChecksum,
  }) async {
    try {
      // التحقق من المساحة المتاحة
      final response = await _dio.head(downloadUrl);
      final contentLength =
          int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? '0',
          ) ??
          0;

      if (contentLength > 0) {
        final hasSpace = await dbManager.hasEnoughSpace(contentLength);
        if (!hasSpace) {
          state = state.copyWith(
            state: DownloadState.failed,
            error:
                'مساحة التخزين غير كافية. مطلوب ${_formatBytes(contentLength)}',
          );
          return;
        }
      }

      // بدء التحميل
      _cancelToken = CancelToken();
      state = state.copyWith(
        state: DownloadState.downloading,
        startTime: DateTime.now(),
        totalBytes: contentLength,
        error: null,
      );

      _startSpeedMonitoring();

      final dbDir = await dbManager.getDatabaseDirectory();
      final tempPath = '${dbDir.path}/civil_registry_temp.db';

      // التحميل مع دعم Resume
      await _dio.download(
        downloadUrl,
        tempPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          state = state.copyWith(
            downloadedBytes: received,
            totalBytes: total > 0 ? total : contentLength,
          );
        },
        deleteOnError: false, // الاحتفاظ بالملف لدعم Resume
      );

      _stopSpeedMonitoring();

      // التحقق من اكتمال التحميل
      if (state.downloadedBytes < state.totalBytes && state.totalBytes > 0) {
        throw Exception('التحميل غير مكتمل');
      }

      // التحقق من سلامة الملف
      state = state.copyWith(state: DownloadState.verifying);

      if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
        final actualChecksum = await dbManager.calculateChecksum(tempPath);
        if (actualChecksum != expectedChecksum) {
          await File(tempPath).delete();
          throw Exception('فشل التحقق من سلامة الملف');
        }
      }

      // نقل الملف إلى الموقع النهائي
      final finalPath = await dbManager.getCivilDatabasePath();
      await File(tempPath).rename(finalPath);

      // حفظ المعلومات
      final checksum =
          expectedChecksum ?? await dbManager.calculateChecksum(finalPath);
      await dbManager.saveDatabaseInfo(
        checksum: checksum,
        size: state.downloadedBytes,
      );

      state = state.copyWith(
        state: DownloadState.completed,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _stopSpeedMonitoring();

      if (e is DioException && e.type == DioExceptionType.cancel) {
        state = state.copyWith(state: DownloadState.paused);
      } else {
        state = state.copyWith(
          state: DownloadState.failed,
          error: e.toString(),
        );
      }

      debugPrint('خطأ في التحميل: $e');
    }
  }

  /// إيقاف التحميل مؤقتاً
  void pauseDownload() {
    _cancelToken?.cancel('تم الإيقاف مؤقتاً');
    _stopSpeedMonitoring();
    state = state.copyWith(state: DownloadState.paused);
  }

  /// استئناف التحميل
  Future<void> resumeDownload({
    required String downloadUrl,
    required CivilDatabaseManager dbManager,
    String? expectedChecksum,
  }) async {
    if (state.state != DownloadState.paused) {
      return;
    }

    await startDownload(
      downloadUrl: downloadUrl,
      dbManager: dbManager,
      expectedChecksum: expectedChecksum,
    );
  }

  /// إلغاء التحميل
  Future<void> cancelDownload(CivilDatabaseManager dbManager) async {
    _cancelToken?.cancel('تم الإلغاء');
    _stopSpeedMonitoring();

    try {
      final dbDir = await dbManager.getDatabaseDirectory();
      final tempPath = '${dbDir.path}/civil_registry_temp.db';
      final tempFile = File(tempPath);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      debugPrint('خطأ في حذف الملف المؤقت: $e');
    }

    state = DownloadProgress(); // إعادة تعيين الحالة
  }

  /// بدء مراقبة السرعة
  void _startSpeedMonitoring() {
    _lastDownloadedBytes = 0;
    _lastSpeedCheck = DateTime.now();

    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastSpeedCheck!).inMilliseconds;

      if (elapsed > 0) {
        final bytesDownloaded = state.downloadedBytes - _lastDownloadedBytes;
        final speed = (bytesDownloaded / elapsed) * 1000; // بايت/ثانية

        state = state.copyWith(speed: speed);

        _lastDownloadedBytes = state.downloadedBytes;
        _lastSpeedCheck = now;
      }
    });
  }

  /// إيقاف مراقبة السرعة
  void _stopSpeedMonitoring() {
    _speedTimer?.cancel();
    _speedTimer = null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  void dispose() {
    _stopSpeedMonitoring();
    _cancelToken?.cancel();
    super.dispose();
  }
}
