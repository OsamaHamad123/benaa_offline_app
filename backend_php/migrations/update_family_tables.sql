-- ============================================
-- 🔄 Migration Script: Family Tables Schema Update
-- التحديث: توحيد البنية مع جدول المستفيدين (Integer IDs, Integer Enums)
-- التاريخ: 2025-11-21
-- ============================================

-- ⚠️ BACKUP FIRST!
-- قبل تنفيذ هذا السكريبت، قم بعمل نسخة احتياطية:
-- mysqldump -u username -p database_name family_deceased family_members > backup_family_tables.sql

-- ============================================
-- 📋 الجزء 1: النسخ الاحتياطي
-- ============================================

-- إنشاء جداول نسخ احتياطية
CREATE TABLE IF NOT EXISTS family_deceased_backup AS SELECT * FROM family_deceased;
CREATE TABLE IF NOT EXISTS family_members_backup AS SELECT * FROM family_members;

-- ============================================
-- 📋 الجزء 2: جدول family_deceased (الأموات)
-- ============================================

-- حذف الجدول القديم وإنشاء جدول جديد
DROP TABLE IF EXISTS family_deceased;

CREATE TABLE family_deceased (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    
    -- نوع المتوفى (1=أب، 2=أم)
    deceased_type TINYINT NOT NULL COMMENT '1=father, 2=mother',
    
    -- الاسم الرباعي
    first_name VARCHAR(100) NOT NULL,
    second_name VARCHAR(100) DEFAULT NULL,
    third_name VARCHAR(100) DEFAULT NULL,
    family_name VARCHAR(100) NOT NULL,
    
    -- الرقم الوطني (INT - 9 أرقام)
    national_id INT NOT NULL,
    
    -- تاريخ وسبب الوفاة
    death_date DATE NOT NULL,
    death_cause TINYINT NOT NULL COMMENT '1=طبيعية, 2=مرض, 3=فجأة, 4=حادث, 5=أخرى, 6=انتحار, 7=مغدور, 8=غير معروف',
    
    -- الوثائق
    document_type TINYINT DEFAULT NULL COMMENT '1=شهادة وفاة, 2=إفادة شهيد',
    document_path TEXT DEFAULT NULL,
    
    notes TEXT DEFAULT NULL,
    
    -- System fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Sync fields
    sync_state VARCHAR(20) DEFAULT 'pending',
    server_id INT DEFAULT NULL,
    last_synced_at TIMESTAMP NULL DEFAULT NULL,
    
    -- Indexes
    INDEX idx_beneficiary (beneficiary_id),
    INDEX idx_deceased_type (deceased_type),
    INDEX idx_death_cause (death_cause),
    INDEX idx_national_id (national_id),
    INDEX idx_sync_state (sync_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- تعليقات على الجدول
ALTER TABLE family_deceased COMMENT = 'جدول الأب/الأم المتوفى - موحد مع بنية جدول المستفيدين';

-- ============================================
-- 📋 الجزء 3: جدول family_members (الأيتام)
-- ============================================

-- حذف الجدول القديم وإنشاء جدول جديد
DROP TABLE IF EXISTS family_members;

CREATE TABLE family_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    
    -- رقم هوية اليتيم (INT - 9 أرقام)
    orphan_national_id INT NOT NULL,
    
    -- الاسم الرباعي
    first_name VARCHAR(100) NOT NULL,
    second_name VARCHAR(100) DEFAULT NULL,
    third_name VARCHAR(100) DEFAULT NULL,
    family_name VARCHAR(100) NOT NULL,
    
    -- تاريخ الميلاد والعمر
    birth_date DATE NOT NULL,
    age INT DEFAULT NULL,
    
    -- الجنس (1=ذكر، 2=أنثى)
    gender TINYINT NOT NULL COMMENT '1=male, 2=female',
    
    -- الحالة الصحية (1=سليم، 2=مريض، 3=مريض مزمن، 4=معاق، 5=غير معروف)
    health_status TINYINT NOT NULL COMMENT '1=healthy, 2=sick, 3=chronic, 4=disabled, 5=unknown',
    
    -- الملفات المرفقة (مفصولة بفاصلة)
    attachments TEXT DEFAULT NULL,
    
    notes TEXT DEFAULT NULL,
    
    -- System fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Sync fields
    sync_state VARCHAR(20) DEFAULT 'pending',
    server_id INT DEFAULT NULL,
    last_synced_at TIMESTAMP NULL DEFAULT NULL,
    
    -- Indexes
    INDEX idx_beneficiary (beneficiary_id),
    INDEX idx_orphan_national_id (orphan_national_id),
    INDEX idx_gender (gender),
    INDEX idx_health_status (health_status),
    INDEX idx_sync_state (sync_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- تعليقات على الجدول
ALTER TABLE family_members COMMENT = 'جدول أفراد الأسرة (الأيتام) - موحد مع بنية جدول المستفيدين';

-- ============================================
-- 📋 الجزء 4: استرجاع البيانات من النسخة الاحتياطية (إن وجدت)
-- ============================================

-- ⚠️ ملاحظة: يجب تعديل هذا الجزء حسب البنية القديمة للبيانات
-- هذا مثال فقط - قد تحتاج لتعديله حسب البنية القديمة

-- استرجاع family_deceased (يجب تحويل القيم النصية إلى أرقام)
-- INSERT INTO family_deceased (
--     beneficiary_id, deceased_type, first_name, second_name, third_name,
--     family_name, national_id, death_date, death_cause, document_type,
--     document_path, notes
-- )
-- SELECT 
--     beneficiary_id,
--     CASE deceased_type
--         WHEN 'father' THEN 1
--         WHEN 'mother' THEN 2
--         ELSE 1
--     END,
--     first_name, second_name, third_name, family_name,
--     CAST(national_id AS UNSIGNED),
--     death_date,
--     CASE death_cause
--         WHEN 'طبيعية' THEN 1
--         WHEN 'مرض' THEN 2
--         WHEN 'فجأة' THEN 3
--         WHEN 'حادث' THEN 4
--         WHEN 'أخرى' THEN 5
--         WHEN 'انتحار' THEN 6
--         WHEN 'مغدور' THEN 7
--         ELSE 8
--     END,
--     CASE document_type
--         WHEN 'شهادة وفاة' THEN 1
--         WHEN 'إفادة شهيد' THEN 2
--         ELSE NULL
--     END,
--     document_path, notes
-- FROM family_deceased_backup;

-- استرجاع family_members (يجب تحويل القيم النصية إلى أرقام)
-- INSERT INTO family_members (
--     beneficiary_id, orphan_national_id, first_name, second_name, third_name,
--     family_name, birth_date, age, gender, health_status, attachments, notes
-- )
-- SELECT 
--     beneficiary_id,
--     CAST(orphan_national_id AS UNSIGNED),
--     first_name, second_name, third_name, family_name,
--     birth_date, age,
--     CASE gender
--         WHEN 'male' THEN 1
--         WHEN 'female' THEN 2
--         ELSE 1
--     END,
--     CASE health_status
--         WHEN 'سليم' THEN 1
--         WHEN 'مريض' THEN 2
--         WHEN 'مريض مزمن' THEN 3
--         WHEN 'معاق' THEN 4
--         ELSE 5
--     END,
--     attachments, notes
-- FROM family_members_backup;

-- ============================================
-- 📋 الجزء 5: التحقق من البيانات
-- ============================================

-- التحقق من عدد السجلات
SELECT 'family_deceased' AS table_name, COUNT(*) AS count FROM family_deceased
UNION ALL
SELECT 'family_deceased_backup', COUNT(*) FROM family_deceased_backup
UNION ALL
SELECT 'family_members', COUNT(*) FROM family_members
UNION ALL
SELECT 'family_members_backup', COUNT(*) FROM family_members_backup;

-- عرض عينة من البيانات
SELECT 'family_deceased' AS source, id, beneficiary_id, deceased_type, first_name, family_name, national_id
FROM family_deceased LIMIT 5;

SELECT 'family_members' AS source, id, beneficiary_id, orphan_national_id, first_name, family_name, gender, health_status
FROM family_members LIMIT 5;

-- ============================================
-- 📋 الجزء 6: حذف النسخ الاحتياطية (بعد التأكد من نجاح العملية)
-- ============================================

-- ⚠️ قم بتنفيذ هذا فقط بعد التأكد من نجاح الاستيراد
-- DROP TABLE IF EXISTS family_deceased_backup;
-- DROP TABLE IF EXISTS family_members_backup;

-- ============================================
-- 📋 الجزء 7: Rollback Script (في حالة الطوارئ)
-- ============================================

-- في حالة الحاجة للرجوع للبنية القديمة:
-- DROP TABLE IF EXISTS family_deceased;
-- DROP TABLE IF EXISTS family_members;
-- CREATE TABLE family_deceased AS SELECT * FROM family_deceased_backup;
-- CREATE TABLE family_members AS SELECT * FROM family_members_backup;

-- ============================================
-- ✅ انتهى السكريبت
-- ============================================

-- ملاحظات مهمة:
-- 1. deceased_type: 1=أب، 2=أم
-- 2. death_cause: 1=طبيعية، 2=مرض، 3=فجأة، 4=حادث، 5=أخرى، 6=انتحار، 7=مغدور، 8=غير معروف
-- 3. document_type: 1=شهادة وفاة، 2=إفادة شهيد
-- 4. gender: 1=ذكر، 2=أنثى
-- 5. health_status: 1=سليم، 2=مريض، 3=مريض مزمن، 4=معاق، 5=غير معروف
-- 6. national_id و orphan_national_id: INT (9 أرقام)
