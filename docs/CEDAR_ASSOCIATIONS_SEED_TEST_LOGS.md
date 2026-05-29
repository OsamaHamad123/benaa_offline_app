# Cedar Associations Seed Test Logs

Date: 2026-05-28
Mode: manual verification checklist

## Scope

- Existing associations module only (no new architecture)
- Cedar Associations Seed insertion/update behavior
- Associations list refresh
- Kafalat/Sponsorship association dropdown integration
- Pending upload inclusion in sync

## Checklist

1. Seed runs once

- Step: Open Associations page -> enable quick tools -> click "إضافة جمعيات Cedar".
- Expected: progress dialog appears then summary snack bar.
- Expected logs:
  - [CedarAssociations] existing associations system detected collection=associations
  - [CedarAssociations] started count=15 force=false
  - [CedarAssociations] created=<count> skipped=<count> updated=0 failed=0
  - [CedarAssociations] list refreshed

2. Associations list shows Cedar associations

- Step: Check Associations list after seed completes.
- Expected: seeded records appear as active associations.

3. Running seed again skips existing records

- Step: Click "إضافة جمعيات Cedar" again.
- Expected: created=0, skipped=15 (or near, if some were edited), updated=0.

4. Force=true updates existing records

- Step: Click "رفع Seed الجمعيات (force)".
- Expected: existing seeded rows are updated, summary shows updated>0 and no duplicates.

5. Kafala/Sponsorship association dropdown shows seeded associations

- Step: Open sponsorship form and association selection field.
- Expected: seeded associations appear from existing active associations source.

6. Upload Changes includes seeded associations

- Step: After seed (local pending), open Sync page and run Upload Changes.
- Expected: associations pending count is included and uploaded via existing sync path.

7. No duplicate associations are created

- Step: Search by seeded names/IDs after repeated seed runs.
- Expected: one row per stable seed ID/name.

## Notes

- Seed data is operational seed data for selection/testing and remains editable in Associations section.
- This is not an official or exhaustive registry.
