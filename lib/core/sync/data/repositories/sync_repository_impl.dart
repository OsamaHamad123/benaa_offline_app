import 'dart:convert';

import '../../domain/entities/sync_result.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../models/sync_models.dart' as api_sync;
import '../datasources/local_sync_datasource.dart';
import '../datasources/remote_sync_datasource.dart';
import '../../../error_handling/error_logger.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../data/models/taxonomy_dto.dart';
import '../../../../features/taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';

/// 🔄 Sync Repository Implementation
///
/// يربط Remote و Local DataSources ويطبق منطق المزامنة
class SyncRepositoryImpl implements ISyncRepository {
  final RemoteSyncDataSource _remote;
  final LocalSyncDataSource _local;

  const SyncRepositoryImpl({
    required RemoteSyncDataSource remote,
    required LocalSyncDataSource local,
  })  : _remote = remote,
        _local = local;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 DELTA SYNC Implementation
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncResult> deltaSync(
    String entityType, {
    DateTime? lastSyncTime,
    ConflictResolution conflictResolution = ConflictResolution.acceptServer,
  }) async {
    try {
      // Get last sync time if not provided
      final since = lastSyncTime ?? await _local.getLastSyncTime(entityType);

      // 1. Pull changes from server
      final pullResult = await pullChanges(entityType, since: since);

      if (pullResult is SyncFailure) {
        return pullResult;
      }

      // 2. Push local changes
      final pushResult = await pushChanges(entityType);

      // 3. Create summary
      if (pullResult is SyncSuccess && pushResult is SyncSuccess) {
        final totalSynced = pullResult.itemsSynced + pushResult.itemsSynced;

        await _local.updateSyncSuccess(
          entityType: entityType,
          itemsSynced: totalSynced,
        );

        return SyncSuccess(
          itemsSynced: totalSynced,
          syncedAt: DateTime.now(),
          message: 'تمت المزامنة بنجاح: $totalSynced عنصر',
        );
      }

      // Handle partial success
      final conflicts = <SyncConflict>[];
      if (pullResult is SyncPartial) {
        conflicts.addAll(pullResult.conflicts);
      }
      if (pushResult is SyncPartial) {
        conflicts.addAll(pushResult.conflicts);
      }

      final successCount = (pullResult is SyncSuccess ? pullResult.itemsSynced : 0) +
          (pushResult is SyncSuccess ? pushResult.itemsSynced : 0);

      return SyncPartial(
        successCount: successCount,
        failureCount: conflicts.length,
        conflicts: conflicts,
        syncedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        e,
        stackTrace,
        context: {
          'operation': 'smart_sync',
          'entity_type': entityType,
        },
        hint: 'Smart sync failed for entity type',
      );

      await _local.updateSyncFailure(
        entityType: entityType,
        error: e.toString(),
      );

      return SyncFailure(
        error: 'فشلت المزامنة الذكية: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📥 PULL CHANGES Implementation
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncResult> pullChanges(
    String entityType, {
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      switch (entityType) {
        case 'taxonomies':
          return await _pullTaxonomies(since: since);

        case 'beneficiaries':
          return await _pullBeneficiaries(since: since, limit: limit);

        case 'visits':
          return await _pullVisits(since: since, limit: limit);

        default:
          return SyncFailure(
            error: 'نوع غير مدعوم: $entityType',
            failedAt: DateTime.now(),
          );
      }
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل جلب التغييرات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// Pull Taxonomies from server
  Future<SyncResult> _pullTaxonomies({DateTime? since}) async {
    try {
      final response = await _remote.pullTaxonomies(since: since);
      final grouped = <String, List<TaxonomyDTO>>{};

      for (final item in response.data) {
        grouped.putIfAbsent(item.group, () => []).add(item);
      }

      final missingGroups = missingRequiredTaxonomyGroupsFromValues(grouped.keys);
      for (final missingGroup in missingGroups) {
        try {
          final fallback = await _remote.pullTaxonomies(group: missingGroup.value);
          if (fallback.data.isEmpty) {
            continue;
          }

          for (final item in fallback.data) {
            grouped.putIfAbsent(item.group, () => []).add(item);
          }
        } catch (_) {
          continue;
        }
      }

      int totalSynced = 0;
      for (final entry in grouped.entries) {
        final uniqueItems = _dedupeTaxonomiesById(entry.value);
        await _local.saveTaxonomiesForGroup(
          entry.key,
          uniqueItems,
        );
        totalSynced += uniqueItems.length;
      }

      return SyncSuccess(
        itemsSynced: totalSynced,
        syncedAt: DateTime.now(),
        message: 'تمت مزامنة التصنيفات: $totalSynced عنصر',
      );
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل جلب التصنيفات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  List<TaxonomyDTO> _dedupeTaxonomiesById(List<TaxonomyDTO> items) {
    if (items.length <= 1) {
      return items;
    }

    final map = <String, TaxonomyDTO>{};
    for (final item in items) {
      final key = item.id.trim().isEmpty ? '${item.group}:${item.code}' : item.id;
      final previous = map[key];
      if (previous == null || item.updatedAt.isAfter(previous.updatedAt)) {
        map[key] = item;
      }
    }

    return map.values.toList(growable: false);
  }

  /// Pull Beneficiaries from server
  Future<SyncResult> _pullBeneficiaries({
    required int limit,
    DateTime? since,
  }) async {
    try {
      final response = await _remote.pullBeneficiaryChanges(
        since: since,
        limit: limit,
      );

      int syncedCount = 0;

      // Save each beneficiary
      for (final beneficiary in response.data) {
        await _local.saveBeneficiary(beneficiary.toJson());
        syncedCount++;
      }

      return SyncSuccess(
        itemsSynced: syncedCount,
        syncedAt: DateTime.now(),
        message: 'تمت مزامنة المستفيدين: $syncedCount عنصر',
      );
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل جلب المستفيدين: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// Pull Visits from server
  Future<SyncResult> _pullVisits({required int limit, DateTime? since}) async {
    try {
      final response = await _remote.pullVisitChanges(
        since: since,
        limit: limit,
      );

      // TODO: Implement visit saving logic
      return SyncSuccess(
        itemsSynced: response.data.length,
        syncedAt: DateTime.now(),
        message: 'تمت مزامنة الزيارات: ${response.data.length} عنصر',
      );
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل جلب الزيارات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📤 PUSH CHANGES Implementation
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncResult> pushChanges(String entityType) async {
    try {
      // Get pending changes from local queue
      final pendingChanges = await _local.getPendingChanges(entityType);

      if (pendingChanges.isEmpty) {
        return SyncSuccess(
          itemsSynced: 0,
          syncedAt: DateTime.now(),
          message: 'لا توجد تغييرات معلقة',
        );
      }

      final syncChanges = _toSyncChanges(pendingChanges);

      late final api_sync.SyncResponse response;
      switch (entityType) {
        case 'beneficiaries':
        case 'beneficiary':
          response = await _remote.pushBeneficiaryChanges(syncChanges);
          break;
        case 'visits':
        case 'visit':
          response = await _remote.pushVisitChanges(syncChanges);
          break;
        default:
          return SyncFailure(
            error: 'نوع غير مدعوم للرفع: $entityType',
            failedAt: DateTime.now(),
          );
      }

      final pendingById = <String, SyncQueueItem>{
        for (final item in pendingChanges) item.id: item,
      };

      final successfulIds = response.success.map((s) => s.clientId).toSet();
      if (successfulIds.isEmpty && !response.hasConflicts && !response.hasErrors) {
        successfulIds.addAll(pendingById.keys);
      }

      for (final id in successfulIds) {
        if (pendingById.containsKey(id)) {
          await _local.removeFromSyncQueue(id);
        }
      }

      final syncedCount = successfulIds.length;
      final int failedCount = (pendingChanges.length - syncedCount).toInt();

      if (failedCount <= 0 && !response.hasConflicts && !response.hasErrors) {
        return SyncSuccess(
          itemsSynced: syncedCount,
          syncedAt: DateTime.now(),
          message: 'تم رفع $syncedCount تغيير',
        );
      }

      final conflicts = response.conflicts
          .map(
            (c) => SyncConflict(
              entityId: c.clientId,
              entityType: entityType,
              reason: ConflictReason.versionMismatch,
              localData: _extractPayloadMap(pendingById[c.clientId]?.payload),
              serverData: c.serverVersion.data,
              localUpdatedAt: DateTime.now(),
              serverUpdatedAt: c.serverVersion.updatedAt,
            ),
          )
          .toList();

      return SyncPartial(
        successCount: syncedCount,
        failureCount: failedCount,
        conflicts: conflicts,
        syncedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل رفع التغييرات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  List<api_sync.SyncChange> _toSyncChanges(List<SyncQueueItem> pendingChanges) {
    return pendingChanges
        .map(
          (item) => api_sync.SyncChange(
            clientId: item.id,
            action: item.operation,
            data: _extractPayloadMap(item.payload),
            timestamp: item.createdAt,
          ),
        )
        .toList();
  }

  Map<String, dynamic> _extractPayloadMap(String? payload) {
    if (payload == null || payload.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'payload': decoded};
    } catch (_) {
      return <String, dynamic>{'raw': payload};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⚔️ RESOLVE CONFLICTS Implementation
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncResult> resolveConflicts(
    List<SyncConflict> conflicts,
    ConflictResolution resolution,
  ) async {
    try {
      int resolvedCount = 0;

      for (final conflict in conflicts) {
        switch (resolution) {
          case ConflictResolution.acceptServer:
            // Override local with server data
            await _local.saveBeneficiary(conflict.serverData);
            resolvedCount++;
            break;

          case ConflictResolution.keepLocal:
            // Keep local data, add to sync queue to push
            await _local.addToSyncQueue(
              entityType: conflict.entityType,
              entityId: conflict.entityId,
              operation: 'update',
              data: conflict.localData,
            );
            resolvedCount++;
            break;

          case ConflictResolution.merge:
            // Manual merge - not implemented
            break;

          case ConflictResolution.askUser:
            // Skip - requires user interaction
            break;

          case ConflictResolution.skip:
            // Do nothing
            break;
        }
      }

      return SyncSuccess(
        itemsSynced: resolvedCount,
        syncedAt: DateTime.now(),
        message: 'تم حل $resolvedCount تعارض',
      );
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل حل التعارضات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 FULL SYNC Implementation
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncResult> fullSync(String entityType) async {
    try {
      // Full sync = pull all + push all
      final pullResult = await pullChanges(entityType);

      if (pullResult is SyncFailure) {
        return pullResult;
      }

      final pushResult = await pushChanges(entityType);

      final totalSynced = (pullResult is SyncSuccess ? pullResult.itemsSynced : 0) +
          (pushResult is SyncSuccess ? pushResult.itemsSynced : 0);

      await _local.updateSyncSuccess(
        entityType: entityType,
        itemsSynced: totalSynced,
      );

      return SyncSuccess(
        itemsSynced: totalSynced,
        syncedAt: DateTime.now(),
        message: 'اكتملت المزامنة الكاملة: $totalSynced عنصر',
      );
    } catch (e, stackTrace) {
      await _local.updateSyncFailure(
        entityType: entityType,
        error: e.toString(),
      );

      return SyncFailure(
        error: 'فشلت المزامنة الكاملة: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 METADATA Operations
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Future<SyncSummary?> getSyncSummary(String entityType) async {
    try {
      final metadata = await _local.getAllSyncMetadata();
      final entityMetadata = metadata.firstWhere(
        (m) => m.entity == entityType,
        orElse: () => throw Exception('No metadata found'),
      );

      return SyncSummary(
        entityType: entityType,
        totalPulled: entityMetadata.totalSynced,
        totalPushed: 0, // TODO: Track separately
        conflicts: 0,
        errors: entityMetadata.failedSyncs,
        duration: const Duration(),
        startedAt: entityMetadata.lastSyncTime,
        completedAt: entityMetadata.lastSyncTime,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String entityType) async {
    return await _local.getLastSyncTime(entityType);
  }

  @override
  Future<int> getPendingChangesCount(String entityType) async {
    return await _local.getPendingChangesCount(entityType);
  }

  @override
  Future<void> clearSyncQueue([String? entityType]) async {
    await _local.clearSyncQueue(entityType);
  }
}
