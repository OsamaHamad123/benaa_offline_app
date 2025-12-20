import 'search_filter.dart' show AdvancedSearchFilter;

/// 💾 Saved Filter Entity
///
/// يمثل فلتر محفوظ مع اسم وتاريخ

class SavedFilter {
  final String id;
  final String name;
  final AdvancedSearchFilter filter;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const SavedFilter({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
    this.lastUsedAt,
  });

  SavedFilter copyWith({
    String? id,
    String? name,
    AdvancedSearchFilter? filter,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return SavedFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filter': filter.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    return SavedFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      filter:
          AdvancedSearchFilter.fromJson(json['filter'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }
}
