import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/activity_log.dart';

/// Activity Logger Service - لتسجيل وإدارة نشاطات المستخدم
class ActivityLogger {
  static const String _storageKey = 'activity_logs';
  static const int _maxLogs = 50; // أقصى عدد من السجلات

  static Future<void> logAdd(
    String beneficiaryId,
    String beneficiaryName,
  ) async {
    final activity = ActivityLog.fromBeneficiaryAdd(
      beneficiaryId,
      beneficiaryName,
    );
    await _saveActivity(activity);
  }

  static Future<void> logEdit(
    String beneficiaryId,
    String beneficiaryName,
  ) async {
    final activity = ActivityLog.fromBeneficiaryEdit(
      beneficiaryId,
      beneficiaryName,
    );
    await _saveActivity(activity);
  }

  static Future<void> logDelete(
    String beneficiaryId,
    String beneficiaryName,
  ) async {
    final activity = ActivityLog.fromBeneficiaryDelete(
      beneficiaryId,
      beneficiaryName,
    );
    await _saveActivity(activity);
  }

  static Future<void> logSync(int count) async {
    final activity = ActivityLog.fromSync(count);
    await _saveActivity(activity);
  }

  static Future<void> logVisit(
    String beneficiaryId,
    String beneficiaryName,
  ) async {
    final activity = ActivityLog.fromVisit(beneficiaryId, beneficiaryName);
    await _saveActivity(activity);
  }

  static Future<void> _saveActivity(ActivityLog activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = await getRecentActivities();

      // إضافة النشاط الجديد في البداية
      logs.insert(0, activity);

      // الاحتفاظ بآخر _maxLogs فقط
      if (logs.length > _maxLogs) {
        logs.removeRange(_maxLogs, logs.length);
      }

      // حفظ البيانات
      final jsonList = logs.map((log) => log.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving activity: $e');
    }
  }

  static Future<List<ActivityLog>> getRecentActivities({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final logs = jsonList
          .map((json) => ActivityLog.fromJson(json as Map<String, dynamic>))
          .toList();

      // إرجاع آخر activities حسب الـ limit
      return logs.take(limit).toList();
    } catch (e) {
      print('Error loading activities: $e');
      return [];
    }
  }

  static Future<List<ActivityLog>> getActivitiesByType(String type) async {
    final logs = await getRecentActivities(limit: _maxLogs);
    return logs.where((log) => log.type == type).toList();
  }

  static Future<Map<String, int>> getActivityStats() async {
    final logs = await getRecentActivities(limit: _maxLogs);

    final stats = <String, int>{
      'total': logs.length,
      'add': 0,
      'edit': 0,
      'delete': 0,
      'sync': 0,
      'visit': 0,
    };

    for (final log in logs) {
      stats[log.type] = (stats[log.type] ?? 0) + 1;
    }

    return stats;
  }

  static Future<List<ActivityLog>> getTodayActivities() async {
    final logs = await getRecentActivities(limit: _maxLogs);
    final today = DateTime.now();

    return logs.where((log) {
      return log.timestamp.year == today.year &&
          log.timestamp.month == today.month &&
          log.timestamp.day == today.day;
    }).toList();
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing activities: $e');
    }
  }
}
