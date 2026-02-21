import '../../data/db/drift_database.dart';

class BeneficiaryIdentityResolver {
  static Future<int?> resolveLocalBeneficiaryId({
    required AppDatabase database,
    required String? beneficiaryId,
  }) async {
    if (beneficiaryId == null) return null;

    final raw = beneficiaryId.trim();
    if (raw.isEmpty) return null;

    final localDirect = int.tryParse(raw);
    if (localDirect != null) {
      final byLocal = await database.beneficiariesDao.getBeneficiaryById(localDirect);
      if (byLocal != null) return byLocal.id;

      final byServer = await database.beneficiariesDao.getBeneficiaryByServerId(localDirect);
      if (byServer != null) return byServer.id;

      final byNational = await (database.select(database.beneficiaries)..where((b) => b.idNumber.equals(localDirect)))
          .getSingleOrNull();
      if (byNational != null) return byNational.id;
    }

    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    final asDigits = int.tryParse(digitsOnly);
    if (asDigits != null) {
      final byServer = await database.beneficiariesDao.getBeneficiaryByServerId(asDigits);
      if (byServer != null) return byServer.id;

      final byNational =
          await (database.select(database.beneficiaries)..where((b) => b.idNumber.equals(asDigits))).getSingleOrNull();
      if (byNational != null) return byNational.id;
    }

    final fileCandidates = <String>{raw};
    if (digitsOnly.isNotEmpty) {
      fileCandidates.add(digitsOnly);
    }

    final byFileId = await (database.select(database.beneficiaries)
          ..where((b) => b.fileIdNumber.isIn(fileCandidates.toList())))
        .getSingleOrNull();
    if (byFileId != null) return byFileId.id;

    final byOriginalFileId = await (database.select(database.beneficiaries)
          ..where((b) => b.originalFileIdFromExcel.isIn(fileCandidates.toList())))
        .getSingleOrNull();

    return byOriginalFileId?.id;
  }

  static Future<String?> resolveLocalBeneficiaryIdAsString({
    required AppDatabase database,
    required String? beneficiaryId,
  }) async {
    final localId = await resolveLocalBeneficiaryId(
      database: database,
      beneficiaryId: beneficiaryId,
    );

    return localId?.toString();
  }
}
