class ModuleSyncStats {
  final int total;
  final int uploaded;
  final int downloaded;
  final int failed;
  final int conflicts;

  const ModuleSyncStats({
    this.total = 0,
    this.uploaded = 0,
    this.downloaded = 0,
    this.failed = 0,
    this.conflicts = 0,
  });

  ModuleSyncStats copyWith({
    int? total,
    int? uploaded,
    int? downloaded,
    int? failed,
    int? conflicts,
  }) {
    return ModuleSyncStats(
      total: total ?? this.total,
      uploaded: uploaded ?? this.uploaded,
      downloaded: downloaded ?? this.downloaded,
      failed: failed ?? this.failed,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  ModuleSyncStats operator +(ModuleSyncStats other) {
    return ModuleSyncStats(
      total: total + other.total,
      uploaded: uploaded + other.uploaded,
      downloaded: downloaded + other.downloaded,
      failed: failed + other.failed,
      conflicts: conflicts + other.conflicts,
    );
  }
}
