import 'package:equatable/equatable.dart';
import 'taxonomy_group.dart';

/// 🏷️ Taxonomy Entity - كيان التصنيف
///
/// يمثل تصنيف واحد في النظام (مثل: محافظة، فئة، حالة اجتماعية)
/// هذا الـ Entity نظيف بدون أي dependencies خارجية
class Taxonomy extends Equatable {
  /// المعرف الفريد
  final String id;

  /// المجموعة التي ينتمي لها (governorate, category, etc.)
  final TaxonomyGroup group;

  /// الكود المختصر (BGD, orphan, married, etc.)
  final String code;

  /// التسمية بالعربية
  final String label;

  /// التسمية بالإنجليزية (اختياري)
  final String? labelEn;

  /// المعرف الأب (للتصنيفات الهرمية)
  final String? parentId;

  /// ترتيب العرض
  final int sortOrder;

  /// هل التصنيف نشط
  final bool isActive;

  /// وصف إضافي
  final String? description;

  /// لون التصنيف (للعرض)
  final String? color;

  /// أيقونة التصنيف
  final String? icon;

  /// بيانات إضافية (metadata)
  final Map<String, dynamic>? metadata;

  /// تاريخ الإنشاء
  final DateTime createdAt;

  /// تاريخ آخر تحديث
  final DateTime updatedAt;

  /// تاريخ الحذف (soft delete)
  final DateTime? deletedAt;

  const Taxonomy({
    required this.id,
    required this.group,
    required this.code,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
    this.labelEn,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.description,
    this.color,
    this.icon,
    this.metadata,
    this.deletedAt,
  });

  /// هل التصنيف محذوف (soft delete)
  bool get isDeleted => deletedAt != null;

  /// هل لديه أب (تصنيف فرعي)
  bool get hasParent => parentId != null && parentId!.isNotEmpty;

  /// الحصول على المعرف الكامل (group_code)
  String get fullId => '${group.prefix}_$code';

  /// نسخة معدلة
  Taxonomy copyWith({
    String? id,
    TaxonomyGroup? group,
    String? code,
    String? label,
    String? labelEn,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    String? description,
    String? color,
    String? icon,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Taxonomy(
      id: id ?? this.id,
      group: group ?? this.group,
      code: code ?? this.code,
      label: label ?? this.label,
      labelEn: labelEn ?? this.labelEn,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        group,
        code,
        label,
        labelEn,
        parentId,
        sortOrder,
        isActive,
        description,
        color,
        icon,
        metadata,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  @override
  String toString() => 'Taxonomy(${group.value}.$code: $label)';
}

/// 📊 Taxonomy Statistics - إحصائيات التصنيفات
class TaxonomyStatistics extends Equatable {
  /// إجمالي عدد التصنيفات
  final int totalCount;

  /// عدد التصنيفات النشطة
  final int activeCount;

  /// عدد التصنيفات غير النشطة
  final int inactiveCount;

  /// عدد التصنيفات لكل مجموعة
  final Map<TaxonomyGroup, int> countByGroup;

  /// آخر وقت مزامنة
  final DateTime? lastSyncTime;

  const TaxonomyStatistics({
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.countByGroup,
    this.lastSyncTime,
  });

  /// إنشاء إحصائيات فارغة
  factory TaxonomyStatistics.empty() {
    return const TaxonomyStatistics(
      totalCount: 0,
      activeCount: 0,
      inactiveCount: 0,
      countByGroup: {},
    );
  }

  @override
  List<Object?> get props => [
        totalCount,
        activeCount,
        inactiveCount,
        countByGroup,
        lastSyncTime,
      ];
}

/// 🔄 Sync Result - نتيجة المزامنة
class TaxonomySyncResult extends Equatable {
  /// عدد التصنيفات المضافة
  final int addedCount;

  /// عدد التصنيفات المحدثة
  final int updatedCount;

  /// عدد التصنيفات المحذوفة
  final int deletedCount;

  /// وقت المزامنة
  final DateTime syncTime;

  /// هل نجحت المزامنة
  final bool success;

  /// رسالة (في حالة الخطأ)
  final String? message;

  const TaxonomySyncResult({
    required this.addedCount,
    required this.updatedCount,
    required this.deletedCount,
    required this.syncTime,
    required this.success,
    this.message,
  });

  /// إجمالي التغييرات
  int get totalChanges => addedCount + updatedCount + deletedCount;

  /// هل هناك تغييرات
  bool get hasChanges => totalChanges > 0;

  /// إنشاء نتيجة ناجحة
  factory TaxonomySyncResult.success({
    int addedCount = 0,
    int updatedCount = 0,
    int deletedCount = 0,
  }) {
    return TaxonomySyncResult(
      addedCount: addedCount,
      updatedCount: updatedCount,
      deletedCount: deletedCount,
      syncTime: DateTime.now(),
      success: true,
    );
  }

  /// إنشاء نتيجة فاشلة
  factory TaxonomySyncResult.failure(String message) {
    return TaxonomySyncResult(
      addedCount: 0,
      updatedCount: 0,
      deletedCount: 0,
      syncTime: DateTime.now(),
      success: false,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        addedCount,
        updatedCount,
        deletedCount,
        syncTime,
        success,
        message,
      ];
}
