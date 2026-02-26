-- Idempotent normalization for legacy attachments person metadata.
-- Safe to run multiple times.

UPDATE attachments
SET
  person_id = CASE
    WHEN person_id IS NULL OR TRIM(person_id) = '' THEN
      TRIM(REPLACE(COALESCE(person_type, ''), '(متوفي)', ''))
    ELSE TRIM(person_id)
  END,
  person_type = CASE
    WHEN person_type LIKE '%(متوفي)%' THEN 'deceased_member'
    ELSE 'family_member'
  END
WHERE person_type IS NOT NULL
  AND TRIM(person_type) != ''
  AND person_type NOT IN (
    'file_owner',
    'family_member',
    'deceased_member',
    'deceased_father',
    'deceased_mother'
  );

UPDATE attachments
SET person_id = NULL
WHERE person_type = 'file_owner';

UPDATE attachments
SET person_id = NULL
WHERE person_id IS NOT NULL
  AND TRIM(person_id) = '';
