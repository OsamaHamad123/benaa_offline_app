import 'package:json_annotation/json_annotation.dart';

part 'visit.g.dart';

@JsonSerializable()
class Visit {
  final String id;
  final String beneficiaryId;
  final DateTime visitDate;
  final String staffName;
  final String notes;
  final bool isSubmitted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;

  const Visit({
    required this.id,
    required this.beneficiaryId,
    required this.visitDate,
    required this.staffName,
    this.notes = '',
    this.isSubmitted = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncState = 'pending',
  });

  factory Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);

  Map<String, dynamic> toJson() => _$VisitToJson(this);

  Visit copyWith({
    String? id,
    String? beneficiaryId,
    DateTime? visitDate,
    String? staffName,
    String? notes,
    bool? isSubmitted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
  }) {
    return Visit(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitDate: visitDate ?? this.visitDate,
      staffName: staffName ?? this.staffName,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  bool get isSynced => syncState == 'synced';
  bool get isPending => syncState == 'pending';
  bool get hasFailed => syncState == 'failed';
}
