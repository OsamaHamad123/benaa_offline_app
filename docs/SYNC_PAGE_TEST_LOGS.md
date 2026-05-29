# Sync Page Test Logs

Date: 2026-05-28
Environment: local dev build, BACKEND_FLAVOR=firebase

## Checklist Status

1. Save beneficiary locally

- Status: pending manual run
- Expected: pending upload count increases

2. Upload changes

- Status: pending manual run
- Expected: beneficiary appears in Firestore beneficiaries, file_number_allocations updated, local syncState=synced

3. Clear beneficiaries locally only

- Status: implemented, pending manual run
- Expected: local beneficiaries count -> 0, Firestore unchanged

4. Download data from Firebase

- Status: implemented, pending manual run
- Expected: previously uploaded beneficiary restored locally, syncState=synced

5. Upload again

- Status: pending manual run
- Expected: no duplicate docs (idempotent)

6. Full sync

- Status: implemented, pending manual run
- Expected: taxonomy ok, file numbers ok, upload ok, download ok, metrics refreshed

7. Network off during download

- Status: pending manual run
- Expected: operation pauses safely with retry path

8. Permission denied simulation

- Status: tools added, pending manual run
- Expected: clear Firestore rules message

9. Performance

- Status: partial improvements implemented, pending profiling
- Expected: no major UI freeze, reduced rebuild noise, no automatic sync loop on open

## Notes

- New maintenance actions available in Sync Page:
  - reset beneficiaries + restore from Firebase
  - reset taxonomies only
  - reset file number pool only
  - Firestore connection check
  - Firestore permissions check

- Foreground fallback is the primary path in Firebase mode.
