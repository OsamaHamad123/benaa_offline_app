import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/sync/sync_manager.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart';
import 'package:benaa_offline_app/features/sync/domain/usecases/sync_with_activity.dart';

/// Provider: SyncManager
final syncManagerProvider = Provider<SyncManager>((ref) {
  final database = ref.watch(databaseProvider);
  // ApiClient يمكن أن يكون null
  return SyncManager(database, apiClient: null);
});

/// Provider: SyncWithActivity UseCase
final syncWithActivityProvider = Provider<SyncWithActivity>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);

  return SyncWithActivity(syncManager: syncManager, logActivity: logActivity);
});
