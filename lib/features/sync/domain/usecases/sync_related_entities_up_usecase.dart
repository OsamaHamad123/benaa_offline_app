import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/api_config.dart';
import '../../../../data/db/drift_database.dart';
import '../entities/sync_flow_contract.dart';

class SyncRelatedEntitiesUpUseCase {
  final AppDatabase _database;
  final Dio _dio;
  final String Function(String endpoint) _normalizeApiEndpoint;
  final Logger _logger;

  static const int _deceasedFatherType = 1;
  static const int _deceasedMotherType = 2;

  SyncRelatedEntitiesUpUseCase({
    required AppDatabase database,
    required Dio dio,
    required String Function(String endpoint) normalizeApiEndpoint,
    Logger? logger,
  })  : _database = database,
        _dio = dio,
        _normalizeApiEndpoint = normalizeApiEndpoint,
        _logger = logger ?? Logger();

  Future<SyncStageCounters> syncAttachments(String deviceId) async {
    int uploaded = 0;
    int failed = 0;

    try {
      final syncStateDistribution = await _database.attachmentsDao.getSyncStateDistribution();
      _logger.i('Attachments sync-state distribution: $syncStateDistribution');

      final pendingAttachments = await _database.attachmentsDao.getPendingAttachments();
      _logger.i('Found ${pendingAttachments.length} attachments to upload');

      if (pendingAttachments.isEmpty) {
        _logger.w(
          'No pending attachments for upload. Check attachments.sync_state and ensure new attachments are saved as pending.',
        );
      }

      for (final attachment in pendingAttachments) {
        try {
          _logger.i(
            'Uploading attachment id=${attachment.id}, beneficiaryId=${attachment.beneficiaryId}, '
            'personId=${attachment.personId ?? '-'}, documentType=${attachment.documentType ?? '-'}',
          );

          final file = File(attachment.filePath);
          if (!file.existsSync()) {
            _logger.w('File not found: ${attachment.filePath}');
            failed++;
            continue;
          }

          final personIdentityNumber = await _resolvePersonIdentityNumberForAttachment(attachment);
          if (personIdentityNumber == null || personIdentityNumber.isEmpty) {
            final beneficiaryDebug = await _buildAttachmentBeneficiaryDebug(attachment);
            _logger.w(
              'Missing person_identity_number for attachment ${attachment.id}. '
              'Beneficiary debug => $beneficiaryDebug',
            );
            failed++;
            continue;
          }

          final resolvedFileType = _resolveAttachmentFileTypeForUpload(attachment, file);

          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(file.path, filename: attachment.fileName),
            'person_identity_number': personIdentityNumber,
            if (resolvedFileType != null) 'file_type': resolvedFileType,
            'entity_type': 'beneficiary',
            'entity_id': attachment.beneficiaryId,
            'device_id': deviceId,
            if (attachment.documentType != null && attachment.documentType!.trim().isNotEmpty)
              'document_type': attachment.documentType,
            if (attachment.notes != null && attachment.notes!.trim().isNotEmpty) 'notes': attachment.notes,
          });

          final response = await _dio.post(
            _normalizeApiEndpoint(ApiConfig.attachmentUploadEndpoint),
            data: formData,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            String? serverUrl;
            if (responseData is Map) {
              serverUrl = responseData['url']?.toString();
            }

            await _database.attachmentsDao.updateAttachmentSyncState(
              attachment.id,
              'synced',
              serverUrl: serverUrl,
            );
            uploaded++;
          } else {
            failed++;
            _logger.w('Failed to upload attachment ${attachment.id}: ${response.statusCode}');
          }
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;
          _logger.w(
            'Error uploading attachment ${attachment.id}: '
            'status=$statusCode, message=${e.message}, response=$responseData',
          );
          failed++;
        } catch (e) {
          _logger.w('Error uploading attachment ${attachment.id}: $e');
          failed++;
        }
      }
    } catch (e) {
      _logger.e('Attachments sync up failed', error: e);
      failed++;
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<SyncStageCounters> syncFamilyMembers(String deviceId) async {
    int uploaded = 0;
    int failed = 0;

    try {
      final pendingMembers = await _database.familyMembersDao.getUnsyncedMembers();
      _logger.i('Found ${pendingMembers.length} family members to upload');

      for (final member in pendingMembers) {
        try {
          final registrationId = await _resolveRegistrationIdForBeneficiary(member.beneficiaryId);
          if (registrationId == null) {
            failed++;
            continue;
          }

          final payload = {
            'registration_id': registrationId,
            'first_name': member.firstName,
            if (member.secondName != null && member.secondName!.isNotEmpty) 'second_name': member.secondName,
            if (member.thirdName != null && member.thirdName!.isNotEmpty) 'third_name': member.thirdName,
            'last_name': member.familyName,
            'person_id': member.orphanNationalId.toString(),
            'person_birth_date': member.birthDate.toIso8601String().split('T').first,
            'person_gender': member.gender,
            'person_health_status': member.healthStatus,
            if (member.sponsorshipStatus != null) 'sponsorship_status': member.sponsorshipStatus,
            if (member.sponsorshipType != null) 'person_type_of_guarantee': member.sponsorshipType,
            if (member.guaranteeType != null) 'guarantee_type': member.guaranteeType,
            if (member.guaranteeType != null) 'guarantee_type_id': member.guaranteeType,
            if (_valueOrNull(member.sponsorName) != null) 'sponsor_name': _valueOrNull(member.sponsorName),
            if (member.sponsorshipStartDate != null)
              'sponsorship_start_date': member.sponsorshipStartDate!.toIso8601String().split('T').first,
            if (_valueOrNull(member.notes) != null) 'notes': _valueOrNull(member.notes),
            if (_valueOrNull(member.attachments) != null) 'attachments': _valueOrNull(member.attachments),
            if (member.age != null) 'age': member.age,
            'device_id': deviceId,
          };

          Response response;
          if (member.serverId != null) {
            response = await _dio.put(
              _normalizeApiEndpoint('/api/mobile/database/re-people/${member.serverId}'),
              data: payload,
            );
          } else {
            response = await _dio.post(
              _normalizeApiEndpoint('/api/mobile/database/re-people'),
              data: payload,
            );
          }

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            int? resolvedServerId;
            if (responseData is Map<String, dynamic>) {
              final dataNode = responseData['data'];
              if (dataNode is Map<String, dynamic>) {
                final item = dataNode['item'] ?? dataNode['record'] ?? dataNode['member'];
                if (item is Map<String, dynamic>) {
                  resolvedServerId = _asInt(item['id']);
                }
              }
              resolvedServerId ??= _asInt(responseData['id']);
            }

            if (resolvedServerId != null) {
              await _database.familyMembersDao.markAsSynced(member.id, resolvedServerId);
            } else {
              await _database.familyMembersDao.markAsSyncedWithoutServerId(member.id);
            }
            uploaded++;
          } else {
            failed++;
          }
        } on DioException catch (e) {
          _logger.w(
            'Error uploading family member ${member.id}: '
            'status=${e.response?.statusCode}, '
            'message=${e.message}, response=${e.response?.data}',
          );
          failed++;
        } catch (e) {
          _logger.w('Error uploading family member ${member.id}: $e');
          failed++;
        }
      }
    } catch (e) {
      _logger.e('Family members sync up failed', error: e);
      failed++;
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<SyncStageCounters> syncDeadPeople(String deviceId) async {
    int uploaded = 0;
    int failed = 0;

    try {
      final pendingDeceased = await _database.familyDeceasedDao.getUnsyncedDeceased();
      _logger.i('Found ${pendingDeceased.length} deceased records to upload');

      final groupedByBeneficiary = <int, List<FamilyDeceased>>{};
      for (final item in pendingDeceased) {
        groupedByBeneficiary.putIfAbsent(item.beneficiaryId, () => <FamilyDeceased>[]).add(item);
      }

      for (final entry in groupedByBeneficiary.entries) {
        final registrationId = await _resolveRegistrationIdForBeneficiary(entry.key);
        if (registrationId == null) {
          failed += entry.value.length;
          continue;
        }

        final father =
            entry.value.where((e) => e.deceasedType == _deceasedFatherType).cast<FamilyDeceased?>().firstWhere(
                  (e) => e != null,
                  orElse: () => null,
                );
        final mother =
            entry.value.where((e) => e.deceasedType == _deceasedMotherType).cast<FamilyDeceased?>().firstWhere(
                  (e) => e != null,
                  orElse: () => null,
                );

        final sharedNotes = _valueOrNull(father?.notes) ?? _valueOrNull(mother?.notes);

        final payload = {
          're_file_id': registrationId,
          if (father != null) ...{
            'father_first_name': father.firstName,
            'father_second_name': father.secondName,
            if (_valueOrNull(father.thirdName) != null) 'father_third_name': _valueOrNull(father.thirdName),
            'father_last_name': father.familyName,
            'father_id': father.nationalId.toString(),
            'father_death_date': father.deathDate.toIso8601String().split('T').first,
            'father_death_reason': father.deathCause,
            if (father.documentType != null) 'father_document_type': father.documentType,
            if (_valueOrNull(father.documentPath) != null) 'father_document_path': _valueOrNull(father.documentPath),
            if (_valueOrNull(father.notes) != null) 'father_notes': _valueOrNull(father.notes),
          },
          if (mother != null) ...{
            'mother_first_name': mother.firstName,
            'mother_second_name': mother.secondName,
            if (_valueOrNull(mother.thirdName) != null) 'mother_third_name': _valueOrNull(mother.thirdName),
            'mother_last_name': mother.familyName,
            'mother_id': mother.nationalId.toString(),
            'mother_death_date': mother.deathDate.toIso8601String().split('T').first,
            'mother_death_reason': mother.deathCause,
            if (mother.documentType != null) 'mother_document_type': mother.documentType,
            if (_valueOrNull(mother.documentPath) != null) 'mother_document_path': _valueOrNull(mother.documentPath),
            if (_valueOrNull(mother.notes) != null) 'mother_notes': _valueOrNull(mother.notes),
          },
          if (sharedNotes != null) 'notes': sharedNotes,
          'device_id': deviceId,
        };

        try {
          final response = await _dio.post(
            _normalizeApiEndpoint('/api/mobile/database/dead-people'),
            data: payload,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            for (final item in entry.value) {
              if (item.serverId != null) {
                await _database.familyDeceasedDao.markAsSynced(item.id, item.serverId!);
              } else {
                await _database.familyDeceasedDao.markAsSyncedWithoutServerId(item.id);
              }
              uploaded++;
            }
          } else {
            failed += entry.value.length;
          }
        } on DioException catch (e) {
          _logger.w(
            'Error uploading dead-people for beneficiary ${entry.key}: '
            'status=${e.response?.statusCode}, '
            'message=${e.message}, response=${e.response?.data}',
          );
          failed += entry.value.length;
        } catch (e) {
          _logger.w('Error uploading dead-people for beneficiary ${entry.key}: $e');
          failed += entry.value.length;
        }
      }
    } catch (e) {
      _logger.e('Dead-people sync up failed', error: e);
      failed++;
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<SyncStageCounters> syncGuardianBankAccounts(String deviceId) async {
    int uploaded = 0;
    int failed = 0;

    try {
      final pendingRows = await _database.customSelect(
        '''
        SELECT
          local_id,
          server_id,
          guardian_registration,
          bank_name_id,
          iban_usd,
          iban_shekel,
          re_id_number,
          re_guardian_name,
          re_phone_number,
          person_owner_identity_number,
          check_account,
          sync_state
        FROM guardian_bank_accounts
        WHERE sync_state IN ('pending', 'modified', 'failed', 'deleted')
        ORDER BY local_id ASC
        ''',
      ).get();

      _logger.i('Found ${pendingRows.length} guardian bank accounts to upload');

      for (final row in pendingRows) {
        final localId = row.read<int>('local_id');
        final serverId = row.read<int?>('server_id');
        final guardianRegistration = row.read<int>('guardian_registration');
        final syncState = row.read<String>('sync_state').trim().toLowerCase();

        try {
          if (syncState == 'deleted') {
            if (serverId != null && serverId > 0) {
              final response = await _dio.delete(
                _normalizeApiEndpoint('${ApiConfig.guardianBankAccountsEndpoint}/$serverId'),
                data: {'device_id': deviceId},
                options: Options(validateStatus: (status) => status != null && status < 500),
              );

              if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
                await _database.customStatement(
                  'DELETE FROM guardian_bank_accounts WHERE local_id = ?',
                  [localId],
                );
                uploaded++;
                continue;
              }

              failed++;
              await _database.customStatement(
                "UPDATE guardian_bank_accounts SET sync_state = 'failed' WHERE local_id = ?",
                [localId],
              );
              continue;
            }

            await _database.customStatement('DELETE FROM guardian_bank_accounts WHERE local_id = ?', [localId]);
            uploaded++;
            continue;
          }

          final payload = <String, dynamic>{
            'guardian_registration': guardianRegistration,
            'bank_name': row.read<int?>('bank_name_id'),
            'iban_usd': row.read<String?>('iban_usd'),
            'iban_shekel': row.read<String?>('iban_shekel'),
            're_id_number': row.read<String?>('re_id_number'),
            're_guardian_name': row.read<String?>('re_guardian_name'),
            're_phone_number': row.read<String?>('re_phone_number'),
            'person_owner_identity_number': row.read<String?>('person_owner_identity_number'),
            'check_account': row.read<int?>('check_account') ?? 0,
            'device_id': deviceId,
          };
          payload.removeWhere((_, value) => value == null || (value is String && value.trim().isEmpty));

          Response response;
          if (serverId != null && serverId > 0) {
            response = await _dio.put(
              _normalizeApiEndpoint('${ApiConfig.guardianBankAccountsEndpoint}/$serverId'),
              data: payload,
              options: Options(validateStatus: (status) => status != null && status < 500),
            );
          } else {
            response = await _dio.post(
              _normalizeApiEndpoint(ApiConfig.guardianBankAccountsEndpoint),
              data: payload,
              options: Options(validateStatus: (status) => status != null && status < 500),
            );
          }

          if (response.statusCode == 200 || response.statusCode == 201) {
            int? resolvedServerId = serverId;
            final body = response.data;
            if (body is Map<String, dynamic>) {
              final data = body['data'];
              if (data is Map<String, dynamic>) {
                final account = data['bank_account'] ?? data['record'] ?? data['item'];
                if (account is Map<String, dynamic>) {
                  resolvedServerId = _asInt(account['id']) ?? resolvedServerId;
                }
              }
            }

            await _database.customStatement(
              '''
              UPDATE guardian_bank_accounts
              SET
                server_id = COALESCE(?, server_id),
                sync_state = 'synced',
                last_synced_at = ?,
                updated_at = COALESCE(updated_at, ?)
              WHERE local_id = ?
              ''',
              [
                resolvedServerId,
                DateTime.now().toIso8601String(),
                DateTime.now().toIso8601String(),
                localId,
              ],
            );
            uploaded++;
          } else {
            failed++;
            await _database.customStatement(
              "UPDATE guardian_bank_accounts SET sync_state = 'failed' WHERE local_id = ?",
              [localId],
            );
          }
        } on DioException catch (e) {
          _logger.w(
            'Error uploading guardian bank account local_id=$localId: '
            'status=${e.response?.statusCode}, message=${e.message}, response=${e.response?.data}',
          );
          failed++;
          await _database.customStatement(
            "UPDATE guardian_bank_accounts SET sync_state = 'failed' WHERE local_id = ?",
            [localId],
          );
        } catch (e) {
          _logger.w('Error uploading guardian bank account local_id=$localId: $e');
          failed++;
          await _database.customStatement(
            "UPDATE guardian_bank_accounts SET sync_state = 'failed' WHERE local_id = ?",
            [localId],
          );
        }
      }
    } catch (e) {
      _logger.e('Guardian bank accounts sync up failed', error: e);
      failed++;
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  Future<int?> _resolveRegistrationIdForBeneficiary(int localBeneficiaryId) async {
    final beneficiary = await (_database.select(_database.beneficiaries)..where((b) => b.id.equals(localBeneficiaryId)))
        .getSingleOrNull();

    if (beneficiary == null) return null;

    final fileIdFromNumber = int.tryParse((beneficiary.fileIdNumber ?? '').trim());
    if (fileIdFromNumber != null) return fileIdFromNumber;

    if (beneficiary.serverId != null) return beneficiary.serverId;

    return null;
  }

  Future<String?> _resolvePersonIdentityNumberForAttachment(Attachment attachment) async {
    final directPersonId = attachment.personId?.trim();
    if (directPersonId != null && directPersonId.isNotEmpty) {
      return directPersonId;
    }

    final localBeneficiaryId = int.tryParse(attachment.beneficiaryId);
    if (localBeneficiaryId == null) {
      return null;
    }

    final beneficiary = await (_database.select(_database.beneficiaries)..where((b) => b.id.equals(localBeneficiaryId)))
        .getSingleOrNull();

    if (beneficiary == null) {
      return null;
    }

    final idNumber = beneficiary.idNumber;
    if (idNumber > 0) {
      return idNumber.toString();
    }

    final fileIdNumber = beneficiary.fileIdNumber?.trim();
    if (fileIdNumber != null && fileIdNumber.isNotEmpty) {
      _logger.w(
        'Attachment ${attachment.id}: idNumber is missing, using fileIdNumber as person_identity_number: '
        '$fileIdNumber',
      );
      return fileIdNumber;
    }

    return null;
  }

  Future<String> _buildAttachmentBeneficiaryDebug(Attachment attachment) async {
    final localBeneficiaryId = int.tryParse(attachment.beneficiaryId);
    if (localBeneficiaryId == null) {
      return 'invalid beneficiaryId="${attachment.beneficiaryId}"';
    }

    final beneficiary = await (_database.select(_database.beneficiaries)..where((b) => b.id.equals(localBeneficiaryId)))
        .getSingleOrNull();

    if (beneficiary == null) {
      return 'beneficiary not found for localId=$localBeneficiaryId';
    }

    return 'localId=${beneficiary.id}, idNumber=${beneficiary.idNumber}, '
        'fileIdNumber=${beneficiary.fileIdNumber ?? '-'}, serverId=${beneficiary.serverId?.toString() ?? '-'}';
  }

  String? _resolveAttachmentFileTypeForUpload(Attachment attachment, File file) {
    final explicitType = attachment.documentType?.trim();
    if (explicitType != null && explicitType.isNotEmpty) {
      return explicitType;
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex >= fileName.length - 1) {
      return null;
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  String? _valueOrNull(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return normalized;
  }
}
