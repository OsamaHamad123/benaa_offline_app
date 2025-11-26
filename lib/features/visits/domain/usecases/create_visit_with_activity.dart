import '../entities/visit_entity.dart';
import '../repositories/visit_repository.dart';
import '../../../dashboard/domain/usecases/log_activity.dart';

/// Use Case: Create Visit with Activity Logging
/// يُنشئ زيارة جديدة ويُسجل النشاط تلقائياً
class CreateVisitWithActivity {
  final VisitRepository visitRepository;
  final LogActivity logActivity;

  const CreateVisitWithActivity({
    required this.visitRepository,
    required this.logActivity,
  });

  Future<void> call({
    required VisitEntity visit,
    required String beneficiaryName,
  }) async {
    // 1. Create the visit first
    await visitRepository.createVisit(visit);

    // 2. Log the activity
    await logActivity(
      type: 'visit',
      description: 'تم تسجيل زيارة جديدة',
      beneficiaryId: visit.beneficiaryId,
      beneficiaryName: beneficiaryName,
      metadata: {
        'visitId': visit.id,
        'visitDate': visit.visitDate.toIso8601String(),
        'staffName': visit.staffName,
        'hasNotes': visit.notes.isNotEmpty,
      },
    );
  }
}
