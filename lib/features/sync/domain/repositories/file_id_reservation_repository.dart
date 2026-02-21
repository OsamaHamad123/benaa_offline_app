import '../../../../core/error_handling/result.dart';

/// 🆔 File ID Reservation Repository Interface
///
/// Responsible for reserving IDs from the server and managing local IDs.
abstract class FileIdReservationRepository {
  /// 📥 Reserve IDs from the server
  /// [count] Number of IDs to reserve
  Future<Result<List<int>>> reserveFromRemote(int count);

  /// 💾 Save reserved IDs to local storage
  Future<Result<void>> saveLocal(List<int> ids);

  /// 🆔 Get next available ID for local use
  Future<Result<int?>> getNextAvailableId();

  /// ✅ Mark an ID as used locally
  Future<Result<void>> markAsUsed(int fileId, int beneficiaryId);

  /// 🔄 Sync used IDs back to server
  Future<Result<void>> syncUsedIds();

  /// 📊 Get current count of available local IDs
  Future<Result<int>> getAvailableCount();

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

  const FileIdDiagnostics({
    required this.availableCount,
    required this.usedUnsyncedCount,
    this.lastReservedAt,
    this.lastSyncedAt,
    this.activeReservationId,
    this.activeReservationRemaining,
  });
}
