# FIRESTORE ASSOCIATIONS / SPONSORSHIPS / VISITS RULES

Development rules added for authenticated users:

```rules
match /associations/{docId} {
  allow read, write: if request.auth != null;
}

match /association_contacts/{docId} {
  allow read, write: if request.auth != null;
}

match /sponsorship_files/{docId} {
  allow read, write: if request.auth != null;
}

match /sponsorship_candidates/{docId} {
  allow read, write: if request.auth != null;
}

match /sponsorships/{docId} {
  allow read, write: if request.auth != null;
}

match /sponsorship_payments/{docId} {
  allow read, write: if request.auth != null;
}

match /beneficiary_visits/{docId} {
  allow read, write: if request.auth != null;
}

match /beneficiary_followups/{docId} {
  allow read, write: if request.auth != null;
}

match /sync_health_checks/{docId} {
  allow read, write: if request.auth != null;
}
```

Notes:

- These are development-friendly rules.
- Production hardening should add role-based constraints, ownership scoping, and field validation.
