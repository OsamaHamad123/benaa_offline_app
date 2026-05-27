# File Number Test Logs

Date: 2026-05-28

## Status legend

- PASS: validated in runtime
- TODO: requires manual runtime validation on device

## Checklist results

1. Online first install

- TODO
- Expected: reserve block, local available = 500

2. Offline add beneficiary

- TODO
- Expected: unique local file number assigned, available decremented

3. Abandoned form (tentative)

- TODO
- Expected: tentative number released back to available

4. Multiple offline beneficiaries

- TODO
- Expected: no duplicates across all created records

5. Sync after offline

- TODO
- Expected: `file_number_allocations` docs created/updated, local status becomes synced

6. Low pool threshold

- TODO
- Expected: warning below 50, auto reserve below 100 when online

7. No pool

- TODO
- Expected: clear blocking message or draft flow

8. Conflict simulation

- TODO
- Expected: conflict marked locally, no overwrite

9. IBAN disabled

- TODO
- Expected: empty/non-standard IBAN does not block save; helper text shown

## Runtime evidence placeholders

- Sync screen should show:
  - "جاري حجز أرقام الملفات..."
  - "الأرقام المتاحة محلياً: ..."
  - "انقطع الاتصال، سيتم الاستكمال لاحقاً"

- Firestore evidence:
  - `file_number_counters/global_<year>` updated atomically
  - `file_number_blocks/<blockId>` created
  - `file_number_allocations/<fileNumber>` confirmed on sync

## Executed checks in this session

- `smoke-codes` task: FAIL (blocked)
- Reason: `Missing required email. Provide -Email or set BENAA_TEST_EMAIL.`
- Additional requirement: set both `BENAA_TEST_EMAIL` and `BENAA_TEST_PASSWORD` before rerun.
- Rerun with credentials and default script BaseUrl: FAIL
- Reason: `The remote name could not be resolved: 'disabled-api.example.com'`.
- Rerun with explicit BaseUrl `https://palestine.benaadev.org`: FAIL
- Reason: `The remote name could not be resolved: 'palestine.benaadev.org'`.
- Conclusion: smoke check is currently blocked by DNS/backend reachability from this environment.

## Implementation status (code-level)

- Added Sync Page action: `رفع أرقام الملفات الأساسية` (Upload Cedar File Numbers).
- Added foreground Cedar upload flow with progress phases:
  - `reserving_block`
  - `importing_local_pool`
  - `completed`
  - `failed`
- Added Firestore debug diagnostics for:
  - `file_number_counters`
  - `file_number_blocks`
  - `file_number_allocations`
- Added local pool status card (available/assigned/synced/conflicts/range).
- Added duplicate-check hardening to prevent Result cast crashes.
- Added save failure rollback for assigned file numbers before persistence.

## Runtime validation pending

- End-to-end validation of Cedar upload and beneficiary save remains pending because backend DNS is unreachable from this environment.
