<?php
/**
 * API تسجيل الخروج
 * المسار: /api/auth/logout.php
 */

require_once '../config.php';

// التحقق من Token
$user = verifyToken();

$db = getDB();

// حذف Token
$stmt = $db->prepare("UPDATE users SET token = NULL, token_expires_at = NULL WHERE id = ?");
$stmt->bind_param("i", $user['id']);
$stmt->execute();

// تسجيل النشاط
logAction($user['id'], 'logout');

sendResponse([
    'success' => true,
    'message' => 'تم تسجيل الخروج بنجاح'
], 200);
?>
