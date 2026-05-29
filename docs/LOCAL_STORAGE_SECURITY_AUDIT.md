# Local Storage Security Audit

**تاريخ المراجعة**: 2025  
**المدقق**: GitHub Copilot — Security Hardening Plan  
**المشروع**: Benaa Offline App (Gaza/Cedar)

---

## ملخص التخزين المحلي

| المكوّن                | الغرض                             | التشفير                               | الموقع           | مستوى الحساسية |
| ---------------------- | --------------------------------- | ------------------------------------- | ---------------- | -------------- |
| `FlutterSecureStorage` | tokens, email, deviceId, password | ✅ مشفّر (EncryptedSharedPreferences) | Android Keystore | عالٍ جداً      |
| SQLite (sqflite)       | بيانات المستفيدين المحلية         | ❌ غير مشفّر                          | files/databases/ | عالٍ جداً      |
| SharedPreferences      | إعدادات تطبيق، flags              | ❌ غير مشفّر                          | shared_prefs/    | منخفض          |
| Cache (http/images)    | بيانات مؤقتة                      | ❌ غير مشفّر                          | cache/           | منخفض          |

---

## FlutterSecureStorage — المفاتيح المخزّنة

```dart
// في lib/core/services/secure_storage.dart
class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _deviceIdKey = 'device_id';
  static const _passwordKey = 'user_password'; // ⚠️ تخزين كلمة المرور!
}
```

### ملاحظات أمنية:

| المفتاح         | المخاطرة                     | التوصية               |
| --------------- | ---------------------------- | --------------------- |
| `auth_token`    | منخفض — مشفّر                | ✅ مقبول              |
| `refresh_token` | منخفض — مشفّر                | ✅ مقبول              |
| `user_email`    | منخفض — مشفّر                | ✅ مقبول              |
| `device_id`     | منخفض — مشفّر                | ✅ مقبول              |
| `user_password` | **عالٍ** — تخزين كلمة المرور | ⚠️ يُفضّل عدم التخزين |

---

## SQLite — قاعدة البيانات المحلية

### الوضع الحالي

- **الملف**: `beneficiaries.db` في مجلد app documents
- **التشفير**: ❌ **غير مشفّر**
- **البيانات المخزّنة**: اسم المستفيد، الرقم الوطني، الهاتف، العنوان، بيانات الأسرة

### الخطر

إذا تمكّن شخص من الوصول الجذري (root) للجهاز أو من نسخ ملف `.db`، يمكنه قراءة جميع بيانات المستفيدين.

### الحل المقترح (P2)

استخدام `sqflite_sqlcipher` (المُدرج بالفعل في `pubspec.yaml`) لتشفير قاعدة البيانات:

```yaml
# pubspec.yaml - مُدرج بالفعل
sqflite_sqlcipher: ^2.x.x
```

**ملاحظة**: تفعيل SQLCipher يتطلب migration plan — موثّق كـ P2 في خطة الأمان.

---

## إجراءات إعادة تعيين البيانات المحلية

| الإجراء                          | يؤثر على Firebase؟ | يطلب تأكيداً؟   | الحالة                  |
| -------------------------------- | ------------------ | --------------- | ----------------------- |
| `resetBeneficiariesAndRestore()` | ❌ محلي فقط        | ✅ يطلب تأكيداً | آمن ✅                  |
| `resetTaxonomiesOnly()`          | ❌ محلي فقط        | ✅ يطلب تأكيداً | آمن ✅ (بعد تحديث 2025) |
| `resetFileNumbersOnly()`         | ❌ محلي فقط        | ✅ يطلب تأكيداً | آمن ✅ (بعد تحديث 2025) |
| `clearSecureStorage()`           | ❌ محلي فقط        | ⚠️ لا تأكيد     | يُوصى بإضافة تأكيد      |

---

## SharedPreferences — البيانات المخزّنة

البيانات المؤقتة فقط (flags، settings)، لا تحتوي على بيانات حساسة.  
الوضع: ✅ مقبول

---

## توصيات P0-P3

| الأولوية | الإجراء                                                   | الجهد |
| -------- | --------------------------------------------------------- | ----- |
| P1 ✅    | التحقق أن reset actions لا تمسح Firebase                  | تم    |
| P1 ✅    | إضافة تأكيد لـ resetTaxonomiesOnly و resetFileNumbersOnly | تم    |
| P2       | تفعيل SQLCipher لتشفير قاعدة البيانات المحلية             | كبير  |
| P2       | مراجعة تخزين `user_password` في SecureStorage             | متوسط |
| P3       | مراجعة ملف cache للصور والملفات                           | صغير  |

---

_آخر تحديث: 2025 — ضمن Security & Privacy Hardening Plan_
