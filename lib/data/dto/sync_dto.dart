import 'package:json_annotation/json_annotation.dart';

part 'sync_dto.g.dart';

// ===========================
// 📤 SYNC REQUEST DTOs
// ===========================

/// 📤 طلب المزامنة للسيرفر
@JsonSerializable()
class SyncRequestDto {
  /// آخر تاريخ مزامنة (لتحديد البيانات المحدثة فقط)
  final DateTime? lastSyncTime;

  /// البيانات المعلقة للرفع
  final List<PendingChangeDto> pendingChanges;

  /// معلومات الجهاز
  final DeviceInfoDto deviceInfo;

  /// معرّف المستخدم
  final String userId;

  SyncRequestDto({
    this.lastSyncTime,
    required this.pendingChanges,
    required this.deviceInfo,
    required this.userId,
  });

  factory SyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRequestDtoToJson(this);
}

/// 📝 تغيير معلق
@JsonSerializable()
class PendingChangeDto {
  /// نوع الكيان (material, stock_movement, beneficiary, etc.)
  final String entityType;

  /// معرّف الكيان
  final String entityId;

  /// العملية (create, update, delete)
  final String operation;

  /// البيانات (JSON object)
  final Map<String, dynamic> data;

  /// وقت إجراء التغيير
  final DateTime timestamp;

  /// الأولوية (1-10، حيث 10 هي الأعلى)
  final int priority;

  /// عدد محاولات الإرسال
  final int retryCount;

  PendingChangeDto({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.priority = 5,
    this.retryCount = 0,
  });

  factory PendingChangeDto.fromJson(Map<String, dynamic> json) =>
      _$PendingChangeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PendingChangeDtoToJson(this);
}

/// 📱 معلومات الجهاز
@JsonSerializable()
class DeviceInfoDto {
  /// معرّف الجهاز الفريد
  final String deviceId;

  /// إصدار التطبيق
  final String appVersion;

  /// المنصة (android, ios, web)
  final String platform;

  /// إصدار نظام التشغيل
  final String? osVersion;

  /// نموذج الجهاز
  final String? deviceModel;

  DeviceInfoDto({
    required this.deviceId,
    required this.appVersion,
    required this.platform,
    this.osVersion,
    this.deviceModel,
  });

  factory DeviceInfoDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoDtoToJson(this);
}

// ===========================
// 📥 SYNC RESPONSE DTOs
// ===========================

/// 📥 استجابة المزامنة من السيرفر
@JsonSerializable()
class SyncResponseDto {
  /// حالة المزامنة
  final bool success;

  /// رسالة (في حالة النجاح أو الفشل)
  final String? message;

  /// البيانات المحدثة من السيرفر
  final List<ServerEntityDto> updatedData;

  /// IDs الكيانات التي تم حذفها على السيرفر
  final List<String> deletedIds;

  /// تاريخ المزامنة من السيرفر (لاستخدامه في المزامنة القادمة)
  final DateTime serverTimestamp;

  /// التغييرات التي فشلت
  final List<FailedChangeDto>? failedChanges;

  /// إحصائيات المزامنة
  final SyncStatsDto? stats;

  SyncResponseDto({
    required this.success,
    this.message,
    required this.updatedData,
    required this.deletedIds,
    required this.serverTimestamp,
    this.failedChanges,
    this.stats,
  });

  factory SyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseDtoToJson(this);
}

/// 🗄️ كيان من السيرفر
@JsonSerializable()
class ServerEntityDto {
  /// نوع الكيان
  final String entityType;

  /// معرّف الكيان
  final String id;

  /// البيانات
  final Map<String, dynamic> data;

  /// تاريخ آخر تحديث
  final DateTime updatedAt;

  /// تاريخ الإنشاء
  final DateTime? createdAt;

  /// معرّف المستخدم الذي أجرى التحديث
  final String? updatedBy;

  ServerEntityDto({
    required this.entityType,
    required this.id,
    required this.data,
    required this.updatedAt,
    this.createdAt,
    this.updatedBy,
  });

  factory ServerEntityDto.fromJson(Map<String, dynamic> json) =>
      _$ServerEntityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerEntityDtoToJson(this);
}

/// ❌ تغيير فشل
@JsonSerializable()
class FailedChangeDto {
  /// معرّف الكيان الذي فشل
  final String entityId;

  /// نوع الكيان
  final String entityType;

  /// سبب الفشل
  final String reason;

  /// كود الخطأ
  final String? errorCode;

  /// هل يمكن إعادة المحاولة؟
  final bool retryable;

  /// البيانات المتضاربة (في حالة Conflict)
  final Map<String, dynamic>? conflictData;

  FailedChangeDto({
    required this.entityId,
    required this.entityType,
    required this.reason,
    this.errorCode,
    this.retryable = true,
    this.conflictData,
  });

  factory FailedChangeDto.fromJson(Map<String, dynamic> json) =>
      _$FailedChangeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FailedChangeDtoToJson(this);
}

/// 📊 إحصائيات المزامنة
@JsonSerializable()
class SyncStatsDto {
  /// عدد السجلات المستلمة
  final int receivedCount;

  /// عدد السجلات المرسلة
  final int sentCount;

  /// عدد السجلات المحذوفة
  final int deletedCount;

  /// عدد السجلات الفاشلة
  final int failedCount;

  /// مدة المزامنة (بالثواني)
  final double? durationSeconds;

  SyncStatsDto({
    required this.receivedCount,
    required this.sentCount,
    required this.deletedCount,
    required this.failedCount,
    this.durationSeconds,
  });

  factory SyncStatsDto.fromJson(Map<String, dynamic> json) =>
      _$SyncStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncStatsDtoToJson(this);

  /// 📊 عدد السجلات الكلي
  int get totalCount => receivedCount + sentCount + deletedCount;

  /// ✅ هل نجحت المزامنة؟
  bool get isSuccessful => failedCount == 0;
}

// ===========================
// 🔐 AUTH DTOs
// ===========================

/// 🔑 طلب تسجيل الدخول
@JsonSerializable()
class LoginRequestDto {
  final String email;
  final String password;
  final String? deviceId;

  LoginRequestDto({required this.email, required this.password, this.deviceId});

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

/// ✅ استجابة تسجيل الدخول
@JsonSerializable()
class LoginResponseDto {
  final bool success;
  final String? token;
  final String? refreshToken;
  final UserDto? user;
  final String? message;
  final String? errorCode;

  LoginResponseDto({
    required this.success,
    this.token,
    this.refreshToken,
    this.user,
    this.message,
    this.errorCode,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}

/// 👤 بيانات المستخدم
@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final Map<String, dynamic>? permissions;

  UserDto({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.permissions,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
