import 'package:riverpod/riverpod.dart';
import '../../data/datasources/activity_local_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/usecases/log_activity.dart';
import '../../../../data/db/drift_database.dart';

/// Database Provider (shared from existing app)
/// يجب أن يتم override في main.dart
final dashboardDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'Database provider must be overridden at app startup',
  );
});

/// Activity Local DataSource Provider
final activityLocalDataSourceProvider = Provider<ActivityLocalDataSource>((
  ref,
) {
  final database = ref.watch(dashboardDatabaseProvider);
  return ActivityLocalDataSourceImpl(database);
});

/// Activity Repository Provider
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final localDataSource = ref.watch(activityLocalDataSourceProvider);
  return ActivityRepositoryImpl(localDataSource);
});

/// Log Activity Use Case Provider
final logActivityUseCaseProvider = Provider<LogActivity>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return LogActivity(repository);
});
