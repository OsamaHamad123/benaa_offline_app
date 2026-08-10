-- ====================================
-- سكريبت إنشاء الجداول المطلوبة
-- شغّل هذا في phpMyAdmin
-- ====================================

-- 1. جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    is_active TINYINT(1) DEFAULT 1,
    token VARCHAR(255) NULL,
    token_expires_at DATETIME NULL,
    device_id VARCHAR(255) NULL,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ⚠️ لا تُنشئ حساباً بكلمة مرور افتراضية معروفة.
-- أنشئ حساب المدير يدوياً بكلمة مرور قوية خاصة بك:
--   1) أنشئ التجزئة:  php -r "echo password_hash('كلمة-مرور-قوية', PASSWORD_DEFAULT);"
--   2) ثم نفّذ:
-- INSERT INTO users (email, name, password_hash, role)
-- VALUES ('you@example.com', 'المدير', '<الصق-التجزئة-هنا>', 'admin');

-- 2. جدول محاولات تسجيل الدخول
CREATE TABLE IF NOT EXISTS login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    success TINYINT(1) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. جدول سجل النشاطات
CREATE TABLE IF NOT EXISTS activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. جدول تاريخ المزامنة
CREATE TABLE IF NOT EXISTS sync_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    stats TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_device_id (device_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. جدول الكيانات المحذوفة
CREATE TABLE IF NOT EXISTS deleted_entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity_type (entity_type),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. جدول المستفيدين (إذا لم يكن موجوداً)
CREATE TABLE IF NOT EXISTS beneficiaries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    national_id VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_national_id (national_id),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. جدول الزيارات (إذا لم يكن موجوداً)
CREATE TABLE IF NOT EXISTS visits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    visit_date DATE NOT NULL,
    notes TEXT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_beneficiary_id (beneficiary_id),
    INDEX idx_visit_date (visit_date),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. جدول المرفقات (إذا لم يكن موجوداً)
CREATE TABLE IF NOT EXISTS attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    visit_id INT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size INT NOT NULL,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id) ON DELETE CASCADE,
    FOREIGN KEY (visit_id) REFERENCES visits(id) ON DELETE SET NULL,
    FOREIGN KEY (uploaded_by) REFERENCES users(id),
    INDEX idx_beneficiary_id (beneficiary_id),
    INDEX idx_visit_id (visit_id),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. جدول الأموات في العائلة
CREATE TABLE IF NOT EXISTS family_deceased (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100) NOT NULL COMMENT 'صلة القرابة: أب، أم، ابن، ابنة، أخ، أخت، زوج، زوجة',
    gender ENUM('male', 'female') NOT NULL,
    death_date DATE NULL COMMENT 'تاريخ الوفاة',
    death_cause VARCHAR(255) NULL COMMENT 'سبب الوفاة',
    age_at_death INT NULL COMMENT 'العمر عند الوفاة',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id) ON DELETE CASCADE,
    INDEX idx_beneficiary_id (beneficiary_id),
    INDEX idx_relationship (relationship),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الأموات في عائلة المستفيد';

-- 10. جدول أفراد العائلة الأحياء
CREATE TABLE IF NOT EXISTS family_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100) NOT NULL COMMENT 'صلة القرابة: ابن، ابنة، أخ، أخت، زوج، زوجة، أب، أم، جد، جدة',
    gender ENUM('male', 'female') NOT NULL,
    national_id VARCHAR(50) NULL COMMENT 'الرقم الوطني',
    birth_date DATE NULL COMMENT 'تاريخ الميلاد',
    age INT NULL COMMENT 'العمر',
    marital_status VARCHAR(50) NULL COMMENT 'الحالة الاجتماعية',
    education_level VARCHAR(100) NULL COMMENT 'المستوى التعليمي',
    occupation VARCHAR(100) NULL COMMENT 'المهنة',
    health_status VARCHAR(100) NULL COMMENT 'الحالة الصحية',
    has_disability TINYINT(1) DEFAULT 0 COMMENT 'لديه إعاقة',
    disability_type VARCHAR(255) NULL COMMENT 'نوع الإعاقة',
    has_chronic_disease TINYINT(1) DEFAULT 0 COMMENT 'لديه مرض مزمن',
    chronic_disease_type VARCHAR(255) NULL COMMENT 'نوع المرض المزمن',
    lives_with_beneficiary TINYINT(1) DEFAULT 1 COMMENT 'يعيش مع المستفيد',
    phone VARCHAR(20) NULL COMMENT 'رقم الهاتف',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id) ON DELETE CASCADE,
    INDEX idx_beneficiary_id (beneficiary_id),
    INDEX idx_relationship (relationship),
    INDEX idx_national_id (national_id),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='أفراد عائلة المستفيد الأحياء';

-- ====================================
-- اكتمل إنشاء الجداول!
-- ====================================
