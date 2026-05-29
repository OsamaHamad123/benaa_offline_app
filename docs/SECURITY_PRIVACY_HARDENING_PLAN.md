# SECURITY & PRIVACY HARDENING PLAN

**تاريخ الإنشاء:** 2026-05-28
**الإصدار:** 2.0 — اكتمل التنفيذ
**نطاق العمل:** Gaza / Cedar — تطبيق بناء للعمل الميداني

---

## ✅ حالة التنفيذ (Implementation Status)

**تاريخ الإغلاق:** 2026-05-28

| البند                                                            | الحالة              | الملف                               |
| ---------------------------------------------------------------- | ------------------- | ----------------------------------- |
| LogSanitizer.maskToken()                                         | ✅ تم               | `lib/core/utils/log_sanitizer.dart` |
| LogSanitizer.maskIban()                                          | ✅ تم               | `lib/core/utils/log_sanitizer.dart` |
| إصلاح raw email في taxonomy_seeder                               | ✅ تم               | `lib/features/taxonomies/data/dev/` |
| إصلاح raw uid في taxonomy_seeder                                 | ✅ تم               | `lib/features/taxonomies/data/dev/` |
| إصلاح raw email في file_id_service                               | ✅ تم               | `lib/features/sync/services/`       |
| مسارات `/analytics`, `/performance*`, `/monitoring` → kDebugMode | ✅ تم               | `lib/routing/app_router.dart`       |
| `/update-normalization` → blockedInReleaseRoutes                 | ✅ تم               | `lib/routing/app_router.dart`       |
| أزرار Cedar Seed → kDebugMode                                    | ✅ تم               | `associations_list_page_v2.dart`    |
| `canAccessAdminTools()` helper                                   | ✅ تم               | `lib/core/auth/role_provider.dart`  |
| `canRunSeeds()` helper                                           | ✅ تم               | `lib/core/auth/role_provider.dart`  |
| `canResetLocalCache()` helper                                    | ✅ تم               | `lib/core/auth/role_provider.dart`  |
| `canExportData()` helper                                         | ✅ تم               | `lib/core/auth/role_provider.dart`  |
| `canDeleteRemoteData()` helper                                   | ✅ تم               | `lib/core/auth/role_provider.dart`  |
| confirmation dialog لـ \_resetTaxonomiesOnly                     | ✅ تم               | `mobile_sync_page.dart`             |
| confirmation dialog لـ \_resetFileNumbersOnly                    | ✅ تم               | `mobile_sync_page.dart`             |
| FIRESTORE_RULES_COVERAGE.md                                      | ✅ تم               | `docs/`                             |
| LOCAL_STORAGE_SECURITY_AUDIT.md                                  | ✅ تم               | `docs/`                             |
| security_logging_test.dart (11 اختبار)                           | ✅ تم               | `test/core/security/`               |
| role_permissions_test.dart (25 اختبار)                           | ✅ تم               | `test/core/auth/`                   |
| admin_tool_visibility_test.dart (11 اختبار)                      | ✅ تم               | `test/features/security/`           |
| sync_safety_test.dart (8 اختبارات)                               | ✅ تم               | `test/features/sync/`               |
| Dashboard flaky test (sets lastRefreshTime)                      | ✅ تم — 131/131 نجح | `test/features/dashboard/`          |

### البنود المؤجّلة (Deferred — P2/P3)

| البند                                         | الأولوية | السبب                         |
| --------------------------------------------- | -------- | ----------------------------- |
| SQLCipher لتشفير SQLite المحلية               | P2       | يتطلب migration plan كامل     |
| تقييد Firestore writes لـ taxonomy_categories | P1       | يتطلب Firebase deployment     |
| تقييد Firestore writes لـ file*number*\*      | P1       | يتطلب Firebase deployment     |
| مراجعة تخزين user_password                    | P2       | تقييم إضافي مطلوب             |
| Cedar Seed confirmation dialog (force)        | P3       | في kDebugMode فقط — خطر منخفض |

### النتائج النهائية

- **flutter analyze**: 0 errors, 0 warnings ✅
- **Security tests**: 101/101 نجح ✅
- **Dashboard tests**: 131/131 نجح ✅
- **Dashboard Quick Actions**: محفوظة بدون تغيير ✅
- **Normal users**: لا يرون admin/debug/seed في production ✅

---

## الملخص التنفيذي

هذا المستند يوثّق خطة تصليب الأمان والخصوصية للتطبيق دون المساس بتصميم Dashboard الموجود أو Quick Actions المجمّدة.

---

## 1. الحمايات الموجودة مسبقاً

| الحماية                        | المستوى        | التفاصيل                                                                                                       |
| ------------------------------ | -------------- | -------------------------------------------------------------------------------------------------------------- |
| `LogSanitizer`                 | موجودة ومختبرة | تعريف كامل بـ `maskNationalId`, `maskPhone`, `maskName`, `maskEmail`, `maskId`, `maskSensitive`, `sanitizeMap` |
| `SecureStorage`                | موجودة         | `FlutterSecureStorage` مع `encryptedSharedPreferences` على Android                                             |
| `resolveUserRoleFromClaims`    | موجودة ومختبرة | دالة pure لتحليل claims بدون Firebase                                                                          |
| `isAdminProvider`              | موجودة         | Provider مختصر للتحقق من صلاحية admin                                                                          |
| `userRoleProvider`             | موجودة         | يقرأ Firebase custom claims                                                                                    |
| Firestore rules                | جزئية          | قواعد جيدة لـ users, beneficiaries, associations, sponsorships                                                 |
| `/sentry-test` route           | محمية          | مقيّدة بـ `kDebugMode` فقط                                                                                     |
| `blockedInReleaseRoutes`       | موجودة         | قائمة routes محظورة في release                                                                                 |
| Taxonomy seed button           | محمية          | مقيّدة بـ `kDebugMode` في TaxonomyManagementPage                                                               |
| Beneficiary reset confirmation | موجودة         | `_resetBeneficiariesAndRestore` لديها `showDialog` تأكيد                                                       |

---

## 2. LogSanitizer — أين يُعرَّف وأين يُستخدم

### التعريف

- **`lib/core/utils/log_sanitizer.dart`** — مكتمل الدوال

### الاختبارات

- **`test/core/utils/log_sanitizer_test.dart`** — 6 اختبارات تغطي المتطلبات الأساسية

### الاستخدام الفعلي في الإنتاج

| الملف                                                               | الاستخدام                  |
| ------------------------------------------------------------------- | -------------------------- |
| `lib/features/dashboard/presentation/state/dashboard_notifier.dart` | `enableDebugMasking()` فقط |

**المشكلة الحرجة:** `LogSanitizer` معرَّف ومختبر لكنه **غير مُستخدم فعلياً** في أي log يكتب بيانات حساسة.

---

## 3. أماكن يوجد فيها سجلات بيانات حساسة RAW

| الملف                                                             | السطر   | المشكلة                                           | الأولوية |
| ----------------------------------------------------------------- | ------- | ------------------------------------------------- | -------- |
| `lib/features/taxonomies/data/dev/firestore_taxonomy_seeder.dart` | 297     | `user?.email` مكشوف في `developer.log`            | **P0**   |
| `lib/features/taxonomies/data/dev/firestore_taxonomy_seeder.dart` | 838-839 | `user?.email` و `user?.uid` مكشوفان               | **P0**   |
| `lib/features/sync/services/file_id_service.dart`                 | 402     | `currentUser.email` مكشوف في `UnifiedLogger.info` | **P0**   |
| `lib/data/services/auth_service.dart`                             | 290     | `AuthStatus.toString()` يتضمن `email`             | **P1**   |
| جميع developer.log في seed files                                  | متعددة  | email/uid بدون masking في dev tools               | **P2**   |

---

## 4. تغطية Firebase/Firestore Collections

### Collections المستخدمة حالياً

| Collection                     | الوحدة           | القاعدة الحالية                                          | مستوى الخطر                                    |
| ------------------------------ | ---------------- | -------------------------------------------------------- | ---------------------------------------------- |
| `users`                        | Auth             | read: owner/admin، write: owner/admin                    | منخفض ✓                                        |
| `beneficiaries`                | Beneficiaries    | read/write: isAuthenticated                              | متوسط — write يجب أن يكون للـ field_worker فقط |
| `beneficiaries/visits`         | Visits           | read: auth، create/update: auth+timestamp، delete: false | منخفض ✓                                        |
| `beneficiaries/attachments`    | Attachments      | read: auth، create/update: auth+timestamp، delete: false | منخفض ✓                                        |
| `beneficiaries/family_members` | Beneficiaries    | admin only write                                         | جيد ✓                                          |
| `associations`                 | Associations     | read: auth، write: admin                                 | جيد ✓                                          |
| `associations/representatives` | Associations     | read: auth، write: admin                                 | جيد ✓                                          |
| `taxonomies`                   | Taxonomies       | read: auth، write: admin                                 | جيد ✓                                          |
| `taxonomy_categories`          | Taxonomies (dev) | read: auth، **write: isAuthenticated — زائد الصلاحية**   | **عالٍ ⚠️**                                    |
| `taxonomy_groups`              | Taxonomies (dev) | read: auth، **write: isAuthenticated — زائد الصلاحية**   | **عالٍ ⚠️**                                    |
| `file_number_counters`         | FileNumbers      | read/write: auth                                         | متوسط — يجب admin فقط                          |
| `file_number_blocks`           | FileNumbers      | read/write: auth                                         | متوسط — يجب admin فقط                          |
| `file_number_allocations`      | FileNumbers      | read/write: auth                                         | متوسط — يجب admin فقط                          |
| `sponsorships`                 | Kafalat          | read: auth، write: admin                                 | جيد ✓                                          |
| `association_contacts`         | Associations     | read: auth، write: auth، delete: admin                   | مقبول                                          |
| `sponsorship_files`            | Kafalat          | read: auth، write: auth، delete: admin                   | مقبول                                          |
| `sponsorship_candidates`       | Kafalat          | read: auth، write: auth، delete: admin                   | مقبول                                          |
| `sponsorship_payments`         | Kafalat          | read: auth، write: auth، delete: admin                   | مقبول                                          |
| `beneficiary_visits`           | Visits           | read/write: auth                                         | متوسط — نسخة مكررة خارج sub-collection         |
| `beneficiary_followups`        | Followups        | read/write: auth                                         | متوسط                                          |
| `sync_health_checks`           | Sync             | read/write: auth                                         | مقبول للتطوير                                  |
| `activities`                   | Dashboard        | read: auth، write: admin                                 | جيد ✓                                          |
| `data_requests`                | Backend          | read: auth، write: admin                                 | جيد ✓                                          |

### Collections غير مشمولة في القواعد (تنطبق عليها default deny)

- `sync_logs` — إن وُجدت
- `sync_batches` — إن وُجدت
- `pending_uploads` — إن وُجدت
- `organizations` — إن وُجدت
- `user_roles` — إن وُجدت

### ملاحظة تطوير مقابل إنتاج

- القواعد الحالية **مناسبة للتطوير** — تحتاج تضييقاً قبل الإنتاج
- `taxonomy_categories` و `taxonomy_groups`: زائدا الصلاحية — write يجب أن يكون admin فقط
- File number collections: يجب أن تكون admin أو field_worker فقط

---

## 5. حالة إخفاء أدوات Admin/Debug/Seed

| الأداة                  | المسار                     | الحماية الحالية | المطلوب                 |
| ----------------------- | -------------------------- | --------------- | ----------------------- |
| Taxonomy Seed Button    | `/taxonomies`              | `kDebugMode` ✓  | كافٍ                    |
| Cedar Associations Seed | `/associations`            | **لا حماية ⚠️** | يجب admin أو kDebugMode |
| `/analytics`            | UxAnalyticsDashboard       | **لا حماية ⚠️** | يجب admin أو kDebugMode |
| `/performance-monitor`  | RealTimePerformanceMonitor | **لا حماية ⚠️** | يجب admin أو kDebugMode |
| `/performance`          | PerformanceDashboard       | **لا حماية ⚠️** | يجب admin أو kDebugMode |
| `/monitoring`           | MonitoringDashboard        | **لا حماية ⚠️** | يجب admin أو kDebugMode |
| `/update-normalization` | Debug page                 | لا حماية ⚠️     | يجب kDebugMode          |
| `/sentry-test`          | SentryTestPage             | `kDebugMode` ✓  | كافٍ                    |
| `_resetTaxonomiesOnly`  | MobileSyncPage             | **لا تأكيد ⚠️** | يجب confirmation dialog |
| `_resetFileNumbersOnly` | MobileSyncPage             | **لا تأكيد ⚠️** | يجب confirmation dialog |
| Dashboard Settings      | `/settings/dashboard`      | لا حماية        | مقبول — إعدادات UI فقط  |

---

## 6. الإجراءات الخطرة التي تحتاج تأكيد

| الإجراء                            | الملف                            | التأكيد الحالي | المطلوب          |
| ---------------------------------- | -------------------------------- | -------------- | ---------------- |
| مسح beneficiaries + إعادة تنزيل    | `mobile_sync_page.dart`          | ✓ موجود        | كافٍ             |
| مسح التصنيفات المحلية فقط          | `mobile_sync_page.dart`          | ✗ غائب         | **مطلوب إضافته** |
| مسح مخزون أرقام الملفات            | `mobile_sync_page.dart`          | ✗ غائب         | **مطلوب إضافته** |
| Cedar Associations Seed (force)    | `associations_list_page_v2.dart` | ✗ غائب         | **مطلوب إضافته** |
| حذف taxonomy من TaxonomyManagement | `taxonomy_management_page.dart`  | ✓ موجود        | كافٍ             |

---

## 7. التخزين المحلي وأمان الرموز

| البيانات             | مكان التخزين                                               | حساسة؟               | الحماية الحالية    | المخاطر                               |
| -------------------- | ---------------------------------------------------------- | -------------------- | ------------------ | ------------------------------------- |
| Auth Token           | `FlutterSecureStorage` (مشفّر)                             | نعم                  | مشفّر ✓            | منخفض                                 |
| Refresh Token        | `FlutterSecureStorage`                                     | نعم                  | مشفّر ✓            | منخفض                                 |
| User Email           | `FlutterSecureStorage`                                     | نعم                  | مشفّر ✓            | منخفض                                 |
| Device ID            | `FlutterSecureStorage`                                     | لا                   | مشفّر              | لا خطر                                |
| Remember Me Password | `FlutterSecureStorage` (مفتاح: `saved_password_encrypted`) | نعم                  | مشفّر ✓            | منخفض — يحتاج تحقق من التشفير الإضافي |
| بيانات المستفيدين    | SQLite محلي (sqflite/SQLCipher)                            | **نعم — حساسة جداً** | **غير مشفّر واضح** | **عالٍ**                              |
| Firebase Auth Token  | FirebaseAuth SDK                                           | نعم                  | مُدار بواسطة SDK ✓ | منخفض                                 |

**ملاحظة مهمة:** قاعدة بيانات SQLite المحلية التي تحتوي بيانات المستفيدين (الرقم الوطني، الهاتف، الاسم) **غير مشفّرة** حالياً. هذا خطر تشغيلي مقبول للتطوير لكنه **خطر إنتاج يجب معالجته** لاحقاً.

---

## 8. نموذج الأدوار والصلاحيات

### الأدوار المعرّفة

```dart
enum UserRole {
  admin,       // وصول كامل
  fieldWorker, // العمليات اليومية العادية
  reviewer,    // قراءة ومراجعة فقط
  readOnly,    // قراءة فقط
  unauthenticated, // لا وصول
}
```

### الصلاحيات المطلوبة (سيتم إضافتها)

| الصلاحية              | admin | fieldWorker | reviewer | readOnly | unauthenticated |
| --------------------- | ----- | ----------- | -------- | -------- | --------------- |
| `canAccessAdminTools` | ✓     | ✗           | ✗        | ✗        | ✗               |
| `canRunSeeds`         | ✓     | ✗           | ✗        | ✗        | ✗               |
| `canResetLocalCache`  | ✓     | ✓           | ✗        | ✗        | ✗               |
| `canExportData`       | ✓     | ✓           | ✓        | ✗        | ✗               |
| `canDeleteRemoteData` | ✓     | ✗           | ✗        | ✗        | ✗               |

---

## 9. قائمة التنفيذ — بالأولويات

### P0 — حرج (يجب تنفيذه فوراً)

- [ ] **إصلاح تسرّب البريد الإلكتروني** في `firestore_taxonomy_seeder.dart` (أسطر 297, 838-839)
- [ ] **إصلاح تسرّب البريد الإلكتروني** في `file_id_service.dart` (سطر 402)
- [ ] **إضافة `maskToken` و`maskIban`** إلى `LogSanitizer`
- [ ] **تأمين مسارات admin** (`/analytics`, `/performance-monitor`, `/performance`, `/monitoring`) خلف `kDebugMode` أو admin role

### P1 — مهم

- [ ] **إضافة تأكيد لـ `_resetTaxonomiesOnly`** في `mobile_sync_page.dart`
- [ ] **إضافة تأكيد لـ `_resetFileNumbersOnly`** في `mobile_sync_page.dart`
- [ ] **تأمين Cedar Associations Seed** خلف `kDebugMode` أو admin check
- [ ] **إضافة دوال صلاحيات** `canAccessAdminTools`, `canRunSeeds` etc. إلى `role_provider.dart`
- [ ] **إنشاء `role_permissions_test.dart`**
- [ ] **إنشاء `admin_tool_visibility_test.dart`**
- [ ] **إضافة اختبارات أمان logging** في `security_logging_test.dart`

### P2 — تصليب

- [ ] **تضييق Firestore rules** لـ `taxonomy_categories` و `taxonomy_groups` (admin فقط)
- [ ] **تضييق Firestore rules** لـ file number collections
- [ ] **إنشاء `FIRESTORE_RULES_COVERAGE.md`**
- [ ] **إنشاء `LOCAL_STORAGE_SECURITY_AUDIT.md`**
- [ ] **إضافة sync safety tests**

### P3 — وثائق ومستقبل الإنتاج

- [ ] **تشفير SQLite** باستخدام SQLCipher أو Drift مع مفتاح — مؤجّل لمرحلة لاحقة
- [ ] **Firestore production rules** مع أدوار field_worker, reviewer, read_only
- [ ] **تدوير أدوار إنتاج** مع Firebase Custom Claims production pipeline
- [ ] **تحديث `SECURITY_PRIVACY_AUDIT.md`**
- [ ] **تحديث `DASHBOARD_BASELINE_2026_05_28.md`** بملاحظة قصيرة

---

## 10. القواعد الأساسية الثابتة

- Dashboard layout: **محمي — لن يُعدَّل**
- Quick Actions الستة: **مجمّدة — لن تتغير**
- المستخدم العادي: **يجب ألا يرى أدوات admin/debug/seed**
- Reset محلي: **يؤثر على البيانات المحلية فقط — لا يحذف من Firestore**
- البيانات الحساسة: **لا تُسجَّل RAW في production paths**
- الجمعيات/التصنيفات/الزيارات: **لن تُعاد هندستها**

---

_يُحدَّث هذا المستند مع كل تغيير أمني مُطبَّق._
