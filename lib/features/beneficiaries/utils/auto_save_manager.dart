import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 💾 Auto-save Manager
/// يحفظ البيانات تلقائياً كل 30 ثانية لتجنب فقدان البيانات
class AutoSaveManager {
  static const String _keyPrefix = 'beneficiary_draft_';
  Timer? _autoSaveTimer;

  /// بدء الحفظ التلقائي
  void startAutoSave(String draftId, Map<String, dynamic> Function() getData) {
    _autoSaveTimer?.cancel();

    // حفظ كل 30 ثانية
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async => await saveDraft(draftId, getData()),
    );
  }

  /// إيقاف الحفظ التلقائي
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// حفظ المسودة
  Future<void> saveDraft(String draftId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(data);
      await prefs.setString('$_keyPrefix$draftId', jsonData);
      await prefs.setString(
        '${_keyPrefix}${draftId}_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Silent fail - لا نريد إزعاج المستخدم
    }
  }

  /// استرجاع المسودة
  Future<Map<String, dynamic>?> loadDraft(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('$_keyPrefix$draftId');
      if (jsonData != null) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  /// حذف المسودة
  Future<void> deleteDraft(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$draftId');
      await prefs.remove('${_keyPrefix}${draftId}_timestamp');
    } catch (e) {
      // Silent fail
    }
  }

  /// التحقق من وجود مسودة
  Future<bool> hasDraft(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_keyPrefix$draftId');
    } catch (e) {
      return false;
    }
  }

  /// الحصول على تاريخ آخر حفظ
  Future<DateTime?> getLastSaveTime(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('${_keyPrefix}${draftId}_timestamp');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  void dispose() {
    stopAutoSave();
  }
}
