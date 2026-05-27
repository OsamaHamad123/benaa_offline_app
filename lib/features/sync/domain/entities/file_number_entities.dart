class FileNumberBlock {
  final String blockId;
  final String deviceId;
  final String userId;
  final String prefix;
  final int year;
  final int start;
  final int end;
  final String status;
  final DateTime? reservedAt;
  final DateTime? expiresAt;
  final int usedCount;
  final int releasedCount;
  final String appVersion;

  const FileNumberBlock({
    required this.blockId,
    required this.deviceId,
    required this.userId,
    required this.prefix,
    required this.year,
    required this.start,
    required this.end,
    required this.status,
    required this.reservedAt,
    required this.expiresAt,
    required this.usedCount,
    required this.releasedCount,
    required this.appVersion,
  });

  int get size => (end - start) + 1;
}

class FileNumberAllocation {
  final String fileNumber;
  final int number;
  final int year;
  final String prefix;
  final String status;
  final String beneficiaryLocalId;
  final String? beneficiaryRemoteId;
  final String deviceId;
  final String userId;
  final String blockId;
  final DateTime assignedAtLocal;

  const FileNumberAllocation({
    required this.fileNumber,
    required this.number,
    required this.year,
    required this.prefix,
    required this.status,
    required this.beneficiaryLocalId,
    required this.beneficiaryRemoteId,
    required this.deviceId,
    required this.userId,
    required this.blockId,
    required this.assignedAtLocal,
  });
}

class LocalFileNumber {
  final String fileNumber;
  final int number;
  final int year;
  final String prefix;
  final String blockId;
  final String status;
  final String? beneficiaryLocalId;
  final String? formSessionId;
  final DateTime? tentativeAt;
  final DateTime? assignedAt;
  final DateTime? syncedAt;

  const LocalFileNumber({
    required this.fileNumber,
    required this.number,
    required this.year,
    required this.prefix,
    required this.blockId,
    required this.status,
    required this.beneficiaryLocalId,
    required this.formSessionId,
    required this.tentativeAt,
    required this.assignedAt,
    required this.syncedAt,
  });
}

class FileNumberCounterStatus {
  final String prefix;
  final int year;
  final int nextNumber;
  final int blockSizeDefault;

  const FileNumberCounterStatus({
    required this.prefix,
    required this.year,
    required this.nextNumber,
    required this.blockSizeDefault,
  });
}
