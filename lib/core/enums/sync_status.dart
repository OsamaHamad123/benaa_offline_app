/// Enum for sync status states
enum SyncStatus {
  synced('تمت المزامنة'),
  pending('بانتظار المزامنة'),
  failed('فشلت المزامنة');

  const SyncStatus(this.arabicLabel);

  final String arabicLabel;

  /// Get SyncStatus from Arabic label
  static SyncStatus fromLabel(String label) {
    return SyncStatus.values.firstWhere(
      (status) => status.arabicLabel == label,
      orElse: () => SyncStatus.pending,
    );
  }

  /// Get SyncStatus from database value (0 = pending, 1 = synced, 2 = failed)
  static SyncStatus fromInt(int value) {
    switch (value) {
      case 0:
        return SyncStatus.pending;
      case 1:
        return SyncStatus.synced;
      case 2:
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }

  /// Convert to database value
  int toInt() {
    switch (this) {
      case SyncStatus.pending:
        return 0;
      case SyncStatus.synced:
        return 1;
      case SyncStatus.failed:
        return 2;
    }
  }
}
