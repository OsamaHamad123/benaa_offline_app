import 'dart:developer' as developer;

import '../../../../core/sync/module_sync_stats.dart';
import '../../../../core/utils/log_sanitizer.dart';
import '../../../associations/data/repositories/association_firestore_repository.dart';
import '../../../sponsorships/data/repositories/sponsorship_repository.dart';
import '../../../visits/data/repositories/visit_firestore_repository.dart';

class ModuleFailureInfo {
  const ModuleFailureInfo({
    required this.moduleName,
    required this.code,
    required this.message,
  });

  final String moduleName;
  final String code;
  final String message;
}

class FirestoreModulesSyncSummary {
  final Map<String, ModuleSyncStats> operations;
  final List<ModuleFailureInfo> failedModules;

  const FirestoreModulesSyncSummary({
    required this.operations,
    this.failedModules = const <ModuleFailureInfo>[],
  });

  ModuleSyncStats get aggregate {
    var total = const ModuleSyncStats();
    for (final item in operations.values) {
      total += item;
    }
    return total;
  }
}

class SyncFirestoreModulesUseCase {
  SyncFirestoreModulesUseCase({
    required AssociationFirestoreRepository associationRepository,
    required SponsorshipRepository sponsorshipRepository,
    required VisitFirestoreRepository visitRepository,
  })  : _associationRepository = associationRepository,
        _sponsorshipRepository = sponsorshipRepository,
        _visitRepository = visitRepository;

  final AssociationFirestoreRepository _associationRepository;
  final SponsorshipRepository _sponsorshipRepository;
  final VisitFirestoreRepository _visitRepository;

  Future<FirestoreModulesSyncSummary> uploadAll() async {
    final map = <String, ModuleSyncStats>{};
    final failures = <ModuleFailureInfo>[];

    developer.log('[ModulesUpload] started', name: 'ModulesUpload');

    Future<void> runUploadStep(
      String opKey,
      String label,
      Future<ModuleSyncStats> Function() action,
    ) async {
      developer.log('[$label] started', name: 'ModulesUpload');
      try {
        final stats = await action();
        map[opKey] = stats;
        developer.log(
          '[$label] completed uploaded=${stats.uploaded} failed=${stats.failed}',
          name: 'ModulesUpload',
        );
        if (stats.failed > 0) {
          failures.add(ModuleFailureInfo(
            moduleName: label,
            code: 'partial_failure',
            message: 'uploaded=${stats.uploaded} failed=${stats.failed}',
          ));
        }
      } catch (e) {
        const fallback = ModuleSyncStats(total: 1, failed: 1);
        map[opKey] = fallback;
        final sanitized = LogSanitizer.sanitizeErrorMessage(e.toString());
        failures.add(ModuleFailureInfo(
          moduleName: label,
          code: 'exception',
          message: sanitized,
        ));
        developer.log(
          '[ModulesUpload] failed module=$label code=exception error=$sanitized',
          name: 'ModulesUpload',
        );
      }
    }

    await runUploadStep('association_upload', 'AssociationsUpload', _associationRepository.uploadPendingAssociations);
    await runUploadStep(
        'association_contacts_upload', 'AssociationContactsUpload', _associationRepository.uploadPendingContacts);
    await runUploadStep('sponsorship_upload', 'SponsorshipsUpload', _sponsorshipRepository.uploadPendingCore);
    await runUploadStep('visit_upload', 'VisitsUpload', _visitRepository.uploadPendingVisits);
    await runUploadStep('followup_upload', 'FollowupsUpload', _visitRepository.uploadPendingFollowups);

    final summary = FirestoreModulesSyncSummary(operations: map, failedModules: failures);
    developer.log(
      '[ModulesUpload] completed success=${failures.isEmpty} failedModules=${failures.map((e) => e.moduleName).toList()}',
      name: 'ModulesUpload',
    );
    return summary;
  }

  Future<FirestoreModulesSyncSummary> downloadAll() async {
    final map = <String, ModuleSyncStats>{};
    final failures = <ModuleFailureInfo>[];

    developer.log('[ModulesDownload] started', name: 'ModulesDownload');

    Future<void> runStep(
      String opKey,
      String label,
      Future<ModuleSyncStats> Function() action,
    ) async {
      developer.log('[$label] started', name: 'ModulesDownload');
      try {
        final stats = await action();
        map[opKey] = stats;
        developer.log(
          '[$label] completed downloaded=${stats.downloaded} updated=${stats.downloaded} failed=${stats.failed}',
          name: 'ModulesDownload',
        );
      } catch (e) {
        const fallback = ModuleSyncStats(total: 1, failed: 1);
        map[opKey] = fallback;
        final sanitized = LogSanitizer.sanitizeErrorMessage(e.toString());
        failures.add(
          ModuleFailureInfo(
            moduleName: label,
            code: 'exception',
            message: sanitized,
          ),
        );
        developer.log(
          '[ModulesDownload] failed module=$label code=exception error=$sanitized',
          name: 'ModulesDownload',
        );
      }
    }

    await runStep('association_download', 'AssociationsDownload', _associationRepository.downloadAssociations);
    await runStep(
      'association_contacts_download',
      'AssociationContactsDownload',
      _associationRepository.downloadAssociationContacts,
    );
    await runStep('sponsorship_download', 'SponsorshipsDownload', _sponsorshipRepository.downloadCore);
    await runStep('visit_download', 'VisitsDownload', _visitRepository.downloadVisits);
    await runStep('followup_download', 'FollowupsDownload', _visitRepository.downloadFollowups);

    final summary = FirestoreModulesSyncSummary(operations: map, failedModules: failures);
    developer.log(
      '[ModulesDownload] completed success=${summary.aggregate.failed == 0} failedModules=${failures.map((e) => e.moduleName).toList()}',
      name: 'ModulesDownload',
    );
    return summary;
  }
}
