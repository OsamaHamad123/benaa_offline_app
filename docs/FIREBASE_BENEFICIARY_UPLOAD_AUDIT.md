# Firebase Beneficiary Upload Audit

Date: 2026-05-28

## Scope

This audit reviews the current local save path, pending upload detection, current upload logic, Firestore mapping availability, and file-number confirmation path for beneficiary upload.

## 1) Current local save path

- New beneficiary save flow is handled in `lib/features/beneficiaries/presentation/providers/beneficiary_form_provider.dart`.
- Save is local-first:
  - Assigns local file number from local pool via `FileIdService.getNextFileNumber()`.
  - Persists beneficiary locally through create use case/repository.
  - On local save failure after assignment, releases assigned file number via `FileIdService.releaseAssignedFileNumber()`.
- Beneficiary persistence path:
  - Provider -> use case -> repository (`beneficiary_repository_impl.dart`) -> local datasource (`beneficiary_local_datasource.dart`) -> Drift table (`beneficiaries`).

## 2) Where newly saved beneficiaries are stored locally

- Drift table: `beneficiaries` in `lib/data/db/tables/beneficiaries_table.dart`.
- Important sync columns already exist:
  - `sync_state` (default `pending`)
  - `server_id` (nullable int)
  - `last_synced_at` (nullable datetime)
- Repository currently sets new/updated beneficiaries to local needs-sync state, which maps to `sync_state = 'pending'`.

## 2.1) Requested field audit matrix

| Requested field | Current equivalent in code/database                        | Status                                         |
| --------------- | ---------------------------------------------------------- | ---------------------------------------------- |
| `syncStatus`    | `beneficiaries.sync_state`                                 | Exists                                         |
| `isSynced`      | Derived as `sync_state == 'synced'`                        | Derived                                        |
| `pendingUpload` | Derived as `sync_state IN ('pending','modified','failed')` | Derived                                        |
| `dirty`         | Equivalent behavior via `modified`/`failed` states         | Partial                                        |
| `createdAt`     | `beneficiaries.created_at`                                 | Exists                                         |
| `updatedAt`     | `beneficiaries.updated_at`                                 | Exists                                         |
| `localId`       | `beneficiaries.id` (local auto-increment int)              | Exists                                         |
| `remoteId`      | `beneficiaries.server_id` (legacy int; nullable)           | Partial (string remote id not explicit column) |
| `fileIdNumber`  | `beneficiaries.file_id_number`                             | Exists                                         |
| `fileNumber`    | Domain alias around `fileNo/fileIdNumber`                  | Exists via mapping                             |

## 3) Pending upload detection

Current available status model in local DB:

- Beneficiary pending-like states observed in code and sync stack:
  - `pending`
  - `modified`
  - `failed`

Current detection status before this implementation:

- No dedicated Firebase beneficiary upload service existed to fetch pending beneficiaries for Firestore upload.
- Existing sync screens showed sync progress, but the upload button was still tied to the legacy/disabled sync-up path.

## 4) Firestore mapper availability

- Firestore mapper exists:
  - `lib/core/backend/mappers/beneficiary_firestore_mapper.dart`
- It already maps beneficiary domain fields to a Firestore-friendly payload.
- Existing generic Firestore service exists:
  - `lib/core/backend/firebase/firebase_firestore_service.dart`

## 5) Current upload logic (before this phase)

- `Upload Changes` button in `lib/features/sync/mobile_sync_page.dart` called `MobileSyncService.syncUp()`.
- In `lib/core/sync/mobile_sync_service.dart`, sync-up path is marked disabled in demo/public mode and returns `demo_mode_disabled`.
- Result: upload button did not perform real Firebase beneficiary upload.

## 6) Whether upload was using old REST or Firebase

- Current in-place sync architecture still contains legacy REST/batch sync flows in `MobileSyncService`.
- The active `syncUp()` entry returned disabled demo response in this environment, not Firebase beneficiary upload.
- Firebase beneficiary upload path was missing as a dedicated active flow.

## 7) Local sync marking after upload

Before this phase:

- No dedicated Firebase upload flow existed to consistently mark uploaded beneficiaries as `synced` in local table after successful Firestore write.

## 8) File number confirmation after beneficiary upload

- File-number reservation/confirmation foundation exists in:
  - `lib/features/sync/services/file_id_service.dart`
  - `lib/features/sync/data/services/firestore_file_number_service.dart`
- However, confirmation tied to beneficiary Firebase upload was not wired as an explicit per-beneficiary upload step.

## 9) Missing parts identified

1. Missing dedicated service for Firebase beneficiary upload from pending local records.
2. Missing deterministic idempotent remote ID strategy in active upload button path.
3. Missing active button wiring from `Upload Changes` to Firebase beneficiary upload.
4. Missing local beneficiary status updates (`synced`/`failed`) in Firebase upload path.
5. Missing explicit file-number allocation confirmation right after each successful beneficiary upload.
6. Missing upload summary card focused on beneficiary upload results.
7. Missing explicit beneficiary upload rules documentation file.

## 10) Exact files to modify

Primary implementation files:

1. `lib/features/sync/services/firebase_beneficiary_upload_service.dart` (new)
2. `lib/features/sync/presentation/providers/mobile_sync_operations_providers.dart`
3. `lib/features/sync/mobile_sync_page.dart`
4. `firestore.rules`

Documentation files:

1. `docs/FIREBASE_BENEFICIARY_UPLOAD_AUDIT.md` (this file)
2. `docs/FIRESTORE_BENEFICIARY_UPLOAD_RULES.md` (new)

## 11) Sync-down note

- Full sync-down for beneficiaries is intentionally deferred.
- Existing architecture should preserve unsynced local changes and avoid destructive overwrite during future merge design.
- A dedicated sync-down strategy doc should be added in the next phase.
