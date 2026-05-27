# Firestore File Number Rules (Development)

## Added collections

- `file_number_counters`

## Publish instructions

1. Ensure the following blocks exist in `firestore.rules`:

```firestore
match /file_number_counters/{docId} {
  allow read, write: if request.auth != null;
}

match /file_number_blocks/{docId} {
  allow read, write: if request.auth != null;
}

match /file_number_allocations/{docId} {
  allow read, write: if request.auth != null;
}
```

2. Deploy rules:

```bash
firebase deploy --only firestore:rules
```

3. Verify in Firebase Console:

- `file_number_counters/global_2026`
- `file_number_blocks/*`
- `file_number_allocations/*`

- `file_number_blocks`
- `file_number_allocations`

```firestore
match /file_number_counters/{docId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}

match /file_number_blocks/{docId} {
  allow read, write: if request.auth != null;
}

match /file_number_allocations/{docId} {
  allow read, write: if request.auth != null;
}
```

## Notes

- These are intentionally permissive for development/testing.
- Before production hardening, tighten by device/user ownership checks and field-level validation.
- Source of truth currently applied in `firestore.rules`.
