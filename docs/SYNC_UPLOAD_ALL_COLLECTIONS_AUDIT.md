# Sync Upload All Collections Audit

Date: 2026-05-28

## Scope Audited

- `lib/features/sync/mobile_sync_page.dart`
- `lib/features/sync/presentation/viewmodels/mobile_sync_dashboard_loader.dart`
- `lib/features/sync/presentation/providers/mobile_sync_operations_providers.dart`
- `lib/features/sync/services/firebase_beneficiary_upload_service.dart`
- `lib/features/sync/domain/usecases/sync_firestore_modules_usecase.dart`
- `lib/features/visits/data/services/visit_firestore_service.dart`
- `lib/features/sponsorships/data/services/sponsorship_firestore_service.dart`
- `lib/features/associations/data/services/association_firestore_service.dart`
- `lib/core/offline/firestore_local_cache_store.dart`
- Drift local tables: `beneficiaries`, `visits`, `sponsorships`, `associations`, `association_representatives`

## Root Cause (Why pending=0 with existing visit)

1. Upload button (`_syncUp`) previously called beneficiary upload only:
   - `_runFirebaseUpload()`
   - This checks pending beneficiaries only.

2. Dashboard pending log was beneficiary-only:
   - `pending=${data.stats['ben_needsSync']}`

3. Visits/sponsorships/associations were written primarily to Drift tables, while module upload services were reading Firestore sidecar cache rows. That created a split-brain path where real local records were not always mirrored into upload queue.

## Where "No data to upload" came from

- Beneficiary upload summary (`hadNoPending`) from:
  - `FirebaseBeneficiaryUploadService.uploadPendingBeneficiaries()`
- This did not include:
  - visits
  - sponsorships
  - associations
  - followups
  - sidecar collections

## Existing Upload Methods (Before this fix)

- Beneficiaries: exists (working)
  - `FirebaseBeneficiaryUploadService.uploadPendingBeneficiaries`
- Modules upload exists but not used by upload button:
  - `SyncFirestoreModulesUseCase.uploadAll`
- Drift-to-sidecar bridge missing/insufficient for active forms:
  - visit/sponsorship/association forms mainly persist Drift rows.

## Missing/Weak Areas Identified

1. Unified pending counter across all collections.
2. Unified registry model for syncable entities.
3. Upload button orchestration for all collections.
4. Safe sidecar physical table names (to avoid colliding with existing Drift tables with same names).
5. Drift pending rows mirroring into Firestore upload queues for visits/sponsorships/associations.

## Changes Implemented

### A) Unified sync collection model/registry

Added:

- `lib/features/sync/domain/models/sync_collection_summary.dart`
- `lib/features/sync/services/sync_collection_registry.dart`

New model:

- `SyncCollectionSummary`
- `SyncUploadAllResult`

Registry responsibilities:

- load per-collection summary (local/pending/failed)
- compute total pending across all collections
- run upload all pending changes (beneficiaries + modules)

### B) Upload button now uploads all collections

Updated:

- `lib/features/sync/mobile_sync_page.dart` (`_syncUp`)

Behavior now:

- computes total pending via `syncCollectionRegistryProvider`
- if total pending is zero: show "لا توجد تغييرات لرفعها"
- else uploads all via registry
- refreshes dashboard metrics after completion

### C) Dashboard pending metrics now all-collections

Updated:

- `lib/features/sync/presentation/viewmodels/mobile_sync_dashboard_loader.dart`
- `lib/features/sync/mobile_sync_page.dart` log message and status card

Added stats keys:

- `visits_pending`, `visits_failed`, `visits_needsSync`
- `followup_pending`, `followup_failed`
- `sponsorship_files_pending`, `sponsorship_candidates_pending`, `sponsorship_payments_pending`
- `association_contacts_pending`
- `total_pending_uploads`

### D) Drift -> Upload queue bridges

#### Visits

Updated:

- `lib/features/visits/data/services/visit_firestore_service.dart`

Added:

- mirror pending Drift visits into sidecar queue before upload
- upload logs:
  - `[VisitUpload] started pending=<count>`
  - `[VisitUpload] uploaded localId=<id> beneficiary=<fileNumber>`
  - `[VisitUpload] failed localId=<id> ...`
  - `[VisitUpload] completed uploaded=<count> failed=<count>`
- mark Drift visit synced after success

#### Sponsorships

Updated:

- `lib/features/sponsorships/data/services/sponsorship_firestore_service.dart`

Added:

- mirror pending Drift sponsorships into sidecar queue before upload
- upload logs:
  - `[SponsorshipUpload] started pending=<count>`
  - `[SponsorshipUpload] uploaded localId=<id> beneficiary=<fileNumber>`
  - `[SponsorshipUpload] completed uploaded=<count> failed=<count>`
- mark Drift sponsorship synced after success

#### Associations

Updated:

- `lib/features/associations/data/services/association_firestore_service.dart`

Added:

- mirror pending Drift associations into sidecar queue before upload
- mark Drift association synced after success

### E) Sidecar table safety fix

Updated:

- `lib/core/offline/firestore_local_cache_store.dart`

Fix:

- physical table names now prefixed (`firecache_<logical>`) to avoid collisions with existing Drift tables such as `associations` and `sponsorships`.
- added generic counters:
  - `countAll(table)`
  - `countByStatuses(table, statuses)`

## What is currently counted in pending total

Counted now:

- beneficiaries (pending/modified/failed)
- visits (pending/modified/failed)
- sponsorships (pending/modified/failed)
- associations (pending/modified/failed)
- association representatives (pending/modified/failed)
- sidecar queues:
  - association_contacts
  - sponsorship_files
  - sponsorship_candidates
  - sponsorship_payments
  - beneficiary_followups

## Remaining Gaps / Next Hardening

1. Association contacts are currently counted via sidecar queue; if app writes only to Drift representatives for some flows, add explicit mapping from representative rows to `association_contacts` payload.
2. Add remoteCount for non-beneficiary modules (currently 0 in summaries unless explicitly queried from Firestore).
3. Expand UI module cards to render per-collection status directly from `SyncCollectionSummary` list.
4. Add integration tests for upload orchestration and pending counters.
