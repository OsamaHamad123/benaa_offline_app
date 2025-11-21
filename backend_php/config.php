<?php
/**
 * إعدادات قاعدة البيانات والاتصال
 * ضع هذا الملف في مجلد api على السيرفر
 */

// إعدادات قاعدة البيانات (من phpMyAdmin)
define('DB_HOST', 'localhost');
define('DB_USER', 'u983550065_pa_benaa101');     // اسم المستخدم
define('DB_PASS', 'Mfarra4121989163@@');      // ⚠️ غيّر هذا!
define('DB_NAME', 'u983550065_aso101');     // اسم قاعدة البيانات

// إعدادات عامة
define('JWT_SECRET', 'Osama123@#$'); // ⚠️ غيّر هذا!
define('TOKEN_EXPIRY', 86400); // 24 ساعة

/**
 * الاتصال بقاعدة البيانات
 */
function getDB() {
    static $conn = null;
    
    if ($conn === null) {
        $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        
        if ($conn->connect_error) {
            http_response_code(500);
            die(json_encode([
                'success' => false,
                'message' => 'فشل الاتصال بقاعدة البيانات: ' . $conn->connect_error
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
header('Access-Control-Allow-Origin: *');
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
    $headers = getallheaders();
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
