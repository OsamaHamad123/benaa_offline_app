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
$deviceId = substr(trim($data['deviceId'] ?? ''), 0, 100);

// التحقق من البيانات المطلوبة
if (empty($email) || empty($password)) {
    sendError('الرجاء إدخال البريد الإلكتروني وكلمة السر', 'MISSING_FIELDS', 400);
}

$db = getDB();
$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

// 🛡️ حماية من تخمين كلمة المرور: قفل مؤقت بعد عدة محاولات فاشلة
$stmt = $db->prepare("
    SELECT COUNT(*) AS attempts FROM login_attempts
    WHERE success = 0
      AND created_at > DATE_SUB(NOW(), INTERVAL " . (int)LOGIN_LOCKOUT_MINUTES . " MINUTE)
      AND (email = ? OR ip_address = ?)
");
$stmt->bind_param("ss", $email, $ip);
$stmt->execute();
$attempts = (int)($stmt->get_result()->fetch_assoc()['attempts'] ?? 0);

if ($attempts >= MAX_LOGIN_ATTEMPTS) {
    sendError('عدد محاولات كبير. حاول مرة أخرى لاحقاً', 'TOO_MANY_ATTEMPTS', 429);
}

// البحث عن المستخدم
$stmt = $db->prepare("SELECT id, email, name, password_hash, role FROM users WHERE email = ? AND is_active = 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

// التحقق من كلمة السر (مع مقاومة هجمات التوقيت وتعداد المستخدمين)
$validPassword = $user !== null && password_verify($password, $user['password_hash']);
if (!$user) {
    // مقارنة وهمية حتى يتساوى زمن الاستجابة سواء وُجد المستخدم أم لا
    password_verify($password, '$2y$10$usesomesillystringfore7hnbRJHxXVLeakoG8K30oukPsA.ztMG');
}

if (!$validPassword) {
    // تسجيل محاولة فاشلة
    $stmt = $db->prepare("INSERT INTO login_attempts (email, success, ip_address, created_at) VALUES (?, 0, ?, NOW())");
    $stmt->bind_param("ss", $email, $ip);
    $stmt->execute();

    sendError('البريد الإلكتروني أو كلمة السر غير صحيحة', 'INVALID_CREDENTIALS', 401);
}

// توليد Token جديد — يُرسل الأصلي للعميل وتُخزن تجزئته فقط
$token = bin2hex(random_bytes(32));
$tokenHash = hashToken($token);
$expiresAt = date('Y-m-d H:i:s', time() + TOKEN_EXPIRY);

// حفظ تجزئة Token في قاعدة البيانات
$stmt = $db->prepare("UPDATE users SET token = ?, token_expires_at = ?, last_login = NOW(), device_id = ? WHERE id = ?");
$stmt->bind_param("sssi", $tokenHash, $expiresAt, $deviceId, $user['id']);
$stmt->execute();

// تسجيل محاولة ناجحة
$stmt = $db->prepare("INSERT INTO login_attempts (email, success, ip_address, created_at) VALUES (?, 1, ?, NOW())");
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
