# FILE NUMBER AUDIT

## Scope audited

- Legacy file-id stack: `FileIdService`, `FileIdRemoteDataSource`, `FileIdReservationRepositoryImpl`, providers, DAO/table.
- Beneficiary model/save flow and form provider.
- Sync upload/down paths and file-id usage in mobile sync service.
- Local DB/cache layer for reserved ids.
- Candidate field names (`fileNumber`, `fileId`, `file_no`, `caseNumber`, `beneficiaryCode`, `referenceNumber`, `registrationNumber`).

## Existing classes/services found

- `lib/features/sync/services/file_id_service.dart`
  - Orchestrates local allocation + low-threshold refill + usage sync.
- `lib/features/sync/data/datasources/file_id_remote_datasource.dart`
  - Legacy REST endpoints (`/codes/request-codes`, `/codes/login-sync`, `/codes/confirm-usage`, old reservation APIs).
- `lib/features/sync/data/repositories/file_id_reservation_repository_impl.dart`
  - Reads/writes local pool, syncs used codes, stores diagnostics.
- `lib/features/sync/presentation/providers/file_id_providers.dart`
  - Riverpod wiring and legacy flow toggle.
- `lib/data/db/tables/file_id_reservation_table.dart`
  - Legacy table `file_id_reservations` (available/used/synced/conflict states).
- `lib/data/db/daos/file_id_reservation_dao.dart`
  - Local code allocation + status transitions + batch metadata.

## Existing algorithm (before this phase)

- Local pool backed mainly by `local_codes` and legacy `file_id_reservations`.
- `getNextId()` allocates the smallest available local code.
- If low availability, app calls legacy REST refill flow.
- On beneficiary save, app marks code as used locally.
- On sync-up, app confirms usage to legacy backend and marks local rows synced.

## Existing REST legacy behavior

- Reservation and refill used old server contract (`request-codes`, `login-sync`, `confirm-usage`) through `FileIdRemoteDataSource`.
- Legacy flow can be disabled in Firebase mode (`legacyFileIdSyncEnabledProvider`).
- In Firebase/demo mode, old sync endpoints are largely disabled in `MobileSyncService` (demo-mode guard).

## Where beneficiary file number was generated/assigned

- New beneficiary save path:
  - `lib/features/beneficiaries/presentation/providers/beneficiary_form_provider.dart`
- Missing file-id backfill for pending/modified beneficiaries:
  - `lib/features/beneficiaries/presentation/providers/list/beneficiaries_list_provider.dart`
- Sync-up fallback assignment when record misses file number:
  - `lib/core/sync/mobile_sync_service.dart`

## Where save flow should consume number

- Primary consume point: `BeneficiaryFormNotifier.save()` in
  `lib/features/beneficiaries/presentation/providers/beneficiary_form_provider.dart`.
- Number is now assigned from local offline pool and consumed on successful local beneficiary save.

## Where sync flow should confirm it

- `MobileSyncService.syncUp()` stage `syncUsedFileIds` already calls `FileIdService.syncUsage()`.
- This is now the integration point for file-number confirmation (`file_number_allocations` sync confirmation).

## Beneficiary fields carrying file number

- Domain entity: `fileNo`, `fileIdNumber`
  - `lib/features/beneficiaries/domain/entities/beneficiary.dart`
- Drift table column: `file_id_number`
  - `lib/data/db/tables/beneficiaries_table.dart`
- Firestore mapper fields: `file_no`, `file_id_number`
  - `lib/core/backend/mappers/beneficiary_firestore_mapper.dart`

## High-risk coupling points identified

- Older sync preflight assumed numeric-only `file_id_number`; this was incompatible with formatted IDs.
- Some auto-backfill logic assumed parseable int and would reject valid formatted values.
- Demo/Firebase mode disables old server sync endpoints; therefore WorkManager/legacy-only flow is insufficient.

## Post-audit implementation decision

- Keep compatibility with legacy methods but introduce offline-first formatted file-number pool and Firestore block reservation as primary path.
- Keep sync-up confirmation through existing flow entry points.
