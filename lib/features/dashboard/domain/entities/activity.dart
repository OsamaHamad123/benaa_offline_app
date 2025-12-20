import 'package:equatable/equatable.dart';

/// Activity Entity for recent activities log
class Activity extends Equatable {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? beneficiaryId;
  final String? beneficiaryName;
  final Map<String, dynamic>? metadata;

  const Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.beneficiaryId,
    this.beneficiaryName,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        timestamp,
        beneficiaryId,
        beneficiaryName,
        metadata,
      ];
}
