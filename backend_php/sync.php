<?php
/**
 * API المزامنة
 * المسار: /api/sync.php
 */

require_once 'config.php';

// التحقق من المصادقة
$currentUser = verifyToken();

// قراءة بيانات الطلب
$data = getRequestData();
$lastSyncTime = $data['lastSyncTime'] ?? null;
$pendingChanges = $data['pendingChanges'] ?? [];
$deviceInfo = $data['deviceInfo'] ?? [];
$userId = $data['userId'] ?? $currentUser['id'];

$db = getDB();
$db->begin_transaction();

try {
    $stats = [
        'receivedCount' => 0,
        'sentCount' => 0,
        'deletedCount' => 0,
        'failedCount' => 0
    ];
    
    $failedChanges = [];
    $updatedData = [];
    $deletedIds = [];
    
    // ====================================
    // 1. معالجة التغييرات المعلقة
    // ====================================
    
    foreach ($pendingChanges as $change) {
        $entityType = $change['entityType'] ?? '';
        $entityId = $change['entityId'] ?? '';
        $operation = $change['operation'] ?? '';
        $changeData = $change['data'] ?? [];
        
        try {
            switch ($entityType) {
                case 'beneficiary':
                    processBeneficiaryChange($db, $operation, $entityId, $changeData, $currentUser['id']);
                    break;
                    
                case 'visit':
                    processVisitChange($db, $operation, $entityId, $changeData, $currentUser['id']);
                    break;
                    
                case 'attachment':
                    processAttachmentChange($db, $operation, $entityId, $changeData, $currentUser['id']);
                    break;
                
                case 'family_deceased':
                    processFamilyDeceasedChange($db, $operation, $entityId, $changeData, $currentUser['id']);
                    break;
                
                case 'family_member':
                    processFamilyMemberChange($db, $operation, $entityId, $changeData, $currentUser['id']);
                    break;
                    
                default:
                    throw new Exception("نوع كيان غير معروف: $entityType");
            }
            
            $stats['receivedCount']++;
            
        } catch (Exception $e) {
            $failedChanges[] = [
                'entityId' => $entityId,
                'entityType' => $entityType,
                'reason' => $e->getMessage(),
                'errorCode' => 'PROCESSING_ERROR',
                'retryable' => true
            ];
            $stats['failedCount']++;
        }
    }
    
    // ====================================
    // 2. جلب البيانات المحدثة من السيرفر
    // ====================================
    
    $lastSyncTimestamp = $lastSyncTime ? date('Y-m-d H:i:s', strtotime($lastSyncTime)) : '1970-01-01 00:00:00';
    
    // جلب المستفيدين المحدثين
    $stmt = $db->prepare("
        SELECT * FROM beneficiaries 
        WHERE updated_at > ? 
        ORDER BY updated_at ASC 
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $updatedData[] = [
            'entityType' => 'beneficiary',
            'id' => (string)$row['id'],
            'data' => $row,
            'updatedAt' => $row['updated_at'],
            'createdAt' => $row['created_at'] ?? $row['updated_at']
        ];
        $stats['sentCount']++;
    }
    
    // TODO: جلب الزيارات والمرفقات المحدثة بنفس الطريقة
    
    // جلب أفراد العائلة الأحياء المحدثين
    $stmt = $db->prepare("
        SELECT * FROM family_members 
        WHERE updated_at > ? 
        ORDER BY updated_at ASC 
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $updatedData[] = [
            'entityType' => 'family_member',
            'id' => (string)$row['id'],
            'data' => $row,
            'updatedAt' => $row['updated_at'],
            'createdAt' => $row['created_at'] ?? $row['updated_at']
        ];
        $stats['sentCount']++;
    }
    
    // جلب أفراد العائلة الأموات المحدثين
    $stmt = $db->prepare("
        SELECT * FROM family_deceased 
        WHERE updated_at > ? 
        ORDER BY updated_at ASC 
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $updatedData[] = [
            'entityType' => 'family_deceased',
            'id' => (string)$row['id'],
            'data' => $row,
            'updatedAt' => $row['updated_at'],
            'createdAt' => $row['created_at'] ?? $row['updated_at']
        ];
        $stats['sentCount']++;
    }
    
    // ====================================
    // 3. جلب IDs المحذوفة
    // ====================================
    
    $stmt = $db->prepare("
        SELECT entity_id FROM deleted_entities 
        WHERE deleted_at > ? 
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $deletedIds[] = $row['entity_id'];
        $stats['deletedCount']++;
    }
    
    // ====================================
    // 4. حفظ معلومات المزامنة
    // ====================================
    
    $stmt = $db->prepare("
        INSERT INTO sync_history (user_id, device_id, stats, created_at) 
        VALUES (?, ?, ?, NOW())
    ");
    $deviceId = $deviceInfo['deviceId'] ?? 'unknown';
    $statsJson = json_encode($stats);
    $stmt->bind_param("iss", $currentUser['id'], $deviceId, $statsJson);
    $stmt->execute();
    
    // تسجيل النشاط
    logAction($currentUser['id'], 'sync', $stats);
    
    $db->commit();
    
    // الاستجابة
    sendResponse([
        'success' => true,
        'message' => 'تمت المزامنة بنجاح',
        'updatedData' => $updatedData,
        'deletedIds' => $deletedIds,
        'serverTimestamp' => date('c'),
        'failedChanges' => $failedChanges,
        'stats' => $stats
    ], 200);
    
} catch (Exception $e) {
    $db->rollback();
    // سجل التفاصيل على الخادم فقط ولا تكشفها للعميل
    error_log('Sync failed for user ' . $currentUser['id'] . ': ' . $e->getMessage());
    sendError('فشلت المزامنة', 'SYNC_ERROR', 500);
}

// ====================================
// دوال المعالجة
// ====================================

function processBeneficiaryChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        // TODO: تنفيذ إدراج/تحديث المستفيد
        // مثال بسيط:
        $stmt = $db->prepare("
            INSERT INTO beneficiaries (id, full_name, national_id, created_at, updated_at) 
            VALUES (?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE 
                full_name = VALUES(full_name),
                national_id = VALUES(national_id),
                updated_at = NOW()
        ");
        // bind وexecute
        
    } elseif ($operation === 'delete') {
        $stmt = $db->prepare("DELETE FROM beneficiaries WHERE id = ?");
        $stmt->bind_param("s", $entityId);
        $stmt->execute();
        
        // حفظ في جدول المحذوفات
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('beneficiary', ?, NOW())");
        $stmt->bind_param("s", $entityId);
        $stmt->execute();
    }
}

function processVisitChange($db, $operation, $entityId, $data, $userId) {
    // TODO: تنفيذ معالجة الزيارات
}

function processAttachmentChange($db, $operation, $entityId, $data, $userId) {
    // TODO: تنفيذ معالجة المرفقات
}

function processFamilyDeceasedChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $stmt = $db->prepare("
            INSERT INTO family_deceased (
                id, beneficiary_id, full_name, relationship, gender, 
                death_date, death_cause, age_at_death, notes, 
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE 
                beneficiary_id = VALUES(beneficiary_id),
                full_name = VALUES(full_name),
                relationship = VALUES(relationship),
                gender = VALUES(gender),
                death_date = VALUES(death_date),
                death_cause = VALUES(death_cause),
                age_at_death = VALUES(age_at_death),
                notes = VALUES(notes),
                updated_at = NOW()
        ");
        
        $stmt->bind_param(
            "iisssssss",
            $data['id'] ?? $entityId,
            $data['beneficiary_id'],
            $data['full_name'],
            $data['relationship'],
            $data['gender'] ?? null,
            $data['death_date'] ?? null,
            $data['death_cause'] ?? null,
            $data['age_at_death'] ?? null,
            $data['notes'] ?? null
        );
        $stmt->execute();
        
    } elseif ($operation === 'delete') {
        $stmt = $db->prepare("DELETE FROM family_deceased WHERE id = ?");
        $stmt->bind_param("i", $entityId);
        $stmt->execute();
        
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('family_deceased', ?, NOW())");
        $stmt->bind_param("s", $entityId);
        $stmt->execute();
    }
}

function processFamilyMemberChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $stmt = $db->prepare("
            INSERT INTO family_members (
                id, beneficiary_id, full_name, relationship, gender, 
                national_id, birth_date, age, marital_status, education_level,
                occupation, health_status, has_disability, disability_type,
                has_chronic_disease, chronic_disease_type, lives_with_beneficiary,
                phone, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE 
                beneficiary_id = VALUES(beneficiary_id),
                full_name = VALUES(full_name),
                relationship = VALUES(relationship),
                gender = VALUES(gender),
                national_id = VALUES(national_id),
                birth_date = VALUES(birth_date),
                age = VALUES(age),
                marital_status = VALUES(marital_status),
                education_level = VALUES(education_level),
                occupation = VALUES(occupation),
                health_status = VALUES(health_status),
                has_disability = VALUES(has_disability),
                disability_type = VALUES(disability_type),
                has_chronic_disease = VALUES(has_chronic_disease),
                chronic_disease_type = VALUES(chronic_disease_type),
                lives_with_beneficiary = VALUES(lives_with_beneficiary),
                phone = VALUES(phone),
                updated_at = NOW()
        ");
        
        $stmt->bind_param(
            "iisssssississsissis",
            $data['id'] ?? $entityId,
            $data['beneficiary_id'],
            $data['full_name'],
            $data['relationship'],
            $data['gender'] ?? null,
            $data['national_id'] ?? null,
            $data['birth_date'] ?? null,
            $data['age'] ?? null,
            $data['marital_status'] ?? null,
            $data['education_level'] ?? null,
            $data['occupation'] ?? null,
            $data['health_status'] ?? null,
            $data['has_disability'] ?? 0,
            $data['disability_type'] ?? null,
            $data['has_chronic_disease'] ?? 0,
            $data['chronic_disease_type'] ?? null,
            $data['lives_with_beneficiary'] ?? 1,
            $data['phone'] ?? null
        );
        $stmt->execute();
        
    } elseif ($operation === 'delete') {
        $stmt = $db->prepare("DELETE FROM family_members WHERE id = ?");
        $stmt->bind_param("i", $entityId);
        $stmt->execute();
        
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('family_member', ?, NOW())");
        $stmt->bind_param("s", $entityId);
        $stmt->execute();
    }
}
?>
