import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncFailure {
  final String itemId;
  final String? group;
  final String? code;
  final String message;

  const SyncFailure({
    required this.itemId,
    required this.message,
    this.group,
    this.code,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'group': group,
      'code': code,
      'message': message,
    };
  }

  factory SyncFailure.fromJson(Map<String, dynamic> json) {
    return SyncFailure(
      itemId: json['itemId']?.toString() ?? '',
      group: json['group']?.toString(),
      code: json['code']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}

class SyncProgressState {
  final bool isRunning;
  final String operation;
  final String phase;
  final int total;
  final int processed;
  final int created;
  final int skipped;
  final int updated;
  final int failed;
  final int pending;
  final double percent;
  final int? fileNumbersAvailable;
  final int? reservedBlockSize;
  final int? pendingAssignedFileNumbers;
  final int? confirmedFileNumbers;
  final int? failedFileNumberConfirmations;
  final String? fileNumberRangeStart;
  final String? fileNumberRangeEnd;
  final String? currentItemId;
  final String? currentGroup;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final List<SyncFailure> failures;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const SyncProgressState({
    required this.isRunning,
    required this.operation,
    required this.phase,
    required this.total,
    required this.processed,
    required this.created,
    required this.skipped,
    required this.updated,
    required this.failed,
    required this.pending,
    required this.percent,
    required this.fileNumbersAvailable,
    required this.reservedBlockSize,
    required this.pendingAssignedFileNumbers,
    required this.confirmedFileNumbers,
    required this.failedFileNumberConfirmations,
    required this.fileNumberRangeStart,
    required this.fileNumberRangeEnd,
    required this.currentItemId,
    required this.currentGroup,
    required this.message,
    required this.errorCode,
    required this.errorMessage,
    required this.failures,
    required this.startedAt,
    required this.finishedAt,
  });

  factory SyncProgressState.idle() {
    final now = DateTime.now();
    return SyncProgressState(
      isRunning: false,
      operation: 'idle',
      phase: 'idle',
      total: 0,
      processed: 0,
      created: 0,
      skipped: 0,
      updated: 0,
      failed: 0,
      pending: 0,
      percent: 0,
      fileNumbersAvailable: null,
      reservedBlockSize: null,
      pendingAssignedFileNumbers: null,
      confirmedFileNumbers: null,
      failedFileNumberConfirmations: null,
      fileNumberRangeStart: null,
      fileNumberRangeEnd: null,
      currentItemId: null,
      currentGroup: null,
      message: null,
      errorCode: null,
      errorMessage: null,
      failures: const <SyncFailure>[],
      startedAt: now,
      finishedAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isRunning': isRunning,
      'operation': operation,
      'phase': phase,
      'total': total,
      'processed': processed,
      'created': created,
      'skipped': skipped,
      'updated': updated,
      'failed': failed,
      'pending': pending,
      'percent': percent,
      'fileNumbersAvailable': fileNumbersAvailable,
      'reservedBlockSize': reservedBlockSize,
      'pendingAssignedFileNumbers': pendingAssignedFileNumbers,
      'confirmedFileNumbers': confirmedFileNumbers,
      'failedFileNumberConfirmations': failedFileNumberConfirmations,
      'fileNumberRangeStart': fileNumberRangeStart,
      'fileNumberRangeEnd': fileNumberRangeEnd,
      'currentItemId': currentItemId,
      'currentGroup': currentGroup,
      'message': message,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'failures': failures.map((e) => e.toJson()).toList(growable: false),
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory SyncProgressState.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double asDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    List<SyncFailure> parseFailures(dynamic value) {
      if (value is! List) return const <SyncFailure>[];
      return value
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .map(SyncFailure.fromJson)
          .toList(growable: false);
    }

    final startedAt = DateTime.tryParse(json['startedAt']?.toString() ?? '') ?? DateTime.now();
    final finishedAtRaw = json['finishedAt']?.toString();

    return SyncProgressState(
      isRunning: json['isRunning'] == true,
      operation: json['operation']?.toString() ?? 'idle',
      phase: json['phase']?.toString() ?? 'idle',
      total: asInt(json['total']),
      processed: asInt(json['processed']),
      created: asInt(json['created']),
      skipped: asInt(json['skipped']),
      updated: asInt(json['updated']),
      failed: asInt(json['failed']),
      pending: asInt(json['pending']),
      percent: asDouble(json['percent']),
      fileNumbersAvailable: json['fileNumbersAvailable'] == null ? null : asInt(json['fileNumbersAvailable']),
      reservedBlockSize: json['reservedBlockSize'] == null ? null : asInt(json['reservedBlockSize']),
      pendingAssignedFileNumbers:
          json['pendingAssignedFileNumbers'] == null ? null : asInt(json['pendingAssignedFileNumbers']),
      confirmedFileNumbers: json['confirmedFileNumbers'] == null ? null : asInt(json['confirmedFileNumbers']),
      failedFileNumberConfirmations:
          json['failedFileNumberConfirmations'] == null ? null : asInt(json['failedFileNumberConfirmations']),
      fileNumberRangeStart: json['fileNumberRangeStart']?.toString(),
      fileNumberRangeEnd: json['fileNumberRangeEnd']?.toString(),
      currentItemId: json['currentItemId']?.toString(),
      currentGroup: json['currentGroup']?.toString(),
      message: json['message']?.toString(),
      errorCode: json['errorCode']?.toString(),
      errorMessage: json['errorMessage']?.toString(),
      failures: parseFailures(json['failures']),
      startedAt: startedAt,
      finishedAt: finishedAtRaw == null ? null : DateTime.tryParse(finishedAtRaw),
    );
  }

  SyncProgressState copyWith({
    bool? isRunning,
    String? operation,
    String? phase,
    int? total,
    int? processed,
    int? created,
    int? skipped,
    int? updated,
    int? failed,
    int? pending,
    double? percent,
    int? fileNumbersAvailable,
    int? reservedBlockSize,
    int? pendingAssignedFileNumbers,
    int? confirmedFileNumbers,
    int? failedFileNumberConfirmations,
    String? fileNumberRangeStart,
    String? fileNumberRangeEnd,
    String? currentItemId,
    String? currentGroup,
    String? message,
    String? errorCode,
    String? errorMessage,
    List<SyncFailure>? failures,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool clearError = false,
  }) {
    return SyncProgressState(
      isRunning: isRunning ?? this.isRunning,
      operation: operation ?? this.operation,
      phase: phase ?? this.phase,
      total: total ?? this.total,
      processed: processed ?? this.processed,
      created: created ?? this.created,
      skipped: skipped ?? this.skipped,
      updated: updated ?? this.updated,
      failed: failed ?? this.failed,
      pending: pending ?? this.pending,
      percent: percent ?? this.percent,
      fileNumbersAvailable: fileNumbersAvailable ?? this.fileNumbersAvailable,
      reservedBlockSize: reservedBlockSize ?? this.reservedBlockSize,
      pendingAssignedFileNumbers: pendingAssignedFileNumbers ?? this.pendingAssignedFileNumbers,
      confirmedFileNumbers: confirmedFileNumbers ?? this.confirmedFileNumbers,
      failedFileNumberConfirmations: failedFileNumberConfirmations ?? this.failedFileNumberConfirmations,
      fileNumberRangeStart: fileNumberRangeStart ?? this.fileNumberRangeStart,
      fileNumberRangeEnd: fileNumberRangeEnd ?? this.fileNumberRangeEnd,
      currentItemId: currentItemId ?? this.currentItemId,
      currentGroup: currentGroup ?? this.currentGroup,
      message: message ?? this.message,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failures: failures ?? this.failures,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}

class SyncProgressController extends StateNotifier<SyncProgressState> {
  SyncProgressController() : super(SyncProgressState.idle());

  void start({
    required String operation,
    String phase = 'preparing',
    int total = 0,
    String? message,
  }) {
    state = SyncProgressState(
      isRunning: true,
      operation: operation,
      phase: phase,
      total: total,
      processed: 0,
      created: 0,
      skipped: 0,
      updated: 0,
      failed: 0,
      pending: total,
      percent: 0,
      fileNumbersAvailable: null,
      reservedBlockSize: null,
      pendingAssignedFileNumbers: null,
      confirmedFileNumbers: null,
      failedFileNumberConfirmations: null,
      fileNumberRangeStart: null,
      fileNumberRangeEnd: null,
      currentItemId: null,
      currentGroup: null,
      message: message,
      errorCode: null,
      errorMessage: null,
      failures: const <SyncFailure>[],
      startedAt: DateTime.now(),
      finishedAt: null,
    );
  }

  void update({
    String? phase,
    int? total,
    int? processed,
    int? created,
    int? skipped,
    int? updated,
    int? failed,
    int? pending,
    int? fileNumbersAvailable,
    int? reservedBlockSize,
    int? pendingAssignedFileNumbers,
    int? confirmedFileNumbers,
    int? failedFileNumberConfirmations,
    String? fileNumberRangeStart,
    String? fileNumberRangeEnd,
    String? currentItemId,
    String? currentGroup,
    String? message,
    String? errorCode,
    String? errorMessage,
    List<SyncFailure>? failures,
  }) {
    final nextTotal = total ?? state.total;
    final nextProcessed = processed ?? state.processed;
    final computedPercent = nextTotal <= 0 ? state.percent : (nextProcessed / nextTotal).clamp(0, 1).toDouble();

    state = state.copyWith(
      phase: phase,
      total: nextTotal,
      processed: nextProcessed,
      created: created,
      skipped: skipped,
      updated: updated,
      failed: failed,
      pending: pending,
      fileNumbersAvailable: fileNumbersAvailable,
      reservedBlockSize: reservedBlockSize,
      pendingAssignedFileNumbers: pendingAssignedFileNumbers,
      confirmedFileNumbers: confirmedFileNumbers,
      failedFileNumberConfirmations: failedFileNumberConfirmations,
      fileNumberRangeStart: fileNumberRangeStart,
      fileNumberRangeEnd: fileNumberRangeEnd,
      percent: computedPercent,
      currentItemId: currentItemId,
      currentGroup: currentGroup,
      message: message,
      errorCode: errorCode,
      errorMessage: errorMessage,
      failures: failures,
    );
  }

  void pause({
    String phase = 'paused',
    String? message,
    String? errorCode,
    String? errorMessage,
  }) {
    state = state.copyWith(
      isRunning: false,
      phase: phase,
      message: message,
      errorCode: errorCode,
      errorMessage: errorMessage,
      finishedAt: DateTime.now(),
    );
  }

  void complete({
    String phase = 'completed',
    String? message,
  }) {
    state = state.copyWith(
      isRunning: false,
      phase: phase,
      processed: state.total == 0 ? state.processed : state.total,
      pending: 0,
      percent: 1,
      message: message,
      finishedAt: DateTime.now(),
      clearError: true,
    );
  }

  void fail({
    String phase = 'failed',
    String? errorCode,
    String? errorMessage,
    String? message,
  }) {
    state = state.copyWith(
      isRunning: false,
      phase: phase,
      message: message ?? state.message,
      errorCode: errorCode,
      errorMessage: errorMessage,
      finishedAt: DateTime.now(),
    );
  }

  void reset() {
    state = SyncProgressState.idle();
  }

  void restore(SyncProgressState snapshot) {
    state = snapshot;
  }
}

final syncControllerProvider = StateNotifierProvider<SyncProgressController, SyncProgressState>((ref) {
  return SyncProgressController();
});

final syncProgressProvider = Provider<SyncProgressState>((ref) {
  return ref.watch(syncControllerProvider);
});
