import 'package:riverpod/riverpod.dart';
import '../../data/datasources/visit_local_datasource.dart';
import '../../data/repositories/visit_repository_impl.dart';
import '../../domain/repositories/visit_repository.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/create_visit_with_activity.dart';
import '../../domain/usecases/get_beneficiary_visits.dart';
import '../state/visit_notifier.dart';
import '../state/visit_state.dart';
import '../../../../data/db/drift_database.dart';
import '../../../dashboard/presentation/providers/activity_providers.dart';
import '../../../dashboard/domain/usecases/log_activity.dart';

/// Database Provider (shared from existing app)
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'Database provider must be overridden at app startup',
  );
});

/// Visit Local DataSource Provider
final visitLocalDataSourceProvider = Provider<VisitLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return VisitLocalDataSource(database);
});

/// Visit Repository Provider
final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final localDataSource = ref.watch(visitLocalDataSourceProvider);
  return VisitRepositoryImpl(localDataSource);
});

/// Create Visit Use Case Provider
final createVisitProvider = Provider<CreateVisit>((ref) {
  final repository = ref.watch(visitRepositoryProvider);
  return CreateVisit(repository);
});

/// Log Activity Use Case Provider
final logActivityProvider = Provider<LogActivity>((ref) {
  return ref.watch(logActivityUseCaseProvider);
});

/// Create Visit With Activity Use Case Provider
/// 🔥 هذا هو الـ Provider الأساسي - يجمع الزيارة + تسجيل النشاط
final createVisitWithActivityProvider = Provider<CreateVisitWithActivity>((
  ref,
) {
  final visitRepository = ref.watch(visitRepositoryProvider);
  final logActivity = ref.watch(logActivityProvider);
  return CreateVisitWithActivity(
    visitRepository: visitRepository,
    logActivity: logActivity,
  );
});

/// Get Beneficiary Visits Use Case Provider
final getBeneficiaryVisitsProvider = Provider<GetBeneficiaryVisits>((ref) {
  final repository = ref.watch(visitRepositoryProvider);
  return GetBeneficiaryVisits(repository);
});

/// Visit Notifier Provider
final visitNotifierProvider = StateNotifierProvider<VisitNotifier, VisitState>((
  ref,
) {
  final createVisit = ref.watch(createVisitProvider);
  final getBeneficiaryVisits = ref.watch(getBeneficiaryVisitsProvider);

  return VisitNotifier(
    createVisit: createVisit,
    getBeneficiaryVisits: getBeneficiaryVisits,
  );
});
