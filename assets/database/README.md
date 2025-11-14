# 🔧 Development Database

## 📂 المجلد هذا لقاعدة البيانات في وضع التطوير

### كيف تستخدمه:

1. **ضع ملف `persons.db` في هذا المجلد**
   ```
   assets/database/persons.db
   ```

2. **تأكد من تفعيل وضع التطوير:**
   ```dart
   // في civil_db_manager.dart
   static const bool isDevelopmentMode = true; // ✅
   ```

3. **شغّل التطبيق:**
   - التطبيق سينسخ الملف من Assets تلقائياً
   - أسرع من التنزيل من الإنترنت
   - مناسب للتطوير والاختبار

---

## 🚀 للإنتاج (Production):

عند الانتهاء من التطوير:

```dart
// في civil_db_manager.dart
static const bool isDevelopmentMode = false; // ❌
```

الآن التطبيق سينزل الملف من URL المحدد في `download_civil_db_page.dart`

---

## ⚠️ ملاحظة مهمة:

**لا تنسخ ملفات كبيرة (4GB) إلى Git!**
- أضف `*.db` إلى `.gitignore`
- الملف هذا للتطوير المحلي فقط
