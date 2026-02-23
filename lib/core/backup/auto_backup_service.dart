import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../storage/secure_store.dart';

/// 💾 Auto Backup Service
/// خدمة النسخ الاحتياطي التلقائي

class AutoBackupService {
  /// إنشاء نسخة احتياطية
  static Future<BackupResult> createBackup({
    required String databasePath,
    String? backupName,
  }) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = backupName ?? 'backup_$timestamp';

      // Get backup directory
      final backupDir = await _getBackupDirectory();

      // Create backup file
      final backupPath = path.join(backupDir.path, '$name.db');
      final sourceFile = File(databasePath);
      final backupFile = await sourceFile.copy(backupPath);

      // Compress backup (optional)
      // final compressedFile = await _compressFile(backupFile);

      return BackupResult(
        success: true,
        backupPath: backupFile.path,
        size: await backupFile.length(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BackupResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// استعادة من نسخة احتياطية
  static Future<RestoreResult> restoreBackup({
    required String backupPath,
    required String databasePath,
  }) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        return RestoreResult(
          success: false,
          error: 'ملف النسخ الاحتياطي غير موجود',
        );
      }

      // Create a backup of current database before restoring
      await createBackup(
        databasePath: databasePath,
        backupName: 'pre_restore_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      );

      // Restore from backup
      final targetFile = File(databasePath);
      await backupFile.copy(targetFile.path);

      return RestoreResult(
        success: true,
        message: 'تمت استعادة النسخة الاحتياطية بنجاح',
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// قائمة النسخ الاحتياطية
  static Future<List<BackupInfo>> listBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      final backups = <BackupInfo>[];

      if (await backupDir.exists()) {
        final files = backupDir.listSync();

        for (var file in files) {
          if (file is File && file.path.endsWith('.db')) {
            final stat = await file.stat();
            backups.add(BackupInfo(
              name: path.basename(file.path),
              path: file.path,
              size: stat.size,
              createdAt: stat.modified,
            ));
          }
        }

        // Sort by date (newest first)
        backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return backups;
    } catch (e) {
      return [];
    }
  }

  /// حذف نسخة احتياطية
  static Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// حذف النسخ القديمة (الاحتفاظ بآخر N نسخة)
  static Future<int> cleanupOldBackups({int keepLast = 10}) async {
    try {
      final backups = await listBackups();

      if (backups.length <= keepLast) {
        return 0;
      }

      int deletedCount = 0;
      final toDelete = backups.skip(keepLast);

      for (var backup in toDelete) {
        if (await deleteBackup(backup.path)) {
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// جدولة النسخ الاحتياطي التلقائي
  static Future<void> scheduleAutoBackup({
    required String databasePath,
    required Duration interval,
  }) async {
    // TODO: Implement with WorkManager or AlarmManager
    // This would require platform-specific implementation

    // For now, we can use a simple periodic backup check
    // In production, use WorkManager for Android or BackgroundTasks for iOS
  }

  /// تصدير النسخة الاحتياطية
  static Future<String?> exportBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        return null;
      }

      // Get downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) return null;

      // Copy to downloads
      final exportPath = path.join(
        downloadsDir.path,
        'benaa_${path.basename(backupPath)}',
      );

      await backupFile.copy(exportPath);
      return exportPath;
    } catch (e) {
      return null;
    }
  }

  /// استيراد نسخة احتياطية من ملف خارجي
  static Future<String?> importBackup(String externalPath) async {
    try {
      final externalFile = File(externalPath);

      if (!await externalFile.exists()) {
        return null;
      }

      final backupDir = await _getBackupDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final importPath = path.join(
        backupDir.path,
        'imported_$timestamp.db',
      );

      await externalFile.copy(importPath);
      return importPath;
    } catch (e) {
      return null;
    }
  }

  /// الحصول على مجلد النسخ الاحتياطية
  static Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(appDir.path, 'backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  /// حفظ إعدادات النسخ الاحتياطي
  Future<void> saveBackupSettings({
    required bool autoBackupEnabled,
    required int backupIntervalDays,
    required int keepBackupsCount,
  }) async {
    await SecureStore.write(
      'auto_backup_enabled',
      autoBackupEnabled.toString(),
    );
    await SecureStore.write(
      'backup_interval_days',
      backupIntervalDays.toString(),
    );
    await SecureStore.write(
      'keep_backups_count',
      keepBackupsCount.toString(),
    );
  }

  /// قراءة إعدادات النسخ الاحتياطي
  Future<BackupSettings> getBackupSettings() async {
    final enabled = await SecureStore.read('auto_backup_enabled');
    final interval = await SecureStore.read('backup_interval_days');
    final keepCount = await SecureStore.read('keep_backups_count');

    return BackupSettings(
      autoBackupEnabled: enabled == 'true',
      backupIntervalDays: int.tryParse(interval ?? '7') ?? 7,
      keepBackupsCount: int.tryParse(keepCount ?? '10') ?? 10,
    );
  }
}

/// نتيجة النسخ الاحتياطي
class BackupResult {
  final bool success;
  final String? backupPath;
  final int? size;
  final String? error;
  final DateTime timestamp;

  BackupResult({
    required this.success,
    required this.timestamp, this.backupPath,
    this.size,
    this.error,
  });
}

/// نتيجة الاستعادة
class RestoreResult {
  final bool success;
  final String? message;
  final String? error;

  RestoreResult({
    required this.success,
    this.message,
    this.error,
  });
}

/// معلومات النسخة الاحتياطية
class BackupInfo {
  final String name;
  final String path;
  final int size;
  final DateTime createdAt;

  BackupInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.createdAt,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
  }
}

/// إعدادات النسخ الاحتياطي
class BackupSettings {
  final bool autoBackupEnabled;
  final int backupIntervalDays;
  final int keepBackupsCount;

  BackupSettings({
    required this.autoBackupEnabled,
    required this.backupIntervalDays,
    required this.keepBackupsCount,
  });
}
