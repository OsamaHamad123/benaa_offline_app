import 'dart:developer' as developer;

import '../../../../core/error_handling/result.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';

class CedarAssociationsSeedResult {
  const CedarAssociationsSeedResult({
    required this.created,
    required this.skipped,
    required this.updated,
    required this.failed,
  });

  final int created;
  final int skipped;
  final int updated;
  final int failed;
}

class CedarAssociationsSeeder {
  const CedarAssociationsSeeder(this._repository);

  static const String _defaultPhone = '0000000000';
  static const String _defaultBankName = 'غير محدد';
  static const String _defaultAccountCurrency = 'USD';

  final AssociationRepository _repository;

  Future<CedarAssociationsSeedResult> seedCedarAssociations({bool force = false}) async {
    developer.log(
      '[CedarAssociations] existing associations system detected collection=associations',
      name: 'CedarAssociations',
    );

    final seeds = _buildSeedRecords();
    developer.log(
      '[CedarAssociations] started count=${seeds.length} force=$force',
      name: 'CedarAssociations',
    );

    final allResult = await _repository.getAllAssociations();
    if (allResult is! Success<List<Association>>) {
      developer.log(
        '[CedarAssociations] created=0 skipped=0 updated=0 failed=${seeds.length}',
        name: 'CedarAssociations',
      );
      return CedarAssociationsSeedResult(
        created: 0,
        skipped: 0,
        updated: 0,
        failed: seeds.length,
      );
    }

    final existing = allResult.value;
    final byId = <String, Association>{
      for (final item in existing) item.id: item,
    };
    final byName = <String, Association>{
      for (final item in existing) _normalize(item.name): item,
    };

    var created = 0;
    var skipped = 0;
    var updated = 0;
    var failed = 0;

    for (final seed in seeds) {
      final existingById = byId[seed.id];
      final existingByName = byName[_normalize(seed.nameAr)];
      final target = existingById ?? existingByName;

      if (target != null) {
        if (!force) {
          skipped += 1;
          continue;
        }

        final updateResult = await _repository.updateAssociation(
          target.copyWith(
            name: seed.nameAr,
            shortName: seed.shortName,
            phone: target.phone.trim().isEmpty ? _defaultPhone : target.phone,
            bankName: target.bankName.trim().isEmpty ? _defaultBankName : target.bankName,
            accountNumber: target.accountNumber.trim().isEmpty ? _defaultAccountNumber(seed.id) : target.accountNumber,
            accountCurrency: target.accountCurrency ?? _defaultAccountCurrency,
            isActive: true,
            updatedAt: DateTime.now(),
          ),
        );

        if (updateResult is Success<Association>) {
          updated += 1;
        } else {
          failed += 1;
        }
        continue;
      }

      final createResult = await _repository.createAssociation(
        AssociationParams(
          id: seed.id,
          name: seed.nameAr,
          shortName: seed.shortName,
          phone: _defaultPhone,
          bankName: _defaultBankName,
          accountNumber: _defaultAccountNumber(seed.id),
          accountCurrency: _defaultAccountCurrency,
          isActive: true,
        ),
      );

      if (createResult is Success<Association>) {
        final inserted = createResult.value;
        byId[inserted.id] = inserted;
        byName[_normalize(inserted.name)] = inserted;
        created += 1;
      } else {
        failed += 1;
      }
    }

    developer.log(
      '[CedarAssociations] created=$created skipped=$skipped updated=$updated failed=$failed',
      name: 'CedarAssociations',
    );

    return CedarAssociationsSeedResult(
      created: created,
      skipped: skipped,
      updated: updated,
      failed: failed,
    );
  }

  List<_CedarAssociationSeedRecord> _buildSeedRecords() {
    return const <_CedarAssociationSeedRecord>[
      _CedarAssociationSeedRecord(
        id: 'cedar-rahma-charity-gaza',
        nameAr: 'جمعية الرحمة للأعمال الخيرية - غزة',
        shortName: 'Rahma Charity Gaza',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-unrwa',
        nameAr: 'وكالة الأمم المتحدة لإغاثة وتشغيل اللاجئين الفلسطينيين - الأونروا',
        shortName: 'UNRWA',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-pcrf',
        nameAr: 'صندوق إغاثة أطفال فلسطين',
        shortName: 'PCRF',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-prcs',
        nameAr: 'جمعية الهلال الأحمر الفلسطيني',
        shortName: 'PRCS',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-turkish-red-crescent',
        nameAr: 'الهلال الأحمر التركي',
        shortName: 'Turkish Red Crescent',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-ihh',
        nameAr: 'هيئة الإغاثة الإنسانية التركية IHH',
        shortName: 'IHH Humanitarian Relief Foundation',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-tika',
        nameAr: 'الوكالة التركية للتعاون والتنسيق - تيكا',
        shortName: 'TIKA',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-oxfam',
        nameAr: 'أوكسفام',
        shortName: 'Oxfam',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-care-international',
        nameAr: 'كير الدولية',
        shortName: 'CARE International',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-action-against-hunger',
        nameAr: 'العمل ضد الجوع',
        shortName: 'Action Against Hunger',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-mercy-corps',
        nameAr: 'ميرسي كور',
        shortName: 'Mercy Corps',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-nrc',
        nameAr: 'المجلس النرويجي للاجئين',
        shortName: 'NRC',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-msf',
        nameAr: 'أطباء بلا حدود',
        shortName: 'MSF',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-save-the-children',
        nameAr: 'إنقاذ الطفل',
        shortName: 'Save the Children',
      ),
      _CedarAssociationSeedRecord(
        id: 'cedar-palestinian-scout-association',
        nameAr: 'جمعية الكشافة الفلسطينية',
        shortName: 'Palestinian Scout Association',
      ),
    ];
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  String _defaultAccountNumber(String id) {
    final suffix = id.replaceAll('cedar-', '').replaceAll('-', '_').toUpperCase();
    return 'CEDAR_$suffix';
  }
}

class _CedarAssociationSeedRecord {
  const _CedarAssociationSeedRecord({
    required this.id,
    required this.nameAr,
    required this.shortName,
  });

  final String id;
  final String nameAr;
  final String shortName;
}
