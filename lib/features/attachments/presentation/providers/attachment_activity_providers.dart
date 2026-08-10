import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart';
import 'package:benaa_offline_app/features/attachments/domain/usecases/add_attachment_with_activity.dart';
import 'package:benaa_offline_app/features/attachments/domain/usecases/delete_attachment_with_activity.dart';

/// Provider: AddAttachmentWithActivity UseCase
final addAttachmentWithActivityProvider = Provider<AddAttachmentWithActivity>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);

  return AddAttachmentWithActivity(
    database: database,
    logActivity: logActivity,
  );
});

/// Provider: DeleteAttachmentWithActivity UseCase
final deleteAttachmentWithActivityProvider =
    Provider<DeleteAttachmentWithActivity>((ref) {
  final database = ref.watch(databaseProvider);
  final logActivity = ref.watch(logActivityUseCaseProvider);

  return DeleteAttachmentWithActivity(
    database: database,
    logActivity: logActivity,
  );
});
