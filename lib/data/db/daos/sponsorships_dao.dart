import 'package:drift/drift.dart';

import '../drift_database.dart';
import '../tables/associations_table.dart';
import '../tables/beneficiaries_table.dart';
import '../tables/sponsorships_table.dart';

part 'sponsorships_dao.g.dart';

/// 🤝 Sponsorships DAO - عمليات الكفالات
@DriftAccessor(tables: [Sponsorships, Beneficiaries, Associations])
class SponsorshipsDao extends DatabaseAccessor<AppDatabase>
    with _$SponsorshipsDaoMixin {
  SponsorshipsDao(super.db);

  // ---------------------------------------------------------------------------
  // Create / Update
  // ---------------------------------------------------------------------------

  Future<int> createSponsorship(SponsorshipsCompanion companion) async {
    return await into(sponsorships).insert(companion);
  }

  Future<int> updateSponsorship({
    required int fileNo,
    required SponsorshipsCompanion companion,
  }) async {
    return await (update(sponsorships)..where((s) => s.fileNo.equals(fileNo)))
        .write(companion);
  }

  Future<int> endSponsorship({
    required int fileNo,
    DateTime? endDate,
  }) async {
    return await (update(sponsorships)..where((s) => s.fileNo.equals(fileNo)))
        .write(
      SponsorshipsCompanion(
        status: const Value('ended'),
        endDate: Value(endDate ?? DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteSponsorship({
    required int fileNo,
  }) async {
    return await (delete(sponsorships)..where((s) => s.fileNo.equals(fileNo)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Sponsored beneficiaries = لديهم كفالة واحدة على الأقل بحالة active
  Stream<List<SponsoredBeneficiarySummary>> watchSponsoredBeneficiaries() {
    final s = sponsorships;
    final b = beneficiaries;

    final query = select(b).join([
      innerJoin(
        s,
        s.beneficiaryId.equalsExp(b.id) & s.status.equals('active'),
      ),
    ])
      ..addColumns([
        s.fileNo.max(),
        s.fileNo.count(),
      ])
      ..groupBy([b.id])
      ..orderBy([
        OrderingTerm.desc(s.fileNo.max()),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final beneficiary = row.readTable(b);
        final lastFileNo = row.read(s.fileNo.max());
        final activeCount = row.read(s.fileNo.count()) ?? 0;

        return SponsoredBeneficiarySummary(
          beneficiary: beneficiary,
          activeSponsorshipsCount: activeCount,
          lastFileNo: lastFileNo,
        );
      }).toList();
    });
  }

  /// Unsponsored beneficiaries = لا يملكون أي كفالة بحالة active
  Stream<List<Beneficiary>> watchUnsponsoredBeneficiaries() {
    return customSelect(
      '''
      SELECT b.*
      FROM beneficiaries b
      WHERE NOT EXISTS (
        SELECT 1
        FROM sponsorships s
        WHERE s.beneficiary_id = b.id
          AND s.status = 'active'
      )
      ORDER BY b.created_at DESC, b.id DESC
      ''',
      readsFrom: {beneficiaries, sponsorships},
    ).watch().map((rows) {
      return rows.map((r) => beneficiaries.map(r.data)).toList(growable: false);
    });
  }

  /// All sponsorships for one beneficiary (active + ended + paused)
  Stream<List<SponsorshipWithAssociation>> watchSponsorshipsForBeneficiary(
    int beneficiaryId,
  ) {
    final s = sponsorships;
    final a = associations;

    final query = select(s).join([
      leftOuterJoin(a, a.id.equalsExp(s.associationId)),
    ])
      ..where(s.beneficiaryId.equals(beneficiaryId))
      ..orderBy([
        OrderingTerm.desc(s.fileNo),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return SponsorshipWithAssociation(
          sponsorship: row.readTable(s),
          association: row.readTableOrNull(a),
        );
      }).toList();
    });
  }

  Future<int> countActiveSponsorshipsForBeneficiary(int beneficiaryId) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS c FROM sponsorships WHERE beneficiary_id = ? AND status = ?',
      variables: [
        Variable.withInt(beneficiaryId),
        Variable.withString('active'),
      ],
      readsFrom: {sponsorships},
    ).getSingle();

    return result.read<int>('c');
  }

  /// All sponsorships (optionally filtered by association/status/search)
  Stream<List<SponsorshipWithDetails>> watchSponsorships({
    String? associationId,
    String status = 'all',
    String sponsorshipType = 'all',
    String query = '',
  }) {
    final s = sponsorships;
    final b = beneficiaries;
    final a = associations;

    final join = select(s).join([
      innerJoin(b, b.id.equalsExp(s.beneficiaryId)),
      leftOuterJoin(a, a.id.equalsExp(s.associationId)),
    ]);

    if (associationId != null && associationId.isNotEmpty) {
      join.where(s.associationId.equals(associationId));
    }

    if (status != 'all') {
      join.where(s.status.equals(status));
    }

    if (sponsorshipType != 'all') {
      join.where(s.sponsorshipType.equals(sponsorshipType));
    }

    final q = query.trim();
    if (q.isNotEmpty) {
      final asInt = int.tryParse(q);
      if (asInt != null) {
        join.where(s.fileNo.equals(asInt) |
            b.idNumber.equals(asInt) |
            b.fullName.contains(q));
      } else {
        join.where(b.fullName.contains(q));
      }
    }

    join.orderBy([
      OrderingTerm.desc(s.updatedAt),
      OrderingTerm.desc(s.fileNo),
    ]);

    return join.watch().map((rows) {
      return rows
          .map((row) => SponsorshipWithDetails(
                sponsorship: row.readTable(s),
                beneficiary: row.readTable(b),
                association: row.readTableOrNull(a),
              ))
          .toList(growable: false);
    });
  }
}

// -----------------------------------------------------------------------------
// Helper models
// -----------------------------------------------------------------------------

class SponsoredBeneficiarySummary {
  final Beneficiary beneficiary;
  final int activeSponsorshipsCount;
  final int? lastFileNo;

  const SponsoredBeneficiarySummary({
    required this.beneficiary,
    required this.activeSponsorshipsCount,
    required this.lastFileNo,
  });
}

class SponsorshipWithAssociation {
  final Sponsorship sponsorship;
  final Association? association;

  const SponsorshipWithAssociation({
    required this.sponsorship,
    required this.association,
  });

  String get associationName => association?.name ?? 'غير معروف';
}

class SponsorshipWithDetails {
  final Sponsorship sponsorship;
  final Beneficiary beneficiary;
  final Association? association;

  const SponsorshipWithDetails({
    required this.sponsorship,
    required this.beneficiary,
    required this.association,
  });

  String get associationName => association?.name ?? 'غير معروف';
}
