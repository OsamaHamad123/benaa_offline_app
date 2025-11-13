import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/civil_database_manager.dart';
import '../../features/setup/initial_setup_page.dart';

/// مساعد للتحقق من حالة قاعدة بيانات السجل المدني وعرض صفحة الإعداد إذا لزم الأمر
class CivilDatabaseSetupHelper {
  /// URL تحميل قاعدة البيانات (يجب تعديله حسب السيرفر الفعلي)
  static const String DOWNLOAD_URL =
      'https://api.benaa.gov.iq/downloads/civil_registry.db';

  /// Checksum المتوقع (اختياري - للتحقق من سلامة الملف)
  static const String? EXPECTED_CHECKSUM = null;

  /// التحقق من حالة قاعدة البيانات وإظهار صفحة الإعداد إذا لزم الأمر
  ///
  /// يُستخدم عند بدء التطبيق للتحقق من وجود قاعدة بيانات السجل المدني
  ///
  /// Returns: true إذا كانت قاعدة البيانات موجودة أو قام المستخدم بتخطي الإعداد
  static Future<bool> checkAndShowSetupIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final dbManager = CivilDatabaseManager(prefs);

    // التحقق من وجود قاعدة البيانات
    final exists = await dbManager.isDatabaseExists();

    if (exists) {
      // قاعدة البيانات موجودة
      return true;
    }

    // التحقق إذا قام المستخدم بتخطي الإعداد سابقاً
    final skipped = prefs.getBool('civil_db_setup_skipped') ?? false;

    if (skipped) {
      // المستخدم اختار التخطي سابقاً
      return true;
    }

    // عرض صفحة الإعداد
    if (context.mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const InitialSetupPage(
            downloadUrl: DOWNLOAD_URL,
            expectedChecksum: EXPECTED_CHECKSUM,
          ),
          fullscreenDialog: true,
        ),
      );

      // إذا اختار المستخدم التخطي
      if (result == false) {
        await prefs.setBool('civil_db_setup_skipped', true);
      }

      return result ?? false;
    }

    return false;
  }

  /// فتح صفحة إعدادات قاعدة البيانات من القائمة
  static Future<void> openSetupPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InitialSetupPage(
          downloadUrl: DOWNLOAD_URL,
          expectedChecksum: EXPECTED_CHECKSUM,
        ),
      ),
    );
  }

  /// الحصول على معلومات حالة قاعدة البيانات
  static Future<Map<String, dynamic>> getDatabaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dbManager = CivilDatabaseManager(prefs);

    return await dbManager.getDatabaseStats();
  }

  /// إعادة تعيين حالة التخطي (لإظهار صفحة الإعداد مرة أخرى)
  static Future<void> resetSkipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('civil_db_setup_skipped');
  }

  /// حذف قاعدة البيانات
  static Future<void> deleteDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final dbManager = CivilDatabaseManager(prefs);
    await dbManager.deleteDatabase();
    await resetSkipStatus();
  }

  /// عرض معلومات قاعدة البيانات في dialog
  static Future<void> showDatabaseInfo(BuildContext context) async {
    final stats = await getDatabaseStatus();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات قاعدة السجل المدني'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('الحالة', stats['exists'] ? 'موجودة' : 'غير موجودة'),
            const Divider(),
            _buildInfoRow('الحجم', stats['sizeFormatted'] ?? 'غير معروف'),
            const Divider(),
            _buildInfoRow('الإصدار', stats['version'] ?? 'غير محدد'),
            const Divider(),
            _buildInfoRow(
              'آخر مزامنة',
              stats['lastSync'] != null
                  ? DateTime.parse(stats['lastSync']).toString()
                  : 'لم تتم',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
