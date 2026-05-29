# ASSOCIATIONS / SPONSORSHIPS / VISITS AUDIT

## Scope

Audit date: 2026-05-28

Keywords checked:

- association, jam3iya, jamiyat
- kafala, kafalat, sponsorship, sponsor
- visit, followup, follow_up
- payment, assistance, caseReport, fieldVisit, beneficiary_notes

## Existing Modules Found

### Associations

- Existing feature module: `lib/features/associations`
- Existing domain entity: `Association` (legacy shape linked to mobile API fields/bank fields).
- Existing repository: `AssociationRepositoryImpl`
- Existing DAO/table:
  - `lib/data/db/tables/associations_table.dart`
  - `lib/data/db/daos/associations_dao.dart`
- Existing sync integration:
  - `SyncAssociationsModuleUseCase`
  - `associations_remote_sync_datasource.dart`
- Existing UI:
  - `associations_list_page_v2.dart`
  - association form sheets and widgets

### Sponsorships / Kafalat

- Existing feature module: `lib/features/kafalat`
- Existing local table: `lib/data/db/tables/sponsorships_table.dart`
- Existing DAO: `lib/data/db/daos/sponsorships_dao.dart`
- Existing sync integration:
  - `SyncSponsorshipsModuleUseCase`
  - `sponsorships_remote_sync_datasource.dart`
- Existing UI:
  - `kafalat_page.dart`
  - import/charts/filters pages
- Gap:
  - no dedicated Firestore-first candidate pipeline (`sponsorship_files`, `sponsorship_candidates`, `sponsorship_payments`) before this change.

### Visits

- Existing feature module: `lib/features/visits`
- Existing local table: `lib/data/db/tables/visits_table.dart`
- Existing DAO/repository/use cases:
  - `visits_dao.dart`
  - `visit_repository_impl.dart`
- Existing UI:
  - visits list and record pages
- Existing behavior:
  - visit model is simple and not yet covering sponsorship/association linkage and follow-up generation contract.

### Follow-ups

- No dedicated top-level module/table/collection existed for `beneficiary_followups`.
- Follow-up existed as taxonomy labels and visit type label only in several UI files.

### Firestore Mapping and Paths

- Existing path constants in `lib/services/firebase/firestore_paths.dart` were incomplete for the requested collections.
- Existing Firestore sync focused mainly on beneficiaries + taxonomy + file numbers in `FirebaseBeneficiaryUploadService` and `MobileSyncPage`.

## Existing Local DB Tables (Relevant)

- `associations`
- `association_representatives`
- `sponsorships`
- `visits`

No existing local tables for:

- `association_contacts`
- `sponsorship_files`
- `sponsorship_candidates`
- `sponsorship_payments`
- `beneficiary_followups`

## Existing Firestore Rule Coverage (Before Change)

- had `/associations` and `/sponsorships` rules with admin restrictions
- no dedicated rules for:
  - `association_contacts`
  - `sponsorship_files`
  - `sponsorship_candidates`
  - `sponsorship_payments`
  - `beneficiary_visits`
  - `beneficiary_followups`

## Missing Modules (Before Change)

- Dedicated Firestore-first repository/services for the new lifecycle collections
- Candidate matching helper with national ID / phone+name / normalized name+city priority
- Beneficiary follow-up table/collection and service
- Unified Firestore module sync orchestrator for these 8 collections
- UI stubs for candidate review and follow-up dashboard

## Recommended Integration Points

1. Keep legacy mobile API modules intact.
2. Add Firestore-first sidecar modules and local cache layer for new collections.
3. Reuse Sync page orchestration and add new upload/download steps inside Firebase full sync flow.
4. Keep Cedar file number assignment only when creating new beneficiary, not when creating sponsorship record.
5. Keep candidate staging explicit (`sponsorship_candidates`) and avoid direct auto-conversion to beneficiary.

## Implemented in this phase

- Added Firestore-first entities/models/services/repositories/providers for:
  - associations and contacts
  - sponsorship files/candidates/sponsorships/payments
  - beneficiary visits/followups
- Added unified offline local cache store with required sync statuses.
- Added candidate matching helper and beneficiary creation from unmatched candidate (with Cedar file number assignment).
- Extended Firebase full sync flow to include new modules upload/download steps.
- Added dev Firestore rules for all requested collections.
- Added UI stubs for required screens/tabs/dashboard.
- Added Cedar Sample Data seeder class.
