# 🚀 دليل رفع Backend على السيرفر

## 📋 الملفات الجاهزة

تم إنشاء نظام Backend كامل بـ PHP في مجلد `backend_php/`:

```
backend_php/
├── config.php                    ← منطق الإعدادات (بدون أسرار)
├── config.local.example.php      ← قالب الأسرار — انسخه إلى config.local.php على السيرفر
├── test.php               ← ملف اختبار API
├── sync.php               ← API المزامنة
├── database_setup.sql     ← سكريبت SQL لإنشاء الجداول
├── auth/
│   ├── login.php         ← تسجيل الدخول
│   └── logout.php        ← تسجيل الخروج
└── README.md             ← هذا الملف
```

---

## ⚙️ خطوات الإعداد

### **الخطوة 1: إنشاء ملف الإعدادات المحلي**

**لا تضع الأسرار في `config.php` أبداً** — فهو متتبع في git.

انسخ `config.local.example.php` إلى `config.local.php` على السيرفر واملأ القيم:

```php
define('DB_USER', 'اسم_المستخدم');
define('DB_PASS', 'كلمة_سر_قاعدة_البيانات');
define('DB_NAME', 'اسم_قاعدة_البيانات');
define('JWT_SECRET', 'مفتاح-عشوائي-قوي');
```

**لتوليد مفتاح سري قوي:**
```bash
php -r "echo bin2hex(random_bytes(32));"
```

بدلاً من الملف يمكنك ضبط متغيرات البيئة:
`BENAA_DB_HOST`, `BENAA_DB_USER`, `BENAA_DB_PASS`, `BENAA_DB_NAME`, `BENAA_JWT_SECRET`

---

### **الخطوة 2: رفع الملفات للسيرفر**

#### **باستخدام FileZilla أو FTP:**

1. اتصل بالسيرفر عبر FTP
2. ارفع محتويات مجلد `backend_php` إلى مجلد `public_html/api/`

**الهيكل النهائي على السيرفر:**
```
public_html/
└── api/
    ├── config.php
    ├── test.php
    ├── sync.php
    ├── database_setup.sql
    └── auth/
        ├── login.php
        └── logout.php
```

#### **باستخدام لوحة التحكم cPanel:**

1. افتح **File Manager**
2. اذهب إلى `public_html`
3. أنشئ مجلد `api`
4. ارفع الملفات داخله

---

### **الخطوة 3: إنشاء الجداول في قاعدة البيانات**

1. افتح **phpMyAdmin**
2. اختر قاعدة البيانات الخاصة بك
3. اذهب إلى تبويب **SQL**
4. انسخ محتوى ملف `database_setup.sql` بالكامل
5. الصقه واضغط **Go**

✅ سيتم إنشاء جميع الجداول المطلوبة!

---

### **الخطوة 4: اختبار API**

افتح المتصفح واذهب إلى:

```
https://نطاقك.com/api/test.php
```

**يجب أن ترى:**
```json
{
  "status": "OK",
  "message": "✅ API يعمل بنجاح!",
  "timestamp": "2024-11-20 10:30:00",
  ...
}
```

---

### **الخطوة 5: تحديث التطبيق**

في ملف `lib/core/config/api_config.dart`:

```dart
static const String defaultBaseUrl = 'https://نطاقك.com/api';
```

**استبدل `نطاقك.com` بالنطاق الفعلي!**

---

## 🔐 إنشاء حساب المدير

لا يُنشئ السكريبت أي حساب افتراضي. أنشئ حسابك بكلمة مرور قوية:

```bash
php -r "echo password_hash('كلمة-مرور-قوية', PASSWORD_DEFAULT);"
```

ثم في phpMyAdmin:

```sql
INSERT INTO users (email, name, password_hash, role)
VALUES ('you@example.com', 'المدير', '<الصق-التجزئة-هنا>', 'admin');
```

---

## 🧪 اختبار تسجيل الدخول

باستخدام **Postman** أو **cURL**:

```bash
POST https://نطاقك.com/api/auth/login.php

Body (JSON):
{
  "email": "you@example.com",
  "password": "كلمة-المرور-التي-أنشأتها",
  "deviceId": "test_device"
}

Response:
{
  "success": true,
  "token": "abc123...",
  "user": {
    "id": "1",
    "email": "you@example.com",
    "name": "المدير",
    "role": "admin"
  }
}
```

---

## 📝 ملاحظات مهمة

### **1. الأمان**
- ⚠️ الأسرار في `config.local.php` أو متغيرات البيئة فقط — لا ترفعها إلى git أبداً
- ⚠️ استخدم HTTPS في الإنتاج
- 🔒 تُخزن رموز الجلسات (tokens) مُجزّأة في قاعدة البيانات
- 🔒 تسجيل الدخول محمي بقفل مؤقت بعد 5 محاولات فاشلة خلال 15 دقيقة

### **2. الأداء**
- الكود مبسّط للبداية
- يمكن تحسينه لاحقاً
- يدعم حتى 100 سجل في كل مزامنة

### **3. التطوير**
- دوال المزامنة `processBeneficiaryChange` و`processVisitChange` تحتاج تنفيذ كامل
- يمكن إضافة ميزات مثل:
  - رفع الملفات
  - إشعارات Push
  - تصدير التقارير

---

## ❓ حل المشاكل الشائعة

### **خطأ 500 Internal Server Error**
- تحقق من كلمة السر في `config.local.php`
- تحقق من أذونات الملفات (755 للمجلدات، 644 للملفات)

### **خطأ في الاتصال بقاعدة البيانات**
- تأكد من صحة بيانات الاتصال في `config.local.php`
- تأكد من أن قاعدة البيانات موجودة

### **خطأ 404 Not Found**
- تأكد من رفع الملفات في المكان الصحيح
- تحقق من رابط API في التطبيق

---

## 🎉 الخطوات التالية

بعد رفع Backend:

1. ✅ اختبر `test.php`
2. ✅ اختبر تسجيل الدخول من Postman
3. ✅ حدّث `api_config.dart` في التطبيق
4. ✅ جرّب تسجيل الدخول من التطبيق
5. ✅ جرّب المزامنة

---

**كل شيء جاهز! 🚀**
