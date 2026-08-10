<?php
/**
 * إعدادات قاعدة البيانات والاتصال
 * ضع هذا الملف في مجلد api على السيرفر
 *
 * ⚠️ الأسرار لا تُكتب هنا أبداً:
 * تُقرأ من متغيرات البيئة (Environment Variables) أو من ملف
 * config.local.php غير المتتبع في git (انظر config.local.example.php).
 */

// تحميل الإعدادات المحلية إن وُجدت (خارج نظام git)
if (file_exists(__DIR__ . '/config.local.php')) {
    require_once __DIR__ . '/config.local.php';
}

/**
 * قراءة إعداد من البيئة مع قيمة افتراضية اختيارية
 */
function envOrDefine($key, $default = null) {
    if (defined($key)) {
        return constant($key);
    }
    $value = getenv($key);
    if ($value === false || $value === '') {
        return $default;
    }
    return $value;
}

// إعدادات قاعدة البيانات
// تُقبل الأسماء بصيغة BENAA_* أو الأسماء المجردة (DB_HOST, ...) في البيئة
if (!defined('DB_HOST')) define('DB_HOST', envOrDefine('BENAA_DB_HOST', envOrDefine('DB_HOST', 'localhost')));
if (!defined('DB_USER')) define('DB_USER', envOrDefine('BENAA_DB_USER', envOrDefine('DB_USER')));
if (!defined('DB_PASS')) define('DB_PASS', envOrDefine('BENAA_DB_PASS', envOrDefine('DB_PASS')));
if (!defined('DB_NAME')) define('DB_NAME', envOrDefine('BENAA_DB_NAME', envOrDefine('DB_NAME')));

// إعدادات عامة
if (!defined('JWT_SECRET')) define('JWT_SECRET', envOrDefine('BENAA_JWT_SECRET', envOrDefine('JWT_SECRET')));
if (!defined('TOKEN_EXPIRY')) define('TOKEN_EXPIRY', 86400); // 24 ساعة

// حماية من محاولات تخمين كلمة المرور (Brute Force)
if (!defined('MAX_LOGIN_ATTEMPTS')) define('MAX_LOGIN_ATTEMPTS', 5);
if (!defined('LOGIN_LOCKOUT_MINUTES')) define('LOGIN_LOCKOUT_MINUTES', 15);

// التأكد من اكتمال الإعدادات قبل التشغيل
if (!DB_USER || !DB_PASS || !DB_NAME || !JWT_SECRET) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    die(json_encode([
        'success' => false,
        'message' => 'الخادم غير مُهيأ. راجع config.local.example.php',
    ], JSON_UNESCAPED_UNICODE));
}

/**
 * الاتصال بقاعدة البيانات
 */
function getDB() {
    static $conn = null;

    if ($conn === null) {
        mysqli_report(MYSQLI_REPORT_OFF);
        $conn = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

        if ($conn->connect_error) {
            // لا تكشف تفاصيل الخطأ للعميل — سجلها على الخادم فقط
            error_log('DB connection failed: ' . $conn->connect_error);
            http_response_code(500);
            die(json_encode([
                'success' => false,
                'message' => 'فشل الاتصال بقاعدة البيانات'
            ], JSON_UNESCAPED_UNICODE));
        }

        $conn->set_charset("utf8mb4");
    }

    return $conn;
}

/**
 * إعدادات Headers للاستجابة
 */
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: no-referrer');

// CORS: يُسمح فقط بالأصل المحدد صراحةً في الإعدادات (التطبيق الجوال لا يحتاج CORS)
$corsOrigin = envOrDefine('BENAA_CORS_ORIGIN', envOrDefine('ALLOWED_ORIGIN', ''));
if ($corsOrigin !== '') {
    header('Access-Control-Allow-Origin: ' . $corsOrigin);
    header('Vary: Origin');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
}

// معالجة OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

/**
 * قراءة JSON من الطلب
 */
function getRequestData() {
    $json = file_get_contents('php://input');
    return json_decode($json, true) ?? [];
}

/**
 * إرسال استجابة JSON
 */
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * إرسال خطأ
 */
function sendError($message, $code = 'ERROR', $statusCode = 400) {
    sendResponse([
        'success' => false,
        'message' => $message,
        'errorCode' => $code
    ], $statusCode);
}

/**
 * الحصول على Token من Header
 */
function getBearerToken() {
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $authHeader = $headers['Authorization'] ?? $headers['authorization']
        ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        return null;
    }

    return substr($authHeader, 7);
}

/**
 * تجزئة الـ Token قبل تخزينه أو مقارنته
 * (تُخزن التجزئة فقط في قاعدة البيانات حتى لا تكون الرموز صالحة عند تسرب البيانات)
 */
function hashToken($token) {
    return hash_hmac('sha256', $token, JWT_SECRET);
}

/**
 * التحقق من Token
 */
function verifyToken() {
    $token = getBearerToken();

    if (!$token) {
        sendError('غير مصرح - يرجى تسجيل الدخول', 'UNAUTHORIZED', 401);
    }

    $db = getDB();
    $tokenHash = hashToken($token);
    $stmt = $db->prepare("SELECT id, email, name FROM users WHERE token = ? AND token_expires_at > NOW() AND is_active = 1");
    $stmt->bind_param("s", $tokenHash);
    $stmt->execute();
    $result = $stmt->get_result();

    if (!($user = $result->fetch_assoc())) {
        sendError('Token غير صالح أو منتهي الصلاحية', 'INVALID_TOKEN', 401);
    }

    return $user;
}

/**
 * تسجيل Log
 */
function logAction($userId, $action, $details = null) {
    $db = getDB();
    $stmt = $db->prepare("INSERT INTO activity_logs (user_id, action, details, created_at) VALUES (?, ?, ?, NOW())");
    $detailsJson = $details ? json_encode($details) : null;
    $stmt->bind_param("iss", $userId, $action, $detailsJson);
    $stmt->execute();
}
?>
