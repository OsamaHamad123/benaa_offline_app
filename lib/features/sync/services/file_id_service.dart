import 'dart:async';
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

  // Threshold to trigger reservation (API contract: renew when remaining < 1000)
  static const int _lowThreshold = 1000;
  static const int _reserveBatchSize = 5000;

  bool _isReserving = false;

  FileIdService(this._repository);

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
  Future<void> markAsUsed(int fileId, int beneficiaryId) async {
    await _repository.markAsUsed(fileId, beneficiaryId);
    UnifiedLogger.info('🆔 File ID $fileId marked as used for beneficiary $beneficiaryId');
  }

  /// 📥 Force reserve now
  Future<void> forceReserve() async {
    if (_isReserving) return;
    await _reserveMore();
  }

  /// 🔄 Sync usage to server
  Future<void> syncUsage() async {
    await _repository.syncUsedIds();
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

    final countResult = await _repository.getAvailableCount();
    if (countResult.isSuccess) {
      final available = countResult.getOrThrow();
      if (available < _lowThreshold) {
        UnifiedLogger.info('⚠️ Low File IDs available ($available). Reserving more...');
        _reserveMore();
      }
    }
  }

  /// 📥 Background reservation
  Future<void> _reserveMore() async {
    _isReserving = true;
    try {
      final reserveResult = await _repository.reserveFromRemote(_reserveBatchSize);

      if (reserveResult.isSuccess) {
        final ids = reserveResult.getOrThrow();
        await _repository.saveLocal(ids);
        UnifiedLogger.success('✅ Reserved and saved ${ids.length} new File IDs');
      } else {
        UnifiedLogger.error('❌ Failed to reserve File IDs from remote', error: reserveResult.getOrThrow().toString());
      }
    } catch (e) {
      UnifiedLogger.error('❌ Error during background ID reservation', error: e);
    } finally {
      _isReserving = false;
    }
  }
}
