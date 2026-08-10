<?php
/**
 * مثال لملف الإعدادات المحلية
 *
 * انسخ هذا الملف إلى config.local.php على السيرفر واملأ القيم الحقيقية.
 * ملف config.local.php غير متتبع في git ويجب ألا يُرفع إلى المستودع أبداً.
 *
 * بدلاً من ذلك يمكن ضبط نفس القيم كمتغيرات بيئة:
 * BENAA_DB_HOST, BENAA_DB_USER, BENAA_DB_PASS, BENAA_DB_NAME, BENAA_JWT_SECRET
 */

define('DB_HOST', 'localhost');
define('DB_USER', '');   // اسم مستخدم قاعدة البيانات
define('DB_PASS', '');   // كلمة مرور قاعدة البيانات
define('DB_NAME', '');   // اسم قاعدة البيانات

// أنشئ مفتاحاً عشوائياً قوياً، مثلاً: php -r "echo bin2hex(random_bytes(32));"
define('JWT_SECRET', '');

// اختياري: السماح بـ CORS لأصل واحد محدد (اتركه فارغاً للتطبيق الجوال)
// define('BENAA_CORS_ORIGIN', 'https://example.com');
?>
