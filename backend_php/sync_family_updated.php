<?php
/**
 * 👨‍👩‍👧‍👦 Family Sync API - Updated Schema
 * ===================================
 * التحديث: توحيد البنية مع جدول المستفيدين (Integer IDs, Integer Enums)
 * التاريخ: 2025-11-21
 * 
 * الاختلافات الرئيسية:
 * - deceased_type: Integer (1=father, 2=mother) بدلاً من String
 * - national_id: Integer (9 أرقام) بدلاً من String
 * - death_cause: Integer (1-8) بدلاً من Arabic String
 * - document_type: Integer (1-2) بدلاً من Arabic String
 * - orphan_national_id: Integer (9 أرقام) بدلاً من String
 * - gender: Integer (1=male, 2=female) بدلاً من String
 * - health_status: Integer (1-5) بدلاً من Arabic String
 */

// Database connection
require_once 'config/database.php';

// Helper functions for enum conversions
class FamilyEnums {
    // Deceased Type (نوع المتوفى)
    const DECEASED_TYPE_FATHER = 1;
    const DECEASED_TYPE_MOTHER = 2;
    
    public static function deceasedTypeToArabic($type) {
        switch ($type) {
            case self::DECEASED_TYPE_FATHER: return 'أب';
            case self::DECEASED_TYPE_MOTHER: return 'أم';
            default: return 'غير معروف';
        }
    }
    
    public static function deceasedTypeFromEnglish($english) {
        switch (strtolower($english)) {
            case 'father': return self::DECEASED_TYPE_FATHER;
            case 'mother': return self::DECEASED_TYPE_MOTHER;
            default: return self::DECEASED_TYPE_FATHER;
        }
    }
    
    // Death Cause (سبب الوفاة)
    const DEATH_CAUSE_NATURAL = 1;
    const DEATH_CAUSE_DISEASE = 2;
    const DEATH_CAUSE_SUDDEN = 3;
    const DEATH_CAUSE_ACCIDENT = 4;
    const DEATH_CAUSE_OTHER = 5;
    const DEATH_CAUSE_SUICIDE = 6;
    const DEATH_CAUSE_MURDERED = 7;
    const DEATH_CAUSE_UNKNOWN = 8;
    
    public static function deathCauseToArabic($cause) {
        switch ($cause) {
            case self::DEATH_CAUSE_NATURAL: return 'طبيعية';
            case self::DEATH_CAUSE_DISEASE: return 'مرض';
            case self::DEATH_CAUSE_SUDDEN: return 'فجأة';
            case self::DEATH_CAUSE_ACCIDENT: return 'حادث';
            case self::DEATH_CAUSE_OTHER: return 'أخرى';
            case self::DEATH_CAUSE_SUICIDE: return 'انتحار';
            case self::DEATH_CAUSE_MURDERED: return 'مغدور';
            case self::DEATH_CAUSE_UNKNOWN: return 'غير معروف';
            default: return 'غير معروف';
        }
    }
    
    public static function deathCauseFromArabic($arabic) {
        switch ($arabic) {
            case 'طبيعية': return self::DEATH_CAUSE_NATURAL;
            case 'مرض': return self::DEATH_CAUSE_DISEASE;
            case 'فجأة': return self::DEATH_CAUSE_SUDDEN;
            case 'حادث': return self::DEATH_CAUSE_ACCIDENT;
            case 'أخرى': return self::DEATH_CAUSE_OTHER;
            case 'انتحار': return self::DEATH_CAUSE_SUICIDE;
            case 'مغدور': return self::DEATH_CAUSE_MURDERED;
            default: return self::DEATH_CAUSE_UNKNOWN;
        }
    }
    
    // Document Type (نوع الوثيقة)
    const DOCUMENT_TYPE_DEATH_CERTIFICATE = 1;
    const DOCUMENT_TYPE_MARTYR_CERTIFICATE = 2;
    
    public static function documentTypeToArabic($type) {
        switch ($type) {
            case self::DOCUMENT_TYPE_DEATH_CERTIFICATE: return 'شهادة وفاة';
            case self::DOCUMENT_TYPE_MARTYR_CERTIFICATE: return 'إفادة شهيد';
            default: return null;
        }
    }
    
    public static function documentTypeFromArabic($arabic) {
        switch ($arabic) {
            case 'شهادة وفاة': return self::DOCUMENT_TYPE_DEATH_CERTIFICATE;
            case 'إفادة شهيد': return self::DOCUMENT_TYPE_MARTYR_CERTIFICATE;
            default: return null;
        }
    }
    
    // Gender (الجنس)
    const GENDER_MALE = 1;
    const GENDER_FEMALE = 2;
    
    public static function genderToArabic($gender) {
        switch ($gender) {
            case self::GENDER_MALE: return 'ذكر';
            case self::GENDER_FEMALE: return 'أنثى';
            default: return 'غير معروف';
        }
    }
    
    public static function genderFromEnglish($english) {
        switch (strtolower($english)) {
            case 'male': return self::GENDER_MALE;
            case 'female': return self::GENDER_FEMALE;
            default: return self::GENDER_MALE;
        }
    }
    
    // Health Status (الحالة الصحية)
    const HEALTH_STATUS_HEALTHY = 1;
    const HEALTH_STATUS_SICK = 2;
    const HEALTH_STATUS_CHRONIC = 3;
    const HEALTH_STATUS_DISABLED = 4;
    const HEALTH_STATUS_UNKNOWN = 5;
    
    public static function healthStatusToArabic($status) {
        switch ($status) {
            case self::HEALTH_STATUS_HEALTHY: return 'سليم';
            case self::HEALTH_STATUS_SICK: return 'مريض';
            case self::HEALTH_STATUS_CHRONIC: return 'مريض مزمن';
            case self::HEALTH_STATUS_DISABLED: return 'معاق';
            case self::HEALTH_STATUS_UNKNOWN: return 'غير معروف';
            default: return 'غير معروف';
        }
    }
    
    public static function healthStatusFromArabic($arabic) {
        switch ($arabic) {
            case 'سليم': return self::HEALTH_STATUS_HEALTHY;
            case 'مريض': return self::HEALTH_STATUS_SICK;
            case 'مريض مزمن': return self::HEALTH_STATUS_CHRONIC;
            case 'معاق': return self::HEALTH_STATUS_DISABLED;
            default: return self::HEALTH_STATUS_UNKNOWN;
        }
    }
}

/**
 * 🔄 معالجة تغيير family_deceased (الأموات)
 */
function processFamilyDeceasedChange($pdo, $change) {
    try {
        // التحقق من الحقول المطلوبة
        $required = ['beneficiary_id', 'deceased_type', 'first_name', 'family_name', 'national_id', 'death_date', 'death_cause'];
        foreach ($required as $field) {
            if (!isset($change[$field]) || $change[$field] === '' || $change[$field] === null) {
                return ['success' => false, 'error' => "Missing required field: $field"];
            }
        }
        
        // Validation
        $deceased_type = (int)$change['deceased_type'];
        if (!in_array($deceased_type, [1, 2])) {
            return ['success' => false, 'error' => 'Invalid deceased_type. Must be 1 (father) or 2 (mother)'];
        }
        
        $national_id = (int)$change['national_id'];
        if ($national_id < 100000000 || $national_id > 999999999) {
            return ['success' => false, 'error' => 'Invalid national_id. Must be 9 digits'];
        }
        
        $death_cause = (int)$change['death_cause'];
        if ($death_cause < 1 || $death_cause > 8) {
            return ['success' => false, 'error' => 'Invalid death_cause. Must be between 1 and 8'];
        }
        
        $document_type = isset($change['document_type']) ? (int)$change['document_type'] : null;
        if ($document_type !== null && !in_array($document_type, [1, 2])) {
            return ['success' => false, 'error' => 'Invalid document_type. Must be 1 or 2'];
        }
        
        // Check for existing record
        if (isset($change['id']) && $change['id']) {
            // Update
            $stmt = $pdo->prepare("
                UPDATE family_deceased SET
                    beneficiary_id = :beneficiary_id,
                    deceased_type = :deceased_type,
                    first_name = :first_name,
                    second_name = :second_name,
                    third_name = :third_name,
                    family_name = :family_name,
                    national_id = :national_id,
                    death_date = :death_date,
                    death_cause = :death_cause,
                    document_type = :document_type,
                    document_path = :document_path,
                    notes = :notes,
                    updated_at = NOW()
                WHERE id = :id
            ");
            $stmt->execute([
                ':id' => $change['id'],
                ':beneficiary_id' => $change['beneficiary_id'],
                ':deceased_type' => $deceased_type,
                ':first_name' => $change['first_name'],
                ':second_name' => $change['second_name'] ?? null,
                ':third_name' => $change['third_name'] ?? null,
                ':family_name' => $change['family_name'],
                ':national_id' => $national_id,
                ':death_date' => $change['death_date'],
                ':death_cause' => $death_cause,
                ':document_type' => $document_type,
                ':document_path' => $change['document_path'] ?? null,
                ':notes' => $change['notes'] ?? null,
            ]);
            
            return ['success' => true, 'id' => $change['id'], 'action' => 'updated'];
        } else {
            // Insert
            $stmt = $pdo->prepare("
                INSERT INTO family_deceased (
                    beneficiary_id, deceased_type, first_name, second_name, third_name,
                    family_name, national_id, death_date, death_cause, document_type,
                    document_path, notes, created_at, updated_at
                ) VALUES (
                    :beneficiary_id, :deceased_type, :first_name, :second_name, :third_name,
                    :family_name, :national_id, :death_date, :death_cause, :document_type,
                    :document_path, :notes, NOW(), NOW()
                )
            ");
            $stmt->execute([
                ':beneficiary_id' => $change['beneficiary_id'],
                ':deceased_type' => $deceased_type,
                ':first_name' => $change['first_name'],
                ':second_name' => $change['second_name'] ?? null,
                ':third_name' => $change['third_name'] ?? null,
                ':family_name' => $change['family_name'],
                ':national_id' => $national_id,
                ':death_date' => $change['death_date'],
                ':death_cause' => $death_cause,
                ':document_type' => $document_type,
                ':document_path' => $change['document_path'] ?? null,
                ':notes' => $change['notes'] ?? null,
            ]);
            
            return ['success' => true, 'id' => $pdo->lastInsertId(), 'action' => 'created'];
        }
    } catch (PDOException $e) {
        return ['success' => false, 'error' => 'Database error: ' . $e->getMessage()];
    }
}

/**
 * 🔄 معالجة تغيير family_member (الأيتام)
 */
function processFamilyMemberChange($pdo, $change) {
    try {
        // التحقق من الحقول المطلوبة
        $required = ['beneficiary_id', 'orphan_national_id', 'first_name', 'family_name', 'birth_date', 'gender', 'health_status'];
        foreach ($required as $field) {
            if (!isset($change[$field]) || $change[$field] === '' || $change[$field] === null) {
                return ['success' => false, 'error' => "Missing required field: $field"];
            }
        }
        
        // Validation
        $orphan_national_id = (int)$change['orphan_national_id'];
        if ($orphan_national_id < 100000000 || $orphan_national_id > 999999999) {
            return ['success' => false, 'error' => 'Invalid orphan_national_id. Must be 9 digits'];
        }
        
        $gender = (int)$change['gender'];
        if (!in_array($gender, [1, 2])) {
            return ['success' => false, 'error' => 'Invalid gender. Must be 1 (male) or 2 (female)'];
        }
        
        $health_status = (int)$change['health_status'];
        if ($health_status < 1 || $health_status > 5) {
            return ['success' => false, 'error' => 'Invalid health_status. Must be between 1 and 5'];
        }
        
        // Check for existing record
        if (isset($change['id']) && $change['id']) {
            // Update
            $stmt = $pdo->prepare("
                UPDATE family_members SET
                    beneficiary_id = :beneficiary_id,
                    orphan_national_id = :orphan_national_id,
                    first_name = :first_name,
                    second_name = :second_name,
                    third_name = :third_name,
                    family_name = :family_name,
                    birth_date = :birth_date,
                    age = :age,
                    gender = :gender,
                    health_status = :health_status,
                    attachments = :attachments,
                    notes = :notes,
                    updated_at = NOW()
                WHERE id = :id
            ");
            $stmt->execute([
                ':id' => $change['id'],
                ':beneficiary_id' => $change['beneficiary_id'],
                ':orphan_national_id' => $orphan_national_id,
                ':first_name' => $change['first_name'],
                ':second_name' => $change['second_name'] ?? null,
                ':third_name' => $change['third_name'] ?? null,
                ':family_name' => $change['family_name'],
                ':birth_date' => $change['birth_date'],
                ':age' => $change['age'] ?? null,
                ':gender' => $gender,
                ':health_status' => $health_status,
                ':attachments' => $change['attachments'] ?? null,
                ':notes' => $change['notes'] ?? null,
            ]);
            
            return ['success' => true, 'id' => $change['id'], 'action' => 'updated'];
        } else {
            // Insert
            $stmt = $pdo->prepare("
                INSERT INTO family_members (
                    beneficiary_id, orphan_national_id, first_name, second_name, third_name,
                    family_name, birth_date, age, gender, health_status, attachments,
                    notes, created_at, updated_at
                ) VALUES (
                    :beneficiary_id, :orphan_national_id, :first_name, :second_name, :third_name,
                    :family_name, :birth_date, :age, :gender, :health_status, :attachments,
                    :notes, NOW(), NOW()
                )
            ");
            $stmt->execute([
                ':beneficiary_id' => $change['beneficiary_id'],
                ':orphan_national_id' => $orphan_national_id,
                ':first_name' => $change['first_name'],
                ':second_name' => $change['second_name'] ?? null,
                ':third_name' => $change['third_name'] ?? null,
                ':family_name' => $change['family_name'],
                ':birth_date' => $change['birth_date'],
                ':age' => $change['age'] ?? null,
                ':gender' => $gender,
                ':health_status' => $health_status,
                ':attachments' => $change['attachments'] ?? null,
                ':notes' => $change['notes'] ?? null,
            ]);
            
            return ['success' => true, 'id' => $pdo->lastInsertId(), 'action' => 'created'];
        }
    } catch (PDOException $e) {
        return ['success' => false, 'error' => 'Database error: ' . $e->getMessage()];
    }
}

/**
 * 📥 جلب family_deceased للمستفيد
 */
function fetchFamilyDeceased($pdo, $beneficiary_id) {
    try {
        $stmt = $pdo->prepare("
            SELECT * FROM family_deceased 
            WHERE beneficiary_id = :beneficiary_id
            ORDER BY deceased_type
        ");
        $stmt->execute([':beneficiary_id' => $beneficiary_id]);
        
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // تحويل القيم إلى النصوص للعرض (للتوافق مع Flutter)
        foreach ($results as &$row) {
            $row['deceased_type_label'] = FamilyEnums::deceasedTypeToArabic($row['deceased_type']);
            $row['death_cause_label'] = FamilyEnums::deathCauseToArabic($row['death_cause']);
            if ($row['document_type']) {
                $row['document_type_label'] = FamilyEnums::documentTypeToArabic($row['document_type']);
            }
        }
        
        return ['success' => true, 'data' => $results];
    } catch (PDOException $e) {
        return ['success' => false, 'error' => 'Database error: ' . $e->getMessage()];
    }
}

/**
 * 📥 جلب family_members للمستفيد
 */
function fetchFamilyMembers($pdo, $beneficiary_id) {
    try {
        $stmt = $pdo->prepare("
            SELECT * FROM family_members 
            WHERE beneficiary_id = :beneficiary_id
            ORDER BY age DESC
        ");
        $stmt->execute([':beneficiary_id' => $beneficiary_id]);
        
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // تحويل القيم إلى النصوص للعرض (للتوافق مع Flutter)
        foreach ($results as &$row) {
            $row['gender_label'] = FamilyEnums::genderToArabic($row['gender']);
            $row['health_status_label'] = FamilyEnums::healthStatusToArabic($row['health_status']);
        }
        
        return ['success' => true, 'data' => $results];
    } catch (PDOException $e) {
        return ['success' => false, 'error' => 'Database error: ' . $e->getMessage()];
    }
}

/**
 * 🎯 Main API Handler
 */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['action'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing action parameter']);
        exit;
    }
    
    switch ($input['action']) {
        case 'sync_deceased':
            $result = processFamilyDeceasedChange($pdo, $input['data']);
            echo json_encode($result);
            break;
            
        case 'sync_member':
            $result = processFamilyMemberChange($pdo, $input['data']);
            echo json_encode($result);
            break;
            
        case 'fetch_deceased':
            $result = fetchFamilyDeceased($pdo, $input['beneficiary_id']);
            echo json_encode($result);
            break;
            
        case 'fetch_members':
            $result = fetchFamilyMembers($pdo, $input['beneficiary_id']);
            echo json_encode($result);
            break;
            
        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action']);
            break;
    }
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed. Use POST.']);
}
?>
