# Firestore Beneficiary Upload Rules (Development)

Date: 2026-05-28

## Required development rules

Use authenticated access for beneficiary upload and file-number allocation confirmation:

```firestore
match /beneficiaries/{docId} {
  allow read, write: if request.auth != null;
}

match /file_number_allocations/{docId} {
  allow read, write: if request.auth != null;
}
```

## Current rule file

Rules are applied in:

- `firestore.rules`

## Deploy instructions

```bash
firebase deploy --only firestore:rules
```

## Verification checklist

1. Sign in from app using Firebase Auth.
2. Save beneficiary locally.
3. Tap `رفع التغييرات`.
4. Verify Firestore documents:
   - `beneficiaries/{beneficiaryRemoteId}` exists/updated.
   - `file_number_allocations/{fileNumber}` exists/updated with `status = synced`.
5. Re-tap upload and confirm no duplicate beneficiary docs are created.

## Production hardening note

These development rules are intentionally broad. For production:

1. Restrict writes by ownership/claims.
2. Validate required schema fields in rules.
3. Enforce least privilege for read scopes.
4. Enable and enforce App Check with proper providers.
