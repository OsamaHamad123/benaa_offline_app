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

        } catch (Throwable $e) {
            // نلتقط Throwable (وليس Exception فقط) حتى لا يُسقط خطأ فادح المعاملة كلها
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

    // جلب الزيارات المحدثة
    $stmt = $db->prepare("
        SELECT * FROM visits
        WHERE updated_at > ?
        ORDER BY updated_at ASC
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $updatedData[] = [
            'entityType' => 'visit',
            'id' => (string)$row['id'],
            'data' => $row,
            'updatedAt' => $row['updated_at'],
            'createdAt' => $row['created_at'] ?? $row['updated_at']
        ];
        $stats['sentCount']++;
    }

    // جلب المرفقات المحدثة
    $stmt = $db->prepare("
        SELECT * FROM attachments
        WHERE updated_at > ?
        ORDER BY updated_at ASC
        LIMIT 100
    ");
    $stmt->bind_param("s", $lastSyncTimestamp);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $updatedData[] = [
            'entityType' => 'attachment',
            'id' => (string)$row['id'],
            'data' => $row,
            'updatedAt' => $row['updated_at'],
            'createdAt' => $row['created_at'] ?? $row['updated_at']
        ];
        $stats['sentCount']++;
    }

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

} catch (Throwable $e) {
    $db->rollback();
    error_log('Sync failed: ' . $e->getMessage());
    sendError('فشلت المزامنة', 'SYNC_ERROR', 500);
}

// ====================================
// دوال المعالجة
// ====================================

function processBeneficiaryChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        // متغيّرات محلية لأن bind_param يمرّر بالمرجع (لا يقبل التعابير)
        $id         = (int)($data['id'] ?? $entityId);
        $fullName   = $data['full_name'] ?? $data['fullName'] ?? '';
        $nationalId = $data['national_id'] ?? $data['nationalId'] ?? '';
        $phone      = $data['phone'] ?? null;
        $address    = $data['address'] ?? null;
        $notes      = $data['notes'] ?? null;

        $stmt = $db->prepare("
            INSERT INTO beneficiaries (id, full_name, national_id, phone, address, notes, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE
                full_name   = VALUES(full_name),
                national_id = VALUES(national_id),
                phone       = VALUES(phone),
                address     = VALUES(address),
                notes       = VALUES(notes),
                updated_at  = NOW()
        ");
        $stmt->bind_param("isssss", $id, $fullName, $nationalId, $phone, $address, $notes);
        $stmt->execute();

    } elseif ($operation === 'delete') {
        $delId = (int)$entityId;
        $stmt = $db->prepare("DELETE FROM beneficiaries WHERE id = ?");
        $stmt->bind_param("i", $delId);
        $stmt->execute();

        // حفظ في جدول المحذوفات
        $entityIdStr = (string)$entityId;
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('beneficiary', ?, NOW())");
        $stmt->bind_param("s", $entityIdStr);
        $stmt->execute();
    }
}

function processVisitChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $id            = (int)($data['id'] ?? $entityId);
        $beneficiaryId = (int)($data['beneficiary_id'] ?? $data['beneficiaryId'] ?? 0);
        $visitDate     = $data['visit_date'] ?? $data['visitDate'] ?? date('Y-m-d');
        $notes         = $data['notes'] ?? null;
        $createdBy     = (int)($data['created_by'] ?? $userId);

        $stmt = $db->prepare("
            INSERT INTO visits (id, beneficiary_id, visit_date, notes, created_by, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE
                beneficiary_id = VALUES(beneficiary_id),
                visit_date     = VALUES(visit_date),
                notes          = VALUES(notes),
                updated_at     = NOW()
        ");
        $stmt->bind_param("iissi", $id, $beneficiaryId, $visitDate, $notes, $createdBy);
        $stmt->execute();

    } elseif ($operation === 'delete') {
        $delId = (int)$entityId;
        $stmt = $db->prepare("DELETE FROM visits WHERE id = ?");
        $stmt->bind_param("i", $delId);
        $stmt->execute();

        $entityIdStr = (string)$entityId;
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('visit', ?, NOW())");
        $stmt->bind_param("s", $entityIdStr);
        $stmt->execute();
    }
}

function processAttachmentChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $id            = (int)($data['id'] ?? $entityId);
        $beneficiaryId = (int)($data['beneficiary_id'] ?? $data['beneficiaryId'] ?? 0);
        $visitId       = isset($data['visit_id']) && $data['visit_id'] !== null ? (int)$data['visit_id'] : null;
        $fileName      = $data['file_name'] ?? $data['fileName'] ?? '';
        $filePath      = $data['file_path'] ?? $data['filePath'] ?? '';
        $fileType      = $data['file_type'] ?? $data['fileType'] ?? '';
        $fileSize      = (int)($data['file_size'] ?? $data['fileSize'] ?? 0);
        $uploadedBy    = (int)($data['uploaded_by'] ?? $userId);

        $stmt = $db->prepare("
            INSERT INTO attachments (id, beneficiary_id, visit_id, file_name, file_path, file_type, file_size, uploaded_by, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
            ON DUPLICATE KEY UPDATE
                beneficiary_id = VALUES(beneficiary_id),
                visit_id       = VALUES(visit_id),
                file_name      = VALUES(file_name),
                file_path      = VALUES(file_path),
                file_type      = VALUES(file_type),
                file_size      = VALUES(file_size),
                updated_at     = NOW()
        ");
        // 8 متغيّرات: id(i) beneficiary_id(i) visit_id(i) file_name(s) file_path(s) file_type(s) file_size(i) uploaded_by(i)
        $stmt->bind_param("iiisssii", $id, $beneficiaryId, $visitId, $fileName, $filePath, $fileType, $fileSize, $uploadedBy);
        $stmt->execute();

    } elseif ($operation === 'delete') {
        $delId = (int)$entityId;
        $stmt = $db->prepare("DELETE FROM attachments WHERE id = ?");
        $stmt->bind_param("i", $delId);
        $stmt->execute();

        $entityIdStr = (string)$entityId;
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('attachment', ?, NOW())");
        $stmt->bind_param("s", $entityIdStr);
        $stmt->execute();
    }
}

function processFamilyDeceasedChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $id            = (int)($data['id'] ?? $entityId);
        $beneficiaryId = (int)($data['beneficiary_id'] ?? 0);
        $fullName      = $data['full_name'] ?? '';
        $relationship  = $data['relationship'] ?? '';
        $gender        = $data['gender'] ?? 'male';
        $deathDate     = $data['death_date'] ?? null;
        $deathCause    = $data['death_cause'] ?? null;
        $ageAtDeath    = isset($data['age_at_death']) && $data['age_at_death'] !== null ? (int)$data['age_at_death'] : null;
        $notes         = $data['notes'] ?? null;

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

        // 9 متغيّرات — الأنواع: i i s s s s s i s
        $stmt->bind_param(
            "iisssssis",
            $id,
            $beneficiaryId,
            $fullName,
            $relationship,
            $gender,
            $deathDate,
            $deathCause,
            $ageAtDeath,
            $notes
        );
        $stmt->execute();

    } elseif ($operation === 'delete') {
        $delId = (int)$entityId;
        $stmt = $db->prepare("DELETE FROM family_deceased WHERE id = ?");
        $stmt->bind_param("i", $delId);
        $stmt->execute();

        $entityIdStr = (string)$entityId;
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('family_deceased', ?, NOW())");
        $stmt->bind_param("s", $entityIdStr);
        $stmt->execute();
    }
}

function processFamilyMemberChange($db, $operation, $entityId, $data, $userId) {
    if ($operation === 'create' || $operation === 'update') {
        $id                  = (int)($data['id'] ?? $entityId);
        $beneficiaryId       = (int)($data['beneficiary_id'] ?? 0);
        $fullName            = $data['full_name'] ?? '';
        $relationship        = $data['relationship'] ?? '';
        $gender              = $data['gender'] ?? 'male';
        $nationalId          = $data['national_id'] ?? null;
        $birthDate           = $data['birth_date'] ?? null;
        $age                 = isset($data['age']) && $data['age'] !== null ? (int)$data['age'] : null;
        $maritalStatus       = $data['marital_status'] ?? null;
        $educationLevel      = $data['education_level'] ?? null;
        $occupation          = $data['occupation'] ?? null;
        $healthStatus        = $data['health_status'] ?? null;
        $hasDisability       = (int)($data['has_disability'] ?? 0);
        $disabilityType      = $data['disability_type'] ?? null;
        $hasChronicDisease   = (int)($data['has_chronic_disease'] ?? 0);
        $chronicDiseaseType  = $data['chronic_disease_type'] ?? null;
        $livesWithBeneficiary= (int)($data['lives_with_beneficiary'] ?? 1);
        $phone               = $data['phone'] ?? null;

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

        // 18 متغيّراً — الأنواع بالترتيب الصحيح (18 حرفاً):
        // id(i) beneficiary_id(i) full_name(s) relationship(s) gender(s) national_id(s)
        // birth_date(s) age(i) marital_status(s) education_level(s) occupation(s) health_status(s)
        // has_disability(i) disability_type(s) has_chronic_disease(i) chronic_disease_type(s)
        // lives_with_beneficiary(i) phone(s)
        $stmt->bind_param(
            "iisssssissssisisis",
            $id,
            $beneficiaryId,
            $fullName,
            $relationship,
            $gender,
            $nationalId,
            $birthDate,
            $age,
            $maritalStatus,
            $educationLevel,
            $occupation,
            $healthStatus,
            $hasDisability,
            $disabilityType,
            $hasChronicDisease,
            $chronicDiseaseType,
            $livesWithBeneficiary,
            $phone
        );
        $stmt->execute();

    } elseif ($operation === 'delete') {
        $delId = (int)$entityId;
        $stmt = $db->prepare("DELETE FROM family_members WHERE id = ?");
        $stmt->bind_param("i", $delId);
        $stmt->execute();

        $entityIdStr = (string)$entityId;
        $stmt = $db->prepare("INSERT INTO deleted_entities (entity_type, entity_id, deleted_at) VALUES ('family_member', ?, NOW())");
        $stmt->bind_param("s", $entityIdStr);
        $stmt->execute();
    }
}
?>
