import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/download_progress.dart';

/// 📥 Civil Registry Database Download Service
/// 🔐 Requires Admin authentication - Bearer Token required
class DatabaseDownloadService {
  static const Duration _statusCacheTtl = Duration(seconds: 4);
  static const String _canonicalDbRelativePath = 'databases/civil_registry.db';
  static const String _legacyDbFileName = 'persons.db';
  static DatabaseFileStatus? _cachedStatus;
  static DateTime? _cachedStatusAt;

  CancelToken? _cancelToken;

  DatabaseDownloadService({Dio? dio, SecureStorage? secureStorage});

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

  /// Check if database exists locally
  Future<bool> isDatabaseAvailable() async {
    final status = await getDatabaseFileStatus();
    return status.isAvailable;
  }

  Future<DatabaseFileStatus> getDatabaseFileStatus({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();
      if (!forceRefresh && _cachedStatus != null && _cachedStatusAt != null) {
        if (now.difference(_cachedStatusAt!) <= _statusCacheTtl) {
          return _cachedStatus!;
        }
      }

      final candidatePaths = await _getCandidateDatabasePaths();

      String? selectedPath;
      int selectedSize = 0;
      DateTime? selectedModifiedAt;

      for (final path in candidatePaths) {
        final file = File(path);
        if (!file.existsSync()) {
          continue;
        }

        final size = file.lengthSync();
        if (selectedPath == null || size > selectedSize) {
          selectedPath = path;
          selectedSize = size;
          selectedModifiedAt = file.lastModifiedSync();
        }
      }

      final canonicalPath = await getDatabasePath();
      final exists = selectedPath != null;
      final status = DatabaseFileStatus(
        path: selectedPath ?? canonicalPath,
        exists: exists,
        size: selectedSize,
        modifiedAt: selectedModifiedAt,
      );

      _cachedStatus = status;
      _cachedStatusAt = now;
      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking database status: $e');
      }
      return const DatabaseFileStatus(path: '', exists: false, size: 0);
    }
  }

  /// Get database file path
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    // Canonical path used by the new flow.
    return '${directory.path}/$_canonicalDbRelativePath';
  }

  Future<List<String>> _getCandidateDatabasePaths() async {
    final directory = await getApplicationDocumentsDirectory();
    final canonicalPath = '${directory.path}/$_canonicalDbRelativePath';
    final legacyRootPath = '${directory.path}/$_legacyDbFileName';
    final legacyNestedPath = '${directory.path}/databases/$_legacyDbFileName';
    return <String>[canonicalPath, legacyRootPath, legacyNestedPath];
  }

  /// Get database size
  Future<int> getDatabaseSize() async {
    final status = await getDatabaseFileStatus();
    return status.size;
  }

  /// Get database download date (file modification date)
  Future<DateTime?> getDownloadDate() async {
    final status = await getDatabaseFileStatus();
    return status.modifiedAt;
  }

  /// Delete database (for re-download)
  Future<void> deleteDatabase() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
        _cachedStatus = null;
        _cachedStatusAt = null;
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

class DatabaseFileStatus {
  final String path;
  final bool exists;
  final int size;
  final DateTime? modifiedAt;

  const DatabaseFileStatus({
    required this.path,
    required this.exists,
    required this.size,
    this.modifiedAt,
  });

  bool get isAvailable => exists && size > 0;
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
