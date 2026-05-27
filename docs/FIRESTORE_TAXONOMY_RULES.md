# Firestore Taxonomy Rules

## Development Rules

Use the following rules during development to allow authenticated access for taxonomy operations:

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /taxonomy_categories/{docId} {
      allow read, write: if request.auth != null;
    }

    match /taxonomy_categories/{docId}/{subCollection=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Production Guidance

For production, replace broad `read, write` access with least-privilege authorization checks.

Recommended steps:

1. Restrict writes to trusted roles or custom claims.
2. Restrict reads to only required user scopes.
3. Validate document schema fields in rules.
4. Keep App Check enabled with proper provider setup.
5. Audit denied requests in Firestore logs before rollout.
