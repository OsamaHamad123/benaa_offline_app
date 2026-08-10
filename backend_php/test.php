<?php
/**
 * ملف اختبار API
 * المسار: /api/test.php
 *
 * لا يكشف أي تفاصيل عن قاعدة البيانات أو الخادم.
 */

require_once 'config.php';

sendResponse([
    'status' => 'OK',
    'message' => '✅ API يعمل بنجاح!',
    'timestamp' => date('Y-m-d H:i:s')
], 200);
?>
