# Associations / Sponsorships / Visits Test Logs

Date: 2026-05-28
Mode: implementation + static verification

## Checklist

1. Create association offline.

- Status: Implemented path exists via `AssociationFirestoreService.upsertAssociationLocal`.
- Expected: `sync_status = pending_upload` in local cache table `associations`.

2. Upload associations.

- Status: Implemented path exists via `uploadPendingAssociations`.
- Expected: Firestore `associations` contains record.

3. Create sponsorship file manually.

- Status: Implemented path exists via `upsertSponsorshipFileLocal`.
- Expected: local cache `sponsorship_files` row created.

4. Add candidate from association.

- Status: Implemented path exists via `upsertCandidateLocal`.
- Expected: local cache `sponsorship_candidates` row created.

5. Match candidate to existing beneficiary.

- Status: Implemented path exists via `runCandidateMatching`.
- Matching priority implemented:
  - nationalId exact match
  - phone exact + name similarity
  - normalized Arabic name + city
  - manual review fallback

6. Create beneficiary from unmatched candidate.

- Status: Implemented path exists via `createBeneficiaryFromCandidate`.
- Expected:
  - new beneficiary local row with Cedar file number
  - candidate status updated to `created_new_beneficiary`
  - local sponsorship record created

7. Create sponsorship for beneficiary.

- Status: Implemented local upsert + module upload path.
- Expected: `sponsorships` synced to Firestore.

8. Schedule visit.

- Status: Implemented via `upsertVisitLocal`.
- Expected: local `beneficiary_visits` row created.

9. Complete visit with nextVisitAt.

- Status: Implemented auto-followup in `VisitFirestoreService.upsertVisitLocal`.
- Expected: local `beneficiary_followups` row created.

10. Full sync.

- Status: Integrated in Firebase full sync flow (`_syncNowOfficial`) with module upload/download steps.
- Expected: all new collections participate in full sync.

## Execution note

- Runtime/integration tests were not executed in this change set.
- This document is an implementation log and ready for QA run in device environment.

## Practical QA Run (2026-05-28)

1. Smoke contract task

- Command:
  `powershell -ExecutionPolicy Bypass -File .\scripts\smoke_codes_contract.ps1 -DeviceId copilot-smoke-device-final -RequestCount 1`
- Result: FAIL (exit code 1)
- Output summary:
  `SMOKE RESULT => FAIL | Missing required email. Provide -Email or set BENAA_TEST_EMAIL.`
- Interpretation:
  smoke run is blocked by missing environment credentials (`BENAA_TEST_EMAIL` and likely `BENAA_TEST_PASSWORD`).

2. Code-level verification after UI wiring

- Checked files:
  - `lib/features/beneficiaries/presentation/pages/beneficiary_relations_tabs_page.dart`
  - `lib/features/beneficiaries/presentation/pages/details_widgets/sections/action_buttons.dart`
  - `lib/features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart`
  - `lib/routing/app_router.dart`
- Result: no analyzer errors reported in these files.

3. UI wiring delta validated

- Added beneficiary relations tab page (sponsorships/visits tabs).
- Added route: `/beneficiaries/:id/relations`.
- Added action button from beneficiary details to open relations tabs.
- Added routes for stubs:
  - `/associations/firestore`
  - `/sponsorships/files`
  - `/sponsorships/candidates/review`
  - `/followups/dashboard`
