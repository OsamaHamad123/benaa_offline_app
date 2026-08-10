import 'package:flutter_riverpod/flutter_riverpod.dart';
// نستخدم syncManagerProvider الأساسي من core/sync/sync_manager.dart
// (المُهيّأ بـ ApiClient حقيقي، مع ref.onDispose يوقف مؤقّته) بدل تعريف
// مزوّد ثانٍ بعميل null كان ينشئ مؤقّت مزامنة مكرّراً يفسد حالة الطابور.
import 'package:benaa_offline_app/core/sync/sync_manager.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart';
import 'package:benaa_offline_app/features/sync/domain/usecases/sync_with_activity.dart';

/// Provider: SyncWithActivity UseCase
final syncWithActivityProvider = Provider<SyncWithActivity>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);

  return SyncWithActivity(syncManager: syncManager, logActivity: logActivity);
});
