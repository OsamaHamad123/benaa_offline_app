import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Log Activity Use Case
/// يسجل نشاط جديد في قاعدة البيانات
class LogActivity {
  final ActivityRepository repository;

  LogActivity(this.repository);

  Future<void> call({
    required String type,
    required String description,
    String? beneficiaryId,
    String? beneficiaryName,
    Map<String, dynamic>? metadata,
  }) async {
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      timestamp: DateTime.now(),
      beneficiaryId: beneficiaryId,
      beneficiaryName: beneficiaryName,
      metadata: metadata,
    );

    await repository.logActivity(activity);
  }
}
