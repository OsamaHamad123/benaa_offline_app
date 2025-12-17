import 'package:equatable/equatable.dart';

/// 👤 Representative Entity - Domain Layer
///
/// كيان مندوب الجمعية (بسيط جداً - اسم فقط)
class Representative extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Representative({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Is valid
  bool get isValid => name.trim().isNotEmpty;

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];

  Representative copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Representative(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Representative($name)';
}
