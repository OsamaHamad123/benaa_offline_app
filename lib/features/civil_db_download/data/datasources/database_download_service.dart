import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/download_progress.dart';
import '../../presentation/pages/config/download_config.dart';
import '../services/optimized_zip_extractor.dart';

/// 📥 Civil Registry Database Download Service
/// 🔐 Requires Admin authentication - Bearer Token required
class DatabaseDownloadService {
  final Dio _dio;
  final SecureStorage _secureStorage;
  CancelToken? _cancelToken;

  DatabaseDownloadService({Dio? dio, SecureStorage? secureStorage})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(minutes: 10),
              ),
            ),
        _secureStorage = secureStorage ?? SecureStorage();

  /// Download database from server
  Future<void> downloadDatabase({
    required String downloadUrl,
    required Function(DownloadProgress) onProgress,
  }) async {
    // DISABLED FOR PUBLIC GITHUB VERSION:
    // Civil registry database download was connected to the old company server and was disabled.
    // No request is sent. No sensitive civil registry data is fetched.
    // TODO: Replace with Firebase Storage or a new authorized backend endpoint.
    onProgress(
      DownloadProgress(
        downloadedBytes: 0,
        totalBytes: 0,
        percentage: 0,
        status: DownloadStatus.failed,
      ),
    );
    throw UnsupportedError(
      '[DEMO MODE] Civil registry download is disabled in this version.',
    );
  }

  /// Cancel download
  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
  }

  /// Verify database integrity
  Future<bool> _verifyDatabase(
    String dbPath, {
    int? expectedSizeBytes,
    String? expectedSha256,
  }) async {
    try {
      final file = File(dbPath);
      if (!await file.exists()) return false;

      final size = await file.length();

      if (expectedSizeBytes != null && expectedSizeBytes > 0 && size != expectedSizeBytes) {
        if (kDebugMode) {
          debugPrint('⚠️ Database size mismatch: local=$size, expected=$expectedSizeBytes');
        }
        return false;
      }

      // Check if file is not empty and has reasonable size (> 100 MB)
      if (size < 100 * 1024 * 1024) {
        if (kDebugMode) {
          debugPrint('⚠️ Database file too small: ${size ~/ (1024 * 1024)} MB');
        }
        return false;
      }

      final chunks = await file.openRead(0, 16).toList();
      if (chunks.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ SQLite header is empty');
        }
        return false;
      }

      final headerBytes = chunks.expand((chunk) => chunk).toList(growable: false);
      if (headerBytes.length < 16) {
        if (kDebugMode) {
          debugPrint('⚠️ SQLite header is too short');
        }
        return false;
      }

      final header = String.fromCharCodes(headerBytes.sublist(0, 16));

      if (!header.startsWith('SQLite format')) {
        if (kDebugMode) {
          debugPrint('⚠️ Invalid SQLite header');
        }
        return false;
      }

      final normalizedExpected = _normalizeSha256(expectedSha256);
      if (normalizedExpected != null) {
        final computedSha = await _computeFileSha256(file);
        if (computedSha != normalizedExpected) {
          if (kDebugMode) {
            debugPrint('⚠️ SHA-256 mismatch: local=$computedSha expected=$normalizedExpected');
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Database verification error: $e');
      }
      return false;
    }
  }

  /// Check if database exists locally
  Future<bool> isDatabaseAvailable() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = '${directory.path}/databases/civil_registry.db';
      final file = File(dbPath);
      return await file.exists();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking database: $e');
      }
      return false;
    }
  }

  /// Get database file path
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    // Use same path as civil_database_manager
    return '${directory.path}/databases/civil_registry.db';
  }

  /// Get database size
  Future<int> getDatabaseSize() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<_RemoteFileInfo?> _fetchRemoteFileInfo({
    required String authToken,
    required String fallbackUrl,
  }) async {
    Future<_RemoteFileInfo?> tryInfoUrl(String url) async {
      try {
        final response = await _dio.get(
          url,
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
          return null;
        }

        return _parseRemoteInfo(response.data as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }

    final fromInfoEndpoint = await tryInfoUrl(DownloadConfig.fileInfoUrl);
    if (fromInfoEndpoint != null) {
      return fromInfoEndpoint;
    }

    final normalizedFallback = fallbackUrl.trim();
    if (normalizedFallback.isNotEmpty) {
      final fromFallbackInfo = await tryInfoUrl(normalizedFallback.replaceFirst('/download', '/info'));
      if (fromFallbackInfo != null) {
        return fromFallbackInfo;
      }

      try {
        final response = await _dio.head(
          normalizedFallback,
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final lengthHeader = response.headers.value('content-length');
          final shaHeader = response.headers.value('x-file-sha256') ?? response.headers.value('x-checksum-sha256');
          final size = _asInt(lengthHeader);
          final sha = _normalizeSha256(shaHeader);

          if (size != null || sha != null) {
            return _RemoteFileInfo(sizeBytes: size, sha256: sha);
          }
        }
      } catch (_) {
        // no-op: metadata is optional
      }
    }

    return null;
  }

  _RemoteFileInfo? _parseRemoteInfo(Map<String, dynamic> root) {
    final dataNode = root['data'];
    final node = dataNode is Map<String, dynamic> ? dataNode : root;

    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (node.containsKey(key) && node[key] != null) {
          return node[key];
        }
      }
      return null;
    }

    final sizeRaw = pick(<String>[
      'size_bytes',
      'file_size_bytes',
      'size',
      'content_length',
    ]);
    final shaRaw = pick(<String>[
      'sha256',
      'checksum',
      'hash',
    ]);

    final parsedSize = _asInt(sizeRaw);
    final parsedSha = _normalizeSha256(shaRaw?.toString());

    if (parsedSize == null && parsedSha == null) {
      return null;
    }

    return _RemoteFileInfo(sizeBytes: parsedSize, sha256: parsedSha);
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  String? _normalizeSha256(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final match = RegExp(r'^[a-f0-9]{64}$').firstMatch(normalized);
    return match == null ? null : normalized;
  }

  Future<String> _computeFileSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  bool _isCancelledError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.cancel;
    }
    final text = error.toString().toLowerCase();
    return text.contains('cancelled') || text.contains('canceled');
  }

  _MappedFailure _mapDownloadFailure(Object error) {
    if (error is CivilDbDownloadException) {
      return _MappedFailure(reason: error.reason, message: error.message);
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return const _MappedFailure(
          reason: DownloadFailureReason.network,
          message: 'تعذر إكمال التنزيل بسبب مشكلة في الشبكة. تحقق من الاتصال وحاول مرة أخرى.',
        );
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return const _MappedFailure(
          reason: DownloadFailureReason.auth,
          message: 'انتهت صلاحية الجلسة أو لا توجد صلاحية كافية لتنزيل السجل المدني.',
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return _MappedFailure(
          reason: DownloadFailureReason.server,
          message: 'الخادم غير متاح حالياً (رمز $statusCode). يرجى المحاولة لاحقاً.',
        );
      }
    }

    final text = error.toString().toLowerCase();
    if (text.contains('verification') ||
        text.contains('checksum') ||
        text.contains('sqlite') ||
        text.contains('size mismatch') ||
        text.contains('integrity')) {
      return const _MappedFailure(
        reason: DownloadFailureReason.integrity,
        message: 'تم تنزيل الملف لكن فشل التحقق من سلامته. أعد المحاولة لتنزيل نسخة جديدة.',
      );
    }

    if (text.contains('no space') || text.contains('disk full') || text.contains('file system')) {
      return const _MappedFailure(
        reason: DownloadFailureReason.storage,
        message: 'المساحة غير كافية أو تعذر حفظ الملف على الجهاز. حرّر مساحة وحاول مرة أخرى.',
      );
    }

    if (text.startsWith('exception:')) {
      final cleaned = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      return _MappedFailure(
          reason: DownloadFailureReason.unknown,
          message: cleaned.isEmpty ? 'حدث خطأ غير متوقع أثناء تنزيل السجل المدني.' : cleaned);
    }

    final cleaned = error.toString().trim();
    return _MappedFailure(
      reason: DownloadFailureReason.unknown,
      message: cleaned.isEmpty ? 'حدث خطأ غير متوقع أثناء تنزيل السجل المدني.' : cleaned,
    );
  }

  /// Get database download date (file modification date)
  Future<DateTime?> getDownloadDate() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        return await file.lastModified();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete database (for re-download)
  Future<void> deleteDatabase() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          debugPrint('🗑️ Database deleted');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting database: $e');
      }
    }
  }
}

class _RemoteFileInfo {
  final int? sizeBytes;
  final String? sha256;

  const _RemoteFileInfo({
    this.sizeBytes,
    this.sha256,
  });
}

class _MappedFailure {
  final DownloadFailureReason reason;
  final String message;

  const _MappedFailure({
    required this.reason,
    required this.message,
  });
}

class CivilDbDownloadException implements Exception {
  final DownloadFailureReason reason;
  final String message;

  const CivilDbDownloadException({
    required this.reason,
    required this.message,
  });

  @override
  String toString() => message;
}
