# SYNC & FIREBASE PIPELINE STABILIZATION PLAN

**Date:** 2026-05-28  
**Phase:** Sync & Firebase Pipeline Stabilization  
**Status:** IN PROGRESS  
**Baseline:** Dashboard 150/150 ✅ | Security 101/101 ✅ | Analyzer 0 errors 0 warnings ✅

---

## 1. Current Sync Architecture Summary

### Backend Mode

- `BACKEND_FLAVOR=firebase` (default)
- `BackendConfig.current.flavor == BackendFlavor.firebase`
- WorkManager is **disabled by default** (`ENABLE_WORKMANAGER=false`)
- All sync in Firebase mode runs **foreground** inside `MobileSyncPage`

### Core Layers

| Layer                               | File                                                                    | Responsibility                                             |
| ----------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------- |
| Sync Page (UI/Orchestrator)         | `lib/features/sync/mobile_sync_page.dart`                               | Button handlers, progress, dashboard refresh               |
| Firebase Beneficiary Upload Service | `lib/features/sync/services/firebase_beneficiary_upload_service.dart`   | Upload/download beneficiaries to/from Firestore            |
| Sync Collection Registry            | `lib/features/sync/services/sync_collection_registry.dart`              | Aggregate pending counts, upload all collections           |
| Sync Firestore Modules UseCase      | `lib/features/sync/domain/usecases/sync_firestore_modules_usecase.dart` | Upload/download associations/sponsorships/visits/followups |
| File ID Service                     | `lib/features/sync/services/file_id_service.dart`                       | File number reservation from Firestore                     |
| Mobile Sync Service                 | `lib/core/sync/mobile_sync_service.dart`                                | Legacy REST-based sync (used in non-Firebase mode only)    |

---

## 2. Upload Pipeline Modules

### Beneficiaries (Primary Upload Path)

- **Entry:** `_syncUp()` → `SyncCollectionRegistry.uploadAllPendingChangesToFirebase()`
- **Firebase service:** `FirebaseBeneficiaryUploadService.uploadPendingBeneficiaries()`
- **Firestore collection:** `beneficiaries`
- **Local source:** Drift `beneficiaries` table (`syncState = 'pending' | 'modified' | 'failed'`)
- **Status:** ✅ Implemented & working

### Firestore Modules Upload (Additional Collections)

- **Entry:** `_syncNowOfficial()` → `SyncFirestoreModulesUseCase.uploadAll()`
- **Also invoked by:** `_syncUp()` via `SyncCollectionRegistry.uploadAllPendingChangesToFirebase()`
- **Collections handled:**

| Module                | Usecase/Repo                                                 | Status |
| --------------------- | ------------------------------------------------------------ | ------ |
| associations          | `AssociationFirestoreRepository.uploadPendingAssociations()` | ✅     |
| association_contacts  | `AssociationFirestoreRepository.uploadPendingContacts()`     | ✅     |
| sponsorships (core)   | `SponsorshipRepository.uploadPendingCore()`                  | ✅     |
| beneficiary_visits    | `VisitFirestoreRepository.uploadPendingVisits()`             | ✅     |
| beneficiary_followups | `VisitFirestoreRepository.uploadPendingFollowups()`          | ✅     |

### Collections Counted in Pending Total (SyncCollectionRegistry)

- beneficiaries (pending/modified/failed)
- beneficiary_visits
- sponsorships
- associations
- association_contacts (sidecar)
- sponsorship_files (sidecar)
- sponsorship_candidates (sidecar)
- sponsorship_payments (sidecar)
- beneficiary_followups (sidecar)

---

## 3. Download Pipeline Modules

### Beneficiaries Download

- **Entry:** `_syncDown()` → `_runFirebaseDownload()` → `FirebaseBeneficiaryUploadService.syncDownBeneficiariesFromFirebase()`
- **Firestore collection:** `beneficiaries`
- **Merge policy:** upsert by `id`, server-wins on conflict
- **Status:** ✅ Implemented

### Firestore Modules Download (via Full Sync only)

- **Entry:** `_syncNowOfficial()` → `SyncFirestoreModulesUseCase.downloadAll()`
- **Collections handled:**

| Module                | Op Key                          | Status |
| --------------------- | ------------------------------- | ------ |
| associations          | `association_download`          | ✅     |
| association_contacts  | `association_contacts_download` | ✅     |
| sponsorships          | `sponsorship_download`          | ✅     |
| beneficiary_visits    | `visit_download`                | ✅     |
| beneficiary_followups | `followup_download`             | ✅     |

> **Gap identified:** The standalone "تنزيل البيانات" button (`_syncDown`) only downloads beneficiaries.  
> Associations/sponsorships/visits/followups are downloaded **only** during full sync (`_syncNowOfficial`).  
> This is a known design decision — standalone download button is beneficiary-focused.

---

## 4. Full Sync Steps (`_syncNowOfficial` in Firebase mode)

```
Step 1: Taxonomy sync (fire-and-forget, non-blocking)
Step 2: File number sync-down (get reserved blocks from Firestore)
Step 3: Upload beneficiaries (_runFirebaseUpload)
Step 4: Upload modules (SyncFirestoreModulesUseCase.uploadAll)
Step 5: Download beneficiaries (_runFirebaseDownload)
Step 6: Download modules (SyncFirestoreModulesUseCase.downloadAll)
Step 7: Update sync metadata (full_sync timestamp)
Step 8: Dashboard refresh + invalidation
```

Each step is logged via `developer.log('[FullSync] step=... status=...')`.

---

## 5. Local Reset Behavior

- `resetBeneficiariesLocalCache()` → SQLite only (Drift `_db` operations)
- `resetTaxonomiesLocalCache()` → SQLite only
- `resetFileNumberPoolLocalCache()` → SQLite only
- **Confirmed:** Zero Firestore API calls in any reset function
- **Confirmation dialogs:** Present for all 3 reset operations
- **Tombstones:** Cleared locally only (`DELETE FROM sync_tombstones`) — no Firestore push
- **Tests:** Covered by `test/features/sync/sync_safety_test.dart` (8 tests ✅)

---

## 6. File Number Reservation Behavior

- Format: `GZ-YYYY-NNNNNN` (e.g., `GZ-2026-000001`)
- **Upload path:** `_uploadCedarFileNumbers()` → `FileIdService.uploadCedarFileNumbers()`
- **Firestore collections:**
  - `file_number_counters` — global counter per year
  - `file_number_blocks` — device-specific blocks
  - `file_number_allocations` — individual assigned numbers
- **Known risk:** Query on `file_number_blocks` with `deviceId + userId + orderBy reservedAt desc` requires a Firestore composite index
- **Current workaround option:** Sort locally after fetching by deviceId/userId without remote orderBy
- **Sync-down path:** `FileIdService.syncDownFileNumberState()` runs during full sync step 2

---

## 7. Foreground Sync vs WorkManager

| Sync Type | Firebase Mode        | Non-Firebase Mode                           |
| --------- | -------------------- | ------------------------------------------- |
| Full sync | Foreground (in-page) | WorkManager → fallback to MobileSyncService |
| Upload    | Foreground (in-page) | Foreground via MobileSyncService            |
| Download  | Foreground (in-page) | WorkManager → fallback to MobileSyncService |

- **DEMO MODE blockers:** `MobileSyncService.syncDown()` and `.syncUp()` return `demo_mode_disabled` — these are only called in non-Firebase mode
- **Firebase mode:** No demo blocker. All paths use FirebaseBeneficiaryUploadService directly
- **WorkManager required for Firebase?** No. All Firebase paths are foreground-only
- **WorkManager enable flag:** `ENABLE_WORKMANAGER=false` by default

---

## 8. Firestore Collections Used by Sync

| Collection                                  | Used For                | Rules Status          |
| ------------------------------------------- | ----------------------- | --------------------- |
| `beneficiaries`                             | Upload/download         | ✅ auth read/write    |
| `beneficiaries/{id}/visits` (subcollection) | Visits sub-docs         | ✅ auth               |
| `beneficiary_visits`                        | Visits top-level        | ✅ auth               |
| `beneficiary_followups`                     | Followups top-level     | ✅ auth               |
| `associations`                              | Associations            | ⚠️ admin-write only   |
| `association_contacts`                      | Association contacts    | ✅ auth create/update |
| `sponsorships`                              | Sponsorships            | ⚠️ admin-write only   |
| `sponsorship_files`                         | Sponsorship files       | ✅ auth               |
| `sponsorship_candidates`                    | Candidates              | ✅ auth               |
| `sponsorship_payments`                      | Payments                | ✅ auth               |
| `taxonomy_categories`                       | Taxonomies              | ⚠️ open to all auth   |
| `taxonomy_groups`                           | Taxonomy groups         | ⚠️ open to all auth   |
| `file_number_counters`                      | File number counters    | ✅ auth               |
| `file_number_blocks`                        | File number blocks      | ✅ auth               |
| `file_number_allocations`                   | File number allocations | ✅ auth               |
| `sync_health_checks`                        | Health checks           | ✅ auth               |

---

## 9. Current Logging/Reporting Gaps

| Gap                                                                                                  | Severity         | Fix                                         |
| ---------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------- |
| `SyncFirestoreModulesUseCase.downloadAll()` errors use raw `e.toString()` — may include document IDs | P1               | Wrap with LogSanitizer.sanitizeErrorMessage |
| Module download errors include `message=$e` without sanitization                                     | P1               | Apply LogSanitizer to error strings         |
| `downloadAll()` log already includes module name via `failedModules.map()`                           | ✅ Already fixed | No action needed                            |
| `uploadAll()` does not report per-module failure list in logs                                        | P2               | Add module failure logging to uploadAll     |
| Beneficiary download log does not include precise upserted/skipped per-run in FullSync log           | P2               | Log from BeneficiaryDownloadSummary         |

---

## 10. Current Permission/Index Risks

| Risk                                                                                               | Impact | Mitigation                                        |
| -------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------- |
| `associations` write is admin-only in Firestore rules — upload will fail for field_worker accounts | P1     | Verify or relax for dev, document production plan |
| `sponsorships` write is admin-only in Firestore rules — upload will fail for field_worker accounts | P1     | Same as above                                     |
| `file_number_blocks` query uses `deviceId + userId + orderBy` — may need composite index           | P1     | Sort locally or create index                      |
| `taxonomy_categories` write open to all auth — risk in production                                  | P2     | Document; restrict in production                  |

---

## 11. Implementation Checklist

### P0 — Correctness & Safety

- [x] Local reset never touches Firestore (verified + tested)
- [x] Foreground sync works in Firebase mode without WorkManager
- [x] Foreground sync does not show DEMO MODE blocker
- [x] Dashboard invalidation after sync (`ref.invalidate(dashboardSummaryProvider)` + `dashboardProvider.notifier.refresh()`)
- [ ] Verify `associations` upload doesn't fail with permission-denied for field_worker in dev
- [ ] Verify `sponsorships` upload doesn't fail with permission-denied for field_worker in dev
- [ ] Fix or document file_number_blocks composite index requirement

### P1 — Observability & Logging

- [ ] Apply LogSanitizer to error strings in `SyncFirestoreModulesUseCase.downloadAll()`
- [ ] Apply LogSanitizer to error strings in `SyncFirestoreModulesUseCase.uploadAll()`
- [ ] Add per-module failure logging to uploadAll
- [ ] Log BeneficiaryDownloadSummary counts inside FullSync logging

### P2 — Tests

- [ ] `test/features/sync/full_sync_observability_test.dart` — verify module name in failure
- [ ] `test/features/sync/upload_pipeline_test.dart` — pending count includes all modules
- [ ] `test/features/sync/download_pipeline_test.dart` — download reports counts
- [ ] `test/features/file_numbers/file_number_sync_query_test.dart` — no composite index needed
- [ ] `test/features/sync/foreground_sync_mode_test.dart` — no demo blocker in Firebase mode
- [ ] `test/features/dashboard/dashboard_sync_invalidation_test.dart` — verify intact

### P3 — Docs & Future Production

- [ ] Update `docs/FIRESTORE_RULES_COVERAGE.md` with sync verification status
- [ ] Create `docs/SYNC_MODULE_REGISTRY.md`
- [ ] Create `docs/SYNC_FIREBASE_PIPELINE_STATUS.md`
- [ ] Update `docs/DASHBOARD_BASELINE_2026_05_28.md` with sync note
- [ ] Document composite index fields for `file_number_blocks`

---

## Constraints (DO NOT)

- Do NOT redesign Dashboard
- Do NOT change Quick Actions
- Do NOT change AppBar visual spec
- Do NOT weaken Security/Privacy protections
- Do NOT remove LogSanitizer usage
- Do NOT expose debug/admin/seed tools to normal users
- Do NOT revert State Management changes
- Do NOT introduce WorkManager dependency for Firebase mode
- Do NOT run full test suite after every small change
- Do NOT rename collections without migration plan
- Do NOT delete remote Firestore data from local reset
