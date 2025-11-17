-- ========================================
-- تحديث full_name_norm للسجلات الموجودة
-- ========================================
-- ⚠️ هذا السكريبت يجب تشغيله مرة واحدة فقط بعد تحديث قاعدة البيانات

-- 1. تحديث جميع السجلات الموجودة
UPDATE beneficiaries 
SET full_name_norm = LOWER(
  TRIM(
    COALESCE(first_name, '') || ' ' || 
    COALESCE(father_name, '') || ' ' || 
    COALESCE(grand_father_name, '') || ' ' || 
    COALESCE(family_name, '')
  )
)
WHERE full_name_norm IS NULL 
   OR full_name_norm = '' 
   OR full_name_norm = ' ';

-- 2. التحقق من النتائج
SELECT 
  id,
  first_name,
  father_name,
  family_name,
  full_name,
  full_name_norm,
  CASE 
    WHEN full_name_norm IS NULL OR full_name_norm = '' THEN 'يحتاج تحديث'
    ELSE 'محدّث'
  END as status
FROM beneficiaries
LIMIT 10;

-- 3. إحصائيات
SELECT 
  COUNT(*) as total_records,
  SUM(CASE WHEN full_name_norm IS NOT NULL AND full_name_norm != '' THEN 1 ELSE 0 END) as updated_records,
  SUM(CASE WHEN full_name_norm IS NULL OR full_name_norm = '' THEN 1 ELSE 0 END) as pending_records
FROM beneficiaries;

-- 4. التحقق من الـ Triggers
SELECT name, sql 
FROM sqlite_master 
WHERE type = 'trigger' 
  AND tbl_name = 'beneficiaries'
  AND name LIKE '%full_name_norm%';

-- 5. اختبار البحث
SELECT id, full_name, full_name_norm
FROM beneficiaries
WHERE full_name_norm LIKE '%محمد%'
LIMIT 5;

-- ========================================
-- ملاحظات:
-- ========================================
-- • السكريبت آمن للتشغيل مرات متعددة
-- • يستخدم TRIM لإزالة المسافات الزائدة
-- • يستخدم LOWER لتوحيد الحالة
-- • التحديث فوري ولا يحتاج restart
-- ========================================
