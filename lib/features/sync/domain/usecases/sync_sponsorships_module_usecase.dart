import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import '../../../../data/db/drift_database.dart';
import '../../../kafalat/data/datasources/sponsorships_remote_sync_datasource.dart';
import '../../../kafalat/data/models/sponsorships_sync_dto.dart';
import '../../../kafalat/domain/constants/sponsorships_sync_keys.dart';
import '../entities/sync_flow_contract.dart';

class SyncSponsorshipsModuleUseCase {
  static const int _maxPaginationPages = 200;

  final AppDatabase _database;
  final SponsorshipsRemoteSyncDataSource _remote;
  final Logger _logger;

  SyncSponsorshipsModuleUseCase({
    required AppDatabase database,
    required SponsorshipsRemoteSyncDataSource remote,
    Logger? logger,
  })  : _database = database,
        _remote = remote,
        _logger = logger ?? Logger();

  Future<SyncStageCounters> syncDown({int perPage = 100}) async {
    final localCount = await (_database.select(_database.sponsorships)).get().then((rows) => rows.length);
    final updatedAfter = await _database.syncMetadataDao.getLastSyncTime(SponsorshipsSyncKeys.sponsorshipsEntity);

    var pass = await _syncDownPass(
      updatedAfter: updatedAfter,
      perPage: perPage,
    );

    if (localCount == 0 && pass.synced == 0 && pass.failed == 0 && updatedAfter != null) {
      _logger.i(
        'Sponsorships incremental returned 0 while local cache is empty. Running one full-check sync without updated_after.',
      );
      final fullPass = await _syncDownPass(
        updatedAfter: null,
        perPage: perPage,
      );
      pass = (
        synced: pass.synced + fullPass.synced,
        failed: pass.failed + fullPass.failed,
        lastSyncTimestamp: fullPass.lastSyncTimestamp ?? pass.lastSyncTimestamp,
      );
      if (fullPass.synced == 0 && fullPass.failed == 0) {
        _logger.i('Sponsorships full-check returned 0 rows; no sponsorships currently available on server.');
      }
    }

    if (pass.synced > 0 || (pass.failed == 0 && pass.lastSyncTimestamp != null)) {
      await _database.syncMetadataDao.updateSyncSuccess(
        SponsorshipsSyncKeys.sponsorshipsEntity,
        totalSynced: pass.synced,
        syncTime: pass.lastSyncTimestamp ?? DateTime.now(),
      );
    }

    if (pass.failed > 0) {
      await _database.syncMetadataDao.updateSyncFailure(
        SponsorshipsSyncKeys.sponsorshipsEntity,
        error: 'failed_rows:${pass.failed}',
      );
    }

    return SyncStageCounters(uploaded: pass.synced, failed: pass.failed);
  }

  Future<({int synced, int failed, DateTime? lastSyncTimestamp})> _syncDownPass({
    required DateTime? updatedAfter,
    required int perPage,
  }) async {
    int synced = 0;
    int failed = 0;
    int page = 1;
    DateTime? lastSyncTimestamp;

    while (true) {
      if (page > _maxPaginationPages) {
        _logger.w('Sponsorships pagination exceeded max pages ($_maxPaginationPages). Breaking.');
        failed++;
        break;
      }

      SponsorshipsListResponseDto response;
      try {
        response = await _remote.fetchSponsorships(
          updatedAfter: updatedAfter,
          page: page,
          perPage: perPage,
        );
      } catch (e) {
        _logger.w('Sponsorships down-sync page fetch failed: $e');
        failed++;
        break;
      }

      if (response.records.isEmpty) {
        lastSyncTimestamp = response.syncTimestamp ?? lastSyncTimestamp;
        if (!response.hasMore) break;
        page++;
        continue;
      }

      await _database.transaction(() async {
        for (final dto in response.records) {
          try {
            final association = await _resolveAssociation(dto);
            final beneficiary = await _resolveBeneficiary(dto);

            if (association == null || beneficiary == null) {
              failed++;
              _logger.w(
                'Sponsorship skipped due to unresolved mapping (id=${dto.id}, sponsor_id=${dto.sponsorId}, identity=${dto.identityNumber}, relation=${dto.relationIdNumber}, internal=${dto.internalFileNumber}).',
              );
              continue;
            }

            final status = _mapStatus(dto.sponsorshipStatusId, dto.sponsorshipStatusName);
            final type = _mapType(dto.sponsorshipTypeId, dto.sponsorshipTypeName);
            final guaranteeType = _mapGuaranteeType(dto.guaranteeTypeId, dto.guaranteeTypeName);

            final existing = dto.id == null ? null : await _database.sponsorshipsDao.getSponsorshipByServerId(dto.id!);

            if (existing != null) {
              await _database.update(_database.sponsorships).replace(
                    existing.copyWith(
                      beneficiaryId: beneficiary.id,
                      associationId: association.id,
                      sponsorName: drift.Value(dto.sponsorName),
                      internalFileNo: drift.Value(dto.internalFileNumber),
                      externalFileNo: drift.Value(dto.externalFileNumber),
                      guardianName: drift.Value(dto.guardianName),
                      guardianIdNumber: drift.Value(int.tryParse(dto.guardianIdentityNumber ?? '')),
                      durationMonths: drift.Value(dto.sponsorshipDurationMonths),
                      startDate: drift.Value(dto.sponsorshipStartDate),
                      endDate: drift.Value(dto.sponsorshipEndDate),
                      status: status,
                      sponsorshipType: type,
                      guaranteeType: drift.Value(guaranteeType),
                      notes: drift.Value(dto.notes),
                      syncState: 'synced',
                      serverId: drift.Value(dto.id),
                      lastSyncedAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(dto.updatedAt ?? DateTime.now()),
                    ),
                  );
            } else {
              await _database.into(_database.sponsorships).insert(
                    SponsorshipsCompanion.insert(
                      beneficiaryId: beneficiary.id,
                      associationId: association.id,
                      sponsorName: drift.Value(dto.sponsorName),
                      internalFileNo: drift.Value(dto.internalFileNumber),
                      externalFileNo: drift.Value(dto.externalFileNumber),
                      guardianName: drift.Value(dto.guardianName),
                      guardianIdNumber: drift.Value(int.tryParse(dto.guardianIdentityNumber ?? '')),
                      durationMonths: drift.Value(dto.sponsorshipDurationMonths),
                      startDate: drift.Value(dto.sponsorshipStartDate),
                      endDate: drift.Value(dto.sponsorshipEndDate),
                      status: drift.Value(status),
                      sponsorshipType: drift.Value(type),
                      guaranteeType: drift.Value(guaranteeType),
                      notes: drift.Value(dto.notes),
                      createdAt: drift.Value(dto.createdAt ?? DateTime.now()),
                      updatedAt: drift.Value(dto.updatedAt ?? DateTime.now()),
                      syncState: const drift.Value('synced'),
                      serverId: drift.Value(dto.id),
                      lastSyncedAt: drift.Value(DateTime.now()),
                    ),
                  );
            }

            synced++;
          } catch (e) {
            failed++;
            _logger.w('Sponsorship down-sync row failed: $e');
          }
        }
      });

      lastSyncTimestamp = response.syncTimestamp ?? lastSyncTimestamp;

      if (!response.hasMore) break;
      page++;
    }

    return (synced: synced, failed: failed, lastSyncTimestamp: lastSyncTimestamp);
  }

  Future<SyncStageCounters> syncUp() async {
    int uploaded = 0;
    int failed = 0;

    final pendingRows = await _database.sponsorshipsDao.getSponsorshipsNeedingSync();

    for (final row in pendingRows) {
      try {
        final association = await _database.associationsDao.getAssociationById(row.associationId);
        final beneficiary = await _database.beneficiariesDao.getBeneficiaryById(row.beneficiaryId);

        final sponsorServerId = association?.serverId;
        final identityNumber = beneficiary?.idNumber;
        final orphanName = beneficiary?.fullName.trim();

        if (sponsorServerId == null || identityNumber == null || orphanName == null || orphanName.isEmpty) {
          failed++;
          continue;
        }

        final dto = SponsorshipDto(
          id: row.serverId,
          sponsorId: sponsorServerId,
          sponsorIds: [sponsorServerId],
          sponsorName: row.sponsorName,
          internalFileNumber: row.internalFileNo,
          externalFileNumber: row.externalFileNo,
          identityNumber: identityNumber.toString(),
          orphanName: orphanName,
          sponsoredBirthDate: beneficiary?.birthDate,
          guardianName: row.guardianName,
          guardianIdentityNumber: row.guardianIdNumber?.toString(),
          sponsorshipDurationMonths: row.durationMonths,
          sponsorshipStartDate: row.startDate,
          sponsorshipEndDate: row.endDate,
          sponsorshipTypeId: _toTypeId(row.sponsorshipType),
          guaranteeTypeId: _toGuaranteeTypeId(row.guaranteeType),
          guaranteeTypeName: row.guaranteeType,
          sponsorshipStatusId: _toStatusId(row.status),
          notes: row.notes,
        );

        Map<String, dynamic>? response;
        if (row.serverId == null) {
          response = await _remote.createSponsorship(
            dto,
            sponsorId: sponsorServerId,
            identityNumber: identityNumber.toString(),
            orphanName: orphanName,
          );
        } else {
          response = await _remote.updateSponsorship(
            sponsorshipId: row.serverId!,
            dto: dto,
            sponsorId: sponsorServerId,
            identityNumber: identityNumber.toString(),
            orphanName: orphanName,
          );
        }

        final responseData = _asMap(response?['data']) ?? _asMap(response?['record']) ?? response;
        final serverId = _asInt(responseData?['id']) ?? row.serverId;

        await _database.sponsorshipsDao.updateSponsorshipSyncState(
          fileNo: row.fileNo,
          syncState: 'synced',
          serverId: serverId,
        );

        uploaded++;
      } catch (e) {
        failed++;
        _logger.w('Sponsorship sync-up failed for fileNo ${row.fileNo}: $e');
      }
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<Association?> _resolveAssociation(SponsorshipDto dto) async {
    if (dto.sponsorId != null) {
      final byServer = await _database.associationsDao.getAssociationByServerId(dto.sponsorId!);
      if (byServer != null) return byServer;
    }

    final name = dto.sponsorName?.trim();
    if (name != null && name.isNotEmpty) {
      final results = await _database.associationsDao.searchAssociations(name);
      if (results.isNotEmpty) return results.first;
    }

    return null;
  }

  Future<Beneficiary?> _resolveBeneficiary(SponsorshipDto dto) async {
    final identity = dto.identityNumber?.trim();
    if (identity != null && identity.isNotEmpty) {
      final identityInt = int.tryParse(identity);
      if (identityInt != null) {
        final byIdentity = await (_database.select(_database.beneficiaries)
              ..where((b) => b.idNumber.equals(identityInt)))
            .getSingleOrNull();
        if (byIdentity != null) return byIdentity;
      }
    }

    final relationId = dto.relationIdNumber?.trim();
    if (relationId != null && relationId.isNotEmpty) {
      final byRelation = await (_database.select(_database.beneficiaries)
            ..where((b) => b.fileIdNumber.equals(relationId) | b.originalFileIdFromExcel.equals(relationId)))
          .getSingleOrNull();
      if (byRelation != null) return byRelation;
    }

    final internal = dto.internalFileNumber?.trim();
    if (internal != null && internal.isNotEmpty) {
      final byInternal = await (_database.select(_database.beneficiaries)
            ..where((b) => b.fileIdNumber.equals(internal) | b.originalFileIdFromExcel.equals(internal)))
          .getSingleOrNull();
      if (byInternal != null) return byInternal;
    }

    return null;
  }

  String _mapStatus(int? statusId, String? statusName) {
    final name = (statusName ?? '').toLowerCase();
    if (statusId == 3 || name.contains('منتهي') || name.contains('expired')) return 'ended';
    if (statusId == 1 || name.contains('مراجعة') || name.contains('pending')) return 'paused';
    return 'active';
  }

  String _mapType(int? typeId, String? typeName) {
    final name = (typeName ?? '').toLowerCase();
    if (typeId == 2 || name.contains('جزئية') || name.contains('partial')) return 'other';
    if (typeId == 3 || name.contains('مرة') || name.contains('one')) return 'one_time';
    return 'monthly';
  }

  int _toStatusId(String status) {
    switch (status) {
      case 'ended':
        return 3;
      case 'paused':
        return 1;
      case 'active':
      default:
        return 2;
    }
  }

  int _toTypeId(String type) {
    switch (type) {
      case 'one_time':
        return 3;
      case 'other':
        return 2;
      case 'monthly':
      default:
        return 1;
    }
  }

  String? _mapGuaranteeType(int? typeId, String? typeName) {
    if (typeName != null && typeName.trim().isNotEmpty) {
      return typeName.trim();
    }

    if (typeId != null) {
      switch (typeId) {
        case 3:
          return 'one_time';
        case 2:
          return 'other';
        case 1:
          return 'monthly';
      }
    }

    return null;
  }

  int? _toGuaranteeTypeId(String? type) {
    final normalized = type?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    switch (normalized) {
      case 'one_time':
        return 3;
      case 'other':
        return 2;
      case 'monthly':
        return 1;
      default:
        return null;
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }
}
