import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// مدير قاعدة بيانات السجل المدني
/// يدير المسارات، التحقق من الوجود، والإحصائيات
class CivilDatabaseManager {
  static const String CIVIL_DB_NAME = 'civil_registry.db';
  static const String CIVIL_DB_COMPRESSED_NAME = 'civil_registry.db.7z';
  static const String DELTAS_DIR = 'deltas';

  // SharedPreferences Keys
  static const String PREF_DB_DOWNLOADED = 'civil_db_downloaded';
  static const String PREF_DB_VERSION = 'civil_db_version';
  static const String PREF_LAST_SYNC = 'civil_db_last_sync';
  static const String PREF_DB_CHECKSUM = 'civil_db_checksum';
  static const String PREF_DB_SIZE = 'civil_db_size';

  final SharedPreferences _prefs;

  CivilDatabaseManager(this._prefs);

  /// الحصول على مجلد قواعد البيانات
  Future<Directory> getDatabaseDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${appDir.path}/databases');

    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return dbDir;
  }

  /// الحصول على مسار قاعدة بيانات السجل المدني
  Future<String> getCivilDatabasePath() async {
    final dbDir = await getDatabaseDirectory();
    return '${dbDir.path}/$CIVIL_DB_NAME';
  }

  /// الحصول على مسار مجلد الدلتات (التحديثات)
  Future<String> getDeltasDirectoryPath() async {
    final dbDir = await getDatabaseDirectory();
    final deltasDir = Directory('${dbDir.path}/$DELTAS_DIR');

    if (!await deltasDir.exists()) {
      await deltasDir.create(recursive: true);
    }

    return deltasDir.path;
  }

  /// التحقق من وجود قاعدة البيانات
  Future<bool> isDatabaseExists() async {
    try {
      final dbPath = await getCivilDatabasePath();
      final file = File(dbPath);
      return await file.exists();
    } catch (e) {
      debugPrint('خطأ في التحقق من وجود القاعدة: $e');
      return false;
    }
  }

  /// الحصول على حجم قاعدة البيانات بالبايت
  Future<int> getDatabaseSize() async {
    try {
      final dbPath = await getCivilDatabasePath();
      final file = File(dbPath);

      if (await file.exists()) {
        return await file.length();
      }

      return 0;
    } catch (e) {
      debugPrint('خطأ في قراءة حجم القاعدة: $e');
      return 0;
    }
  }

  /// الحصول على حجم قاعدة البيانات بصيغة مقروءة
  Future<String> getDatabaseSizeFormatted() async {
    final bytes = await getDatabaseSize();
    return _formatBytes(bytes);
  }

  /// تنسيق الحجم بالبايت إلى صيغة مقروءة
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// حساب checksum للملف (MD5)
  Future<String> calculateChecksum(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $filePath');
      }

      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('خطأ في حساب checksum: $e');
      rethrow;
    }
  }

  /// التحقق من سلامة قاعدة البيانات
  Future<bool> verifyDatabaseIntegrity({String? expectedChecksum}) async {
    try {
      final dbPath = await getCivilDatabasePath();

      if (!await File(dbPath).exists()) {
        return false;
      }

      // إذا لم يتم تحديد checksum متوقع، نستخدم المحفوظ
      final checksum = expectedChecksum ?? await getSavedChecksum();

      if (checksum == null || checksum.isEmpty) {
        // لا يوجد checksum للمقارنة، نعتبر القاعدة صحيحة
        return true;
      }

      final actualChecksum = await calculateChecksum(dbPath);
      return actualChecksum == checksum;
    } catch (e) {
      debugPrint('خطأ في التحقق من سلامة القاعدة: $e');
      return false;
    }
  }

  /// حفظ معلومات قاعدة البيانات بعد التحميل
  Future<void> saveDatabaseInfo({
    required String checksum,
    required int size,
    String? version,
  }) async {
    await _prefs.setBool(PREF_DB_DOWNLOADED, true);
    await _prefs.setString(PREF_DB_CHECKSUM, checksum);
    await _prefs.setInt(PREF_DB_SIZE, size);
    await _prefs.setString(PREF_LAST_SYNC, DateTime.now().toIso8601String());

    if (version != null) {
      await _prefs.setString(PREF_DB_VERSION, version);
    }
  }

  /// التحقق من حالة التحميل
  Future<bool> isDownloaded() async {
    return _prefs.getBool(PREF_DB_DOWNLOADED) ?? false;
  }

  /// الحصول على checksum المحفوظ
  Future<String?> getSavedChecksum() async {
    return _prefs.getString(PREF_DB_CHECKSUM);
  }

  /// الحصول على إصدار القاعدة
  Future<String?> getDatabaseVersion() async {
    return _prefs.getString(PREF_DB_VERSION);
  }

  /// الحصول على آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime() async {
    final syncString = _prefs.getString(PREF_LAST_SYNC);
    if (syncString != null) {
      return DateTime.tryParse(syncString);
    }
    return null;
  }

  /// حذف قاعدة البيانات
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getCivilDatabasePath();
      final file = File(dbPath);

      if (await file.exists()) {
        await file.delete();
      }

      // حذف الملفات المساعدة
      final shmFile = File('$dbPath-shm');
      if (await shmFile.exists()) await shmFile.delete();

      final walFile = File('$dbPath-wal');
      if (await walFile.exists()) await walFile.delete();

      // مسح المعلومات المحفوظة
      await _prefs.remove(PREF_DB_DOWNLOADED);
      await _prefs.remove(PREF_DB_CHECKSUM);
      await _prefs.remove(PREF_DB_SIZE);
      await _prefs.remove(PREF_DB_VERSION);
    } catch (e) {
      debugPrint('خطأ في حذف القاعدة: $e');
      rethrow;
    }
  }

  /// مسح ملفات الدلتا القديمة
  Future<void> cleanOldDeltas({int keepDays = 30}) async {
    try {
      final deltasPath = await getDeltasDirectoryPath();
      final deltasDir = Directory(deltasPath);

      if (!await deltasDir.exists()) return;

      final now = DateTime.now();
      final files = await deltasDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified).inDays;

          if (age > keepDays) {
            await file.delete();
            debugPrint('تم حذف ملف دلتا قديم: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في تنظيف ملفات الدلتا: $e');
    }
  }

  /// الحصول على إحصائيات القاعدة
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final exists = await isDatabaseExists();
    final size = await getDatabaseSize();
    final sizeFormatted = _formatBytes(size);
    final version = await getDatabaseVersion();
    final lastSync = await getLastSyncTime();
    final downloaded = await isDownloaded();

    return {
      'exists': exists,
      'size': size,
      'sizeFormatted': sizeFormatted,
      'version': version,
      'lastSync': lastSync?.toIso8601String(),
      'isDownloaded': downloaded,
    };
  }

  /// الحصول على المساحة المتاحة في التخزين
  Future<int> getAvailableSpace() async {
    try {
      // في Android/iOS يمكن استخدام مكتبات إضافية للحصول على المساحة
      // هنا نضع قيمة تقديرية
      // يمكن استخدام package:disk_space للحصول على القيمة الفعلية

      return 10 * 1024 * 1024 * 1024; // 10 GB افتراضياً
    } catch (e) {
      debugPrint('خطأ في الحصول على المساحة المتاحة: $e');
      return 0;
    }
  }

  /// التحقق من توفر مساحة كافية
  Future<bool> hasEnoughSpace(int requiredBytes) async {
    final available = await getAvailableSpace();
    // نضيف 500 MB كمساحة احتياطية
    return available >= (requiredBytes + (500 * 1024 * 1024));
  }

  /// عرض معلومات القاعدة (للتطوير)
  Future<void> printDatabaseInfo() async {
    final stats = await getDatabaseStats();
    debugPrint('=== معلومات قاعدة السجل المدني ===');
    debugPrint('موجودة: ${stats['exists']}');
    debugPrint('الحجم: ${stats['sizeFormatted']}');
    debugPrint('الإصدار: ${stats['version'] ?? 'غير محدد'}');
    debugPrint('آخر مزامنة: ${stats['lastSync'] ?? 'لم تتم'}');
    debugPrint('تم التحميل: ${stats['isDownloaded']}');
    debugPrint('===================================');
  }
}
