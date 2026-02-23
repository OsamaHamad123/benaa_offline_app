import 'package:equatable/equatable.dart';

/// 🎯 Domain Entity - Sync Result
///
/// يمثل نتيجة أي عملية مزامنة (Success/Failure/Partial)
sealed class SyncResult extends Equatable {
  const SyncResult();

  @override
  List<Object?> get props => [];
}

/// ✅ مزامنة ناجحة بالكامل
class SyncSuccess extends SyncResult {
  final int itemsSynced;
  final DateTime syncedAt;
  final String message;

  const SyncSuccess({
    required this.itemsSynced,
    required this.syncedAt,
    this.message = 'تمت المزامنة بنجاح',
  });

  @override
  List<Object?> get props => [itemsSynced, syncedAt, message];
}

/// ⚠️ مزامنة جزئية (بعض العناصر فشلت)
class SyncPartial extends SyncResult {
  final int successCount;
  final int failureCount;
  final List<SyncConflict> conflicts;
  final DateTime syncedAt;

  const SyncPartial({
    required this.successCount,
    required this.failureCount,
    required this.conflicts,
    required this.syncedAt,
  });

  @override
  List<Object?> get props => [successCount, failureCount, conflicts, syncedAt];

  int get totalItems => successCount + failureCount;
  double get successRate => successCount / totalItems;
}

/// ❌ فشل المزامنة
class SyncFailure extends SyncResult {
  final String error;
  final StackTrace? stackTrace;
  final DateTime failedAt;

  const SyncFailure({
    required this.error,
    required this.failedAt,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [error, stackTrace, failedAt];
}

/// ⚔️ تعارض في البيانات
class SyncConflict extends Equatable {
  final String entityId;
  final String entityType; // 'beneficiary', 'visit', 'taxonomy', etc.
  final ConflictReason reason;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;

  const SyncConflict({
    required this.entityId,
    required this.entityType,
    required this.reason,
    required this.localData,
    required this.serverData,
    required this.localUpdatedAt,
    required this.serverUpdatedAt,
  });

  @override
  List<Object?> get props => [
        entityId,
        entityType,
        reason,
        localData,
        serverData,
        localUpdatedAt,
        serverUpdatedAt,
      ];

  /// هل السيرفر أحدث من النسخة المحلية؟
  bool get isServerNewer => serverUpdatedAt.isAfter(localUpdatedAt);

  /// هل النسخة المحلية أحدث؟
  bool get isLocalNewer => localUpdatedAt.isAfter(serverUpdatedAt);

  /// هل التعديلات في نفس الوقت؟
  bool get isSameTime => serverUpdatedAt.difference(localUpdatedAt).inSeconds.abs() < 5;
}

/// أسباب التعارضات
enum ConflictReason {
  /// تعديل من طرفين في نفس الوقت
  editEditConflict('edit_edit'),

  /// محاولة تعديل عنصر محذوف
  editDeleteConflict('edit_delete'),

  /// محاولة حذف عنصر معدل
  deleteEditConflict('delete_edit'),

  /// اختلاف في الإصدار
  versionMismatch('version_mismatch'),

  /// تعارض غير معروف
  unknown('unknown');

  const ConflictReason(this.code);
  final String code;
}

/// 🔧 قرار حل التعارض
enum ConflictResolution {
  /// اقبل النسخة من السيرفر
  acceptServer,

  /// احتفظ بالنسخة المحلية
  keepLocal,

  /// دمج البيانات (field-level merge)
  merge,

  /// اسأل المستخدم
  askUser,

  /// تخطى هذا التعارض
  skip,
}

/// 📊 ملخص المزامنة
class SyncSummary extends Equatable {
  final String entityType;
  final int totalPulled; // عدد العناصر المسحوبة من السيرفر
  final int totalPushed; // عدد العناصر المرفوعة للسيرفر
  final int conflicts; // عدد التعارضات
  final int errors; // عدد الأخطاء
  final Duration duration; // مدة المزامنة
  final DateTime startedAt;
  final DateTime? completedAt;

  const SyncSummary({
    required this.entityType,
    required this.totalPulled,
    required this.totalPushed,
    required this.conflicts,
    required this.errors,
    required this.duration,
    required this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        entityType,
        totalPulled,
        totalPushed,
        conflicts,
        errors,
        duration,
        startedAt,
        completedAt,
      ];

  bool get isComplete => completedAt != null;
  bool get hasConflicts => conflicts > 0;
  bool get hasErrors => errors > 0;
  bool get isFullySuccessful => !hasConflicts && !hasErrors;
}
