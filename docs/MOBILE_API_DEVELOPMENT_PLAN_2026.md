# Mobile API Development Plan (Comprehensive)

Base Domain: https://disabled-api.example.com

API Prefix (from official docs): /api/mobile

Version: 1.0.0 (as documented)

---

## 0) Execution Status (Live)

### Completed in code

- ✅ Unified taxonomy networking with the authenticated core API client.
- ✅ Forced taxonomy provider invalidation after sync to reconnect form dropdowns.
- ✅ Added taxonomy diagnostics card in sync screen + compact dashboard status badge.
- ✅ Fixed beneficiary sync-down to import related entities (documents + family members + deceased) instead of importing only beneficiary core rows.
- ✅ Added post-login File ID orchestration (sync used reservation counters + ensure fresh reservation availability).
- ✅ Implemented server-aligned `codes/*` compatibility in mobile data layer with fallback to `file-ids/*` for backward compatibility.

### In progress

- 🔄 Backend payload-shape hardening for all relationship variants (nested vs `entities` list vs top-level keys).
- 🔄 Validation matrix execution for each endpoint group in production-like runtime.

### Next immediate milestones

1. Verify imported attachments appear in beneficiary attachments tab after `syncDown`.
2. Verify family members/deceased appear in beneficiary family tabs after `syncDown`.
3. Add payload-level diagnostic counters per page (`beneficiaries`, `attachments`, `family_members`, `dead_people`).

---

## 1) Current Diagnosis Summary

### What is working now

- Beneficiaries and sponsorship-related data are downloading.
- File ID routes are reachable (`/api/mobile/database/file-ids/*`).

### Root causes found for taxonomy issue

1. Taxonomy networking used a separate `Dio` client path, which could diverge from the authenticated main API client.
2. Even after successful taxonomy sync, bridge dropdown providers were not invalidated globally, so UI could keep stale empty values.
3. Historical endpoint drift existed (`/api/mobile/sync/*`); official docs indicate data endpoints under `/api/mobile/database/*` and categories under `/api/mobile/categories/*`.

### Fixes already applied in code

- Unified taxonomy `Dio` to use the same core authenticated `ApiClient.dio`.
- Added provider invalidation for all taxonomy group bridge providers after sync success.
- Aligned base URL handling to root domain and normalized old `/api` persisted config.
- Updated sync endpoint constants toward documented `/api/mobile/database/*` routes.

---

## 2) API Scope Coverage (from docs)

### A. Login Synchronization (Authentication)

Endpoints:

- `POST /api/mobile/auth/login`
- `GET /api/mobile/auth/validate`
- `POST /api/mobile/auth/refresh`
- `POST /api/mobile/auth/logout`
- `GET /api/mobile/profile`
- `GET /api/mobile/devices`

Implementation checklist:

- Persist `access_token`, `expires_at`, `device_id` in secure storage.
- On app start: offline validity check then optional refresh when near expiry.
- On any `401`: clear stale token and redirect to online auth flow.
- Track and display `token_expires_at` and remaining days in diagnostics screen.

Definition of done:

- 100% of authenticated API calls include Bearer token.
- No endpoint uses a separate unauthenticated client by mistake.

---

### B. Categories Synchronization (Full CRUD)

Primary endpoints:

- `GET /api/mobile/categories/sync-all`
- `GET /api/mobile/categories`
- `POST /api/mobile/categories`
- Category-specific sub-routes (e.g., provinces)

Implementation checklist:

- Use `sync-all` as primary full/delta source.
- Parse all category buckets to internal `TaxonomyGroup` mapping.
- Save in Drift as single source of truth.
- Invalidate all cached group providers after sync.
- Add a small diagnostics screen/card showing last taxonomy sync count/time.

Definition of done:

- Dropdowns across beneficiaries/visits/kafalat resolve from dynamic taxonomy values.
- No hardcoded list remains for supported groups.

---

### C. Central Database Synchronization

Endpoints:

- `GET /api/mobile/database/data`
- `POST /api/mobile/database/data/batch`
- Related entities endpoints (`re-people`, `dead-people`, attachments)

Implementation checklist:

- Keep paginated down-sync with robust parser for supported payload shapes.
- Up-sync via batch endpoint with idempotent local state transitions.
- Add explicit preflight check (`auth/validate`) before large sync sessions.
- Persist sync metadata (`last_success`, `last_error`, counts, duration).

Definition of done:

- Full sync down/up completes without fallback 404 probing in normal flow.
- Sync status UI reflects accurate counters and errors.

---

### D. Associations Synchronization (Sponsors/Employees)

Endpoints:

- `/api/mobile/associations/sponsors`
- `/api/mobile/associations/employees`
- `/api/mobile/associations/employees/batch`

Implementation checklist:

- Normalize DTOs and upsert semantics for local Drift entities.
- Use conflict policy and serverId mapping.
- Hook into global sync orchestration with separate step metrics.

Definition of done:

- Association dropdowns and lookups always sourced from synced local cache.

---

### E. Sponsorships Synchronization

Endpoints:

- `/api/mobile/sponsorships`
- `/api/mobile/sponsorships/batch`
- `/api/mobile/sponsorships/stats`
- `/api/mobile/sponsorships/by-identity/*`

Implementation checklist:

- Ensure sponsorship import/update consumes taxonomy type codes from categories.
- Add duplication guard (active sponsorship uniqueness rules).
- Keep status/transition mapping aligned with backend enums.

Definition of done:

- Sponsorship import and sync produce consistent counts with backend stats.

---

### F. Mobile Code Reservation System

Endpoints:

- `/api/mobile/codes/*`
- `/api/mobile/database/file-ids/reserve`
- `/api/mobile/database/file-ids/sync-used`

Implementation checklist:

- Reserve low-watermark strategy and background refill.
- Sync used IDs with retry/backoff and reconciliation report.
- Track reservation health in diagnostics panel.
- Trigger reservation orchestration right after successful login to reduce first-create failures.
- Use explicit used code payload (`codes[]`) when server exposes `/api/mobile/codes/confirm-usage`, with automatic fallback to count-based `file-ids/sync-used`.

Definition of done:

- No creation flow blocked due to missing local IDs while online.

---

### G. Persons File Download (Admin)

Endpoints:

- `/api/mobile/database/persons-file/info`
- `/api/mobile/database/persons-file/download`

Implementation checklist:

- Pre-download size/version check.
- Resumable or chunk-safe download strategy.
- Local file integrity/hash verification if provided.

Definition of done:

- Admin file download flow is deterministic, resumable, and validated.

---

## 3) Cross-Cutting Engineering Work

### Observability

- Standardized request log tags per module (`auth`, `taxonomy`, `sync`, `codes`).
- Persist last API error body per module for support diagnostics.
- Add one-click export for sync diagnostics.

### Reliability

- Exponential backoff + jitter for network/transient errors.
- Circuit-breaker style cool-down after repeated hard failures.
- Explicit fallback policy only where backend contract is uncertain.

### Data Integrity

- Drift transaction boundaries around batch sync writes.
- Server/local identity mapping and idempotent upsert rules.
- Sync metadata table with per-step checkpointing.

### UX

- Clear “what failed and why” messages (auth vs route vs validation).
- Manual retry controls per sync segment.
- Taxonomy freshness indicator where dropdowns depend on it.

---

## 4) Execution Phases

### Phase 1 (Stabilization)

- Freeze endpoints to documented routes only.
- Ensure all mobile API calls use unified authenticated Dio.
- Add mandatory taxonomy provider invalidation after sync.
- Acceptance: taxonomy dropdowns populate after first successful sync.

### Phase 2 (Coverage Completion)

- Implement/verify all modules A..G against docs.
- Remove legacy/unused route fallbacks once stable.
- Acceptance: end-to-end daily sync succeeds on clean install and existing users.

### Phase 3 (Hardening)

- Add diagnostics dashboard + exportable report.
- Add focused integration tests for critical sync paths.
- Acceptance: production-grade observability and faster incident triage.

---

## 5) Verification Matrix

For each endpoint group, verify:

- Route reachable (non-404)
- Auth behavior (401 when token missing, 200 with token)
- Validation behavior (422 payload contract)
- Parser compatibility with actual payload shape
- Local DB persistence and UI visibility

Recommended smoke run order:

1. login -> validate
2. categories/sync-all
3. database/data down-sync
4. file-ids reserve/sync-used
5. sponsorship batch/stat checks

---

## 6) Immediate Next Actions (short)

1. Run app, trigger taxonomy sync, confirm dropdowns now populate.
2. If taxonomy still empty, capture exact `categories/sync-all` response body for parser alignment.
3. Then finalize by removing no-longer-needed legacy sync fallbacks.
