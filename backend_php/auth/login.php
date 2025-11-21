<?php
/**
 * API تسجيل الدخول
 * المسار: /api/auth/login.php
 */

require_once '../config.php';

// قراءة البيانات
$data = getRequestData();
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';
$deviceId = $data['deviceId'] ?? '';

// التحقق من البيانات المطلوبة
if (empty($email) || empty($password)) {
    sendError('الرجاء إدخال البريد الإلكتروني وكلمة السر', 'MISSING_FIELDS', 400);
}

$db = getDB();

// البحث عن المستخدم
$stmt = $db->prepare("SELECT id, email, name, password_hash, role FROM users WHERE email = ? AND is_active = 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if (!($user = $result->fetch_assoc())) {
    sendError('البريد الإلكتروني أو كلمة السر غير صحيحة', 'INVALID_CREDENTIALS', 401);
}

// التحقق من كلمة السر
if (!password_verify($password, $user['password_hash'])) {
    // تسجيل محاولة فاشلة
    $stmt = $db->prepare("INSERT INTO login_attempts (email, success, ip_address, created_at) VALUES (?, 0, ?, NOW())");
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $stmt->bind_param("ss", $email, $ip);
    $stmt->execute();
    
    sendError('البريد الإلكتروني أو كلمة السر غير صحيحة', 'INVALID_CREDENTIALS', 401);
}

// توليد Token جديد
$token = bin2hex(random_bytes(32));
$expiresAt = date('Y-m-d H:i:s', time() + TOKEN_EXPIRY);

// حفظ Token في قاعدة البيانات
$stmt = $db->prepare("UPDATE users SET token = ?, token_expires_at = ?, last_login = NOW(), device_id = ? WHERE id = ?");
$stmt->bind_param("sssi", $token, $expiresAt, $deviceId, $user['id']);
$stmt->execute();

// تسجيل محاولة ناجحة
$stmt = $db->prepare("INSERT INTO login_attempts (email, success, ip_address, created_at) VALUES (?, 1, ?, NOW())");
$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$stmt->bind_param("ss", $email, $ip);
$stmt->execute();

// تسجيل النشاط
logAction($user['id'], 'login', ['device_id' => $deviceId, 'ip' => $ip]);

// الاستجابة
sendResponse([
    'success' => true,
    'token' => $token,
    'refreshToken' => null, // يمكن إضافة refresh token لاحقاً
    'user' => [
        'id' => (string)$user['id'],
        'email' => $user['email'],
        'name' => $user['name'],
        'role' => $user['role'] ?? 'user'
    ]
], 200);
?>
