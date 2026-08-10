<?php
/**
 * ملف اختبار API
 * المسار: /api/test.php
 */

require_once 'config.php';

// لا تكشف أي تفاصيل عن الخادم أو قاعدة البيانات هنا
getDB(); // يفشل الطلب برسالة عامة إذا تعذر الاتصال

sendResponse([
    'status' => 'OK',
    'message' => '✅ API يعمل بنجاح!',
    'timestamp' => date('Y-m-d H:i:s')
], 200);
?>
