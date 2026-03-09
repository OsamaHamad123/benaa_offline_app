import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/beneficiaries/data/repositories/guardian_bank_account_repository_impl.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/entities/guardian_bank_account.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late GuardianBankAccountRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GuardianBankAccountRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<String> seedBeneficiary({required int fileIdNumber}) async {
    final inserted = await database.into(database.beneficiaries).insert(
          BeneficiariesCompanion.insert(
            idNumber: 123456789,
            phoneNumber: 599111111,
            altPhoneNumber: 599222222,
            firstName: const Value('اختبار'),
            fatherName: const Value('مستفيد'),
            grandFatherName: const Value('واحد'),
            familyName: const Value('تجريبي'),
            fileIdNumber: Value(fileIdNumber.toString()),
          ),
        );
    return inserted.toString();
  }

  test('saveByBeneficiaryLocalId inserts pending row for new account', () async {
    final beneficiaryId = await seedBeneficiary(fileIdNumber: 8101);

    await repository.saveByBeneficiaryLocalId(
      beneficiaryId: beneficiaryId,
      draft: const GuardianBankAccount(
        guardianRegistration: 0,
        bankNameId: 3,
        bankNameLabel: 'Bank A',
        ibanUsd: 'PS92PIBC000000000012345678901',
        checkAccountApproved: true,
      ),
    );

    final row = await database
        .customSelect(
          'SELECT bank_name_id, bank_name_label, sync_state, check_account '
          'FROM guardian_bank_accounts WHERE guardian_registration = 8101',
        )
        .getSingle();

    expect(row.read<int?>('bank_name_id'), 3);
    expect(row.read<String?>('bank_name_label'), 'Bank A');
    expect(row.read<String>('sync_state'), 'pending');
    expect(row.read<int>('check_account'), 1);
  });

  test('loadByBeneficiaryLocalId returns mapped account when exists', () async {
    final beneficiaryId = await seedBeneficiary(fileIdNumber: 8102);

    await database.customStatement(
      '''
      INSERT INTO guardian_bank_accounts (
        guardian_registration,
        bank_name_id,
        bank_name_label,
        iban_usd,
        check_account,
        sync_state
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [8102, 7, 'Bank B', 'PS33BANKB0000000000000001', 1, 'synced'],
    );

    final account = await repository.loadByBeneficiaryLocalId(beneficiaryId);

    expect(account, isNot(equals(null)));
    expect(account!.guardianRegistration, 8102);
    expect(account.bankNameId, 7);
    expect(account.bankNameLabel, 'Bank B');
    expect(account.ibanUsd, 'PS33BANKB0000000000000001');
    expect(account.checkAccountApproved, isTrue);
  });

  test('saveByBeneficiaryLocalId marks synced server row as deleted when draft empty', () async {
    final beneficiaryId = await seedBeneficiary(fileIdNumber: 8103);

    await database.customStatement(
      'INSERT INTO guardian_bank_accounts (server_id, guardian_registration, iban_usd, sync_state) '
      'VALUES (?, ?, ?, ?)',
      [1234, 8103, 'PSOLD', 'synced'],
    );

    await repository.saveByBeneficiaryLocalId(
      beneficiaryId: beneficiaryId,
      draft: const GuardianBankAccount(
        guardianRegistration: 0,
      ),
    );

    final row = await database
        .customSelect(
          'SELECT sync_state FROM guardian_bank_accounts WHERE guardian_registration = 8103',
        )
        .getSingle();

    expect(row.read<String>('sync_state'), 'deleted');
  });
}
