class SyncCollectionSummary {
  const SyncCollectionSummary({
    required this.collectionName,
    required this.labelAr,
    required this.localCount,
    required this.remoteCount,
    required this.pendingUpload,
    required this.failedUpload,
    required this.conflicts,
    required this.lastUploadAt,
  });

  final String collectionName;
  final String labelAr;
  final int localCount;
  final int remoteCount;
  final int pendingUpload;
  final int failedUpload;
  final int conflicts;
  final DateTime? lastUploadAt;
}

class SyncUploadAllResult {
  const SyncUploadAllResult({
    required this.totalPending,
    required this.totalUploaded,
    required this.totalFailed,
    required this.noData,
    required this.moduleBreakdown,
  });

  final int totalPending;
  final int totalUploaded;
  final int totalFailed;
  final bool noData;
  final Map<String, int> moduleBreakdown;
}
