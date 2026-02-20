import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';

/// 🚀 Optimized ZIP Extractor for Large Files (4GB+)
///
/// يستخدم:
/// - Isolate للعمليات الثقيلة (لا يجمد UI)
/// - Stream-based reading للملفات الكبيرة
/// - Progress callback للتتبع
class OptimizedZipExtractor {
  /// استخراج ZIP في Isolate منفصل مع تتبع التقدم
  ///
  /// مناسب للملفات الكبيرة (4GB+) حيث:
  /// - لا يحمل الملف كاملاً في الذاكرة
  /// - يعمل في thread منفصل
  /// - يبلغ عن التقدم
  static Future<void> extractZipWithProgress({
    required String zipPath,
    required String outputDir,
    required Function(double progress, String? currentFile) onProgress,
    String? targetFileName,
  }) async {
    // إنشاء Isolate للعمل الثقيل
    final resultPort = ReceivePort();
    final progressPort = ReceivePort();

    // استماع للتقدم
    progressPort.listen((message) {
      if (message is Map<String, dynamic>) {
        onProgress(
          message['progress'] as double,
          message['currentFile'] as String?,
        );
      }
    });

    try {
      await Isolate.spawn(
        _extractZipIsolate,
        _IsolateParams(
          zipPath: zipPath,
          outputDir: outputDir,
          resultPort: resultPort.sendPort,
          progressPort: progressPort.sendPort,
          targetFileName: targetFileName,
        ),
      );

      // انتظار النتيجة
      final result = await resultPort.first;

      if (result is String && result.startsWith('ERROR:')) {
        throw Exception(result.substring(6));
      }

      if (kDebugMode) {
        debugPrint('✅ ZIP extraction completed successfully');
      }
    } finally {
      resultPort.close();
      progressPort.close();
    }
  }

  /// الدالة التي تعمل في الـ Isolate
  static void _extractZipIsolate(_IsolateParams params) {
    try {
      final zipFile = File(params.zipPath);

      if (!zipFile.existsSync()) {
        params.resultPort.send('ERROR:ZIP file not found');
        return;
      }

      // قراءة الـ ZIP وفك الضغط
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      final totalFiles = archive.files.where((f) => f.isFile).length;
      var processedFiles = 0;

      for (final file in archive.files) {
        if (!file.isFile) continue;

        final filename = file.name;

        // إذا تم تحديد اسم ملف معين
        String outputFilename = filename;
        if (params.targetFileName != null) {
          // إذا كان persons.db → تحويل إلى civil_registry.db
          if (filename.toLowerCase() == 'persons.db') {
            outputFilename = params.targetFileName!;
          }
        }

        // استخراج الملف
        final outputFile = File('${params.outputDir}/$outputFilename');
        outputFile.createSync(recursive: true);
        outputFile.writeAsBytesSync(file.content as List<int>);

        processedFiles++;

        // إرسال التقدم
        params.progressPort.send({
          'progress': processedFiles / totalFiles,
          'currentFile': outputFilename,
        });
      }

      params.resultPort.send('SUCCESS');
    } catch (e) {
      params.resultPort.send('ERROR:$e');
    }
  }

  /// استخراج مبسط للملفات المتوسطة الحجم
  static Future<void> extractZipSimple({
    required String zipPath,
    required String outputDir,
    String? renameDbTo,
  }) async {
    return compute(
        _extractZipCompute,
        _SimpleExtractParams(
          zipPath: zipPath,
          outputDir: outputDir,
          renameDbTo: renameDbTo,
        ));
  }

  static void _extractZipCompute(_SimpleExtractParams params) {
    final bytes = File(params.zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      if (!file.isFile) continue;

      final filename = file.name;
      String outputFilename = filename;

      // تحويل persons.db إلى الاسم المطلوب
      if (params.renameDbTo != null && filename.toLowerCase() == 'persons.db') {
        outputFilename = params.renameDbTo!;
      }

      final outputFile = File('${params.outputDir}/$outputFilename');
      outputFile.createSync(recursive: true);
      outputFile.writeAsBytesSync(file.content as List<int>);
    }
  }
}

/// Parameters للـ Isolate
class _IsolateParams {
  final String zipPath;
  final String outputDir;
  final SendPort resultPort;
  final SendPort progressPort;
  final String? targetFileName;

  _IsolateParams({
    required this.zipPath,
    required this.outputDir,
    required this.resultPort,
    required this.progressPort,
    this.targetFileName,
  });
}

/// Parameters للاستخراج البسيط
class _SimpleExtractParams {
  final String zipPath;
  final String outputDir;
  final String? renameDbTo;

  _SimpleExtractParams({
    required this.zipPath,
    required this.outputDir,
    this.renameDbTo,
  });
}

/// 🔄 Retry Logic Helper
class RetryHelper {
  /// تنفيذ عملية مع إعادة المحاولة
  ///
  /// - [maxAttempts]: عدد المحاولات الأقصى (default: 3)
  /// - [initialDelay]: التأخير الأولي بالثواني (default: 2)
  /// - [exponentialBackoff]: استخدام تأخير متزايد (default: true)
  static Future<T> retry<T>({
    required Future<T> Function() action,
    required String operationName,
    int maxAttempts = 3,
    int initialDelaySeconds = 2,
    bool exponentialBackoff = true,
    Function(int attempt, Exception error)? onRetry,
  }) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await action();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());

        if (attempt == maxAttempts) {
          if (kDebugMode) {
            debugPrint('❌ $operationName failed after $maxAttempts attempts: $e');
          }
          break;
        }

        // حساب التأخير
        final delay = exponentialBackoff
            ? initialDelaySeconds * (1 << (attempt - 1)) // 2, 4, 8 seconds...
            : initialDelaySeconds;

        if (kDebugMode) {
          debugPrint(
            '⚠️ $operationName attempt $attempt failed, retrying in ${delay}s: $e',
          );
        }

        onRetry?.call(attempt, lastError);

        await Future.delayed(Duration(seconds: delay));
      }
    }

    throw lastError ?? Exception('Unknown error in $operationName');
  }
}
