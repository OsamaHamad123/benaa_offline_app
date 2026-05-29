# SYNC MODULE REGISTRY

**Date:** 2026-05-28  
**Phase:** Sync & Firebase Pipeline Stabilization  
**Status:** Initial Inventory

> This is an inventory document only. No module redesign in this phase.

---

## Legend

| Column               | Meaning                                   |
| -------------------- | ----------------------------------------- |
| Local Table          | Drift SQLite table                        |
| Firestore Collection | Firestore top-level collection            |
| Upload               | Upload supported in this phase            |
| Download             | Download supported in this phase          |
| Pending Count        | Included in pending total                 |
| Last Sync Marker     | Sync timestamp tracked in `sync_metadata` |
| Error Logging        | Quality of error logging                  |
| Tests                | Dedicated tests exist                     |

---

## Beneficiary Modules

### beneficiaries

| Field                | Value                                                                           |
| -------------------- | ------------------------------------------------------------------------------- |
| Local Table          | `beneficiaries` (Drift)                                                         |
| Firestore Collection | `beneficiaries`                                                                 |
| Upload               | ✅ Yes — `FirebaseBeneficiaryUploadService.uploadPendingBeneficiaries()`        |
| Download             | ✅ Yes — `FirebaseBeneficiaryUploadService.syncDownBeneficiariesFromFirebase()` |
| Pending Count        | ✅ Yes — counted in `SyncCollectionRegistry`                                    |
| Last Sync Marker     | ✅ `beneficiaries_upload`, `beneficiaries_download`                             |
| Error Logging        | ✅ Good — per-beneficiary failure with `BeneficiaryUploadFailure` list          |
| Tests                | ✅ sync_safety_test.dart (reset tests), partial in existing tests               |

### beneficiary_visits

| Field                | Value                                                                                                               |
| -------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Local Table          | `visits` (Drift)                                                                                                    |
| Firestore Collection | `beneficiary_visits`                                                                                                |
| Upload               | ✅ Yes — `VisitFirestoreRepository.uploadPendingVisits()` → `SyncFirestoreModulesUseCase.uploadAll()`               |
| Download             | ✅ Yes — `VisitFirestoreRepository.downloadVisits()` → `SyncFirestoreModulesUseCase.downloadAll()` (full sync only) |
| Pending Count        | ✅ Yes — counted in `SyncCollectionRegistry`                                                                        |
| Last Sync Marker     | ✅ `visit_upload` in `syncMetadataDao`                                                                              |
| Error Logging        | ⚠️ Module-level only — `e.toString()` without LogSanitizer                                                          |
| Tests                | ❌ None dedicated                                                                                                   |

### beneficiary_followups

| Field                | Value                                                                                                    |
| -------------------- | -------------------------------------------------------------------------------------------------------- |
| Local Table          | `visits` / sidecar (`firecache_beneficiary_followups`)                                                   |
| Firestore Collection | `beneficiary_followups`                                                                                  |
| Upload               | ✅ Yes — `VisitFirestoreRepository.uploadPendingFollowups()` → `SyncFirestoreModulesUseCase.uploadAll()` |
| Download             | ✅ Yes — `VisitFirestoreRepository.downloadFollowups()` → full sync only                                 |
| Pending Count        | ✅ Yes — sidecar counted                                                                                 |
| Last Sync Marker     | ✅ `followup_upload`                                                                                     |
| Error Logging        | ⚠️ Module-level only — no LogSanitizer                                                                   |
| Tests                | ❌ None dedicated                                                                                        |

### beneficiary_documents (attachments)

| Field                | Value                                                                                |
| -------------------- | ------------------------------------------------------------------------------------ |
| Local Table          | `attachments` (subcollection of beneficiaries in Firebase)                           |
| Firestore Collection | `beneficiaries/{id}/attachments` (subcollection)                                     |
| Upload               | ⚠️ Partial — metadata uploaded as part of beneficiary upload flow                    |
| Download             | ⚠️ Partial — metadata included in beneficiary download; binary download is on-demand |
| Pending Count        | ❌ Not counted separately                                                            |
| Last Sync Marker     | ❌ None dedicated                                                                    |
| Error Logging        | ⚠️ Basic                                                                             |
| Tests                | ❌ None dedicated                                                                    |

### family_members

| Field                | Value                                                      |
| -------------------- | ---------------------------------------------------------- |
| Local Table          | `re_people` (Drift)                                        |
| Firestore Collection | `beneficiaries/{id}/family_members` (subcollection)        |
| Upload               | ⚠️ Partial — via legacy MobileSyncService (REST mode only) |
| Download             | ✅ Included in beneficiary download (sub-document)         |
| Pending Count        | ❌ Not counted separately                                  |
| Last Sync Marker     | ❌ None                                                    |
| Error Logging        | ⚠️ Basic                                                   |
| Tests                | ❌ None                                                    |

---

## Sponsorship / Kafalat Modules

### sponsorships

| Field                | Value                                                |
| -------------------- | ---------------------------------------------------- |
| Local Table          | `sponsorships` (Drift)                               |
| Firestore Collection | `sponsorships`                                       |
| Upload               | ✅ Yes — `SponsorshipRepository.uploadPendingCore()` |
| Download             | ✅ Yes — `SponsorshipRepository.downloadCore()`      |
| Pending Count        | ✅ Yes — Drift rows counted                          |
| Last Sync Marker     | ✅ `sponsorship_upload`                              |
| Error Logging        | ⚠️ Module-level — no LogSanitizer on errors          |
| Tests                | ❌ None dedicated                                    |

> **Firestore rules risk:** `sponsorships` write is admin-only. Field_worker uploads will fail in production rules.  
> In current dev rules, `sponsorships` has `allow create: if isAdmin()` — this blocks upload for normal users.

### sponsorship_files

| Field                | Value                                                               |
| -------------------- | ------------------------------------------------------------------- |
| Local Table          | Sidecar `firecache_sponsorship_files`                               |
| Firestore Collection | `sponsorship_files`                                                 |
| Upload               | ✅ Sidecar queue                                                    |
| Download             | ❌ Not explicitly downloaded (included in `downloadCore` aggregate) |
| Pending Count        | ✅ Sidecar counted                                                  |
| Last Sync Marker     | ✅ `sponsorship_upload`                                             |
| Error Logging        | ⚠️ Basic                                                            |
| Tests                | ❌ None                                                             |

### sponsorship_candidates

| Field                | Value                                      |
| -------------------- | ------------------------------------------ |
| Local Table          | Sidecar `firecache_sponsorship_candidates` |
| Firestore Collection | `sponsorship_candidates`                   |
| Upload               | ✅ Sidecar queue                           |
| Download             | ❌ Not separately                          |
| Pending Count        | ✅ Sidecar counted                         |
| Last Sync Marker     | ✅ `sponsorship_upload`                    |
| Error Logging        | ⚠️ Basic                                   |
| Tests                | ❌ None                                    |

### sponsorship_payments

| Field                | Value                                    |
| -------------------- | ---------------------------------------- |
| Local Table          | Sidecar `firecache_sponsorship_payments` |
| Firestore Collection | `sponsorship_payments`                   |
| Upload               | ✅ Sidecar queue                         |
| Download             | ❌ Not separately                        |
| Pending Count        | ✅ Sidecar counted                       |
| Last Sync Marker     | ✅ `sponsorship_upload`                  |
| Error Logging        | ⚠️ Basic                                 |
| Tests                | ❌ None                                  |

---

## Associations Modules

### associations

| Field                | Value                                                                 |
| -------------------- | --------------------------------------------------------------------- |
| Local Table          | `associations` (Drift)                                                |
| Firestore Collection | `associations`                                                        |
| Upload               | ✅ Yes — `AssociationFirestoreRepository.uploadPendingAssociations()` |
| Download             | ✅ Yes — `AssociationFirestoreRepository.downloadAssociations()`      |
| Pending Count        | ✅ Drift rows counted                                                 |
| Last Sync Marker     | ✅ `association_upload`                                               |
| Error Logging        | ⚠️ Module-level — no LogSanitizer                                     |
| Tests                | ❌ None dedicated                                                     |

> **Firestore rules risk:** `associations` write is admin-only. Same concern as sponsorships.

### association_contacts

| Field                | Value                                                                            |
| -------------------- | -------------------------------------------------------------------------------- |
| Local Table          | Sidecar `firecache_association_contacts` + `association_representatives` (Drift) |
| Firestore Collection | `association_contacts`                                                           |
| Upload               | ✅ `AssociationFirestoreRepository.uploadPendingContacts()`                      |
| Download             | ✅ `AssociationFirestoreRepository.downloadAssociationContacts()`                |
| Pending Count        | ✅ Sidecar counted                                                               |
| Last Sync Marker     | ✅ `association_contacts_upload`                                                 |
| Error Logging        | ⚠️ Module-level                                                                  |
| Tests                | ❌ None                                                                          |

---

## Taxonomy Modules

### taxonomy_categories

| Field                | Value                                |
| -------------------- | ------------------------------------ |
| Local Table          | `taxonomies` (Drift)                 |
| Firestore Collection | `taxonomy_categories`                |
| Upload               | ✅ Via taxonomy seed/sync providers  |
| Download             | ✅ `TaxonomySyncNotifier.sync()`     |
| Pending Count        | ❌ Not in unified pending count      |
| Last Sync Marker     | ✅ Taxonomy-specific sync time       |
| Error Logging        | ⚠️ Basic via provider errors         |
| Tests                | Partial via taxonomy_providers tests |

### taxonomy_groups

| Field                | Value                     |
| -------------------- | ------------------------- |
| Local Table          | `taxonomies` (Drift)      |
| Firestore Collection | `taxonomy_groups`         |
| Upload               | ⚠️ Same as above          |
| Download             | ⚠️ Same as above          |
| Pending Count        | ❌ Not in unified pending |
| Last Sync Marker     | ❌ None separate          |
| Error Logging        | ⚠️ Basic                  |
| Tests                | Partial                   |

---

## File Number Modules

### file_number_counters

| Field                | Value                                          |
| -------------------- | ---------------------------------------------- |
| Local Table          | N/A (read-only from Firestore)                 |
| Firestore Collection | `file_number_counters`                         |
| Upload               | ⚠️ Read + atomic increment only                |
| Download             | ✅ Read during reservation                     |
| Pending Count        | ❌ Not applicable                              |
| Last Sync Marker     | ❌ None                                        |
| Error Logging        | ⚠️ Basic — uses LogSanitizer for error masking |
| Tests                | ❌ None dedicated                              |

### file_number_blocks

| Field                | Value                                                         |
| -------------------- | ------------------------------------------------------------- |
| Local Table          | `file_number_pool` or `file_id_reservations` (Drift)          |
| Firestore Collection | `file_number_blocks`                                          |
| Upload               | ✅ Written during reservation (`uploadCedarFileNumbers`)      |
| Download             | ✅ Read during `syncDownFileNumberState()`                    |
| Pending Count        | ❌ Not in upload pending                                      |
| Last Sync Marker     | ❌ None                                                       |
| Error Logging        | ⚠️ Uses LogSanitizer (LogSanitizer imported in FileIdService) |
| Tests                | ❌ None for composite index safety                            |

> **Known risk:** Query `file_number_blocks` where `deviceId == X AND userId == Y orderBy reservedAt desc` requires composite Firestore index.  
> **Fix option:** Remove remote `orderBy`, sort locally.

### file_number_allocations

| Field                | Value                            |
| -------------------- | -------------------------------- |
| Local Table          | `file_ids` (Drift)               |
| Firestore Collection | `file_number_allocations`        |
| Upload               | ✅ During reservation            |
| Download             | ⚠️ Read during confirmation flow |
| Pending Count        | ❌ Not in unified pending        |
| Last Sync Marker     | ❌ None                          |
| Error Logging        | ⚠️ Basic                         |
| Tests                | ❌ None                          |

---

## Sync Infrastructure Modules

### sync_health_checks

| Field                | Value                                          |
| -------------------- | ---------------------------------------------- |
| Local Table          | N/A                                            |
| Firestore Collection | `sync_health_checks`                           |
| Upload               | ✅ Written during `runFirestoreHealthChecks()` |
| Download             | ✅ Read during health check                    |
| Pending Count        | ❌ Not applicable                              |
| Last Sync Marker     | ❌ None                                        |
| Error Logging        | ✅ Good — read/write errors surfaced to UI     |
| Tests                | ❌ None dedicated                              |

### sync_logs (app log export)

| Field                | Value                                    |
| -------------------- | ---------------------------------------- |
| Local Table          | N/A                                      |
| Firestore Collection | Not used — logs exported locally as JSON |
| Upload               | ❌ Not uploaded to Firestore             |
| Download             | ❌ N/A                                   |
| Pending Count        | ❌ N/A                                   |
| Tests                | ❌ N/A                                   |

---

## Summary Matrix

| Module                  | Upload       | Download       | Pending Counted | Error Logging        | Tests   |
| ----------------------- | ------------ | -------------- | --------------- | -------------------- | ------- |
| beneficiaries           | ✅           | ✅             | ✅              | ✅ Good              | Partial |
| beneficiary_visits      | ✅           | ✅ (full sync) | ✅              | ⚠️ No sanitizer      | ❌      |
| beneficiary_followups   | ✅           | ✅ (full sync) | ✅              | ⚠️ No sanitizer      | ❌      |
| beneficiary_documents   | ⚠️ Partial   | ⚠️ Partial     | ❌              | ⚠️ Basic             | ❌      |
| family_members          | ⚠️ REST only | ✅ sub-doc     | ❌              | ⚠️ Basic             | ❌      |
| sponsorships            | ✅           | ✅ (full sync) | ✅              | ⚠️ No sanitizer      | ❌      |
| sponsorship_files       | ✅ Sidecar   | ❌             | ✅              | ⚠️ Basic             | ❌      |
| sponsorship_candidates  | ✅ Sidecar   | ❌             | ✅              | ⚠️ Basic             | ❌      |
| sponsorship_payments    | ✅ Sidecar   | ❌             | ✅              | ⚠️ Basic             | ❌      |
| associations            | ✅           | ✅ (full sync) | ✅              | ⚠️ No sanitizer      | ❌      |
| association_contacts    | ✅           | ✅ (full sync) | ✅              | ⚠️ No sanitizer      | ❌      |
| taxonomy_categories     | ✅           | ✅             | ❌              | ⚠️ Basic             | Partial |
| taxonomy_groups         | ⚠️           | ⚠️             | ❌              | ⚠️ Basic             | Partial |
| file_number_counters    | ✅ R/W       | ✅             | ❌              | ⚠️ Partial sanitizer | ❌      |
| file_number_blocks      | ✅           | ✅             | ❌              | ⚠️ Partial sanitizer | ❌      |
| file_number_allocations | ✅           | ⚠️             | ❌              | ⚠️ Basic             | ❌      |
| sync_health_checks      | ✅           | ✅             | ❌              | ✅ Good              | ❌      |
