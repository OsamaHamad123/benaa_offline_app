import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:drift/drift.dart' as drift;

part 'taxonomy_dto.g.dart';

/// 📦 Taxonomy DTO - Data Transfer Object
///
/// يستخدم للتواصل مع API ويتحول لـ Drift entity
@JsonSerializable()
class TaxonomyDTO {
  final String id;
  final String group;
  final String code;
  final String label;

  @JsonKey(name: 'parent_id')
  final String? parentId;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const TaxonomyDTO({
    required this.id,
    required this.group,
    required this.code,
    required this.label,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
  });

  /// From JSON (من API)
  factory TaxonomyDTO.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyDTOFromJson(json);

  /// To JSON (للـ API)
  Map<String, dynamic> toJson() => _$TaxonomyDTOToJson(this);

  /// Convert to Drift Companion (للحفظ في Database)
  TaxonomiesCompanion toCompanion() {
    return TaxonomiesCompanion.insert(
      id: id,
      group: group,
      code: code,
      label: label,
      updatedAt: updatedAt,
      parentId: drift.Value(parentId),
      sortOrder: drift.Value(sortOrder),
      isActive: drift.Value(isActive),
    );
  }

  /// From Drift Entity (من Database)
  factory TaxonomyDTO.fromEntity(Taxonomy entity) {
    return TaxonomyDTO(
      id: entity.id,
      group: entity.group,
      code: entity.code,
      label: entity.label,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  String toString() => 'TaxonomyDTO($group.$code: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxonomyDTO &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
