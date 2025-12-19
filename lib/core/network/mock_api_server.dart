import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎭 Mock API Server - محاكي سيرفر محلي للتجربة
///
/// يحفظ البيانات في SharedPreferences ويحاكي سلوك API حقيقي:
/// - Network delays
/// - Success/Error responses
/// - Conflict detection
/// - Data persistence
class MockApiServer {
  static const String _keyBeneficiaries = 'mock_server_beneficiaries';
  static const String _keyVisits = 'mock_server_visits';
  static const String _keyAttachments = 'mock_server_attachments';

  final SharedPreferences _prefs;

  // إعدادات السيرفر الوهمي
  bool simulateNetworkDelay = true;
  int minDelayMs = 500;
  int maxDelayMs = 2000;
  double errorRate = 0.1; // 10% احتمال حدوث خطأ
  bool simulateConflicts = true;

  MockApiServer(this._prefs);

  /// تأخير وهمي لمحاكاة الشبكة
  Future<void> _simulateNetworkDelay() async {
    if (!simulateNetworkDelay) return;

    final delay = minDelayMs +
        (maxDelayMs - minDelayMs) * (DateTime.now().millisecond % 1000) / 1000;
    await Future.delayed(Duration(milliseconds: delay.toInt()));
  }

  /// محاكاة خطأ عشوائي
  void _simulateRandomError() {
    if (DateTime.now().millisecond % 100 < errorRate * 100) {
      throw MockApiException('Network timeout - simulated error');
    }
  }

  // ============================================================================
  // BENEFICIARIES API
  // ============================================================================

  /// مزامنة المستفيدين
  Future<Map<String, dynamic>> syncBeneficiaries(
    List<Map<String, dynamic>> beneficiaries,
  ) async {
    await _simulateNetworkDelay();
    _simulateRandomError();

    final serverBeneficiaries = _getServerBeneficiaries();
    final results = <Map<String, dynamic>>[];
    final conflicts = <Map<String, dynamic>>[];

    for (final beneficiary in beneficiaries) {
      final localId = beneficiary['id'] as String;
      final serverId = beneficiary['server_id'] as String?;

      // تحقق من وجود تعارض
      if (simulateConflicts && serverId != null) {
        final serverRecord = serverBeneficiaries.firstWhere(
          (b) => b['id'] == serverId,
          orElse: () => {},
        );

        if (serverRecord.isNotEmpty) {
          final serverUpdated = DateTime.parse(
            serverRecord['updated_at'] as String? ??
                serverRecord['created_at'] as String,
          );
          final localUpdated = DateTime.parse(
            beneficiary['updated_at'] as String? ??
                beneficiary['created_at'] as String,
          );

          // إذا السيرفر أحدث، في تعارض
          if (serverUpdated.isAfter(localUpdated)) {
            conflicts.add({
              'local_id': localId,
              'server_id': serverId,
              'local_data': beneficiary,
              'server_data': serverRecord,
              'conflict_type': 'UPDATE_CONFLICT',
            });
            continue;
          }
        }
      }

      // إنشاء أو تحديث على السيرفر
      final newServerId =
          serverId ?? 'server_${DateTime.now().millisecondsSinceEpoch}';
      final serverRecord = {
        ...beneficiary,
        'id': newServerId,
        'local_id': localId,
        'synced_at': DateTime.now().toIso8601String(),
      };

      // تحديث أو إضافة في "السيرفر"
      final existingIndex = serverBeneficiaries.indexWhere(
        (b) => b['id'] == newServerId,
      );

      if (existingIndex >= 0) {
        serverBeneficiaries[existingIndex] = serverRecord;
      } else {
        serverBeneficiaries.add(serverRecord);
      }

      results.add(serverRecord);
    }

    // حفظ البيانات في السيرفر الوهمي
    await _saveServerBeneficiaries(serverBeneficiaries);

    return {
      'success': true,
      'data': results,
      'conflicts': conflicts,
      'synced_count': results.length,
      'conflict_count': conflicts.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// جلب المستفيدين من السيرفر
  Future<Map<String, dynamic>> fetchBeneficiaries({
    DateTime? since,
    int? limit,
    int? offset,
  }) async {
    await _simulateNetworkDelay();
    _simulateRandomError();

    var beneficiaries = _getServerBeneficiaries();

    // فلترة حسب التاريخ
    if (since != null) {
      beneficiaries = beneficiaries.where((b) {
        final updated = DateTime.parse(
          b['updated_at'] as String? ?? b['created_at'] as String,
        );
        return updated.isAfter(since);
      }).toList();
    }

    // Pagination
    final total = beneficiaries.length;
    final start = offset ?? 0;
    final end = limit != null ? start + limit : beneficiaries.length;

    final paginatedData = beneficiaries.sublist(
      start.clamp(0, beneficiaries.length),
      end.clamp(0, beneficiaries.length),
    );

    return {
      'success': true,
      'data': paginatedData,
      'total': total,
      'limit': limit,
      'offset': offset,
      'has_more': end < total,
    };
  }

  /// حذف مستفيد من السيرفر
  Future<Map<String, dynamic>> deleteBeneficiary(String serverId) async {
    await _simulateNetworkDelay();
    _simulateRandomError();

    final beneficiaries = _getServerBeneficiaries();
    beneficiaries.removeWhere((b) => b['id'] == serverId);
    await _saveServerBeneficiaries(beneficiaries);

    return {
      'success': true,
      'message': 'Beneficiary deleted successfully',
      'deleted_id': serverId,
    };
  }

  // ============================================================================
  // CONFLICTS RESOLUTION
  // ============================================================================

  /// حل التعارضات
  Future<Map<String, dynamic>> resolveConflict({
    required String localId,
    required String serverId,
    required String resolution, // 'use_local' | 'use_server' | 'merge'
    Map<String, dynamic>? mergedData,
  }) async {
    await _simulateNetworkDelay();

    final beneficiaries = _getServerBeneficiaries();
    final serverIndex = beneficiaries.indexWhere((b) => b['id'] == serverId);

    if (serverIndex < 0) {
      throw MockApiException('Server record not found');
    }

    Map<String, dynamic> finalData;

    switch (resolution) {
      case 'use_local':
        // استخدم البيانات المحلية
        finalData = mergedData ?? {};
        break;
      case 'use_server':
        // استخدم بيانات السيرفر (لا تفعل شيء)
        return {
          'success': true,
          'resolution': 'use_server',
          'data': beneficiaries[serverIndex],
        };
      case 'merge':
        // دمج البيانات
        if (mergedData == null) {
          throw MockApiException('Merged data required for merge resolution');
        }
        finalData = mergedData;
        break;
      default:
        throw MockApiException('Invalid resolution type: $resolution');
    }

    // تحديث السيرفر
    beneficiaries[serverIndex] = {
      ...finalData,
      'id': serverId,
      'resolved_at': DateTime.now().toIso8601String(),
    };

    await _saveServerBeneficiaries(beneficiaries);

    return {
      'success': true,
      'resolution': resolution,
      'data': beneficiaries[serverIndex],
    };
  }

  // ============================================================================
  // SERVER STATUS
  // ============================================================================

  /// حالة السيرفر
  Future<Map<String, dynamic>> getServerStatus() async {
    await _simulateNetworkDelay();

    return {
      'success': true,
      'server_time': DateTime.now().toIso8601String(),
      'version': '1.0.0-mock',
      'is_mock': true,
      'stats': {
        'total_beneficiaries': _getServerBeneficiaries().length,
        'total_visits': _getServerVisits().length,
        'total_attachments': _getServerAttachments().length,
      },
    };
  }

  // ============================================================================
  // STORAGE HELPERS
  // ============================================================================

  List<Map<String, dynamic>> _getServerBeneficiaries() {
    final data = _prefs.getString(_keyBeneficiaries);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(data) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> _saveServerBeneficiaries(
    List<Map<String, dynamic>> beneficiaries,
  ) async {
    await _prefs.setString(_keyBeneficiaries, jsonEncode(beneficiaries));
  }

  List<Map<String, dynamic>> _getServerVisits() {
    final data = _prefs.getString(_keyVisits);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(data) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  List<Map<String, dynamic>> _getServerAttachments() {
    final data = _prefs.getString(_keyAttachments);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(data) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// مسح كل بيانات السيرفر الوهمي
  Future<void> clearServerData() async {
    await _prefs.remove(_keyBeneficiaries);
    await _prefs.remove(_keyVisits);
    await _prefs.remove(_keyAttachments);
  }

  /// إضافة بيانات تجريبية للسيرفر
  Future<void> seedTestData() async {
    final testBeneficiaries = [
      {
        'id': 'server_test_1',
        'full_name': 'محمد أحمد علي',
        'national_id': '100200300400',
        'created_at':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'server_test_2',
        'full_name': 'فاطمة حسن محمود',
        'national_id': '200300400500',
        'created_at':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    await _saveServerBeneficiaries(testBeneficiaries);
  }
}

/// استثناء API وهمي
class MockApiException implements Exception {
  final String message;
  MockApiException(this.message);

  @override
  String toString() => 'MockApiException: $message';
}
