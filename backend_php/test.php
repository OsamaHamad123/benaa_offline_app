<?php
/**
 * ملف اختبار API
 * المسار: /api/test.php
 */

require_once 'config.php';

sendResponse([
    'status' => 'OK',
    'message' => '✅ API يعمل بنجاح!',
    'timestamp' => date('Y-m-d H:i:s'),
    'server_time' => time(),
    'php_version' => phpversion(),
    'database' => [
        'host' => DB_HOST,
        'name' => DB_NAME,
        'connected' => true
    ]
], 200);
?>
