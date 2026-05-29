# SYNC PAGE AUDIT

Date: 2026-05-28
Scope:

- lib/features/sync/mobile_sync_page.dart
- lib/core/sync/mobile_sync_service.dart
- lib/features/sync/presentation/providers/sync_progress_providers.dart
- lib/features/sync/presentation/providers/mobile_sync_operations_providers.dart
- lib/features/sync/presentation/viewmodels/mobile_sync_dashboard_loader.dart
- lib/features/sync/data/repositories/mobile_sync_beneficiary_repository.dart
- lib/core/backend/firebase/firebase_firestore_service.dart
- lib/core/backend/mappers/beneficiary_firestore_mapper.dart
- file number services/providers
- taxonomy sync providers/services
- local beneficiaries DB table/DAO
- backend/demo flags

## Executive Summary

- Root cause of download blocker: sync-down path still routed to legacy MobileSyncService demo guard returning `demo_mode_disabled`.
- Upload path for beneficiaries is already Firebase-based and functional (Firestore + file_number_allocations confirmation).
- WorkManager is optional and disabled by default (`ENABLE_WORKMANAGER=false`), but foreground fallback exists.
- Sync page previously mixed Firebase + legacy REST semantics and labels, creating confusing state and disabled/demo behavior.
- Sync-down for beneficiaries was missing in Firebase service layer and had no local merge/conflict policy implementation.

## Button/Action Audit

| Button / Action                             | Current Behavior (Before Rebuild)                                                                                              | Expected Firebase Behavior                                                                  | Status                              | Responsible File/Function                                                                                               |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| مزامنة الآن (شاملة)                         | Ran `syncDown()` then `syncUp()` from MobileSyncService in foreground when WorkManager unavailable.                            | Full Firebase sequence: taxonomy -> file numbers -> upload -> download -> metrics refresh.  | needs refactor (done in this phase) | lib/features/sync/mobile_sync_page.dart / \_syncNowOfficial                                                             |
| تنزيل البيانات من السيرفر                   | Called `BackgroundSyncWorker.triggerSyncDown()` first, fallback to `MobileSyncService.syncDown()` which returns demo disabled. | Foreground Firebase sync-down from Firestore beneficiaries with merge/upsert and conflicts. | demo-only/disabled (fixed)          | lib/features/sync/mobile_sync_page.dart / \_syncDown, lib/core/sync/mobile_sync_service.dart / syncDown                 |
| رفع التغييرات                               | Uses FirebaseBeneficiaryUploadService and uploads pending/modified/failed local beneficiaries to Firestore.                    | Keep enabled in Firebase mode; idempotent upsert and file number confirmation.              | working                             | lib/features/sync/mobile_sync_page.dart / \_syncUp, lib/features/sync/services/firebase_beneficiary_upload_service.dart |
| رفع أرقام الملفات الأساسية                  | Uses FileIdService with Firestore file number service.                                                                         | Keep enabled with local pool diagnostics.                                                   | working                             | lib/features/sync/mobile_sync_page.dart / \_uploadCedarFileNumbers, lib/features/sync/services/file_id_service.dart     |
| Upload/Sync Taxonomy Master Data            | Firestore taxonomy seeding/hydration pipeline.                                                                                 | Keep enabled and report partial failures safely.                                            | working                             | lib/features/sync/mobile_sync_page.dart / \_syncTaxonomyMasterDataForUpload, taxonomy providers/services                |
| تصدير التشخيص                               | Exports diagnostics JSON report from latest sync/taxonomy stats.                                                               | Keep enabled.                                                                               | working                             | lib/features/sync/mobile_sync_page.dart / \_exportSyncDiagnostics                                                       |
| سجل المزامنة                                | Opens history viewer.                                                                                                          | Keep enabled.                                                                               | working                             | lib/features/sync/mobile_sync_page.dart / app bar action                                                                |
| تحديث الإحصائيات                            | Triggered immediate refresh; no debounce/guard.                                                                                | Debounced/guarded refresh to avoid jank.                                                    | needs refactor (partially fixed)    | lib/features/sync/mobile_sync_page.dart / \_refreshDashboardData                                                        |
| مسح بيانات المستفيدين محلياً وإعادة التنزيل | Not present.                                                                                                                   | Add guarded reset + restore flow.                                                           | missing (added)                     | lib/features/sync/mobile_sync_page.dart / \_resetBeneficiariesAndRestore                                                |
| Reset التصنيفات فقط                         | Not present.                                                                                                                   | Add maintenance action.                                                                     | missing (added)                     | lib/features/sync/mobile_sync_page.dart / \_resetTaxonomiesOnly                                                         |
| Reset أرقام الملفات فقط                     | Not present.                                                                                                                   | Add maintenance action.                                                                     | missing (added)                     | lib/features/sync/mobile_sync_page.dart / \_resetFileNumbersOnly                                                        |

## Buttons Still Disabled Conditions

- All action buttons are disabled while sync is running (`status.isSyncing || syncProgress.isRunning`).
- This is correct for mutual exclusion.
- Problematic disable reason (fixed): sync-down path effectively disabled by demo guard in legacy service.

## WorkManager Calls

| Action          | WorkManager call                                                             | Notes                                                       |
| --------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Sync Down       | `BackgroundSyncWorker.triggerSyncDown()`                                     | Previously first attempt in page, then fallback foreground. |
| Full Sync       | `BackgroundSyncWorker.triggerManualSync()`                                   | Previously first attempt in page.                           |
| Sync Up one-off | `BackgroundSyncWorker.triggerSyncUp()` exists in worker, not primary on page | Upload on page already foreground Firebase.                 |

Observation:

- WorkManager itself is feature-flagged by `ENABLE_WORKMANAGER` and disabled by default.
- In Firebase mode, foreground sync is preferred and should not block if WorkManager is disabled.

## Demo Mode / Disabled Messages

### Legacy blockers found

- `lib/core/sync/mobile_sync_service.dart`:
  - `syncRecordByFileId()` logs `[DEMO MODE] ... disabled` and returns `demo_mode_disabled`.
  - `syncDown()` logs `[DEMO MODE] syncDown is disabled ...` and returns `demo_mode_disabled`.
  - `syncUp()` logs `[DEMO MODE] syncUp is disabled ...` and returns `demo_mode_disabled`.

### UI labels indicating disabled demo mode

- `lib/features/sync/mobile_sync_page.dart` had static info card lines:
  - `[DISABLED - demo mode]`
  - `[DISABLED]`
- Replaced with backend-aware Firebase labels in this phase.

## Old REST / Legacy Backend Calls

- MobileSyncService remains legacy REST-oriented (Dio + disabled base URL placeholder).
- `ApiConfig.defaultBaseUrl` and `AppConfig._defaultApiBaseUrl` still reference `https://disabled-api.example.com` (placeholder).
- Taxonomy/File-ID providers correctly gate legacy REST sync using explicit env flags + backend flavor checks.

## Firebase Actions Already Implemented

- Firebase Auth sign-in state and initialization.
- Firestore beneficiary upload (`beneficiaries` collection, deterministic doc id).
- File number confirmation (`file_number_allocations`).
- Taxonomy Firestore seed/hydration and diagnostics.
- File number pool management via Firestore block reservation and local pool merge.
- Attachment metadata upload for pending attachment rows.

## Missing Sync Actions (Before This Phase)

- Beneficiary Firebase sync-down with local merge/upsert and conflict policy.
- Local reset + restore flow for beneficiaries.
- Unified full sync sequencing strictly in Firebase mode.
- Firebase-centric dashboard metrics (remote count, last upload/download).

## UI Jank / Performance Risks Found

1. Frequent full dashboard refresh calls without throttle/guard.
2. Large page rebuild scope on sync status stream updates.
3. Progress updates could trigger dense rebuilds on each record event.
4. Remote metadata/count not cached.
5. Mixed diagnostic + operational widgets increase build cost in one tree.

Mitigations introduced in this phase:

- Dashboard refresh guard with short cooldown and in-flight lock.
- Chunked processing and `Future.delayed(Duration.zero)` yielding in upload/download loops.
- Progress batching every chunk in download service.
- Firebase metrics loaded explicitly and logged with structured tags.

## Files/Functions Most Responsible for Previous Blocker

- `lib/core/sync/mobile_sync_service.dart::syncDown`
- `lib/core/sync/mobile_sync_service.dart::syncUp`
- `lib/features/sync/mobile_sync_page.dart::_syncDown`
- `lib/features/sync/mobile_sync_page.dart::_syncNowOfficial`

## Notes on Local DB and Conflict Policy

- Beneficiaries table sync state values in use: `pending`, `modified`, `synced`, `failed`.
- In Firebase sync-down merge:
  - Local unsynced rows are preserved and treated as conflict/skip.
  - Synced rows can be updated from remote.
  - New remote rows are inserted.
  - Remote soft-deleted docs are skipped.

## Post-Rebuild Verification Targets

- No `[DEMO MODE] syncDown is disabled` path in Firebase sync page flows.
- Sync-down should restore beneficiaries after local reset.
- Upload remains idempotent and does not duplicate Firestore docs.
- Full sync should run in foreground safely when WorkManager is unavailable.

## Additional Implementation Notes (Current)

- Sync actions are now grouped into control-center cards:
  - رفع البيانات
  - تنزيل البيانات
  - التصنيفات
  - أرقام الملفات
  - أدوات الصيانة
- Added explicit maintenance checks:
  - Firestore connection check
  - Firestore permissions check (read/write probe)
- Full sync no longer re-enters button handlers in Firebase path; it executes upload/download directly to avoid nested progress resets.
- Sync-down now respects pending local delete tombstones and skips restoring matching remote records until delete sync resolves.
