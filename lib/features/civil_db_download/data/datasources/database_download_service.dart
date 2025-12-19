import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../../domain/entities/download_progress.dart';

/// 📥 Civil Registry Database Download Service
class DatabaseDownloadService {
  final Dio _dio;
  CancelToken? _cancelToken;

  DatabaseDownloadService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(minutes: 10),
              ),
            );

  /// Download database from server
  Future<void> downloadDatabase({
    required String downloadUrl,
    required Function(DownloadProgress) onProgress,
  }) async {
    _cancelToken = CancelToken();

    try {
      // Get local path (same as civil_database_manager)
      final directory = await getApplicationDocumentsDirectory();
      final dbDirectory = Directory('${directory.path}/databases');
      if (!await dbDirectory.exists()) {
        await dbDirectory.create(recursive: true);
      }

      // Use the same name as CivilDatabaseManager expects
      final finalPath = '${dbDirectory.path}/civil_registry.db';
      final downloadPath = '${dbDirectory.path}/civil_registry.zip';

      // Check if already exists
      final existingFile = File(finalPath);
      if (await existingFile.exists()) {
        if (kDebugMode) {
          debugPrint('📂 Database already exists at: $finalPath');
        }
        onProgress(
          DownloadProgress(
            downloadedBytes: 0,
            totalBytes: 0,
            percentage: 100,
            status: DownloadStatus.completed,
          ),
        );
        return;
      }

      // Start downloading
      onProgress(
        DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 0,
          status: DownloadStatus.checking,
        ),
      );

      int lastDownloadedBytes = 0;
      DateTime lastProgressTime = DateTime.now();

      // Check if partial download exists for resume
      int downloadedLength = 0;
      final partialFile = File(downloadPath);
      if (await partialFile.exists()) {
        downloadedLength = await partialFile.length();
        if (kDebugMode) {
          debugPrint(
            '📥 Resuming download from ${downloadedLength ~/ (1024 * 1024)} MB',
          );
        }
      }

      // Download ZIP file with resume support
      await _dio.download(
        downloadUrl,
        downloadPath,
        cancelToken: _cancelToken,
        deleteOnError: false, // Keep partial download
        options: Options(
          headers: downloadedLength > 0
              ? {'Range': 'bytes=$downloadedLength-'}
              : null,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Add downloaded length for resume
            final actualReceived = received + downloadedLength;
            final actualTotal = total + downloadedLength;
            final percentage = (actualReceived / actualTotal * 100);

            // Calculate speed
            final now = DateTime.now();
            final timeDiff = now.difference(lastProgressTime).inMilliseconds;
            double? speed;

            if (timeDiff > 500) {
              // Update speed every 500ms
              final bytesDiff = received - lastDownloadedBytes;
              speed = (bytesDiff / (1024 * 1024)) / (timeDiff / 1000); // MB/s
              lastDownloadedBytes = received;
              lastProgressTime = now;
            }

            onProgress(
              DownloadProgress(
                downloadedBytes: actualReceived,
                totalBytes: actualTotal,
                percentage: percentage,
                status: DownloadStatus.downloading,
              )..downloadSpeed = speed,
            );
          }
        },
      );

      // Extract ZIP file
      onProgress(
        DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 90,
          status: DownloadStatus.extracting,
        ),
      );

      await _extractZipFile(downloadPath, dbDirectory.path);

      // Delete ZIP file
      final zipFile = File(downloadPath);
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      // Verify extracted database
      onProgress(
        DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 95,
          status: DownloadStatus.verifying,
        ),
      );

      final verified = await _verifyDatabase(finalPath);
      if (!verified) {
        // Clean up failed download
        if (await File(finalPath).exists()) {
          await File(finalPath).delete();
        }
        throw Exception('Database verification failed');
      }

      // Complete
      onProgress(
        DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 100,
          status: DownloadStatus.completed,
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ Database downloaded successfully to: $finalPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Database download error: $e');
      }

      // Clean up failed downloads
      try {
        final directory = await getApplicationDocumentsDirectory();
        final dbDirectory = Directory('${directory.path}/databases');

        final zipFile = File('${dbDirectory.path}/civil_registry.zip');
        if (await zipFile.exists()) {
          await zipFile.delete();
          if (kDebugMode) {
            debugPrint('🗑️ Cleaned up ZIP file');
          }
        }

        final partialDb = File('${dbDirectory.path}/civil_registry.db');
        if (await partialDb.exists()) {
          await partialDb.delete();
          if (kDebugMode) {
            debugPrint('🗑️ Cleaned up partial database');
          }
        }
      } catch (cleanupError) {
        if (kDebugMode) {
          debugPrint('⚠️ Cleanup error: $cleanupError');
        }
      }

      onProgress(
        DownloadProgress(
          downloadedBytes: 0,
          totalBytes: 0,
          percentage: 0,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Cancel download
  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
  }

  /// Extract ZIP file
  Future<void> _extractZipFile(String zipPath, String outputDir) async {
    try {
      if (kDebugMode) {
        debugPrint('📦 Extracting ZIP: $zipPath');
      }

      // Read ZIP file
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract all files and rename if needed
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;

          // If file is persons.db, rename to civil_registry.db
          final outputFilename = filename.toLowerCase() == 'persons.db'
              ? 'civil_registry.db'
              : filename;

          final outputFile = File('$outputDir/$outputFilename');
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(data);

          if (kDebugMode) {
            debugPrint(
              '✓ Extracted: $filename${filename != outputFilename ? " → $outputFilename" : ""}',
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ ZIP extraction complete');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ZIP extraction error: $e');
      }
      rethrow;
    }
  }

  /// Verify database integrity
  Future<bool> _verifyDatabase(String dbPath) async {
    try {
      final file = File(dbPath);
      if (!await file.exists()) return false;

      final size = await file.length();

      // Check if file is not empty and has reasonable size (> 100 MB)
      if (size < 100 * 1024 * 1024) {
        if (kDebugMode) {
          debugPrint('⚠️ Database file too small: ${size ~/ (1024 * 1024)} MB');
        }
        return false;
      }

      // TODO: Add SQLite header verification
      final bytes = await file.openRead(0, 16).first;
      final header = String.fromCharCodes(bytes);

      if (!header.startsWith('SQLite format')) {
        if (kDebugMode) {
          debugPrint('⚠️ Invalid SQLite header');
        }
        return false;
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
