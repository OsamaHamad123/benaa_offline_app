# Beneficiary Details Flow Audit

Date: 2026-05-28
Scope: Beneficiary List -> Beneficiary Details -> Relations Tabs
Approach: minimal-safe changes, preserve existing local-first/offline architecture

## 1) Current Tap Behavior Audit

### List item tap behavior

- File reviewed: `lib/features/beneficiaries/presentation/pages/list_widgets/beneficiary_card_v2.dart`
- Result: card tap already routes directly to details when not in selection mode.
- Behavior source:
  - `InkWell.onTap` routes to `/beneficiaries/{id}` by default.

### Explicit direct-navigation hardening

- File changed: `lib/features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart`
- Change: explicit `onTap` passed to `BeneficiaryCardV2` in both list and grid builders.
- Why: removes ambiguity from wrapper widgets and guarantees direct navigation path at call-site level.

## 2) Where the "3 options" behavior can come from

- No evidence found that primary card tap opens a 3-option chooser in the list flow.
- Existing alternative action surfaces are:
  - trailing popup actions inside card (call/whatsapp/edit/delete)
  - swipe gestures (edit/delete)
- Conclusion: if a 3-option prompt was seen, it is not produced by the main list-item tap path audited here.

## 3) Details / Relations Routing Audit

### Existing routes

- `/beneficiaries/:id` -> `BeneficiaryDetailsPageV2`
- `/beneficiaries/:id/relations` -> `BeneficiaryRelationsTabsPage`

### Details page action

- File reviewed: `lib/features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart`
- Result: app bar menu includes `relations` action and routes correctly to `/beneficiaries/{id}/relations`.

## 4) Real Data Linking Audit (Sponsorships / Visits / Follow-ups / Documents)

### Sponsorships

- Source: Drift DAO `watchSponsorshipsForBeneficiary(localId)`.
- Mapping key: local beneficiary id (int).
- Add flow: `SponsorshipFormSheet(beneficiaryId: localId)`.

### Visits

- Sources merged:
  - local Drift visits table (`visitsDao.getBeneficiaryVisits(localId as string)`)
  - local Firestore cache collection `beneficiary_visits` fallback.
- Matching strategy:
  - `beneficiaryId`, `beneficiaryLocalId`, `beneficiaryRemoteId`, `beneficiaryFileNumber`
  - values matched against resolved candidate set `{localId, remoteId?, fileNumber?}`.

### Follow-ups

- Source: local Firestore cache collection `beneficiary_followups`.
- Matching strategy: same candidate-id strategy as visits.

### Documents

- Source: `attachmentsProvider(localId.toString())`.
- Actions: list in-tab + open full attachments page.

## 5) Identity Mismatch Handling Audit

- Resolver used: `BeneficiaryIdentityResolver` to normalize incoming route id to local id.
- Candidate-id set introduced in relations flow to bridge mixed schemas (local/remote/file identifiers).
- Impact: reduces false-empty tabs when older/newer data uses different beneficiary key fields.

## 6) Minimal Safe Changes Applied

1. Replaced placeholder relations tabs page with real tabs and real data providers.
2. Kept existing forms and DAOs; no schema migration introduced.
3. Added explicit direct-navigation `onTap` in beneficiaries list/grid cards.
4. Preserved details page as primary profile page; relations opened as dedicated tabs page.

## 7) Residual Risks

1. Firestore cache payload fields are not fully standardized across all historical rows; fallback matching mitigates but cannot guarantee perfect linkage for malformed payloads.
2. Visits from different legacy sources may still differ in field completeness (summary/status/visit type quality).
3. Runtime smoke validation is blocked without required environment credentials.

## 8) Recommendation

- Keep the current minimal patch set.
- Add a small normalization layer at sync-write boundaries so all visit/follow-up payloads always include:
  - `beneficiaryLocalId`, `beneficiaryRemoteId`, `beneficiaryFileNumber`.
- Then linkage can be simplified and made fully deterministic.
