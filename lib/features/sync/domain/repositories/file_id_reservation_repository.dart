import '../../../../core/error_handling/result.dart';

/// 🆔 File ID Reservation Repository Interface
///
/// Responsible for reserving IDs from the server and managing local IDs.
abstract class FileIdReservationRepository {
  /// ⭐ Run codes login-sync flow (reconcile local code status + fetch new codes)
  Future<Result<void>> loginSyncCodes();

  /// 📥 Reserve IDs from the server
  /// [count] Number of IDs to reserve
  Future<Result<List<int>>> reserveFromRemote(int count);

  /// 💾 Save reserved IDs to local storage
  Future<Result<void>> saveLocal(List<int> ids);

  /// 🆔 Get next available ID for local use
  Future<Result<int?>> getNextAvailableId();

  /// ✅ Mark an ID as used locally
  Future<Result<void>> markAsUsed(
    int fileId,
    int beneficiaryId, {
    String recordType,
    int? recordId,
  });

  /// 🔄 Sync used IDs back to server
  Future<Result<void>> syncUsedIds();

  /// 📊 Get current count of available local IDs
  Future<Result<int>> getAvailableCount();

  /// ♻️ Contract-aligned refill using device-stats + request-codes.
  /// Returns number of newly saved codes.
  Future<Result<int>> refillIfNeeded({
    required int lowThreshold,
    required int requestCount,
  });

  /// 📈 Diagnostics for local pool + remote reservation
  Future<Result<FileIdDiagnostics>> getDiagnostics();
}

class FileIdDiagnostics {
  final int availableCount;
  final int usedUnsyncedCount;
  final DateTime? lastReservedAt;
  final DateTime? lastSyncedAt;
  final int? activeReservationId;
  final int? activeReservationRemaining;
  final int? remoteUnusedCount;
  final bool? remoteCanRequestMore;
  final int? remoteAvailableSlots;
  final DateTime? lastLoginSyncAt;
  final String? lastRefillErrorCode;
  final String? lastRefillErrorMessage;

  const FileIdDiagnostics({
    required this.availableCount,
    required this.usedUnsyncedCount,
    this.lastReservedAt,
    this.lastSyncedAt,
    this.activeReservationId,
    this.activeReservationRemaining,
    this.remoteUnusedCount,
    this.remoteCanRequestMore,
    this.remoteAvailableSlots,
    this.lastLoginSyncAt,
    this.lastRefillErrorCode,
    this.lastRefillErrorMessage,
  });
}
