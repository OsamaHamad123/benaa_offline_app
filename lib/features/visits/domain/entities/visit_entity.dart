import 'package:equatable/equatable.dart';

/// Visit Entity - كيان الزيارة
class VisitEntity extends Equatable {
  final String id;
  final String beneficiaryId;
  final DateTime visitDate;
  final String staffName;
  final String notes;
  final bool isSubmitted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverId;
  final DateTime? lastSyncedAt;

  const VisitEntity({
    required this.id,
    required this.beneficiaryId,
    required this.visitDate,
    required this.staffName,
    required this.notes,
    required this.isSubmitted,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.serverId,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [
        id,
        beneficiaryId,
        visitDate,
        staffName,
        notes,
        isSubmitted,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt,
      ];

  VisitEntity copyWith({
    String? id,
    String? beneficiaryId,
    DateTime? visitDate,
    String? staffName,
    String? notes,
    bool? isSubmitted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    String? serverId,
    DateTime? lastSyncedAt,
  }) {
    return VisitEntity(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitDate: visitDate ?? this.visitDate,
      staffName: staffName ?? this.staffName,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
