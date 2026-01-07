import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/debug_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/civil_db_status.dart';

/// 📁 Civil Database Manager
///
/// Manages downloading and storing civil registry database
/// Supports both Development (copy from Assets) and Production (download from URL)
class CivilDbManager {
  static const String _dbFileName = 'persons.db';
  static const String _tempFileName = 'persons.db.downloading';

  // 🔧 Development Mode Configuration
  // Set to true to copy from Assets instead of downloading
  static const bool isDevelopmentMode = true; // ⚠️ Set to false for production!
  static const String assetDbPath = 'assets/database/persons.db';

  final Dio _dio;
  CancelToken? _cancelToken;

  CivilDbManager({Dio? dio}) : _dio = dio ?? Dio();

  /// Get the local database file path
  Future<String> getLocalDbPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, _dbFileName);
  }

  /// Get temporary download file path
  Future<String> _getTempFilePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, _tempFileName);
  }

  /// Check if database file exists locally
  Future<bool> isDatabaseDownloaded() async {
    final dbPath = await getLocalDbPath();
    return await File(dbPath).exists();
  }

  /// Get database file size
  Future<int?> getDatabaseSize() async {
    try {
      final dbPath = await getLocalDbPath();
      final file = File(dbPath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // File doesn't exist or error reading
    }
    return null;
  }

  /// Download database with progress tracking
  /// In Development Mode: Copies from Assets
  /// In Production Mode: Downloads from URL
  Stream<CivilDbStatus> downloadDatabase(String downloadUrl) async* {
    // 🔧 Development Mode: Copy from Assets
    if (isDevelopmentMode) {
      yield* _copyFromAssets();
      return;
    }

    // 🌐 Production Mode: Download from URL
    _cancelToken = CancelToken();
    final tempPath = await _getTempFilePath();
    final finalPath = await getLocalDbPath();

    try {
      // Initial status
      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.0,
        filePath: finalPath,
      );

      // Download with progress
      await _dio.download(
        downloadUrl,
        tempPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          // Progress tracking handled by stream
          // Progress: ${(received / total * 100).toStringAsFixed(1)}%
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // Move temp file to final location
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(finalPath);
      }

      // Download complete
      final fileSize = await getDatabaseSize();
      yield CivilDbStatus(
        status: CivilDbStatusType.ready,
        filePath: finalPath,
        fileSize: fileSize,
        downloadProgress: 1.0,
        lastUpdated: DateTime.now(),
      );
    } on DioException catch (e) {
      // Clean up temp file
      try {
        await File(tempPath).delete();
      } catch (cleanupError) {
        DebugLogger.warning('Failed to cleanup temp file: $cleanupError');
      }

      String errorMessage = 'فشل تنزيل قاعدة البيانات';

      if (e.type == DioExceptionType.cancel) {
        errorMessage = 'تم إلغاء التنزيل';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'قاعدة البيانات غير متوفرة على الخادم. يرجى التحقق من رابط التنزيل أو التواصل مع الدعم الفني';
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        errorMessage = 'لا تملك صلاحية لتنزيل قاعدة البيانات. يرجى تسجيل الدخول مجدداً';
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'انتهت مهلة الاتصال. تحقق من الإنترنت';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'خطأ في الاتصال بالإنترنت';
      } else if (e.response != null) {
        errorMessage = 'خطأ ${e.response!.statusCode}: ${e.response!.statusMessage ?? "غير محدد"}';
      }

      yield CivilDbStatus(
        status: CivilDbStatusType.error,
        errorMessage: errorMessage,
      );
    } catch (e) {
      // Clean up temp file
      try {
        await File(tempPath).delete();
      } catch (cleanupError) {
        DebugLogger.warning(
          'Failed to cleanup temp file after error: $cleanupError',
        );
      }

      yield CivilDbStatus(
        status: CivilDbStatusType.error,
        errorMessage: 'خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  /// Copy database from Assets (Development Mode)
  Stream<CivilDbStatus> _copyFromAssets() async* {
    final finalPath = await getLocalDbPath();

    try {
      DebugLogger.debug('Development Mode: Copying from Assets...');
      DebugLogger.info('📂 Asset path: $assetDbPath');
      DebugLogger.info('📂 Final path: $finalPath');

      // Initial status
      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.0,
        filePath: finalPath,
      );

      // Simulate progress for better UX
      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.3,
        filePath: finalPath,
      );

      // Load from Assets
      DebugLogger.info('📥 Loading from Assets...');
      final byteData = await rootBundle.load(assetDbPath);
      DebugLogger.success('Loaded ${byteData.lengthInBytes} bytes');

      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.6,
        filePath: finalPath,
      );

      // Write to file
      final file = File(finalPath);
      DebugLogger.info('💾 Writing to file...');
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      DebugLogger.success('File written successfully');

      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.9,
        filePath: finalPath,
      );

      // Complete
      final fileSize = await getDatabaseSize();
      DebugLogger.success('Database ready! Size: ${fileSize ?? 0} bytes');
      yield CivilDbStatus(
        status: CivilDbStatusType.ready,
        filePath: finalPath,
        fileSize: fileSize,
        downloadProgress: 1.0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      DebugLogger.error('Error copying from Assets', e);
      yield CivilDbStatus(
        status: CivilDbStatusType.error,
        errorMessage: 'فشل نسخ قاعدة البيانات من Assets: ${e.toString()}',
      );
    }
  }

  /// Download with manual progress updates (better control)
  Stream<CivilDbStatus> downloadDatabaseWithProgress(
    String downloadUrl,
  ) async* {
    // 🔧 Development Mode: Copy from Assets
    if (isDevelopmentMode) {
      yield* _copyFromAssets();
      return;
    }

    // 🌐 Production Mode: Download from URL
    _cancelToken = CancelToken();
    final tempPath = await _getTempFilePath();
    final finalPath = await getLocalDbPath();

    try {
      // Initial status
      yield CivilDbStatus(
        status: CivilDbStatusType.downloading,
        downloadProgress: 0.0,
        filePath: finalPath,
      );

      // Download with progress
      await _dio.download(
        downloadUrl,
        tempPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) async* {
          if (total > 0) {
            final progress = received / total;
            yield CivilDbStatus(
              status: CivilDbStatusType.downloading,
              downloadProgress: progress,
              filePath: finalPath,
              fileSize: total,
            );
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // Move temp file to final location
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(finalPath);
      }

      // Download complete
      final fileSize = await getDatabaseSize();
      yield CivilDbStatus(
        status: CivilDbStatusType.ready,
        filePath: finalPath,
        fileSize: fileSize,
        downloadProgress: 1.0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Clean up temp file
      try {
        await File(tempPath).delete();
      } catch (cleanupError) {
        DebugLogger.warning(
          'Failed to cleanup temp file in downloadWithProgress: $cleanupError',
        );
      }

      yield CivilDbStatus(
        status: CivilDbStatusType.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel ongoing download
  Future<void> cancelDownload() async {
    _cancelToken?.cancel('Download cancelled by user');
    _cancelToken = null;

    // Clean up temp file
    try {
      final tempPath = await _getTempFilePath();
      await File(tempPath).delete();
    } catch (e) {
      // Temp file cleanup failed - not critical, will be cleaned next time
      DebugLogger.warning('Failed to cleanup temp file on cancel: $e');
    }
  }

  /// Delete downloaded database
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getLocalDbPath();
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete database: $e');
    }
  }

  /// Check database status
  Future<CivilDbStatus> checkStatus() async {
    try {
      final isDownloaded = await isDatabaseDownloaded();

      if (!isDownloaded) {
        return const CivilDbStatus(status: CivilDbStatusType.notDownloaded);
      }

      final dbPath = await getLocalDbPath();
      final fileSize = await getDatabaseSize();

      return CivilDbStatus(
        status: CivilDbStatusType.ready,
        filePath: dbPath,
        fileSize: fileSize,
        downloadProgress: 1.0,
      );
    } catch (e) {
      return CivilDbStatus(
        status: CivilDbStatusType.error,
        errorMessage: e.toString(),
      );
    }
  }
}
