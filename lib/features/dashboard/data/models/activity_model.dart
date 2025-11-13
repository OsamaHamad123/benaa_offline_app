import '../../domain/entities/activity.dart';

/// Activity Model - extends Entity with JSON serialization
class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.type,
    required super.description,
    required super.timestamp,
    super.beneficiaryId,
    super.beneficiaryName,
    super.metadata,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      beneficiaryId: json['beneficiaryId'] as String?,
      beneficiaryName: json['beneficiaryName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      'metadata': metadata,
    };
  }
}
