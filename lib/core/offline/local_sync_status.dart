enum LocalSyncStatus {
  pendingUpload('pending_upload'),
  synced('synced'),
  failedUpload('failed_upload'),
  pendingDelete('pending_delete'),
  conflict('conflict');

  const LocalSyncStatus(this.value);
  final String value;

  static LocalSyncStatus fromValue(String? value) {
    for (final status in LocalSyncStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return LocalSyncStatus.pendingUpload;
  }
}
