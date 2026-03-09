import 'dart:async';
import '../../../../core/config/api_config.dart';
import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/utils/unified_logger.dart';
import '../domain/repositories/file_id_reservation_repository.dart';

/// 🆔 File ID Service
///
/// Orchestrates File ID management:
/// - Provides next available ID
/// - Triggers background reservation if running low
/// - Manages usage sync
class FileIdService {
  final FileIdReservationRepository _repository;
  final int _lowThreshold;
  final int _reserveBatchSize;

  bool _isReserving = false;
  bool _noCodesAdminAlertSent = false;

  FileIdService(
    this._repository, {
    int lowThreshold = ApiConfig.fileIdRenewThreshold,
    int reserveBatchSize = ApiConfig.fileIdReserveBatchSize,
  })  : _lowThreshold = lowThreshold < 1 ? ApiConfig.fileIdRenewThreshold : lowThreshold,
        _reserveBatchSize = reserveBatchSize.clamp(100, 10000);

  /// 🆔 Get Next Available ID
  ///
  /// returns the next ID and triggers background reservation if low.
  Future<int?> getNextId() async {
    try {
      final result = await _repository.getNextAvailableId();

      if (result.isFailure) {
        UnifiedLogger.error('❌ Failed to get next File ID', error: result.getOrThrow());
        return null;
      }

      final id = result.getOrNull();

      // Check if we are running low and need to reserve more
      _checkAndReserveIfNeeded();

      return id;
    } catch (e) {
      UnifiedLogger.error('❌ Error in FileIdService.getNextId', error: e);
      return null;
    }
  }

  /// ✅ Mark ID as used
  Future<void> markAsUsed(
    int fileId,
    int beneficiaryId, {
    String recordType = 'data',
    int? recordId,
  }) async {
    await _repository.markAsUsed(
      fileId,
      beneficiaryId,
      recordType: recordType,
      recordId: recordId,
    );
    UnifiedLogger.info('🆔 File ID $fileId marked as used for beneficiary $beneficiaryId');
  }

  /// 📥 Force reserve now
  Future<void> forceReserve() async {
    if (_isReserving) return;
    await _refillByCodesContract();
  }

  /// 🔄 Sync usage to server
  Future<void> syncUsage() async {
    await _repository.syncUsedIds();
  }

  /// ⭐ Run login sync against /codes/login-sync
  Future<void> loginSync() async {
    await _repository.loginSyncCodes();
  }

  Future<String> buildNoFileIdSaveMessage() async {
    final diagnostics = await getDiagnostics();
    final code = diagnostics?.lastRefillErrorCode?.trim();

    if (code == 'no_codes_available') {
      return 'لا توجد أكواد متاحة على السيرفر حالياً. يرجى إبلاغ الإدارة لإنشاء دفعة أكواد جديدة ثم إعادة المحاولة.';
    }

    if (code == 'limit_reached') {
      return 'وصل الجهاز للحد الأعلى من الأكواد غير المستخدمة (5000). استخدم الأكواد الحالية أو نفّذ مزامنة ثم أعد المحاولة.';
    }

    return 'تعذر حجز رقم الملف من السيرفر. يرجى تنفيذ المزامنة ثم إعادة المحاولة.';
  }

  /// 🔄 Public method to trigger reservation check
  Future<void> ensureReservation() async {
    await _checkAndReserveIfNeeded();
  }

  /// 📊 Get diagnostics for local/remote File ID state
  Future<FileIdDiagnostics?> getDiagnostics() async {
    final result = await _repository.getDiagnostics();
    if (result.isFailure) {
      return null;
    }
    return result.getOrNull();
  }

  /// 📊 Check availability and reserve in background if needed
  Future<void> _checkAndReserveIfNeeded() async {
    if (_isReserving) return;

    _isReserving = true;
    try {
      final refillResult = await _repository.refillIfNeeded(
        lowThreshold: _lowThreshold,
        requestCount: _reserveBatchSize,
      );

      if (refillResult.isSuccess) {
        final added = refillResult.getOrThrow();
        if (added > 0) {
          UnifiedLogger.success('✅ Refilled $added codes via /codes/request-codes');
        }
        await _handleRefillDiagnostics();
        return;
      }

      UnifiedLogger.warning('⚠️ Codes refill failed via /codes/request-codes');
      await _handleRefillDiagnostics();
    } finally {
      _isReserving = false;
    }
  }

  Future<void> _refillByCodesContract() async {
    _isReserving = true;
    try {
      final result = await _repository.refillIfNeeded(
        lowThreshold: _lowThreshold,
        requestCount: _reserveBatchSize,
      );

      if (result.isSuccess) {
        final added = result.getOrThrow();
        if (added > 0) {
          UnifiedLogger.success('✅ Requested and saved $added codes');
        }
        await _handleRefillDiagnostics();
        return;
      }
      UnifiedLogger.warning('⚠️ Force refill finished without new codes');
      await _handleRefillDiagnostics();
    } catch (e) {
      UnifiedLogger.warning('⚠️ Force refill failed: $e');
    } finally {
      _isReserving = false;
    }
  }

  Future<void> _handleRefillDiagnostics() async {
    final diagnostics = await getDiagnostics();
    final code = diagnostics?.lastRefillErrorCode?.trim();
    final message = diagnostics?.lastRefillErrorMessage?.trim();

    if (code == 'no_codes_available') {
      UnifiedLogger.warning('🚨 No codes available on server. Admin needs to create a new batch.');
      if (!_noCodesAdminAlertSent) {
        _noCodesAdminAlertSent = true;
        await NotificationsService.showCodesInventoryAlert(
          title: 'تنبيه إداري: نفاد أكواد السيرفر',
          body: 'لا توجد أكواد متاحة حالياً. يلزم إنشاء دفعة جديدة من السيرفر فوراً.',
        );
      }
      return;
    }

    _noCodesAdminAlertSent = false;

    if (code == 'limit_reached') {
      UnifiedLogger.info('ℹ️ Device reached max unused codes limit (5000).');
      return;
    }

    if (message != null && message.isNotEmpty) {
      UnifiedLogger.warning('⚠️ Codes refill issue: $message');
    }
  }
}
