import 'package:json_annotation/json_annotation.dart';

part 'taxonomy.g.dart';

@JsonSerializable()
class Taxonomy {
  final String id;
  final String group; // 'governorate', 'category', 'gender'
  final String code;
  final String label;
  final bool isActive;
  final DateTime updatedAt;

  const Taxonomy({
    required this.id,
    required this.group,
    required this.code,
    required this.label,
    this.isActive = true,
    required this.updatedAt,
  });

  factory Taxonomy.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyFromJson(json);

  Map<String, dynamic> toJson() => _$TaxonomyToJson(this);

  Taxonomy copyWith({
    String? id,
    String? group,
    String? code,
    String? label,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Taxonomy(
      id: id ?? this.id,
      group: group ?? this.group,
      code: code ?? this.code,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => '$group: $label ($code)';
}

// Predefined taxonomy groups
class TaxonomyGroup {
  static const String governorate = 'governorate';
  static const String category = 'category';
  static const String gender = 'gender';
  static const String associationType = 'association_type';
}
