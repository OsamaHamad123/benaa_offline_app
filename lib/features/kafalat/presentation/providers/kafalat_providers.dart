import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../../data/db/daos/sponsorships_dao.dart';
import '../../../../data/db/drift_database.dart';

final kafalatSponsoredBeneficiariesProvider = StreamProvider.autoDispose<List<SponsoredBeneficiarySummary>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.sponsorshipsDao.watchSponsoredBeneficiaries();
});

final kafalatUnsponsoredBeneficiariesProvider = StreamProvider.autoDispose<List<Beneficiary>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.sponsorshipsDao.watchUnsponsoredBeneficiaries();
});

final kafalatActiveAssociationsProvider = FutureProvider.autoDispose<List<Association>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.associationsDao.getAllActiveAssociations();
});

final beneficiarySponsorshipsProvider =
    StreamProvider.autoDispose.family<List<SponsorshipWithAssociation>, int>((ref, beneficiaryId) {
  final db = ref.watch(databaseProvider);
  return db.sponsorshipsDao.watchSponsorshipsForBeneficiary(beneficiaryId);
});
