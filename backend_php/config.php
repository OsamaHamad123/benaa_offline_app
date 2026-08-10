<?php
/**
 * إعدادات قاعدة البيانات والاتصال
 * ضع هذا الملف في مجلد api على السيرفر.
 *
 * ⚠️ الأسرار تُقرأ من متغيرات البيئة (environment variables) ولا تُكتب في الكود.
 * على الاستضافة، عرّفها في لوحة التحكم أو في ملف .env خارج مجلد الويب،
 * أو أنشئ ملف config.local.php (غير متتبَّع في git) يعرّف الثوابت التالية.
 */

// تحميل إعدادات محلية غير متتبَّعة في git إن وُجدت (اختياري)
if (file_exists(__DIR__ . '/config.local.php')) {
    require_once __DIR__ . '/config.local.php';
}

/**
 * قارئ متغيّر بيئة مع قيمة افتراضية.
 */
function env_value($key, $default = null) {
    $value = getenv($key);
    if ($value === false || $value === '') {
        return $default;
    }
    return $value;
}

// إعدادات قاعدة البيانات — تُقرأ من البيئة (لا تضع بيانات إنتاج حقيقية هنا)
if (!defined('DB_HOST')) define('DB_HOST', env_value('DB_HOST', 'localhost'));
if (!defined('DB_USER')) define('DB_USER', env_value('DB_USER', 'CHANGE_ME'));
if (!defined('DB_PASS')) define('DB_PASS', env_value('DB_PASS', 'CHANGE_ME'));
if (!defined('DB_NAME')) define('DB_NAME', env_value('DB_NAME', 'CHANGE_ME'));

// إعدادات عامة
if (!defined('JWT_SECRET')) define('JWT_SECRET', env_value('JWT_SECRET', 'CHANGE_ME'));
if (!defined('TOKEN_EXPIRY')) define('TOKEN_EXPIRY', (int)env_value('TOKEN_EXPIRY', 86400)); // 24 ساعة

// أصل مسموح به لطلبات CORS (يمكن حصره في الإنتاج على نطاق لوحة الإدارة)
if (!defined('ALLOWED_ORIGIN')) define('ALLOWED_ORIGIN', env_value('ALLOWED_ORIGIN', '*'));

/**
 * الاتصال بقاعدة البيانات
 */
function getDB() {
    static $conn = null;

    if ($conn === null) {
        // كبت تحذيرات mysqli التلقائية حتى لا تتسرّب تفاصيل الاتصال
        mysqli_report(MYSQLI_REPORT_OFF);
        $conn = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

        if ($conn->connect_error) {
            // لا نكشف تفاصيل الخطأ الداخلية للعميل
            error_log('DB connection failed: ' . $conn->connect_error);
            http_response_code(500);
            die(json_encode([
                'success' => false,
                'message' => 'تعذّر الاتصال بقاعدة البيانات'
            ]));
        }

        $conn->set_charset("utf8mb4");
    }

    return $conn;
}

/**
 * إعدادات Headers للسماح بالطلبات من التطبيق
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: ' . ALLOWED_ORIGIN);
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

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
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        return null;
    }

    return substr($authHeader, 7);
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
    $stmt = $db->prepare("SELECT id, email, name FROM users WHERE token = ? AND token_expires_at > NOW()");
    $stmt->bind_param("s", $token);
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
