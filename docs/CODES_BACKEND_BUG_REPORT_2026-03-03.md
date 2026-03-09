# Backend Bug Report - Mobile Codes Assignment Inconsistency

Date: 2026-03-03
Environment: Production
Base URL: https://palestine.benaadev.org
Reporter: Mobile App Team

## Summary

There is a backend inconsistency in the mobile codes reservation flow:

- Codes batch is active and contains available codes.
- Endpoint GET /api/mobile/codes/available returns real available codes.
- But endpoints POST /api/mobile/codes/login-sync and POST /api/mobile/codes/request-codes do not assign codes.
- request-codes returns 404 no_codes_available even while stats/available confirm 5000 available codes.

This is server-side assignment logic issue, not mobile client payload issue.

## Reproduction Credentials

- username: admin@gmail.com
- password: password

## Reproduction Steps (Exact)

1. Login via POST /api/mobile/auth/login.
2. Check active batch via GET /api/mobile/codes/batch/active.
3. Check global stats via GET /api/mobile/codes/stats.
4. Check available list via GET /api/mobile/codes/available?count=5.
5. Run login sync for a fresh device via POST /api/mobile/codes/login-sync with:
   {
   "device_id": "<fresh-device-id>",
   "device_codes": []
   }
6. Request codes via POST /api/mobile/codes/request-codes with:
   {
   "device_id": "<same-device-id>",
   "count": 1
   }

## Actual Results (Observed)

- GET /api/mobile/codes/batch/active -> 200
  - batch.status = active
  - batch.available_count = 5000
- GET /api/mobile/codes/stats -> 200
  - data.codes.total = 5000
  - data.codes.available = 5000
- GET /api/mobile/codes/available?count=5 -> 200
  - returns real codes: 000003, 000004, 000005, ...
- POST /api/mobile/codes/login-sync -> 200
  - data.new_codes_count = 0
  - device total_assigned = 0
- POST /api/mobile/codes/request-codes -> 404
  - error = no_codes_available

## Expected Results

For a fresh device with no assigned codes and an active batch with available codes:

- login-sync should assign up to max allowed device codes (or at least > 0).
- request-codes should return 200 with assigned codes (not 404 no_codes_available).

## Why This Is Backend Bug

The same backend confirms codes exist and are available through:

- /codes/stats
- /codes/available

So inventory exists, but assignment endpoints behave as if inventory is empty.
This indicates mismatch in backend filtering/assignment query or batch selection logic.

## Most Likely Backend Root Causes

1. Assignment query excludes valid rows (wrong where clauses):
   - checks is_used/device_id/synced incorrectly
   - filters by wrong batch status or expiration timezone
2. request-codes and available endpoints do not use same source query.
3. Transaction race/locking causing assignment selection to return empty.
4. Device limit check uses wrong field (counts assigned/unused incorrectly).
5. Soft-delete/global scope excludes rows in assignment path but not in available path.

## Backend Checks Recommended

1. Compare SQL used by:
   - GET /codes/available
   - POST /codes/request-codes
   - POST /codes/login-sync
2. Verify active batch selection condition exactly matches available endpoint.
3. Log assignment candidate count before return in request-codes/login-sync.
4. Log device current totals used by can_request_more and max limit checks.
5. Verify expiration timezone conversion at query layer.
6. Verify no hidden scope (tenant, guard, deleted_at, mobile flag) applied only on assignment endpoints.

## Temporary Workaround

Not possible on mobile side while backend returns no_codes_available for assignment endpoints.
Mobile app already sends contract-correct payloads and handles errors correctly.

## Evidence Files

- scripts/codes_e2e_report_1772526369.json
- scripts/codes_e2e_report_1772526393.json

## Additional Note

Batch creation succeeded (201) and batch became active (200), but assignment still failed afterward for fresh devices. This confirms issue persists after provisioning codes.
