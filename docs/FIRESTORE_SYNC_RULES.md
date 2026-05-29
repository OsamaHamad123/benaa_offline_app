# Firestore Sync Rules (Firebase Sync Control Center)

Date: 2026-05-28

## Goal

Allow authenticated app users to:

- upload beneficiaries
- download beneficiaries
- confirm file number allocations
- read taxonomy master data

while blocking unauthenticated access and unsafe writes.

## Suggested Rules (Starter)

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwnerOrService() {
      return isSignedIn();
    }

    match /beneficiaries/{beneficiaryId} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false; // use soft delete fields instead (isDeleted/deletedAt)

      match /attachments/{attachmentId} {
        allow read: if isSignedIn();
        allow create, update: if isOwnerOrService();
        allow delete: if false;
      }

      match /visits/{visitId} {
        allow read: if isSignedIn();
        allow create, update: if isOwnerOrService();
        allow delete: if false;
      }
    }

    match /file_number_allocations/{fileNumber} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false;
    }

    match /file_number_blocks/{blockId} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false;
    }

    match /file_number_counters/{counterId} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false;
    }

    match /sync_health_checks/{docId} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false;
    }

    match /taxonomy_categories/{docId} {
      allow read: if isSignedIn();
      allow create, update: if isOwnerOrService();
      allow delete: if false;
    }
  }
}
```

## Required Beneficiary Fields (Recommended)

For consistent sync up/down and future incremental sync:

- localId
- remoteId
- fileNumber
- fileIdNumber
- updatedAt
- createdAt
- syncStatus
- createdBy
- deviceId
- isDeleted
- deletedAt

## Error Mapping Guidance

- permission-denied:
  - Show message: `لا يوجد صلاحية للوصول إلى Firestore. راجع القواعد أو حساب المستخدم.`
- unavailable / network:
  - Show message: `انقطع الاتصال، يمكن إعادة المحاولة.`
- unauthenticated:
  - Show message: `انتهت الجلسة، يرجى تسجيل الدخول مجدداً.`

## Index/Query Notes

For later incremental sync:

- query: beneficiaries where updatedAt > lastDownloadAt
- add index for updatedAt (and composite indexes if additional filters are introduced)

## Security Notes

- Keep delete blocked at document level; use soft delete markers instead.
- Restrict write fields if needed with stricter validation functions after schema stabilizes.
- Consider App Check enforcement after development rollout is stable.
