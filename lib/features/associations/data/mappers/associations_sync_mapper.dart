import 'package:drift/drift.dart' as drift;

import '../../../../data/db/drift_database.dart';
import '../models/associations_sync_dto.dart';

class AssociationsSyncMapper {
  const AssociationsSyncMapper._();

  static AssociationsCompanion sponsorDtoToAssociationCompanion(
    SponsorDto dto, {
    Association? existing,
  }) {
    final now = DateTime.now();
    final localId = existing?.id ?? 'srv-sponsor-${dto.id}';

    return AssociationsCompanion(
      id: drift.Value(localId),
      name: drift.Value(dto.sponsorName.trim()),
      shortName: drift.Value(_orNull(dto.sponsorShortName)),
      phone: drift.Value(_orDefault(dto.sponsorPhoneNumber, '')),
      email: drift.Value(_orNull(dto.sponsorEmail)),
      bankName: drift.Value(_orDefault(dto.sponsorBankName, 'غير محدد')),
      accountNumber: drift.Value(_orDefault(dto.sponsorAccountBankNumber, 'N/A')),
      swiftCode: drift.Value(_orNull(dto.sponsorBankSwiftCode)),
      bankPhone: drift.Value(_orNull(dto.sponsorBankRelatedPhoneNumber)),
      accountCurrency: drift.Value(_orNull(dto.sponsorBankAccountCurrency)),
      representativeId: drift.Value(existing?.representativeId),
      isActive: drift.Value(dto.status == null ? true : dto.status == 1),
      createdAt: drift.Value(existing?.createdAt ?? dto.createdAt ?? now),
      updatedAt: drift.Value(dto.updatedAt ?? now),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(dto.id),
      lastSyncedAt: drift.Value(now),
    );
  }

  static AssociationRepresentativesCompanion employeeDtoToRepresentativeCompanion(
    AssociationEmployeeDto dto, {
    Representative? existing,
  }) {
    final now = DateTime.now();
    final localId = existing?.id ?? 'srv-employee-${dto.id ?? '${dto.sponsorId}-${dto.employeeName.hashCode}'}';

    return AssociationRepresentativesCompanion(
      id: drift.Value(localId),
      name: drift.Value(dto.employeeName.trim()),
      createdAt: drift.Value(existing?.createdAt ?? dto.createdAt ?? now),
      updatedAt: drift.Value(dto.updatedAt ?? now),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(dto.id),
    );
  }

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String _orDefault(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }
}
