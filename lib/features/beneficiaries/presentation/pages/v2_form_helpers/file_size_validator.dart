import 'dart:async';
import 'dart:io';

/// 📏 File Size Validator
class FileSizeValidator {
  // الحد الأقصى لحجم الملف: 10 ميجابايت
  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  /// التحقق من حجم ملف واحد
  static FileSizeValidationResult validateFile(File file) {
    final fileSize = file.lengthSync();

    if (fileSize > maxFileSizeInBytes) {
      return FileSizeValidationResult(
        isValid: false,
        fileSizeInBytes: fileSize,
        errorMessage: 'حجم الملف يتجاوز الحد الأقصى (10 ميجابايت)',
      );
    }

    return FileSizeValidationResult(isValid: true, fileSizeInBytes: fileSize);
  }

  /// التحقق من حجم مجموعة ملفات
  static MultiFileSizeValidationResult validateFiles(List<File> files) {
    final invalidFiles = <File, String>{};
    int totalSize = 0;

    for (final file in files) {
      final result = validateFile(file);
      totalSize += result.fileSizeInBytes;

      if (!result.isValid) {
        invalidFiles[file] = result.errorMessage!;
      }
    }

    return MultiFileSizeValidationResult(
      isAllValid: invalidFiles.isEmpty,
      invalidFiles: invalidFiles,
      totalSizeInBytes: totalSize,
    );
  }

  /// تحويل البايتات إلى نص قابل للقراءة
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
  }
}

/// نتيجة التحقق من حجم ملف واحد
class FileSizeValidationResult {
  final bool isValid;
  final int fileSizeInBytes;
  final String? errorMessage;

  FileSizeValidationResult({
    required this.isValid,
    required this.fileSizeInBytes,
    this.errorMessage,
  });
}

/// نتيجة التحقق من حجم مجموعة ملفات
class MultiFileSizeValidationResult {
  final bool isAllValid;
  final Map<File, String> invalidFiles;
  final int totalSizeInBytes;

  MultiFileSizeValidationResult({
    required this.isAllValid,
    required this.invalidFiles,
    required this.totalSizeInBytes,
  });

  String get formattedTotalSize =>
      FileSizeValidator.formatFileSize(totalSizeInBytes);
}

/// 🕐 Debounced Validator
class DebouncedValidator {
  Timer? _debounceTimer;
  final Duration delay;

  DebouncedValidator({this.delay = const Duration(milliseconds: 500)});

  /// تنفيذ validation بعد فترة من التوقف عن الكتابة
  void run(Function() callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// إلغاء أي validation معلق
  void cancel() {
    _debounceTimer?.cancel();
  }

  /// تنظيف الموارد
  void dispose() {
    _debounceTimer?.cancel();
  }
}
