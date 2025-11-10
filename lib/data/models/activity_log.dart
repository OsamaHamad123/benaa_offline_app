/// Activity Log Model - لتسجيل نشاطات المستخدم
class ActivityLog {
  final String id;
  final String type; // 'add', 'edit', 'delete', 'sync', 'visit'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? beneficiaryId;
  final String? beneficiaryName;
  final Map<String, dynamic>? metadata;

  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.beneficiaryId,
    this.beneficiaryName,
    this.metadata,
  });

  // Factory constructor من البيانات
  factory ActivityLog.fromBeneficiaryAdd(String id, String name) {
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'add',
      title: 'إضافة مستفيد جديد',
      subtitle: name,
      timestamp: DateTime.now(),
      beneficiaryId: id,
      beneficiaryName: name,
    );
  }

  factory ActivityLog.fromBeneficiaryEdit(String id, String name) {
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'edit',
      title: 'تعديل بيانات مستفيد',
      subtitle: name,
      timestamp: DateTime.now(),
      beneficiaryId: id,
      beneficiaryName: name,
    );
  }

  factory ActivityLog.fromBeneficiaryDelete(String id, String name) {
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'delete',
      title: 'حذف مستفيد',
      subtitle: name,
      timestamp: DateTime.now(),
      beneficiaryId: id,
      beneficiaryName: name,
    );
  }

  factory ActivityLog.fromSync(int count) {
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'sync',
      title: 'مزامنة البيانات',
      subtitle: '$count مستفيد تم مزامنته',
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLog.fromVisit(String beneficiaryId, String beneficiaryName) {
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'visit',
      title: 'إضافة زيارة',
      subtitle: beneficiaryName,
      timestamp: DateTime.now(),
      beneficiaryId: beneficiaryId,
      beneficiaryName: beneficiaryName,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      subtitle: json['subtitle'],
      timestamp: DateTime.parse(json['timestamp']),
      beneficiaryId: json['beneficiaryId'],
      beneficiaryName: json['beneficiaryName'],
      metadata: json['metadata'],
    );
  }

  // Get relative time string
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    }
  }
}
