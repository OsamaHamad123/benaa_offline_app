import 'package:drift/drift.dart';

import '../../../../data/db/drift_database.dart';
import '../../domain/entities/guardian_bank_account.dart';
import '../../domain/repositories/guardian_bank_account_repository.dart';

class GuardianBankAccountRepositoryImpl implements GuardianBankAccountRepository {
  final AppDatabase database;

  const GuardianBankAccountRepositoryImpl(this.database);

  @override
  Future<GuardianBankAccount?> loadByBeneficiaryLocalId(String beneficiaryId) async {
    final localId = int.tryParse(beneficiaryId);
    if (localId == null) return null;

    final beneficiaryRow = await database.customSelect(
      'SELECT file_id_number FROM beneficiaries WHERE id = ? LIMIT 1',
      variables: [Variable<int>(localId)],
    ).getSingleOrNull();

    final guardianRegistration = _asInt(beneficiaryRow?.data['file_id_number']);
    if (guardianRegistration == null || guardianRegistration <= 0) return null;

    final accountRow = await database.customSelect(
      '''
      SELECT
        local_id,
        server_id,
        guardian_registration,
        bank_name_id,
        bank_name_label,
        iban_usd,
        iban_shekel,
        re_id_number,
        re_guardian_name,
        re_phone_number,
        person_owner_identity_number,
        check_account
      FROM guardian_bank_accounts
      WHERE guardian_registration = ?
      LIMIT 1
      ''',
      variables: [Variable<int>(guardianRegistration)],
    ).getSingleOrNull();

    if (accountRow == null) return null;

    return GuardianBankAccount(
      localId: accountRow.read<int?>('local_id'),
      serverId: accountRow.read<int?>('server_id'),
      guardianRegistration: accountRow.read<int>('guardian_registration'),
      bankNameId: accountRow.read<int?>('bank_name_id'),
      bankNameLabel: accountRow.read<String?>('bank_name_label'),
      ibanUsd: accountRow.read<String?>('iban_usd'),
      ibanShekel: accountRow.read<String?>('iban_shekel'),
      representativeIdNumber: accountRow.read<String?>('re_id_number'),
      guardianName: accountRow.read<String?>('re_guardian_name'),
      representativePhone: accountRow.read<String?>('re_phone_number'),
      ownerIdentityNumber: accountRow.read<String?>('person_owner_identity_number'),
      checkAccountApproved: (accountRow.read<int?>('check_account') ?? 0) == 1,
    );
  }

  @override
  Future<void> saveByBeneficiaryLocalId({
    required String beneficiaryId,
    required GuardianBankAccount draft,
  }) async {
    final localId = int.tryParse(beneficiaryId);
    if (localId == null) return;

    final beneficiaryRow = await database.customSelect(
      'SELECT file_id_number FROM beneficiaries WHERE id = ? LIMIT 1',
      variables: [Variable<int>(localId)],
    ).getSingleOrNull();

    final guardianRegistration = _asInt(beneficiaryRow?.data['file_id_number']);
    if (guardianRegistration == null || guardianRegistration <= 0) return;

    final nowIso = DateTime.now().toIso8601String();
    final checkAccount = draft.checkAccountApproved ? 1 : 0;

    final existing = await database.customSelect(
      'SELECT local_id, server_id FROM guardian_bank_accounts WHERE guardian_registration = ? LIMIT 1',
      variables: [Variable<int>(guardianRegistration)],
    ).getSingleOrNull();

    if (!draft.hasAnyData) {
      if (existing == null) return;
      final existingLocalId = existing.read<int>('local_id');
      final serverId = existing.read<int?>('server_id');

      if (serverId != null && serverId > 0) {
        await database.customStatement(
          '''
          UPDATE guardian_bank_accounts
          SET
            sync_state = 'deleted',
            updated_at = ?,
            check_account = 0,
            is_approved = 0
          WHERE local_id = ?
          ''',
          [nowIso, existingLocalId],
        );
      } else {
        await database.customStatement(
          'DELETE FROM guardian_bank_accounts WHERE local_id = ?',
          [existingLocalId],
        );
      }
      return;
    }

    if (existing != null) {
      final existingLocalId = existing.read<int>('local_id');
      final serverId = existing.read<int?>('server_id');
      final nextSyncState = serverId == null ? 'pending' : 'modified';

      await database.customStatement(
        '''
        UPDATE guardian_bank_accounts
        SET
          bank_name_id = ?,
          bank_name_label = ?,
          iban_usd = ?,
          iban_shekel = ?,
          re_id_number = ?,
          re_guardian_name = ?,
          re_phone_number = ?,
          person_owner_identity_number = ?,
          check_account = ?,
          is_approved = ?,
          updated_at = ?,
          sync_state = CASE
            WHEN sync_state = 'deleted' THEN 'modified'
            WHEN sync_state IN ('pending', 'failed') THEN sync_state
            ELSE ?
          END
        WHERE local_id = ?
        ''',
        [
          draft.bankNameId,
          _nullableTrimmed(draft.bankNameLabel),
          _nullableTrimmed(draft.ibanUsd),
          _nullableTrimmed(draft.ibanShekel),
          _nullableTrimmed(draft.representativeIdNumber),
          _nullableTrimmed(draft.guardianName),
          _nullableTrimmed(draft.representativePhone),
          _nullableTrimmed(draft.ownerIdentityNumber),
          checkAccount,
          checkAccount,
          nowIso,
          nextSyncState,
          existingLocalId,
        ],
      );
      return;
    }

    await database.customStatement(
      '''
      INSERT INTO guardian_bank_accounts (
        guardian_registration,
        bank_name_id,
        bank_name_label,
        iban_usd,
        iban_shekel,
        re_id_number,
        re_guardian_name,
        re_phone_number,
        person_owner_identity_number,
        check_account,
        is_approved,
        created_at,
        updated_at,
        sync_state
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
      ''',
      [
        guardianRegistration,
        draft.bankNameId,
        _nullableTrimmed(draft.bankNameLabel),
        _nullableTrimmed(draft.ibanUsd),
        _nullableTrimmed(draft.ibanShekel),
        _nullableTrimmed(draft.representativeIdNumber),
        _nullableTrimmed(draft.guardianName),
        _nullableTrimmed(draft.representativePhone),
        _nullableTrimmed(draft.ownerIdentityNumber),
        checkAccount,
        checkAccount,
        nowIso,
        nowIso,
      ],
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  static String? _nullableTrimmed(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
