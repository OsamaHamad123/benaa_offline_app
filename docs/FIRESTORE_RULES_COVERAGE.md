# Firestore Rules Coverage Audit

**تاريخ المراجعة**: 2025  
**المدقق**: GitHub Copilot — Security Hardening Plan  
**المشروع**: Benaa Offline App (Gaza/Cedar)

---

## ملخص التغطية

| المجموعة                  | الوحدة (Module)  | قراءة        | كتابة        | مناسبة للتطوير | خطر الإنتاج | الحالة                          |
| ------------------------- | ---------------- | ------------ | ------------ | -------------- | ----------- | ------------------------------- |
| `beneficiaries`           | إدارة المستفيدين | مصادق ✅     | مصادق ✅     | ✅ مناسبة      | متوسط       | ⚠️ يحتاج role-based write       |
| `visits`                  | زيارات ميدانية   | مصادق ✅     | مصادق ✅     | ✅ مناسبة      | متوسط       | ⚠️ يحتاج role-based write       |
| `kafalat`                 | كفالات           | مصادق ✅     | مصادق ✅     | ✅ مناسبة      | متوسط       | ⚠️ يحتاج role-based write       |
| `associations`            | جمعيات           | مصادق ✅     | مصادق ✅     | ✅ مناسبة      | متوسط       | ⚠️ قاعدة مكررة تُبطل admin-only |
| `taxonomy_categories`     | التصنيفات        | مصادق ✅     | مصادق ⚠️     | ✅ مناسبة      | **عالٍ P1** | ❌ يجب تقييد بـ isAdmin()       |
| `taxonomy_groups`         | التصنيفات        | مصادق ✅     | مصادق ⚠️     | ✅ مناسبة      | **عالٍ P1** | ❌ يجب تقييد بـ isAdmin()       |
| `file_number_counters`    | أرقام الملفات    | auth ✅      | auth ⚠️      | ✅ مناسبة      | **عالٍ P1** | ❌ يجب تقييد الأدوار            |
| `file_number_blocks`      | أرقام الملفات    | auth ✅      | auth ⚠️      | ✅ مناسبة      | **عالٍ P1** | ❌ يجب تقييد الأدوار            |
| `file_number_allocations` | أرقام الملفات    | auth ✅      | auth ⚠️      | ✅ مناسبة      | **عالٍ P1** | ❌ يجب تقييد الأدوار            |
| `users`                   | المستخدمون       | مالك فقط ✅  | مالك فقط ✅  | ✅ مناسبة      | منخفض       | ✅ آمن                          |
| `admin_config`            | إدارة النظام     | admin فقط ✅ | admin فقط ✅ | ✅ مناسبة      | منخفض       | ✅ آمن                          |
| `sync_logs`               | مزامنة البيانات  | مصادق ✅     | مصادق ✅     | ✅ مناسبة      | منخفض-متوسط | ✅ مقبول                        |

---

## المشكلات الحرجة

### ⚠️ P1 — taxonomy_categories / taxonomy_groups (كتابة مفتوحة لجميع المصادقين)

**المشكلة**: أي مستخدم مصادق يمكنه حذف أو تعديل التصنيفات.  
**التأثير**: مستخدم field_worker يمكنه مسح تصنيفات النظام.  
**الحل المقترح**:

```javascript
// في firestore.rules
match /taxonomy_categories/{docId} {
  allow read: if isAuthenticated();
  allow create, update, delete: if isAdmin(); // دالة isAdmin() التي تتحقق من custom claims
}
```

### ⚠️ P1 — file_number_counters / file_number_blocks / file_number_allocations

**المشكلة**: write مفتوح لأي `request.auth != null` — يسمح بتعديل عدادات أرقام الملفات.  
**التأثير**: قد يحجز مستخدم عدداً كبيراً من أرقام الملفات أو يتلاعب بالعدادات.  
**الحل المقترح**:

```javascript
match /file_number_counters/{counterId} {
  allow read: if isAuthenticated();
  allow write: if isAdmin() || isFieldWorker(); // دور محدد فقط
}
```

---

## دوال المساعدة المقترحة في Firestore Rules

```javascript
function isAuthenticated() {
  return request.auth != null;
}

function isAdmin() {
  return isAuthenticated() && request.auth.token.admin == true;
}

function isFieldWorker() {
  return (
    isAuthenticated() &&
    (request.auth.token.role == 'field_worker' || isAdmin())
  );
}

function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

---

## الوضع الحالي (بعد تدقيق 2025)

- ✅ حماية البيانات الشخصية للمستفيدين — auth.uid مطلوب
- ✅ حماية بيانات الزيارات والكفالات — auth.uid مطلوب
- ⚠️ التصنيفات — كتابة مفتوحة لجميع المصادقين (P1)
- ⚠️ أرقام الملفات — كتابة مفتوحة لجميع المصادقين (P1)
- ❌ لا يوجد تحقق من الدور في قواعد Firestore (custom claims غير مستخدمة)

---

## خطوات العمل التالية

1. **P1**: إضافة `isAdmin()` helper في `firestore.rules`
2. **P1**: تقييد كتابة `taxonomy_categories` و `taxonomy_groups` للمشرفين فقط
3. **P1**: تقييد كتابة `file_number_*` للأدوار المناسبة
4. **P2**: اختبار القواعد بـ Firebase Emulator Suite
5. **P2**: توثيق كل collection في هذا الملف

---

_ملاحظة: هذا الملف يُحدَّث مع كل تغيير في `firestore.rules`_

---

## Sync Pipeline Verification Status (2026-05-28)

**المرحلة**: Sync & Firebase Pipeline Stabilization

### مجموعات تم التحقق من توافقها مع pipeline المزامنة

| المجموعة                  | رفع ✅/⚠️/❌  | تنزيل ✅/⚠️/❌ | ملاحظة                                           |
| ------------------------- | ------------- | -------------- | ------------------------------------------------ |
| `beneficiaries`           | ✅ مصادق      | ✅ مصادق       | auth مطلوب — الأكثر اختباراً                     |
| `beneficiary_visits`      | ✅ مصادق      | ✅ مصادق       | `allow read, write: if auth != null`             |
| `beneficiary_followups`   | ✅ مصادق      | ✅ مصادق       | `allow read, write: if auth != null`             |
| `sponsorships`            | ⚠️ admin-only | ✅ مصادق       | **P0 Production Risk**: upload يفشل لغير admin   |
| `sponsorship_files`       | ✅ مصادق      | —              | auth مطلوب                                       |
| `sponsorship_candidates`  | ✅ مصادق      | —              | auth مطلوب                                       |
| `sponsorship_payments`    | ✅ مصادق      | —              | auth مطلوب                                       |
| `associations`            | ⚠️ admin-only | ✅ مصادق       | **P0 Production Risk**: upload يفشل لغير admin   |
| `association_contacts`    | ✅ مصادق      | ✅ مصادق       | `allow create, update: if isAuthenticated()`     |
| `taxonomy_categories`     | ✅ مصادق      | ✅ مصادق       | ⚠️ كتابة مفتوحة (راجع P1 فوق)                    |
| `taxonomy_groups`         | ✅ مصادق      | ✅ مصادق       | ⚠️ كتابة مفتوحة (راجع P1 فوق)                    |
| `file_number_counters`    | ✅ مصادق      | ✅ مصادق       | auth فقط — P1 risk                               |
| `file_number_blocks`      | ✅ مصادق      | ✅ مصادق       | auth فقط — لا composite index مطلوب (local sort) |
| `file_number_allocations` | ✅ مصادق      | ✅ مصادق       | auth فقط                                         |
| `sync_health_checks`      | ✅ مصادق      | ✅ مصادق       | `allow read, write: if auth != null`             |

### ثغرات الصلاحيات في Pipeline (مؤرشفة للإنتاج)

**P0 — Sponsorships write (admin-only)**:

- قاعدة Firestore: `allow create: if isAdmin()` في `sponsorships`
- المشكلة: field_worker لا يمكنه رفع بيانات الكفالات
- الحل المؤقت: في التطوير، استخدم حساب admin للرفع
- الحل الدائم: مراجعة business logic — هل رفع الكفالات مسموح لـ field_worker؟

**P0 — Associations write (admin-only)**:

- قاعدة Firestore: `allow create, update, delete: if isAdmin()` في `associations`
- المشكلة: field_worker لا يمكنه رفع بيانات الجمعيات
- الحل المؤقت: استخدم حساب admin للرفع في التطوير
- الحل الدائم: مراجعة — هل الجمعيات بيانات admin-managed فقط؟

### TODO للإنتاج

- [ ] مراجعة قواعد `sponsorships` و `associations` مع فريق العمل
- [ ] تحديد ما إذا كان field_worker يحتاج صلاحية رفع هذه المجموعات
- [ ] تقييد `taxonomy_categories` و `taxonomy_groups` write بـ isAdmin() — راجع P1 فوق
- [ ] تقييد `file_number_*` write بالأدوار المناسبة
