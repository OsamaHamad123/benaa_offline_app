import 'package:benaa_offline_app/features/associations/data/datasources/associations_remote_sync_datasource.dart';
import 'package:benaa_offline_app/features/associations/data/mappers/associations_sync_mapper.dart';
import 'package:benaa_offline_app/features/associations/data/models/associations_sync_dto.dart';
import 'package:benaa_offline_app/features/associations/domain/constants/associations_sync_keys.dart';
import 'package:logger/logger.dart';

import '../../../../data/db/drift_database.dart';
import '../entities/sync_flow_contract.dart';

class SyncAssociationsModuleUseCase {
  static const int _maxPaginationPages = 200;
  final AppDatabase _database;
  final AssociationsRemoteSyncDataSource _remote;
  final Logger _logger;

  SyncAssociationsModuleUseCase({
    required AppDatabase database,
    required AssociationsRemoteSyncDataSource remote,
    Logger? logger,
  })  : _database = database,
        _remote = remote,
        _logger = logger ?? Logger();

  Future<SyncStageCounters> syncDown({int perPage = 100}) async {
    int synced = 0;
    int failed = 0;

    try {
      final sponsorsSince = await _database.syncMetadataDao.getLastSyncTime(AssociationsSyncKeys.sponsorsEntity);
      final employeesSince = await _database.syncMetadataDao.getLastSyncTime(AssociationsSyncKeys.employeesEntity);

      final localSponsorsCount = (await _database.associationsDao.getAllAssociations()).length;
      final localEmployeesCount = (await _database.associationsDao.getAllRepresentatives()).length;

      final sponsorsResult = await _syncSponsorsDown(
        updatedAfter: sponsorsSince,
        perPage: perPage,
      );
      _logger.i(
        'Associations syncDown sponsors stage => uploaded: ${sponsorsResult.uploaded}, failed: ${sponsorsResult.failed}, updatedAfter: ${sponsorsSince?.toIso8601String() ?? 'null'}',
      );
      synced += sponsorsResult.uploaded;
      failed += sponsorsResult.failed;

      final employeesResult = await _syncEmployeesDown(
        updatedAfter: employeesSince,
        perPage: perPage,
      );
      _logger.i(
        'Associations syncDown employees stage => uploaded: ${employeesResult.uploaded}, failed: ${employeesResult.failed}, updatedAfter: ${employeesSince?.toIso8601String() ?? 'null'}',
      );
      synced += employeesResult.uploaded;
      failed += employeesResult.failed;

      final needsSponsorsBootstrap = localSponsorsCount == 0 &&
          sponsorsResult.uploaded == 0 &&
          sponsorsResult.failed == 0 &&
          sponsorsSince != null;
      if (needsSponsorsBootstrap) {
        _logger.w(
          'Sponsors incremental returned 0 while local cache is empty. Retrying full sync without updated_after.',
        );
        final fullSponsors = await _syncSponsorsDown(
          updatedAfter: null,
          perPage: perPage,
        );
        synced += fullSponsors.uploaded;
        failed += fullSponsors.failed;
      }
      if (localSponsorsCount == 0 && sponsorsResult.uploaded == 0 && sponsorsResult.failed > 0) {
        _logger.w(
          'Skipping sponsors bootstrap full retry because incremental stage has failures (likely transient/rate-limit).',
        );
      }

      final needsEmployeesBootstrap = localEmployeesCount == 0 &&
          employeesResult.uploaded == 0 &&
          employeesResult.failed == 0 &&
          employeesSince != null;
      if (needsEmployeesBootstrap) {
        _logger.i(
          'Employees incremental returned 0 while local cache is empty. Running one full-check sync without updated_after.',
        );
        final fullEmployees = await _syncEmployeesDown(
          updatedAfter: null,
          perPage: perPage,
        );
        synced += fullEmployees.uploaded;
        failed += fullEmployees.failed;
        if (fullEmployees.uploaded == 0 && fullEmployees.failed == 0) {
          _logger.i('Employees full-check returned 0 rows; no employees currently available on server.');
        }
      }
      if (localEmployeesCount == 0 && employeesResult.uploaded == 0 && employeesResult.failed > 0) {
        _logger.w(
          'Skipping employees bootstrap full retry because incremental stage has failures (likely transient/rate-limit).',
        );
      }
    } catch (e) {
      _logger.w('Associations sync-down failed: $e');
      failed++;
    }

    return SyncStageCounters(uploaded: synced, failed: failed);
  }

  Future<SyncStageCounters> syncUp({
    int employeeBatchThreshold = 20,
  }) async {
    int uploaded = 0;
    int failed = 0;

    try {
      final pendingSponsors = await _database.associationsDao.getAssociationsNeedingSync();

      for (final sponsor in pendingSponsors) {
        try {
          final profile = await _database.associationsDao.getSponsorProfileByAssociationId(sponsor.id);

          final dto = SponsorDto(
            id: sponsor.serverId ?? 0,
            sponsorName: sponsor.name,
            sponsorShortName: sponsor.shortName,
            sponsorPhoneNumber: sponsor.phone,
            sponsorEmail: sponsor.email,
            sponsorAddress: profile?['sponsor_address']?.toString(),
            sponsorBankNameId: _asInt(profile?['sponsor_bank_name_id']),
            sponsorBankName: sponsor.bankName,
            sponsorAccountBankNumber: sponsor.accountNumber,
            sponsorBankSwiftCode: sponsor.swiftCode,
            sponsorCategoryId: _resolveSponsorCategoryId(profile),
            countryCode: profile?['country_code']?.toString(),
            countryName: profile?['country_name']?.toString(),
            updatedAt: sponsor.updatedAt,
            createdAt: sponsor.createdAt,
          );

          if (sponsor.serverId == null) {
            await _remote.createSponsor(dto);
          } else {
            await _remote.updateSponsor(
              sponsorId: sponsor.serverId!,
              sponsor: dto,
            );
          }

          await _database.associationsDao.updateSyncState(
            id: sponsor.id,
            syncState: 'synced',
            serverId: sponsor.serverId,
          );
          uploaded++;
        } catch (e) {
          _logger.w('Sponsor sync-up failed for ${sponsor.id}: $e');
          failed++;
        }
      }

      final pendingEmployees = await _database.associationsDao.getRepresentativesNeedingSync();

      final resolvedEmployees = <({Representative rep, int sponsorServerId})>[];
      for (final rep in pendingEmployees) {
        final sponsorServerId = await _resolveRepresentativeSponsorServerId(rep);
        if (sponsorServerId == null) {
          _logger.w('Representative ${rep.id} has no resolved sponsor_server_id; using fallback 0.');
        }
        resolvedEmployees.add((rep: rep, sponsorServerId: sponsorServerId ?? 0));
      }

      if (resolvedEmployees.length >= employeeBatchThreshold) {
        try {
          final batch = resolvedEmployees
              .map(
                (item) => AssociationEmployeeDto(
                  id: item.rep.serverId,
                  sponsorId: item.sponsorServerId,
                  employeeName: item.rep.name,
                ),
              )
              .toList(growable: false);

          await _remote.batchUpsertEmployees(batch);

          for (final item in resolvedEmployees) {
            final rep = item.rep;
            await _database.associationsDao.updateRepresentativeSyncState(
              id: rep.id,
              syncState: 'synced',
              serverId: rep.serverId,
            );
            uploaded++;
          }
        } catch (e) {
          _logger.w('Employees batch sync-up failed: $e');
          failed += resolvedEmployees.length;
        }
      } else {
        for (final item in resolvedEmployees) {
          final rep = item.rep;
          try {
            final dto = AssociationEmployeeDto(
              id: rep.serverId,
              sponsorId: item.sponsorServerId,
              employeeName: rep.name,
              updatedAt: rep.updatedAt,
              createdAt: rep.createdAt,
            );

            if (rep.serverId == null) {
              await _remote.createEmployee(dto);
            } else {
              await _remote.updateEmployee(
                employeeId: rep.serverId!,
                employee: dto,
              );
            }

            await _database.associationsDao.updateRepresentativeSyncState(
              id: rep.id,
              syncState: 'synced',
              serverId: rep.serverId,
            );
            uploaded++;
          } catch (e) {
            _logger.w('Employee sync-up failed for ${rep.id}: $e');
            failed++;
          }
        }
      }
    } catch (e) {
      _logger.w('Associations sync-up failed: $e');
      failed++;
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<SyncStageCounters> _syncSponsorsDown({
    required DateTime? updatedAfter,
    required int perPage,
  }) async {
    int synced = 0;
    int failed = 0;
    int page = 1;
    DateTime? lastSyncTimestamp;
    String? previousPageFingerprint;
    bool guardTriggered = false;

    while (true) {
      if (page > _maxPaginationPages) {
        _logger.w(
          'Sponsors down-sync pagination exceeded max pages ($_maxPaginationPages). Breaking to prevent endless loop.',
        );
        guardTriggered = true;
        break;
      }

      final response = await _remote.fetchSponsors(
        updatedAfter: updatedAfter,
        page: page,
        perPage: perPage,
      );
      _logger.i(
        'Sponsors page $page => rows: ${response.records.length}, hasMore: ${response.hasMore}, syncTimestamp: ${response.syncTimestamp?.toIso8601String() ?? 'null'}',
      );

      final currentFingerprint = _buildSponsorsPageFingerprint(response.records);
      if (response.hasMore && previousPageFingerprint != null && previousPageFingerprint == currentFingerprint) {
        _logger.w(
          'Sponsors down-sync detected repeated page payload at page $page. Breaking to prevent infinite pagination loop.',
        );
        guardTriggered = true;
        break;
      }

      for (final sponsor in response.records) {
        try {
          final existing = await _database.associationsDao.getAssociationByServerId(sponsor.id);
          final companion = AssociationsSyncMapper.sponsorDtoToAssociationCompanion(
            sponsor,
            existing: existing,
          );
          await _database.associationsDao.upsertAssociation(companion);
          await _database.associationsDao.upsertSponsorProfile(
            associationId: companion.id.value,
            sponsorAddress: sponsor.sponsorAddress,
            countryCode: sponsor.countryCode,
            countryName: sponsor.countryName,
            sponsorBankNameId: sponsor.sponsorBankNameId,
            associationTypeCode: sponsor.sponsorCategoryId?.toString(),
          );
          synced++;
        } catch (e) {
          failed++;
          _logger.w('Sponsor down-sync row failed ${sponsor.id}: $e');
        }
      }

      lastSyncTimestamp = response.syncTimestamp ?? lastSyncTimestamp;
      previousPageFingerprint = currentFingerprint;

      if (!response.hasMore) {
        break;
      }
      page++;
    }

    if (guardTriggered) {
      failed++;
    }

    final shouldPersistSyncSuccess = synced > 0 || lastSyncTimestamp != null;
    if (shouldPersistSyncSuccess) {
      await _database.syncMetadataDao.updateSyncSuccess(
        AssociationsSyncKeys.sponsorsEntity,
        totalSynced: synced,
        syncTime: lastSyncTimestamp ?? DateTime.now(),
      );
    } else {
      _logger.w(
        'Sponsors stage returned no rows and no sync timestamp; skipping sync success metadata update to avoid stale incremental lock.',
      );
      failed++;
    }

    if (failed > 0) {
      await _database.syncMetadataDao.updateSyncFailure(
        AssociationsSyncKeys.sponsorsEntity,
        error: 'failed_rows:$failed',
      );
    }

    return SyncStageCounters(uploaded: synced, failed: failed);
  }

  Future<SyncStageCounters> _syncEmployeesDown({
    required DateTime? updatedAfter,
    required int perPage,
  }) async {
    int synced = 0;
    int failed = 0;
    int page = 1;
    DateTime? lastSyncTimestamp;
    String? previousPageFingerprint;
    bool guardTriggered = false;

    while (true) {
      if (page > _maxPaginationPages) {
        _logger.w(
          'Employees down-sync pagination exceeded max pages ($_maxPaginationPages). Breaking to prevent endless loop.',
        );
        guardTriggered = true;
        break;
      }

      final response = await _remote.fetchEmployees(
        updatedAfter: updatedAfter,
        page: page,
        perPage: perPage,
      );
      _logger.i(
        'Employees page $page => rows: ${response.records.length}, hasMore: ${response.hasMore}, syncTimestamp: ${response.syncTimestamp?.toIso8601String() ?? 'null'}',
      );

      final currentFingerprint = _buildEmployeesPageFingerprint(response.records);
      if (response.hasMore && previousPageFingerprint != null && previousPageFingerprint == currentFingerprint) {
        _logger.w(
          'Employees down-sync detected repeated page payload at page $page. Breaking to prevent infinite pagination loop.',
        );
        guardTriggered = true;
        break;
      }

      for (final employee in response.records) {
        try {
          final serverId = employee.id;
          final existing = serverId == null
              ? null
              : await _database.associationsDao.getRepresentativeByServerId(
                  serverId,
                );

          final companion = AssociationsSyncMapper.employeeDtoToRepresentativeCompanion(
            employee,
            existing: existing,
          );

          await _database.associationsDao.upsertRepresentative(companion);
          if (employee.sponsorId > 0) {
            await _database.associationsDao.upsertEmployeeProfile(
              representativeId: companion.id.value,
              sponsorServerId: employee.sponsorId,
            );

            await _database.associationsDao.linkRepresentativeToAssociationByServerId(
              sponsorServerId: employee.sponsorId,
              representativeId: companion.id.value,
            );
          }
          synced++;
        } catch (e) {
          failed++;
          _logger.w('Employee down-sync row failed ${employee.id}: $e');
        }
      }

      lastSyncTimestamp = response.syncTimestamp ?? lastSyncTimestamp;
      previousPageFingerprint = currentFingerprint;

      if (!response.hasMore) {
        break;
      }
      page++;
    }

    if (guardTriggered) {
      failed++;
    }

    final shouldPersistSyncSuccess = synced > 0 || lastSyncTimestamp != null;
    if (shouldPersistSyncSuccess) {
      await _database.syncMetadataDao.updateSyncSuccess(
        AssociationsSyncKeys.employeesEntity,
        totalSynced: synced,
        syncTime: lastSyncTimestamp ?? DateTime.now(),
      );
    } else {
      _logger.w(
        'Employees stage returned no rows and no sync timestamp; skipping sync success metadata update to avoid stale incremental lock.',
      );
      failed++;
    }

    if (failed > 0) {
      await _database.syncMetadataDao.updateSyncFailure(
        AssociationsSyncKeys.employeesEntity,
        error: 'failed_rows:$failed',
      );
    }

    return SyncStageCounters(uploaded: synced, failed: failed);
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  int? _resolveSponsorCategoryId(Map<String, dynamic>? profile) {
    if (profile == null) return null;

    final direct = _asInt(profile['sponsor_category_id'] ?? profile['association_type_id']);
    if (direct != null) return direct;

    final fromCode = profile['association_type_code']?.toString();
    if (fromCode == null) return null;
    return int.tryParse(fromCode.trim());
  }

  String _buildSponsorsPageFingerprint(List<SponsorDto> rows) {
    if (rows.isEmpty) return 'empty';
    final first = rows.first.id;
    final last = rows.last.id;
    return '${rows.length}:$first:$last';
  }

  String _buildEmployeesPageFingerprint(List<AssociationEmployeeDto> rows) {
    if (rows.isEmpty) return 'empty';
    final first = rows.first.id ?? -1;
    final last = rows.last.id ?? -1;
    return '${rows.length}:$first:$last';
  }

  Future<int?> _resolveRepresentativeSponsorServerId(Representative representative) async {
    final fromProfile = await _database.associationsDao.getEmployeeSponsorServerId(representative.id);
    if (fromProfile != null && fromProfile > 0) {
      return fromProfile;
    }

    final linkedAssociation = await _database.associationsDao.getAssociationByRepresentativeId(representative.id);
    final serverId = linkedAssociation?.serverId;
    if (serverId != null && serverId > 0) {
      return serverId;
    }

    final allAssociations = await _database.associationsDao.getAllAssociations();
    final withServerId = allAssociations
        .where((association) => association.serverId != null && association.serverId! > 0)
        .toList(growable: false);
    if (withServerId.length == 1) {
      return withServerId.first.serverId;
    }

    return null;
  }
}
