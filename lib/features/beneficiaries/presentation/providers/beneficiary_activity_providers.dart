import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/usecases/create_beneficiary_with_activity.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/usecases/update_beneficiary_with_activity.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/usecases/delete_beneficiary_with_activity.dart';

/// Provider: CreateBeneficiaryWithActivity UseCase
final createBeneficiaryWithActivityProvider =
    Provider<CreateBeneficiaryWithActivity>((ref) {
      final database = ref.watch(databaseProvider);
      final logActivity = ref.watch(logActivityUseCaseProvider);

      return CreateBeneficiaryWithActivity(
        database: database,
        logActivity: logActivity,
      );
    });

/// Provider: UpdateBeneficiaryWithActivity UseCase
final updateBeneficiaryWithActivityProvider =
    Provider<UpdateBeneficiaryWithActivity>((ref) {
      final database = ref.watch(databaseProvider);
      final logActivity = ref.watch(logActivityUseCaseProvider);

      return UpdateBeneficiaryWithActivity(
        database: database,
        logActivity: logActivity,
      );
    });

/// Provider: DeleteBeneficiaryWithActivity UseCase
final deleteBeneficiaryWithActivityProvider =
    Provider<DeleteBeneficiaryWithActivity>((ref) {
      final database = ref.watch(databaseProvider);
      final logActivity = ref.watch(logActivityUseCaseProvider);

      return DeleteBeneficiaryWithActivity(
        database: database,
        logActivity: logActivity,
      );
    });
