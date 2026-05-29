# Firestore Required Indexes

Date: 2026-05-28

## file_number_blocks

Collection: file_number_blocks

Required composite index:

1. deviceId Ascending
2. userId Ascending
3. reservedAt Descending
4. **name** Descending

Reason:

- Needed when query uses:
  - where deviceId == <deviceId>
  - where userId == <uid>
  - orderBy reservedAt desc

## Note for development

The app now supports a development-safe fallback query pattern for file number sync-down:

- where deviceId == <deviceId>
- where userId == <uid>
- no server-side orderBy
- local in-memory sort by reservedAt desc

This reduces dependency on composite index creation during development.
