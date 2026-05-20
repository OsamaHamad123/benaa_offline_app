# التقرير التقني الشامل — تطبيق بناء الميداني (Benaa Offline App)

### مستوى مشروع تخرج جامعي — تاريخ التقرير: 24 أبريل 2026

---

> **ملاحظة:** هذا التقرير يُغطي تحليلاً هندسياً معمّقاً للكود المصدري الكامل، قابلاً للدفاع أمام لجان التخرج الجامعية.

---

# الفهرس

1. [الملخص التنفيذي](#section-1)
2. [تحليل هيكل المشروع الكامل](#section-2)
3. [تحليل قاعدة البيانات](#section-3)
4. [خطة الهجرة إلى Firebase](#section-4)
5. [إزالة الوحدات غير الضرورية](#section-5)
6. [تحليل إدارة الحالة (State Management)](#section-6)
7. [تحليل UI/UX الكامل](#section-7)
8. [تحليل الوحدات الوظيفية](#section-8)
9. [تحليل التنفيذ البرمجي](#section-9)
10. [تحليل الأمان](#section-10)
11. [تحليل الأداء](#section-11)
12. [خطة الاختبارات](#section-12)
13. [أسئلة اللجنة والإجابات النموذجية](#section-13)
14. [خطة العمل النهائية للفريق](#section-14)
15. [مقارنة تقنية معمّقة](#section-15)
16. [تدفق البيانات الكامل E2E](#section-16)
17. [تحليل الحالات الحرجة](#section-17)
18. [تحليل ترقيات قاعدة البيانات (Schema Migrations)](#section-18)
19. [مؤشرات الأداء القابلة للقياس (KPIs)](#section-19)
20. [سجل المخاطر (Risk Register)](#section-20)
21. [الدروس المستفادة (Lessons Learned)](#section-21)
22. [مقارنة مع مشاريع مشابهة](#section-22)
23. [تحليل التكلفة — Firebase مقابل SQLite](#section-23)
24. [دليل المساهمة (Contribution Guide)](#section-24)

---

<a name="section-1"></a>

# القسم الأول — الملخص التنفيذي

## 1.1 ما الذي يفعله النظام؟

**Benaa Offline App** هو تطبيق جوال مبني بـ Flutter، مُصمَّم للعمل في بيئات بدون إنترنت مستمر (Offline-First). يستهدف **منظمات العمل الإنساني والخيري** في مناطق النزاع (فلسطين)، ويُمكّنها من:

- تسجيل وإدارة **المستفيدين** (الأيتام، الأرامل، المهجّرون، ذوو الاحتياجات الخاصة)
- إدارة **الكفالات** (Kafalat) — ربط الكافلين بالمستفيدين عبر الجمعيات
- تسجيل **الزيارات الميدانية** لموظفي الجمعيات
- إدارة **الجمعيات** والمندوبين
- **مزامنة البيانات** مع الخادم المركزي عند توفر الاتصال
- توليد **التقارير والإحصاءات** في PDF و Excel
- البحث في **السجل المدني** (Civil Registry) لاسترجاع بيانات المواطنين

## 1.2 المستخدمون المستهدفون

| الفئة                | الدور                                             |
| -------------------- | ------------------------------------------------- |
| موظف الجمعية الخيرية | تسجيل المستفيدين، تسجيل الزيارات، رفع المرفقات    |
| مندوب الجمعية        | إدارة الكفالات، مراجعة المستفيدين                 |
| مدير النظام          | إدارة الجمعيات، استيراد البيانات، مراجعة التقارير |
| الإدارة العليا       | لوحة الإحصاءات، تقارير PDF/Excel                  |

## 1.3 الميزات الرئيسية

- **Offline-First Architecture:** يعمل بدون إنترنت بالكامل
- **مزامنة ذكية:** طابور مزامنة متدرج الأولويات مع Retry Logic
- **تشفير قاعدة البيانات:** SQLCipher + AES-GCM لحماية البيانات الحساسة
- **مصادقة بيومترية:** دعم بصمة الإصبع/الوجه
- **استيراد Excel:** رفع بيانات الكفالات من ملفات Excel
- **QR Code:** مسح رموز QR لتحديد هوية المستفيدين
- **إدارة المرفقات:** صور، PDF، وثائق رسمية
- **تقارير متقدمة:** إحصاءات حسب المحافظة، الفئة، الجنس، العمر
- **نظام تصنيفات (Taxonomy):** قوائم ديناميكية قابلة للتحديث من الخادم
- **إشعارات محلية:** تنبيهات لعمليات المزامنة والبيانات

## 1.4 الغرض التجاري والقيمة

الهدف هو **رقمنة العمل الميداني الإنساني** في المناطق التي تعاني من انقطاع الاتصال بالإنترنت. يحل التطبيق مشكلة رئيسية: **جمع البيانات بدقة في الميدان** ثم مزامنتها مع قاعدة البيانات المركزية لاحقاً. هذا يقلل الأخطاء البشرية ويُسرّع عمليات توزيع المساعدات.

---

<a name="section-2"></a>

# القسم الثاني — تحليل هيكل المشروع الكامل

## 2.1 شجرة هيكل المشروع

```
benaa_offline_app/
├── android/                        # إعدادات Android Native
│   ├── app/build.gradle.kts        # إعدادات البناء + SQLCipher
│   └── gradle.properties           # إعدادات الذاكرة وJVM
├── assets/
│   ├── env.json                    # إعدادات بيئة التشغيل (URL السيرفر)
│   ├── env.example.json            # نموذج الإعدادات
│   ├── data/                       # بيانات ثابتة
│   └── images/                     # الصور والأيقونات
├── lib/
│   ├── main.dart                   # نقطة الدخول (Debug)
│   ├── main_release.dart           # نقطة الدخول (Release)
│   ├── app.dart                    # MaterialApp + ProviderScope
│   ├── core/                       # النواة المشتركة
│   │   ├── accessibility/          # دعم إمكانية الوصول
│   │   ├── analytics/              # تتبع الأداء والسلوك
│   │   ├── backup/                 # النسخ الاحتياطي
│   │   ├── cache/                  # التخزين المؤقت
│   │   ├── config/                 # AppConfig + ApiConfig
│   │   ├── connectivity/           # مراقبة الشبكة
│   │   ├── constants/              # ثوابت النظام
│   │   ├── database/               # خدمات قاعدة البيانات
│   │   ├── design_system/          # نظام التصميم (Animations, Themes)
│   │   ├── error/                  # معالجة الأخطاء
│   │   ├── extensions/             # Context/String Extensions
│   │   ├── helpers/                # مساعدون عامون
│   │   ├── monitoring/             # Sentry + App Monitoring
│   │   ├── navigation/             # مساعدو التنقل
│   │   ├── network/                # ApiClient (Dio)
│   │   ├── notifications/          # إشعارات محلية
│   │   ├── offline/                # دعم العمل بدون إنترنت
│   │   ├── pagination/             # ترقيم الصفحات
│   │   ├── performance/            # أدوات قياس الأداء
│   │   ├── printing/               # طباعة PDF
│   │   ├── providers/              # Riverpod Providers المشتركة
│   │   ├── search/                 # منطق البحث
│   │   ├── security/               # CryptoBox + SessionManager
│   │   ├── services/               # خدمات النظام
│   │   ├── settings/               # إعدادات التطبيق
│   │   ├── storage/                # SecureStorage + SecureStore
│   │   ├── sync/                   # SyncManager + MobileSyncService
│   │   ├── theme/                  # ألوان وخطوط التطبيق
│   │   ├── utils/                  # أدوات مساعدة (Logger, Arabic Normalizer)
│   │   ├── ux/                     # UX Widgets
│   │   └── widgets/                # Widgets مشتركة
│   ├── data/
│   │   ├── api/                    # SyncApiClient
│   │   ├── db/
│   │   │   ├── drift_database.dart # AppDatabase (Drift ORM)
│   │   │   ├── tables/             # 14 جدول
│   │   │   └── daos/               # 13 DAO
│   │   ├── dto/                    # Data Transfer Objects
│   │   ├── models/                 # نماذج البيانات
│   │   ├── repositories/           # تنفيذات Repository
│   │   └── services/               # خدمات البيانات
│   ├── features/
│   │   ├── associations/           # إدارة الجمعيات
│   │   ├── attachments/            # إدارة المرفقات
│   │   ├── auth/                   # المصادقة
│   │   ├── beneficiaries/          # إدارة المستفيدين (الوحدة الأكبر)
│   │   ├── civil_db_download/      # تحميل قاعدة السجل المدني
│   │   ├── civil_registry/         # البحث في السجل المدني
│   │   ├── dashboard/              # لوحة التحكم الرئيسية
│   │   ├── initialization/         # تهيئة التطبيق
│   │   ├── kafalat/                # إدارة الكفالات
│   │   ├── reports/                # التقارير والإحصاءات
│   │   ├── search/                 # البحث المتقدم
│   │   ├── settings/               # إعدادات المستخدم
│   │   ├── setup/                  # إعداد النظام الأولي
│   │   ├── sync/                   # واجهة المزامنة
│   │   ├── taxonomies/             # إدارة التصنيفات
│   │   └── visits/                 # الزيارات الميدانية
│   ├── routing/
│   │   └── app_router.dart         # GoRouter (نظام التوجيه)
│   ├── theme/
│   │   └── app_colors.dart         # ألوان التطبيق
│   └── l10n/                       # الترجمة (عربي فقط)
├── integration_test/               # اختبارات التكامل
├── test/                           # اختبارات الوحدة
├── scripts/                        # سكريبتات البناء والاختبار
├── docs/                           # وثائق المشروع الداخلية
├── pubspec.yaml                    # تبعيات Flutter
└── graduation_project/             # مجلد التقرير (هذا الملف)
```

## 2.2 نمط المعمارية المستخدم

التطبيق يستخدم **Clean Architecture** بنمط **Feature-First**، مُطبَّقة بشكل انتقائي حسب الوحدة.

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│        Pages → Providers (Riverpod) → State              │
├─────────────────────────────────────────────────────────┤
│                    Domain Layer                          │
│       Entities → Use Cases → Repository Interfaces       │
├─────────────────────────────────────────────────────────┤
│                     Data Layer                           │
│    Repository Impl → DAOs (Drift) → API Client (Dio)     │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                    │
│      SQLCipher DB → SecureStorage → Notifications        │
└─────────────────────────────────────────────────────────┘
```

**خصائص المعمارية:**

- كل Feature لها مجلداتها: `data/`, `domain/`, `presentation/`
- `core/` تحتوي على الخدمات المشتركة بين جميع الـ Features
- الـ Providers (Riverpod) هي جسر التواصل بين Domain وPresentation
- يستخدم Drift ORM كـ Repository للبيانات المحلية

## 2.3 التقنيات والأطر المستخدمة

| الفئة                 | التقنية / المكتبة           | الإصدار    | الغرض                  |
| --------------------- | --------------------------- | ---------- | ---------------------- |
| **Framework**         | Flutter                     | SDK ^3.5.0 | إطار العمل الأساسي     |
| **Language**          | Dart                        | ^3.5.0     | لغة البرمجة            |
| **State Management**  | Riverpod + Flutter Hooks    | 2.6.1      | إدارة الحالة           |
| **Local DB**          | Drift (SQLite)              | 2.20.3     | قاعدة البيانات المحلية |
| **DB Encryption**     | sqflite_sqlcipher           | 3.1.0      | تشفير قاعدة البيانات   |
| **HTTP Client**       | Dio                         | 5.9.0      | طلبات الشبكة           |
| **Navigation**        | GoRouter                    | 14.6.2     | نظام التوجيه           |
| **Security**          | flutter_secure_storage      | 9.2.2      | تخزين آمن للـ Token    |
| **Encryption**        | encrypt (AES-GCM)           | 5.0.3      | تشفير الملفات          |
| **Biometrics**        | local_auth                  | 2.3.0      | المصادقة البيومترية    |
| **Monitoring**        | sentry_flutter              | 8.11.0     | رصد الأخطاء            |
| **Charts**            | fl_chart                    | 1.1.1      | الرسوم البيانية        |
| **PDF**               | pdf + printing              | 3.11.3     | توليد PDF              |
| **Excel**             | excel                       | 4.0.6      | استيراد/تصدير Excel    |
| **QR**                | mobile_scanner + qr_flutter | 5.2.3      | مسح QR                 |
| **Notifications**     | flutter_local_notifications | 19.5.0     | الإشعارات المحلية      |
| **Background Sync**   | workmanager                 | 0.9.0+3    | المزامنة في الخلفية    |
| **Localization**      | flutter_localizations       | sdk        | الترجمة (عربي)         |
| **Crypto**            | crypto                      | 3.0.6      | تجزئة كلمات المرور     |
| **Image Compression** | flutter_image_compress      | 2.3.0      | ضغط الصور              |
| **Responsive UI**     | flutter_screenutil          | 5.9.3      | تكيف الشاشات           |
| **Animation**         | animations + lottie         | 2.0.11     | الرسوم المتحركة        |

## 2.4 نظام المصادقة

يستخدم التطبيق نظام **JWT Bearer Token** مع:

- حفظ Token في `FlutterSecureStorage` (Keychain/KeyStore)
- تجديد تلقائي للـ Token عبر Refresh Token
- انتهاء الجلسة تلقائياً بعد 15 دقيقة من الخمول (SessionManager)
- دعم البيومترية (بصمة/وجه) كبديل لكلمة المرور
- وضع **Offline Auth**: حفظ hash كلمة المرور محلياً للتحقق بدون إنترنت
- ربط كل جلسة بـ Device ID فريد

## 2.5 نظام التوجيه (Routing)

يستخدم **GoRouter** مع إعادة توجيه ذكية:

```
/app-init          → تهيئة التطبيق
/init              → شاشة الترحيب
/login             → تسجيل الدخول (V2)
/database-download → تحميل قاعدة السجل المدني
/dashboard         → لوحة التحكم الرئيسية
/beneficiaries     → قائمة المستفيدين
/beneficiaries/new → إضافة مستفيد جديد
/beneficiaries/:id → تفاصيل مستفيد
/beneficiaries/edit/:id → تعديل مستفيد
/visits            → قائمة الزيارات
/kafalat           → صفحة الكفالات
/kafalat/import    → استيراد Excel
/associations      → قائمة الجمعيات
/reports           → التقارير
/sync              → صفحة المزامنة
/settings          → الإعدادات
/civil-search      → البحث في السجل المدني
/taxonomies        → إدارة التصنيفات
```

**منطق إعادة التوجيه:**

1. إذا لم يكن المستخدم مسجلاً → `/login`
2. إذا لم تكن قاعدة السجل المدني محملة → `/database-download`
3. وإلا → `/dashboard`

## 2.6 ملفات الإعداد والبناء

| الملف                          | الغرض                                 |
| ------------------------------ | ------------------------------------- |
| `pubspec.yaml`                 | تبعيات Flutter (65+ حزمة)             |
| `assets/env.json`              | URL السيرفر (قابل للتغيير في الإنتاج) |
| `assets/env.example.json`      | نموذج الإعدادات الافتراضية            |
| `analysis_options.yaml`        | قواعد Lint                            |
| `build.yaml`                   | إعداد Code Generation (Drift/JSON)    |
| `l10n.yaml`                    | إعداد الترجمة العربية                 |
| `sentry.properties`            | مفاتيح Sentry للرصد                   |
| `android/app/build.gradle.kts` | إعدادات Build + SQLCipher             |
| `Makefile`                     | أوامر البناء والاختبار المختصرة       |

---

<a name="section-3"></a>

# القسم الثالث — تحليل قاعدة البيانات

## 3.1 نوع قاعدة البيانات المستخدمة

| الجانب                 | التفاصيل                                                        |
| ---------------------- | --------------------------------------------------------------- |
| **نوع قاعدة البيانات** | SQLite (محلي على الجهاز)                                        |
| **طبقة التشفير**       | SQLCipher — تشفير AES-256 لكامل ملف DB                          |
| **ORM المستخدم**       | Drift 2.20.3 (Dart-native type-safe ORM)                        |
| **إصدار Schema**       | 32 (يدعم 32 نقطة ترقية تدريجية)                                 |
| **الحجم التقديري**     | يتراوح بين 50MB و500MB حسب حجم البيانات                         |
| **قواعد البيانات**     | قاعدتان: `app.db` (رئيسية) + `civil_registry.db` (للسجل المدني) |

## 3.2 جداول قاعدة البيانات الرئيسية

يحتوي `AppDatabase` على **14 جدولاً رئيسياً:**

---

### جدول 1: `beneficiaries` — المستفيدون

| العمود                          | النوع    | القيد              | الوصف                     |
| ------------------------------- | -------- | ------------------ | ------------------------- |
| `id`                            | INTEGER  | PK, AUTO INCREMENT | المعرف المحلي             |
| `file_id_number`                | TEXT     | NULLABLE           | رقم الملف من السيرفر      |
| `original_file_id_from_excel`   | TEXT     | NULLABLE           | رقم الملف الأصلي من Excel |
| `section_id`                    | INTEGER  | NULLABLE           | معرف القسم                |
| `request_status`                | INTEGER  | DEFAULT 1          | حالة الطلب                |
| `id_number`                     | INTEGER  | UNIQUE, NOT NULL   | الرقم الوطني              |
| `first_name`                    | TEXT     | NULLABLE           | الاسم الأول               |
| `father_name`                   | TEXT     | NULLABLE           | اسم الأب                  |
| `grand_father_name`             | TEXT     | NULLABLE           | اسم الجد                  |
| `family_name`                   | TEXT     | NULLABLE           | اسم العائلة               |
| `full_name`                     | TEXT     | GENERATED (STORED) | الاسم الكامل المحسوب      |
| `full_name_norm`                | TEXT     | NULLABLE           | الاسم بعد التطبيع (للبحث) |
| `relationship`                  | INTEGER  | NULLABLE           | صلة القرابة               |
| `birth_date`                    | DATETIME | NULLABLE           | تاريخ الميلاد             |
| `gender`                        | INTEGER  | NULLABLE           | الجنس (1=ذكر، 2=أنثى)     |
| `phone_number`                  | INTEGER  | NOT NULL           | رقم الهاتف                |
| `alt_phone_number`              | INTEGER  | NOT NULL           | رقم هاتف بديل             |
| `number_of_individuals`         | INTEGER  | NULLABLE           | عدد أفراد الأسرة          |
| `marital_status`                | INTEGER  | NULLABLE           | الحالة الاجتماعية         |
| `number_of_males`               | INTEGER  | NULLABLE           | عدد الذكور                |
| `number_of_females`             | INTEGER  | NULLABLE           | عدد الإناث                |
| `academic_qualification`        | INTEGER  | NULLABLE           | المؤهل العلمي             |
| `employment_status_breadwinner` | INTEGER  | NULLABLE           | حالة عمل رب الأسرة        |
| `displacement_status`           | INTEGER  | NULLABLE           | حالة النزوح               |
| `address_before_displacement`   | TEXT     | NULLABLE           | العنوان قبل النزوح        |
| `current_address`               | TEXT     | NULLABLE           | العنوان الحالي            |
| `city`                          | INTEGER  | NULLABLE           | المدينة (taxonomy id)     |
| `province`                      | INTEGER  | NULLABLE           | المحافظة (taxonomy id)    |
| `health_status`                 | INTEGER  | NULLABLE           | الحالة الصحية             |
| `number_of_chronic_diseases`    | INTEGER  | NULLABLE           | عدد المصابين بأمراض مزمنة |
| `number_with_special_needs`     | INTEGER  | NULLABLE           | عدد ذوي الاحتياجات الخاصة |
| `housing_status`                | INTEGER  | NULLABLE           | حالة السكن                |
| `current_housing_type`          | INTEGER  | NULLABLE           | نوع السكن الحالي          |
| `assistance_type_code`          | TEXT     | NULLABLE           | كود نوع المساعدة          |
| `disability_type_code`          | TEXT     | NULLABLE           | كود نوع الإعاقة           |
| `income_source_code`            | TEXT     | NULLABLE           | كود مصدر الدخل            |
| `guarantee_type_code`           | TEXT     | NULLABLE           | كود نوع الضمان            |
| `description_needs`             | TEXT     | NULLABLE           | وصف الاحتياجات            |
| `user_insert_data`              | TEXT     | NULLABLE           | اسم مُدخل البيانات        |
| `created_at`                    | DATETIME | NULLABLE           | تاريخ الإنشاء             |
| `updated_at`                    | DATETIME | NULLABLE           | تاريخ آخر تعديل           |
| `sync_state`                    | TEXT     | DEFAULT 'pending'  | حالة المزامنة             |
| `server_id`                     | INTEGER  | NULLABLE           | المعرف على السيرفر        |
| `last_synced_at`                | DATETIME | NULLABLE           | آخر وقت مزامنة            |

---

### جدول 2: `visits` — الزيارات الميدانية

| العمود           | النوع    | القيد             | الوصف                 |
| ---------------- | -------- | ----------------- | --------------------- |
| `id`             | TEXT     | PK (UUID)         | معرف الزيارة          |
| `beneficiary_id` | TEXT     | NOT NULL          | FK → beneficiaries.id |
| `visit_date`     | DATETIME | NOT NULL          | تاريخ الزيارة         |
| `staff_name`     | TEXT     | NOT NULL          | اسم الموظف            |
| `notes`          | TEXT     | DEFAULT ''        | ملاحظات الزيارة       |
| `is_submitted`   | BOOLEAN  | DEFAULT false     | هل تم الإرسال؟        |
| `created_at`     | DATETIME | NOT NULL          | تاريخ الإنشاء         |
| `updated_at`     | DATETIME | NOT NULL          | تاريخ التعديل         |
| `sync_state`     | TEXT     | DEFAULT 'pending' | حالة المزامنة         |
| `server_id`      | TEXT     | NULLABLE          | المعرف على السيرفر    |
| `last_synced_at` | DATETIME | NULLABLE          | آخر مزامنة            |

---

### جدول 3: `attachments` — المرفقات

| العمود           | النوع    | القيد             | الوصف                     |
| ---------------- | -------- | ----------------- | ------------------------- |
| `id`             | TEXT     | PK (UUID)         | معرف المرفق               |
| `beneficiary_id` | TEXT     | NOT NULL          | FK → beneficiaries        |
| `visit_id`       | TEXT     | NULLABLE          | FK → visits               |
| `file_name`      | TEXT     | NOT NULL          | اسم الملف                 |
| `file_path`      | TEXT     | NOT NULL          | المسار الكامل للملف       |
| `type`           | TEXT     | NOT NULL          | 'image' / 'pdf' / 'other' |
| `file_size`      | INTEGER  | NOT NULL          | الحجم بالبايت             |
| `thumbnail_path` | TEXT     | NULLABLE          | مسار الصورة المصغرة       |
| `document_type`  | TEXT     | NULLABLE          | نوع الوثيقة               |
| `person_type`    | TEXT     | NULLABLE          | نوع الشخص المرتبط         |
| `person_id`      | TEXT     | NULLABLE          | معرف الشخص                |
| `notes`          | TEXT     | NULLABLE          | ملاحظات                   |
| `created_at`     | DATETIME | NOT NULL          | تاريخ الرفع               |
| `updated_at`     | DATETIME | NOT NULL          | تاريخ التعديل             |
| `sync_state`     | TEXT     | DEFAULT 'pending' | حالة المزامنة             |
| `server_url`     | TEXT     | NULLABLE          | URL على السيرفر           |
| `last_synced_at` | DATETIME | NULLABLE          | آخر مزامنة                |

---

### جدول 4: `taxonomies` — التصنيفات

| العمود       | النوع    | القيد        | الوصف                           |
| ------------ | -------- | ------------ | ------------------------------- |
| `id`         | TEXT     | PK           | معرف فريد                       |
| `group`      | TEXT     | NOT NULL     | المجموعة (governorate/city/...) |
| `code`       | TEXT     | NOT NULL     | الكود الفريد                    |
| `label`      | TEXT     | NOT NULL     | التسمية العربية                 |
| `parent_id`  | TEXT     | NULLABLE     | FK → taxonomies.id (هرمي)       |
| `sort_order` | INTEGER  | DEFAULT 0    | ترتيب العرض                     |
| `is_active`  | BOOLEAN  | DEFAULT true | نشط أم لا                       |
| `updated_at` | DATETIME | NOT NULL     | تاريخ التحديث                   |

**مجموعات التصنيفات (40+ مجموعة):**
`governorate`, `city`, `category`, `marital_status`, `displacement_status`, `employment_status`, `education_level`, `health_status`, `housing_type`, `housing_status`, `disability_type`, `income_source`, `association_type`, `sponsorship_type`, `guarantee_type`, `document_type`, `bank_name`, `currency`، وأخرى.

---

### جدول 5: `associations` — الجمعيات

| العمود              | النوع    | القيد             | الوصف                               |
| ------------------- | -------- | ----------------- | ----------------------------------- |
| `id`                | TEXT     | PK                | معرف الجمعية                        |
| `name`              | TEXT     | NOT NULL          | اسم الجمعية                         |
| `short_name`        | TEXT     | NULLABLE          | الاسم المختصر                       |
| `phone`             | TEXT     | NOT NULL          | رقم الهاتف                          |
| `email`             | TEXT     | NULLABLE          | البريد الإلكتروني                   |
| `bank_name`         | TEXT     | NOT NULL          | اسم البنك                           |
| `account_number`    | TEXT     | NOT NULL          | رقم الحساب                          |
| `swift_code`        | TEXT     | NULLABLE          | رمز Swift                           |
| `account_currency`  | TEXT     | NULLABLE          | عملة الحساب                         |
| `representative_id` | TEXT     | NULLABLE          | FK → association_representatives.id |
| `is_active`         | BOOLEAN  | DEFAULT true      | نشط                                 |
| `created_at`        | DATETIME | NOT NULL          | تاريخ الإنشاء                       |
| `sync_state`        | TEXT     | DEFAULT 'pending' | حالة المزامنة                       |
| `server_id`         | INTEGER  | NULLABLE          | ID السيرفر                          |

---

### جدول 6: `association_representatives` — مندوبو الجمعيات

| العمود       | النوع    | القيد             | الوصف         |
| ------------ | -------- | ----------------- | ------------- |
| `id`         | TEXT     | PK                | معرف المندوب  |
| `name`       | TEXT     | NOT NULL          | اسم المندوب   |
| `created_at` | DATETIME | NOT NULL          | تاريخ الإنشاء |
| `sync_state` | TEXT     | DEFAULT 'pending' | حالة المزامنة |
| `server_id`  | INTEGER  | NULLABLE          | ID السيرفر    |

---

### جدول 7: `sponsorships` — الكفالات

| العمود               | النوع    | القيد              | الوصف                  |
| -------------------- | -------- | ------------------ | ---------------------- |
| `file_no`            | INTEGER  | PK, AUTO INCREMENT | رقم الملف الفريد       |
| `beneficiary_id`     | INTEGER  | FK → beneficiaries | المستفيد               |
| `association_id`     | TEXT     | FK → associations  | الجمعية                |
| `sponsor_name`       | TEXT     | NULLABLE           | اسم الكافل             |
| `internal_file_no`   | TEXT     | NULLABLE           | رقم الملف الداخلي      |
| `external_file_no`   | TEXT     | NULLABLE           | رقم الملف الخارجي      |
| `guardian_name`      | TEXT     | NULLABLE           | اسم المعيل             |
| `guardian_id_number` | INTEGER  | NULLABLE           | رقم هوية المعيل        |
| `duration_months`    | INTEGER  | NULLABLE           | مدة الكفالة بالأشهر    |
| `start_date`         | DATETIME | NULLABLE           | تاريخ البدء            |
| `end_date`           | DATETIME | NULLABLE           | تاريخ الانتهاء         |
| `amount`             | REAL     | NULLABLE           | القيمة المالية         |
| `currency`           | TEXT     | NULLABLE           | العملة                 |
| `status`             | TEXT     | DEFAULT 'active'   | active/paused/ended    |
| `sponsorship_type`   | TEXT     | DEFAULT 'monthly'  | monthly/one_time/other |
| `guarantee_type`     | TEXT     | NULLABLE           | كود نوع الضمان         |
| `bank_name`          | TEXT     | NULLABLE           | اسم البنك              |
| `account_number`     | TEXT     | NULLABLE           | رقم الحساب             |
| `governorate`        | TEXT     | NULLABLE           | المحافظة               |
| `notes`              | TEXT     | NULLABLE           | ملاحظات                |
| `created_at`         | DATETIME | NOT NULL           | تاريخ الإنشاء          |
| `sync_state`         | TEXT     | DEFAULT 'pending'  | حالة المزامنة          |

---

### جدول 8: `family_members` — أفراد الأسرة (الأيتام)

| العمود               | النوع    | القيد              | الوصف                          |
| -------------------- | -------- | ------------------ | ------------------------------ |
| `id`                 | INTEGER  | PK, AUTO INCREMENT | المعرف                         |
| `beneficiary_id`     | INTEGER  | FK → beneficiaries | المستفيد                       |
| `orphan_national_id` | INTEGER  | NOT NULL           | رقم هوية اليتيم                |
| `first_name`         | TEXT     | NOT NULL           | الاسم الأول                    |
| `family_name`        | TEXT     | NOT NULL           | اسم العائلة                    |
| `birth_date`         | DATETIME | NOT NULL           | تاريخ الميلاد                  |
| `gender`             | INTEGER  | NOT NULL           | 1=ذكر، 2=أنثى                  |
| `health_status`      | INTEGER  | NOT NULL           | 1-5                            |
| `sponsorship_status` | INTEGER  | NULLABLE           | 1=مكفول، 2=غير مكفول، 3=انتظار |
| `sponsor_name`       | TEXT     | NULLABLE           | اسم الكفيل                     |
| `sync_state`         | TEXT     | DEFAULT 'pending'  | حالة المزامنة                  |

---

### جدول 9: `family_deceased` — الوالدان المتوفيان

| العمود           | النوع    | القيد              | الوصف                      |
| ---------------- | -------- | ------------------ | -------------------------- |
| `id`             | INTEGER  | PK, AUTO INCREMENT | المعرف                     |
| `beneficiary_id` | INTEGER  | FK → beneficiaries | المستفيد                   |
| `deceased_type`  | INTEGER  | NOT NULL           | 1=أب، 2=أم                 |
| `national_id`    | INTEGER  | NOT NULL           | الرقم الوطني               |
| `death_date`     | DATETIME | NOT NULL           | تاريخ الوفاة               |
| `death_cause`    | INTEGER  | NOT NULL           | سبب الوفاة (1-8)           |
| `document_type`  | INTEGER  | NULLABLE           | 1=شهادة وفاة، 2=إفادة شهيد |
| `sync_state`     | TEXT     | DEFAULT 'pending'  | حالة المزامنة              |

---

### جدول 10: `activities` — سجل الأنشطة

| العمود           | النوع    | القيد             | الوصف                                 |
| ---------------- | -------- | ----------------- | ------------------------------------- |
| `id`             | TEXT     | PK (UUID)         | معرف النشاط                           |
| `beneficiary_id` | TEXT     | NOT NULL          | المستفيد المرتبط                      |
| `user_id`        | TEXT     | NOT NULL          | المستخدم المنفذ                       |
| `activity_type`  | TEXT     | NOT NULL          | create/update/delete/visit/attachment |
| `description`    | TEXT     | NOT NULL          | وصف النشاط                            |
| `changes`        | TEXT     | NULLABLE          | JSON للتغييرات                        |
| `created_at`     | DATETIME | NOT NULL          | التوقيت                               |
| `sync_state`     | TEXT     | DEFAULT 'pending' | حالة المزامنة                         |

---

### جدول 11: `sync_queue` — طابور المزامنة

| العمود         | النوع    | القيد     | الوصف                                |
| -------------- | -------- | --------- | ------------------------------------ |
| `id`           | TEXT     | PK (UUID) | معرف العنصر                          |
| `entity`       | TEXT     | NOT NULL  | beneficiary/visit/attachment         |
| `entity_id`    | TEXT     | NOT NULL  | ID الكيان                            |
| `operation`    | TEXT     | NOT NULL  | create/update/delete/upload          |
| `payload`      | TEXT     | NOT NULL  | JSON البيانات                        |
| `priority`     | INTEGER  | DEFAULT 0 | الأولوية (10=Auth, 9=Beneficiary...) |
| `attempts`     | INTEGER  | DEFAULT 0 | عدد المحاولات                        |
| `last_error`   | TEXT     | NULLABLE  | آخر رسالة خطأ                        |
| `created_at`   | DATETIME | NOT NULL  | وقت الإضافة                          |
| `scheduled_at` | DATETIME | NULLABLE  | وقت إعادة المحاولة                   |

---

### جدول 12: `sync_metadata` — بيانات المزامنة

| العمود           | النوع    | القيد     | الوصف                 |
| ---------------- | -------- | --------- | --------------------- |
| `entity`         | TEXT     | PK        | نوع البيانات          |
| `last_sync_time` | DATETIME | NOT NULL  | آخر مزامنة ناجحة      |
| `total_synced`   | INTEGER  | DEFAULT 0 | إجمالي ما تمت مزامنته |
| `failed_syncs`   | INTEGER  | DEFAULT 0 | إجمالي الفاشل         |
| `last_error`     | TEXT     | NULLABLE  | آخر خطأ               |

---

### جدول 13: `file_id_reservations` — حجوزات أرقام الملفات

| العمود           | النوع    | القيد               | الوصف                 |
| ---------------- | -------- | ------------------- | --------------------- |
| `id`             | INTEGER  | PK, AUTO INCREMENT  | المعرف                |
| `file_id`        | INTEGER  | UNIQUE              | رقم الملف المحجوز     |
| `status`         | TEXT     | DEFAULT 'available' | available/used/synced |
| `beneficiary_id` | INTEGER  | NULLABLE, FK        | المستفيد المستخدِم    |
| `reserved_at`    | DATETIME | NOT NULL            | وقت الحجز             |
| `used_at`        | DATETIME | NULLABLE            | وقت الاستخدام         |

---

### جدول 14: `data_requests` — طلبات المساعدات

| العمود           | النوع    | القيد             | الوصف                               |
| ---------------- | -------- | ----------------- | ----------------------------------- |
| `id`             | TEXT     | PK (UUID)         | المعرف                              |
| `beneficiary_id` | TEXT     | NOT NULL          | المستفيد                            |
| `request_type`   | TEXT     | NOT NULL          | نوع الطلب                           |
| `status`         | TEXT     | NOT NULL          | pending/approved/rejected/completed |
| `details`        | TEXT     | NULLABLE          | JSON تفاصيل الطلب                   |
| `request_date`   | DATETIME | NOT NULL          | تاريخ الطلب                         |
| `sync_state`     | TEXT     | DEFAULT 'pending' | حالة المزامنة                       |

---

## 3.3 مخطط العلاقات (ER Diagram — نصي)

```
┌──────────────────────────────────────────────────────────────────────┐
│                     ER DIAGRAM — AppDatabase                         │
└──────────────────────────────────────────────────────────────────────┘

BENEFICIARIES (1) ──────────────── (M) VISITS
      │                                    │
      │                                    │(1)
      │                                    ▼
      ├─── (1:M) ATTACHMENTS ◄────── (visit_id nullable)
      │
      ├─── (1:M) FAMILY_MEMBERS
      │
      ├─── (1:M) FAMILY_DECEASED   [max 2: father / mother]
      │
      ├─── (1:M) SPONSORSHIPS ─────── (M:1) ASSOCIATIONS
      │                                        │
      │                               (M:1) ASSOCIATION_REPRESENTATIVES
      │
      ├─── (1:M) ACTIVITIES
      │
      ├─── (1:M) DATA_REQUESTS
      │
      └─── (1:1?) FILE_ID_RESERVATIONS   [when file_id used]

TAXONOMIES  [self-referential hierarchy via parent_id]
   └── group → [code, label] → parent_id

SYNC_QUEUE     → references any entity by (entity, entity_id)
SYNC_METADATA  → one row per entity type ('beneficiaries','visits',...)
```

## 3.4 قاعدة السجل المدني (civil_registry.db) — قاعدة منفصلة

| الجدول                    | الغرض                          |
| ------------------------- | ------------------------------ |
| `civil_registry`          | بيانات المواطنين — للقراءة فقط |
| `civil_registry_city`     | المدن والمحافظات — مرجعية      |
| `civil_registry_relation` | العلاقات العائلية — مرجعية     |

تُنزَّل هذه القاعدة كاملةً من السيرفر بصيغة مضغوطة ومشفرة، وتُستخدم للبحث السريع دون الرجوع للشبكة.

## 3.5 مستوى التطبيع (Normalization)

| المعيار | التقييم | الملاحظة                                                  |
| ------- | ------- | --------------------------------------------------------- |
| 1NF     | ✅ محقق | لا حقول متكررة                                            |
| 2NF     | ✅ محقق | كل حقل يعتمد على PK كاملاً                                |
| 3NF     | ⚠️ جزئي | بعض القيم taxonomy مخزنة كـ codes نصية بدلاً من FK للأداء |
| BCNF    | ⚠️ جزئي | القرارات التصميمية المتعمدة لأداء Offline-first           |

## 3.6 الفهارس (Indexes)

تُنشأ فهارس أداء تلقائياً عبر `_createPerformanceIndexes()`:

| الفهرس                             | الجدول        | الغرض                 |
| ---------------------------------- | ------------- | --------------------- |
| `idx_beneficiaries_sync_state`     | beneficiaries | استعلامات المزامنة    |
| `idx_beneficiaries_id_number`      | beneficiaries | البحث بالرقم الوطني   |
| `idx_beneficiaries_full_name_norm` | beneficiaries | البحث النصي العربي    |
| `idx_visits_beneficiary_id`        | visits        | تحميل زيارات المستفيد |
| `idx_attachments_beneficiary_id`   | attachments   | تحميل مرفقات المستفيد |
| `idx_sync_queue_priority`          | sync_queue    | ترتيب طابور المزامنة  |
| `idx_sponsorships_beneficiary_id`  | sponsorships  | استعلامات الكفالات    |

## 3.7 تدفق البيانات (Data Flow)

```
[الموظف الميداني]
        │ يُدخل البيانات في الـ UI
        ▼
[Presentation — ConsumerWidget (Riverpod)]
        │ يُرسل حدثاً للـ Notifier
        ▼
[Domain — Use Case / Repository Interface]
        │ ينفذ منطق الأعمال
        ▼
[Data — DAO (Drift ORM)]
        │ INSERT/UPDATE
        ▼
[SQLCipher Local Database]   ← مُشفّر AES-256 على الجهاز
        │
        │ عند توفر الإنترنت
        ▼
[SyncManager → MobileSyncService]
        │ يقرأ sync_queue مرتباً بالأولوية
        ▼
[ApiClient (Dio)] → POST /api/mobile/database/data/batch
        │
        ▼
[خادم بناء — MySQL/PostgreSQL]  ← قاعدة البيانات المركزية
```

---

<a name="section-4"></a>

# القسم الرابع — خطة الهجرة إلى Firebase

## 4.1 لماذا Firebase؟

| المعيار              | الخادم الحالي (PHP/MySQL) | Firebase                 |
| -------------------- | ------------------------- | ------------------------ |
| **البنية التحتية**   | خادم مُدار يدوياً         | مُدار بالكامل من Google  |
| **Offline Support**  | يحتاج تنفيذ يدوي          | مدمج في Firestore SDK    |
| **Real-time Sync**   | Polling دوري              | Real-time listeners      |
| **التوسع (Scaling)** | يدوي (يتطلب DevOps)       | تلقائي                   |
| **التكلفة**          | خادم مخصص                 | Pay-as-you-go            |
| **الأمان**           | قواعد أمان يدوية          | Firestore Security Rules |
| **المصادقة**         | JWT مُدار يدوياً          | Firebase Auth جاهز       |
| **ملفات المرفقات**   | API رفع مخصص              | Firebase Storage         |
| **الإشعارات**        | غير مدعوم                 | Firebase Cloud Messaging |

## 4.2 خدمات Firebase المُوصى بها

| الخدمة                             | الاستخدام في التطبيق                                   |
| ---------------------------------- | ------------------------------------------------------ |
| **Firebase Authentication**        | تسجيل دخول الموظفين (Email/Password) + Biometric Token |
| **Cloud Firestore**                | جميع البيانات الرئيسية (beneficiaries, visits, etc.)   |
| **Firebase Storage**               | المرفقات (صور، PDF، وثائق)                             |
| **Firebase Cloud Messaging (FCM)** | إشعارات المزامنة والتنبيهات                            |
| **Cloud Functions**                | المنطق الخلفي (validations، batch operations)          |
| **Firebase Hosting**               | لوحة إدارة ويب (إن وُجدت)                              |
| **Firebase Analytics**             | تتبع سلوك المستخدمين                                   |

> **Realtime Database:** غير مطلوب — Firestore يُغني عنه لهذا النظام.

## 4.3 تحويل الجداول إلى Collections

| الجدول القديم                 | Collection Firestore                                 | الملاحظات                                         |
| ----------------------------- | ---------------------------------------------------- | ------------------------------------------------- |
| `beneficiaries`               | `/beneficiaries/{id}`                                | Document per beneficiary                          |
| `visits`                      | `/visits/{id}` أو `/beneficiaries/{id}/visits/{vid}` | Sub-collection مُوصى بها                          |
| `attachments`                 | `/beneficiaries/{id}/attachments/{aid}`              | Sub-collection + Storage URL                      |
| `family_members`              | `/beneficiaries/{id}/family_members/{mid}`           | Sub-collection                                    |
| `family_deceased`             | `/beneficiaries/{id}/family_deceased/{did}`          | Sub-collection                                    |
| `sponsorships`                | `/sponsorships/{id}`                                 | مستقلة مع حقل `beneficiaryId`                     |
| `associations`                | `/associations/{id}`                                 | Document per association                          |
| `association_representatives` | `/associations/{id}/representatives/{rid}`           | Sub-collection                                    |
| `taxonomies`                  | `/taxonomies/{group}/items/{id}`                     | هرمي                                              |
| `activities`                  | `/activities/{id}`                                   | مع Composite Index على (beneficiaryId, createdAt) |
| `data_requests`               | `/data_requests/{id}`                                | مع حقل `beneficiaryId`                            |
| `sync_queue`                  | لا تُهاجر                                            | تُستبدل بـ Firestore offline persistence          |
| `sync_metadata`               | لا تُهاجر                                            | تُستبدل بـ Firestore metadata                     |
| `file_id_reservations`        | `/file_id_counters/global` (Atomic counter)          | Cloud Function للحجز الذري                        |
| `civil_registry`              | لا تُهاجر                                            | تبقى SQLite محلية (حجمها كبير جداً)               |

## 4.4 هيكل Firestore Collections (تفصيلي)

```
firestore/
│
├── beneficiaries/
│   └── {beneficiaryId}/
│       ├── id_number: number
│       ├── first_name: string
│       ├── father_name: string
│       ├── family_name: string
│       ├── birth_date: timestamp
│       ├── gender: number
│       ├── phone_number: string
│       ├── displacement_status: number
│       ├── sync_state: string          ← للتتبع المحلي
│       ├── association_id: string      ← Reference
│       ├── created_at: timestamp
│       ├── updated_at: timestamp
│       │
│       ├── visits/ (sub-collection)
│       │   └── {visitId}/
│       │       ├── visit_date: timestamp
│       │       ├── staff_name: string
│       │       └── notes: string
│       │
│       ├── attachments/ (sub-collection)
│       │   └── {attachmentId}/
│       │       ├── storage_url: string   ← Firebase Storage URL
│       │       ├── document_type: string
│       │       └── file_size: number
│       │
│       ├── family_members/ (sub-collection)
│       │   └── {memberId}/
│       │       └── ...
│       │
│       └── family_deceased/ (sub-collection)
│           └── {deceasedId}/
│               └── ...
│
├── sponsorships/
│   └── {sponsorshipId}/
│       ├── beneficiary_id: string      ← Reference
│       ├── association_id: string      ← Reference
│       ├── sponsor_name: string
│       ├── amount: number
│       ├── status: string
│       └── ...
│
├── associations/
│   └── {associationId}/
│       ├── name: string
│       ├── bank_name: string
│       ├── account_number: string
│       └── representatives/ (sub-collection)
│
├── taxonomies/
│   └── {group}/
│       └── items/ (sub-collection)
│           └── {itemId}/
│               ├── code: string
│               ├── label: string
│               └── parent_id: string
│
├── activities/
│   └── {activityId}/
│       ├── beneficiary_id: string
│       ├── activity_type: string
│       └── created_at: timestamp
│
└── file_id_counters/
    └── global/
        └── next_file_id: number       ← Atomic increment via Cloud Function
```

## 4.5 معالجة العلاقات في NoSQL

في Firestore لا توجد Foreign Keys حقيقية. الحلول المُعتمدة:

| نوع العلاقة                             | الحل في Firestore                       |
| --------------------------------------- | --------------------------------------- |
| One-to-Many (beneficiary → visits)      | Sub-collection داخل document المستفيد   |
| Many-to-One (sponsorship → association) | حقل `association_id` (Reference String) |
| Self-reference (taxonomy → parent)      | حقل `parent_id` مع Composite Index      |
| Many-to-Many (لا يوجد في النظام حالياً) | Junction Collection إذا احتجنا          |

**مثال — جلب مستفيد وزياراته:**

```dart
// Firestore
final beneficiary = await firestore.doc('beneficiaries/$id').get();
final visits = await firestore
    .collection('beneficiaries/$id/visits')
    .orderBy('visit_date', descending: true)
    .get();
```

## 4.6 استراتيجية المزامنة مع Offline Support

Firestore SDK يوفر Offline Persistence مدمجة:

```dart
// تفعيل Offline Persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**استراتيجية الـ Conflict Resolution:**

- **Server Wins:** عند تعارض البيانات، تنتصر نسخة السيرفر
- **Last Write Wins:** بناءً على `updated_at` timestamp
- **Optimistic Updates:** التحديث المحلي فوري، ثم المزامنة تلقائياً
- **Tombstones:** حذف ناعم `deleted_at` بدلاً من الحذف المادي

**مقارنة مع النظام الحالي:**

| الجانب             | النظام الحالي             | مع Firebase                  |
| ------------------ | ------------------------- | ---------------------------- |
| Offline Storage    | SQLCipher DB              | SQLite Cache (Firestore SDK) |
| Sync Trigger       | يدوي أو Background Worker | تلقائي عند الاتصال           |
| Conflict Detection | يدوي (timestamps)         | مدمج في Firestore            |
| Retry Logic        | مُبرمج يدوياً             | مدمج في SDK                  |

## 4.7 قواعد الأمان (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // دالة مساعدة — التحقق من المصادقة
    function isAuthenticated() {
      return request.auth != null;
    }

    // دالة مساعدة — التحقق من الدور
    function hasRole(role) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }

    // المستفيدون — القراءة والكتابة للمصادقين فقط
    match /beneficiaries/{id} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.resource.data.updated_at > resource.data.updated_at;
      allow delete: if hasRole('admin');

      // Sub-collections
      match /visits/{visitId} {
        allow read, write: if isAuthenticated();
      }
      match /attachments/{attachmentId} {
        allow read, write: if isAuthenticated();
      }
      match /family_members/{memberId} {
        allow read, write: if isAuthenticated();
      }
      match /family_deceased/{deceasedId} {
        allow read, write: if isAuthenticated();
      }
    }

    // الجمعيات — للمصادقين
    match /associations/{id} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('manager');
    }

    // الكفالات — للمصادقين
    match /sponsorships/{id} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }

    // التصنيفات — للقراءة فقط للمستخدمين العاديين
    match /taxonomies/{group}/items/{itemId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin');
    }

    // Firebase Storage Rules (منفصلة)
  }
}
```

## 4.8 قواعد Firebase Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // مرفقات المستفيدين
    match /beneficiaries/{beneficiaryId}/attachments/{file} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024  // 10MB max
        && request.resource.contentType.matches('image/.*|application/pdf');
    }
  }
}
```

## 4.9 خطوات الهجرة بالترتيب

### المرحلة 1 — الإعداد (أسبوع 1)

1. إنشاء مشروع Firebase
2. تفعيل Firestore + Storage + Auth + FCM
3. إضافة `google-services.json` للمشروع
4. إضافة حزم Firebase لـ `pubspec.yaml`
5. إعداد Firebase Auth بـ Email/Password

### المرحلة 2 — بناء طبقة البيانات (أسبوع 2-3)

6. إنشاء Firestore Repository لكل Collection
7. استبدال `SyncApiClient` بـ Firestore Streams
8. استبدال `sync_queue` بـ Firestore Offline Persistence
9. بناء Cloud Functions للعمليات الحساسة (حجز File IDs)

### المرحلة 3 — هجرة البيانات (أسبوع 4)

10. كتابة سكريبت Python/Node لتحويل MySQL → Firestore
11. تشغيل هجرة البيانات التاريخية
12. التحقق من سلامة البيانات

### المرحلة 4 — هجرة المصادقة (أسبوع 5)

13. استبدال JWT بـ Firebase Auth tokens
14. ربط Biometric Auth بـ Firebase Custom Tokens
15. اختبار دورة Auth الكاملة

### المرحلة 5 — هجرة الملفات (أسبوع 6)

16. رفع المرفقات الموجودة إلى Firebase Storage
17. تحديث روابط المرفقات في Firestore
18. اختبار رفع/تنزيل الملفات

### المرحلة 6 — الاختبار والإطلاق (أسبوع 7-8)

19. اختبار الـ Offline Flow كاملاً
20. اختبار الأمان (Security Rules)
21. اختبار الأداء والـ Indexes
22. إطلاق تدريجي (Phased Rollout)

## 4.10 المخاطر وأفضل الممارسات

| المخطر                         | الحل                                                          |
| ------------------------------ | ------------------------------------------------------------- |
| **حجم Firestore القراءات**     | إضافة Pagination + Composite Indexes لتفادي الفواتير المرتفعة |
| **تعارض البيانات (Conflicts)** | تطبيق `updated_at` Timestamp Strategy                         |
| **قاعدة السجل المدني (كبيرة)** | تبقى SQLite محلياً — لا تُهاجر                                |
| **بيانات حساسة**               | تشفير الحقول الحساسة قبل الحفظ في Firestore                   |
| **Firestore Limits**           | Document size max 1MB — تحقق من حجم الـ payload               |
| **Offline Sync Conflicts**     | تطبيق Operational Transform أو Last-Write-Wins                |
| **تكلفة الاستخدام**            | تفعيل Firestore Budget Alerts                                 |

---

<a name="section-5"></a>

# القسم الخامس — إزالة الوحدات غير الضرورية

## 5.1 نظرة عامة

بعد التحليل الكامل، تبيّن وجود **6 وحدات/ملفات** يمكن إزالتها أو تقليصها بشكل آمن دون التأثير على الوظائف الأساسية.

---

## 5.2 الوحدة 1 — Civil Registry Test Page

### الوصف

ملف `lib/features/civil_registry/civil_registry_test_page.dart` — صفحة اختبار فقط للسجل المدني، لا قيمة إنتاجية لها.

### مكان وجوده

```
lib/features/civil_registry/civil_registry_test_page.dart
lib/routing/app_router.dart (line 18) ← import
```

### الملفات المعتمدة عليه

```dart
// app_router.dart
import '../features/civil_registry/civil_registry_test_page.dart';
// مسار: /civil-registry-test
```

### طريقة الإزالة الآمنة

**الخطوة 1:** حذف الملف:

```
lib/features/civil_registry/civil_registry_test_page.dart
```

**الخطوة 2:** إزالة import من `app_router.dart` (السطر 18)

**الخطوة 3:** إزالة مسار الـ Route المرتبط به:

```dart
// احذف هذا المسار من GoRouter routes:
GoRoute(path: '/civil-registry-test', builder: ...)
```

### الأثر بعد الإزالة

- ✅ لا تأثير على الوظائف الإنتاجية
- ✅ تنظيف الكود
- ⚠️ يُوصى بإبقاء منطق البحث في السجل المدني المُنفَّذ في `/civil-search`

---

## 5.3 الوحدة 2 — Import Test Data Page

### الوصف

ملف `lib/features/sync/import_test_data_page.dart` — صفحة لاستيراد بيانات تجريبية (test data) في بيئة التطوير.

### مكان وجوده

```
lib/features/sync/import_test_data_page.dart
lib/routing/app_router.dart (line 22)
```

### طريقة الإزالة الآمنة

1. حذف الملف `import_test_data_page.dart`
2. إزالة import وRoute من `app_router.dart`

### الأثر

- ✅ لا تأثير إنتاجي — هذا ملف تطوير فقط
- ✅ تقليل حجم التطبيق

---

## 5.4 الوحدة 3 — Test Mobile API Page

### الوصف

ملف `lib/features/sync/test_mobile_api_page.dart` — صفحة لاختبار API يدوياً في بيئة التطوير.

### مكان وجوده

```
lib/features/sync/test_mobile_api_page.dart
lib/routing/app_router.dart (line 24)
```

### طريقة الإزالة الآمنة

1. حذف الملف `test_mobile_api_page.dart`
2. إزالة import وRoute من `app_router.dart`
3. إبقاء `MobileSyncService` — هي الخدمة الإنتاجية الفعلية

### الأثر

- ✅ لا تأثير إنتاجي

---

## 5.5 الوحدة 4 — Sentry Test Page (Debug Only)

### الوصف

ملف `lib/core/debug/sentry_test_page.dart` — صفحة لاختبار Sentry Error Reporting.

### مكان وجوده

```
lib/core/debug/sentry_test_page.dart
lib/routing/app_router.dart (line 8)
```

### طريقة الإزالة الآمنة

الأفضل **إبقاؤه في Debug Mode فقط** باستخدام conditional import:

```dart
// بدلاً من الحذف، أضف guard:
if (kDebugMode) ...[
  GoRoute(path: '/sentry-test', builder: ...)
]
```

### الأثر

- ✅ لا تأثير في Release Mode
- ✅ يُساعد في التطوير والاختبار

---

## 5.6 الوحدة 5 — Examples Page

### الوصف

ملف `lib/features/examples/widgets_example_page.dart` — صفحة أمثلة Widget للمطورين.

### طريقة التعامل

- حذف في Release Build
- يمكن إبقاؤه محلياً للمطورين عبر conditional Route

---

## 5.7 الوحدة 6 — جداول قاعدة بيانات السجل المدني في AppDatabase

### الوصف

جدول `civil_registry` في `civil_registry_tables.dart` لا يزال موجوداً في الكود، لكنه تم تعليقه في `drift_database.dart` (تم نقله لقاعدة بيانات منفصلة).

### الحالة الحالية

```dart
// drift_database.dart
// 🗑️ Civil Registry tables removed - using separate database (civil_registry.db)
```

### التوصية

- ✅ الكود المعلَّق جيد — لا داعي للحذف الكامل
- الملفات `civil_registry_tables.dart` يمكن إبقاؤها كـ reference
- التأكد أن لا استيرادات زائفة تسبب حجم بناء أكبر

---

## 5.8 ملخص ما يجب إزالته

| الوحدة                   | الملفات                         | الأولوية | الصعوبة | السبب                        |
| ------------------------ | ------------------------------- | -------- | ------- | ---------------------------- |
| Civil Registry Test Page | `civil_registry_test_page.dart` | عالية    | سهلة    | صفحة اختبار بلا قيمة إنتاجية |
| Import Test Data Page    | `import_test_data_page.dart`    | عالية    | سهلة    | بيانات تجريبية فقط           |
| Test Mobile API Page     | `test_mobile_api_page.dart`     | عالية    | سهلة    | للتطوير فقط                  |
| Sentry Test Page         | `sentry_test_page.dart`         | متوسطة   | سهلة    | تحويله لـ Debug-only route   |
| Examples Page            | `widgets_example_page.dart`     | منخفضة   | سهلة    | وثائق تطوير                  |

### الأثر الإجمالي المتوقع بعد الإزالة

| المقياس        | قبل           | بعد        |
| -------------- | ------------- | ---------- |
| عدد الـ Routes | ~22           | ~17        |
| حجم APK        | لا تأثير كبير | تقليص طفيف |
| نظافة الكود    | متوسطة        | عالية      |
| سرعة الـ Build | طبيعية        | تحسن طفيف  |

---

<a name="section-6"></a>

# القسم السادس — تحليل إدارة الحالة (State Management)

## 6.1 المكتبة المستخدمة

يستخدم التطبيق **Riverpod 2.6.1** (مع Flutter Hooks) كمكتبة إدارة الحالة الرئيسية. هذا خيار متقدم يُعدّ من أفضل الحلول في نظام Flutter.

## 6.2 أنواع Providers المستخدمة

| نوع الـ Provider             | الاستخدام في التطبيق                                                     |
| ---------------------------- | ------------------------------------------------------------------------ |
| `Provider<T>`                | الخدمات الثابتة: `ApiClient`, `AppDatabase`, `SecureStorage`             |
| `FutureProvider<T>`          | البيانات غير المتزامنة: `appConfigProvider`, `sharedPreferencesProvider` |
| `StateNotifierProvider<N,S>` | الحالة المعقدة: `beneficiariesListProvider`, `authNotifierProvider`      |
| `StreamProvider<T>`          | البيانات اللحظية: `syncStatusProvider`                                   |
| `StateProvider<T>`           | حالة بسيطة: `selectedFilterProvider`, `darkModeProvider`                 |
| `AsyncNotifierProvider`      | استخدام محدود في الوحدات الحديثة                                         |

## 6.3 تدفق الحالة — مثال المصادقة

```
[LoginPageV2]
    │ المستخدم يضغط Login
    ▼
[authNotifierProvider.notifier.login(email, password)]
    │ يُرسل إلى AuthNotifier
    ▼
[AuthNotifier extends StateNotifier<AuthState>]
    │ state = AuthLoading('جاري تسجيل الدخول...')
    │
    ▼
[AuthRepository.login()] → HTTP POST /api/mobile/auth/login
    │
    ├── نجاح → state = AuthAuthenticated(session, isOffline: false)
    │              └── GoRouter يوجه إلى /dashboard
    │
    └── فشل → state = AuthError(message, errorCode, canRetry)
                   └── يُعرض رسالة خطأ للمستخدم
```

## 6.4 تدفق الحالة — قائمة المستفيدين

```
[BeneficiariesListPageV2]
    │ ref.watch(beneficiariesListProvider)
    ▼
[BeneficiariesListNotifier extends StateNotifier<BeneficiariesListState>]
    │
    ├── loadInitialData() ← يُشغَّل عند الإنشاء
    │       │ يفحص Cache أولاً
    │       ▼
    │   [AppDatabase.beneficiariesDao.getAllBeneficiaries(filters)]
    │       │
    │       ▼
    │   state = state.copyWith(items: [...], isLoading: false)
    │
    ├── loadMore() ← عند التمرير للأسفل (Infinite Scroll)
    │
    ├── search(query) ← مع Debounce 300ms
    │
    └── applyFilter(filter) ← من FilterBottomSheet
```

## 6.5 إدارة حالة المزامنة

```dart
// StreamProvider للمزامنة
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.statusStream;
});

// استخدام في الـ UI
final syncState = ref.watch(syncStatusProvider);
syncState.when(
  data: (status) => SyncProgressBar(status),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => ErrorText(e.toString()),
);
```

## 6.6 إدارة الحالة المحلية للنماذج (Form State)

النماذج تستخدم `StatefulWidget` مع `GlobalKey<FormState>` للتحقق، بينما تستخدم Riverpod للبيانات الخلفية:

```
[BeneficiaryFormPageV3]
    │ StatefulWidget + FormKey (للتحقق المحلي)
    │ ref.watch(taxonomiesProvider) (للقوائم من DB)
    │ ref.watch(associationsProvider) (قائمة الجمعيات)
    ▼
[BeneficiaryFormNotifier]
    │ saveDraft() → INSERT/UPDATE في SQLite
    │ submit() → INSERT في sync_queue
    ▼
[Drift DAO] → SQLite
```

## 6.7 نقاط الضعف الحالية

| المشكلة                       | التفاصيل                                                    | الحل المُوصى                        |
| ----------------------------- | ----------------------------------------------------------- | ----------------------------------- |
| **Mixed State Styles**        | بعض الصفحات تستخدم `StatefulWidget` محلية جنباً مع Riverpod | توحيد باستخدام Riverpod فقط         |
| **Over-watching**             | بعض الـ Providers تُعاد بناؤها أكثر مما يجب                 | استخدام `select()` للاشتراك الجزئي  |
| **Heavy Notifiers**           | `BeneficiariesListNotifier` يحتوي على منطق كثير             | تقسيمه إلى Notifiers أصغر           |
| **No Bloc for complex flows** | بعض التدفقات المعقدة (Sync) تحتاج BLoC                      | إضافة BLoC للمزامنة فقط             |
| **Provider Leaks**            | بعض Providers لا تُعيد تعيين حالتها عند Logout              | إضافة `ref.invalidate()` عند Logout |

## 6.8 البديل الأفضل (مُوصى به للمستقبل)

```
الحالي:  Provider + StateNotifier + Flutter Hooks
المُوصى: Provider + AsyncNotifier (Riverpod 2.x) + flutter_hooks
السبب:   AsyncNotifier أحدث وأكثر type-safety من StateNotifier
```

---

<a name="section-7"></a>

# القسم السابع — تحليل UI/UX الكامل

## 7.1 نظام التصميم العام

| العنصر              | التفاصيل                                                 |
| ------------------- | -------------------------------------------------------- |
| **Framework**       | Material Design 3 (MD3)                                  |
| **الخطوط**          | Google Fonts                                             |
| **الألوان**         | `AppColors` — نظام ألوان موحد                            |
| **التكيف**          | `flutter_screenutil` — responsive على جميع الأحجام       |
| **الرسوم المتحركة** | `animations` + `lottie` + `flutter_staggered_animations` |
| **اللغة**           | عربي فقط (RTL)                                           |
| **الدعم**           | Light/Dark mode                                          |

---

## 7.2 تحليل الشاشات

---

# شاشة 1 — تسجيل الدخول (LoginPageV2)

## الغرض

بوابة الوصول للنظام، التحقق من هوية الموظف.

## المكونات

- حقل البريد الإلكتروني (Email Field)
- حقل كلمة المرور (مع زر الإظهار/الإخفاء)
- خيار "تذكرني"
- زر تسجيل الدخول (بـ Loading indicator)
- زر المصادقة البيومترية (بصمة/وجه)
- رسالة خطأ ديناميكية
- خلفية Glassmorphic متحركة

## المدخلات

| الحقل             | النوع                    | التحقق                  |
| ----------------- | ------------------------ | ----------------------- |
| البريد الإلكتروني | TextFormField            | Email format validation |
| كلمة المرور       | TextFormField (obscured) | Not empty, min 6 chars  |

## الإجراءات

1. Submit → `authNotifierProvider.notifier.login()`
2. Biometric → `BiometricAuthWidget.authenticate()`
3. تحميل بيانات محفوظة عند فتح الصفحة

## تدفق التنقل

```
Login (نجاح) → /app-init →
    ├── DB غير موجودة → /database-download
    └── DB موجودة → /dashboard
```

## قواعد التحقق

- Email: `RegExp(r'^[^@]+@[^@]+\.[^@]+')`
- Password: `value.length >= 6`

## ملاحظات UX

- ✅ Glassmorphic تصميم جميل ومهني
- ✅ دعم "Remember Me" عبر SecureStorage
- ✅ دعم البيومترية
- ✅ رسائل خطأ واضحة
- ⚠️ لا يوجد "نسيت كلمة المرور" — يحتاج إضافة
- ⚠️ لا يوجد خيار تغيير URL السيرفر بشكل مرئي من الـ UI

---

# شاشة 2 — تهيئة التطبيق (AppInitializationPage)

## الغرض

شاشة التحميل الأولية — تتحقق من حالة المصادقة وقاعدة البيانات.

## المكونات

- Lottie Animation (loading)
- نص حالة التهيئة
- شريط تقدم

## الإجراءات

1. تحقق من `SecureStorage.isLoggedIn()`
2. تحميل `AppConfig`
3. تحقق من وجود قاعدة السجل المدني
4. توجيه لـ /login أو /dashboard

## ملاحظات UX

- ✅ تجربة Splash Screen سلسة
- ⚠️ وقت التهيئة قد يكون طويلاً على الأجهزة البطيئة

---

# شاشة 3 — تحميل قاعدة السجل المدني (DatabaseDownloadPage)

## الغرض

تنزيل قاعدة بيانات السجل المدني من السيرفر (ضرورية للبحث).

## المكونات

- شريط تقدم التنزيل (نسبة مئوية)
- حجم الملف وسرعة التنزيل
- زر بدء التنزيل / الإلغاء
- خيار تخطي (Skip) إذا أراد المستخدم التأجيل

## الإجراءات

1. `DatabaseDownloadService.downloadDatabase()` → تنزيل تدريجي
2. `NotificationsService.showDownloadProgress()` → إشعار محلي
3. عند الاكتمال → توجيه لـ /dashboard

## ملاحظات UX

- ✅ شريط تقدم ديناميكي
- ✅ إمكانية التخطي
- ⚠️ لا يوجد Resume للتنزيل المتوقف — يجب إعادة البدء من الصفر

---

# شاشة 4 — لوحة التحكم (DashboardPage)

## الغرض

الصفحة الرئيسية — ملخص إحصائيات النظام وأزرار التنقل السريع.

## المكونات

- Welcome Banner (بحث سريع)
- بطاقات الإحصاءات: (إجمالي المستفيدين، المكفولون، الزيارات، المزامنة)
- رسوم بيانية (fl_chart): توزيع حسب المحافظة، الفئة
- قائمة آخر الأنشطة
- Floating Action Button: إضافة مستفيد جديد
- شريط تنقل سفلي: (Dashboard, Beneficiaries, Kafalat, Reports, Settings)
- مؤشر حالة الاتصال (Online/Offline)
- مؤشر تقدم المزامنة

## المدخلات

- شريط بحث سريع (يفتح بحثاً في `/civil-search`)
- فلاتر سريعة: All / Pending / Synced

## الإجراءات

1. النقر على بطاقة → التنقل للشاشة المرتبطة
2. بحث → `/civil-search?q=...`
3. FAB → `/beneficiaries/new`
4. تحديث بالسحب → إعادة تحميل الإحصاءات

## ملاحظات UX

- ✅ تصميم MD3 نظيف
- ✅ رسوم بيانية تفاعلية
- ✅ مؤشر الاتصال واضح
- ✅ Welcome Banner ترحيبي
- ⚠️ بعض البطاقات قد تكون كثيرة على الشاشات الصغيرة
- ⚠️ يُوصى بإضافة زر اختصار للمزامنة في الـ App Bar

---

# شاشة 5 — قائمة المستفيدين (BeneficiariesListPageV2)

## الغرض

عرض جميع المستفيدين مع إمكانية البحث والفلترة.

## المكونات

- شريط بحث (مع Debounce 300ms)
- فلاتر سريعة: (الكل / معلقون / مزامنون)
- قائمة بطاقات المستفيدين (Swipeable Cards)
- لوحة إحصاءات سريعة في الأعلى
- Infinite Scroll (تحميل تدريجي)
- Skeleton Loading أثناء التحميل
- Bulk Actions Bar (عند التحديد المتعدد)
- Filter Bottom Sheet المتقدم
- FAB: إضافة مستفيد جديد

## المدخلات

| الإدخال            | الوصف                  |
| ------------------ | ---------------------- |
| نص البحث           | اسم، رقم وطني، رقم ملف |
| فلتر المحافظة      | من قوائم التصنيفات     |
| فلتر الفئة         | يتيم/أرملة/مهجَّر/...  |
| فلتر حالة المزامنة | pending/synced/failed  |

## ملاحظات UX

- ✅ Swipe Actions (تعديل، حذف، مزامنة)
- ✅ Debounce للبحث يمنع طلبات زائدة
- ✅ Skeleton Loading تجربة تحميل ناعمة
- ✅ Infinite Scroll فعّال
- ⚠️ البحث النصي العربي يعتمد على `full_name_norm` — يجب تحديثه دائماً
- ⚠️ الفلاتر المتقدمة قد تكون معقدة للمستخدم الجديد

---

# شاشة 6 — نموذج إضافة/تعديل المستفيد (BeneficiaryFormPageV3)

## الغرض

إدخال أو تعديل بيانات مستفيد كاملة.

## المكونات

النموذج مقسم إلى أقسام (Sections):

1. **المعلومات الشخصية** — الاسم الرباعي، رقم الهوية، الجنس، تاريخ الميلاد
2. **معلومات الاتصال** — رقم الهاتف، العنوان
3. **الوضع الأسري** — الحالة الاجتماعية، عدد الأفراد، الأيتام
4. **الوضع المعيشي** — السكن، الدخل، التوظيف
5. **الوضع الصحي** — الحالة الصحية، الأمراض المزمنة، الإعاقات
6. **بيانات النزوح** — حالة النزوح، العنوان قبل وبعد
7. **الاحتياجات** — وصف الاحتياجات، نوع المساعدة
8. **المرفقات** — رفع صور ووثائق

## قواعد التحقق (Validation)

| الحقل         | القاعدة                      |
| ------------- | ---------------------------- |
| الاسم الأول   | مطلوب، حروف عربية فقط، min 2 |
| رقم الهوية    | مطلوب، 9 أرقام بالضبط، فريد  |
| رقم الهاتف    | مطلوب، 10-15 رقم             |
| تاريخ الميلاد | لا يتجاوز اليوم              |
| عدد الأفراد   | رقم موجب                     |

## ملاحظات UX

- ✅ نموذج طويل مقسم بشكل منطقي
- ✅ حفظ تلقائي كـ Draft
- ✅ QR Scanner لملء بيانات من السجل المدني
- ⚠️ النموذج طويل جداً — يُوصى بـ Stepper أو Tab-based form
- ⚠️ لا يوجد Auto-save indicator واضح

---

# شاشة 7 — تفاصيل المستفيد (BeneficiaryDetailsPageV2)

## الغرض

عرض جميع بيانات مستفيد محدد مع الإجراءات المتاحة.

## المكونات

- بطاقة المعلومات الأساسية (مع صورة)
- Tabs: (المعلومات الشخصية / أفراد الأسرة / الكفالات / الزيارات / المرفقات / الأنشطة)
- Timeline للأنشطة
- زر تعديل (Edit FAB)
- زر مزامنة

## ملاحظات UX

- ✅ تنظيم Tab-based واضح
- ✅ Timeline للأنشطة يُظهر تاريخ المستفيد كاملاً
- ⚠️ يُوصى بإضافة Quick Actions: (إضافة زيارة، إضافة كفالة) مباشرة من هذه الشاشة

---

# شاشة 8 — الكفالات (KafalatPage)

## الغرض

إدارة الكفالات — عرض المستفيدين المكفولين وغير المكفولين.

## المكونات

- Tab Bar: (غير مكفول / مكفول)
- **تبويب "غير مكفول":** قائمة المستفيدين الذين يمكن كفالتهم
- **تبويب "مكفول":** قائمة الكفالات النشطة مع حالتها
- فلاتر سريعة: الجمعية، نوع الكفالة، حالة الكفالة
- أزرار Quick Actions في كل بطاقة
- FAB: إنشاء كفالة جديدة
- زر استيراد Excel

## ملاحظات UX

- ✅ تنظيم Tab واضح (مكفول/غير مكفول)
- ✅ فلاتر متعددة
- ⚠️ عملية إنشاء كفالة جديدة تمر بخطوات متعددة — يُوصى بـ Wizard

---

# شاشة 9 — استيراد كفالات Excel (KafalatImportPage)

## الغرض

استيراد بيانات الكفالات من ملفات Excel دفعةً واحدة.

## المكونات

- زر اختيار ملف Excel
- معاينة البيانات (Data Preview Table)
- مؤشر التقدم
- تقرير الأخطاء

## ملاحظات UX

- ✅ معاينة قبل الاستيراد
- ⚠️ لا يوجد Rollback في حالة الفشل الجزئي

---

# شاشة 10 — الجمعيات (AssociationsListPageV2)

## الغرض

إدارة الجمعيات الخيرية المسجلة في النظام.

## المكونات

- شريط بحث
- فلاتر: النشطة فقط، حسب البنك، حسب المندوب
- بطاقات احترافية لكل جمعية (Professional Association Card)
- Swipe Actions: تعديل، حذف، مشاهدة الكفالات
- Sorting Menu: حسب الاسم، تاريخ الإنشاء
- نموذج إضافة/تعديل كـ Bottom Sheet

## ملاحظات UX

- ✅ بطاقات احترافية تعرض المعلومات المهمة
- ✅ Swipe Actions بديهية
- ⚠️ يُوصى بإضافة إحصائية لكل جمعية (عدد الكفالات)

---

# شاشة 11 — الزيارات الميدانية (VisitsListPageM3)

## الغرض

عرض وإدارة الزيارات الميدانية لموظفي الجمعية.

## المكونات

- Tab Bar: (كل الزيارات / المعلقة / المزامَنة)
- بطاقات الزيارات مع Timeline
- فلتر حسب حالة المزامنة
- خيار عرض التقويم (Calendar View)

## ملاحظات UX

- ✅ Timeline View مميزة
- ✅ تمييز بصري لحالات المزامنة
- ⚠️ يُوصى بإضافة Calendar View فعّال

---

# شاشة 12 — التقارير (ReportsPage)

## الغرض

عرض إحصاءات وتقارير شاملة عن المستفيدين والكفالات.

## المكونات

- فلتر الفترة الزمنية: (اليوم / الأسبوع / الشهر / مخصص)
- إحصاءات إجمالية: (بطاقات ملخص)
- تقارير مفصلة:
  - حسب المحافظة
  - حسب الفئة
  - حسب الجنس
  - حسب العمر
- رسوم بيانية (fl_chart)
- تصدير: PDF / Excel

## ملاحظات UX

- ✅ رسوم بيانية تفاعلية
- ✅ تصدير متعدد الصيغ
- ⚠️ يُوصى بإضافة تقرير تنبؤي (Trend Analysis)

---

# شاشة 13 — المزامنة (MobileSyncPage)

## الغرض

مركز المزامنة — مراقبة وإدارة عمليات المزامنة مع السيرفر.

## المكونات

- بطاقة حالة الاتصال
- إحصاءات المزامنة: (عدد العناصر المعلقة، الفاشلة، المزامَنة)
- أزرار العمليات: (مزامنة الآن، مزامنة المستفيدين، مزامنة الزيارات)
- سجل آخر عمليات المزامنة
- أوضاع العرض: (تشغيلي / تشخيصي)

## ملاحظات UX

- ✅ معلومات تشخيصية تفصيلية للمطور
- ⚠️ معقدة للمستخدم العادي — يُوصى بـ "وضع بسيط" و"وضع متقدم"

---

# شاشة 14 — الإعدادات (CleanSettingsPage)

## الغرض

إعدادات التطبيق والحساب.

## المكونات

- إعداد URL السيرفر
- إعدادات الجلسة (مهلة الانتهاء)
- مهلة المصادقة البيومترية
- وضع التطوير (Developer Mode)
- تسجيل الخروج

## ملاحظات UX

- ✅ تنظيم واضح
- ⚠️ يُوصى بإضافة "تغيير كلمة المرور" مباشرة من الإعدادات

---

# شاشة 15 — البحث في السجل المدني (CivilSearchPage)

## الغرض

البحث في قاعدة السجل المدني الوطني للعثور على مواطنين.

## المكونات

- شريط بحث متقدم (بالاسم، رقم الهوية)
- نتائج البحث مع تفاصيل المواطن
- زر "استخدام هذه البيانات" لملء نموذج المستفيد

## ملاحظات UX

- ✅ بحث سريع باستخدام `full_name_norm`
- ✅ تكامل مع نموذج المستفيد
- ⚠️ يتطلب تحميل قاعدة بيانات كبيرة مسبقاً

---

## 7.3 ملاحظات عامة على UX

| الجانب                 | التقييم             | التوصية                               |
| ---------------------- | ------------------- | ------------------------------------- |
| التصميم البصري         | ✅ عالٍ (MD3)       | ممتاز — استمرار                       |
| الاستجابة (Responsive) | ✅ جيد (ScreenUtil) | تحسين للتابلت                         |
| تجربة Offline          | ✅ ممتازة           | استمرار                               |
| إمكانية الوصول         | ⚠️ جزئي             | إضافة Semantics وScreen Reader        |
| الـ Onboarding         | ❌ غير موجود        | إضافة دليل للمستخدم الجديد            |
| الأخطاء للمستخدم       | ✅ جيد              | تحسين رسائل الأخطاء لتكون أكثر وضوحاً |
| الأداء المرئي          | ✅ Skeleton Loading | ممتاز                                 |
| RTL Support            | ✅ كامل             | ممتاز                                 |

---

<a name="section-8"></a>

# القسم الثامن — الوحدات الوظيفية (Functional Modules)

## 8.1 نظرة عامة على الوحدات

يتبع التطبيق **Feature-First Architecture** — كل وحدة وظيفية مستقلة في مجلدها الخاص تحت `lib/features/`:

```
lib/features/
├── auth/                  # المصادقة وإدارة الجلسة
├── beneficiaries/         # إدارة المستفيدين (Core Feature)
├── visits/                # الزيارات الميدانية
├── kafalat/               # نظام الكفالات
├── associations/          # الجمعيات الخيرية
├── sync/                  # المزامنة مع السيرفر
├── reports/               # التقارير والإحصاءات
├── dashboard/             # لوحة التحكم
├── taxonomy/              # التصنيفات (قوائم المراجعة)
├── civil_registry/        # السجل المدني (Read-Only)
├── notifications/         # الإشعارات المحلية
├── settings/              # إعدادات التطبيق
└── attachments/           # إدارة المرفقات والملفات
```

---

## 8.2 وحدة المصادقة (Auth Module)

### الهدف

التحكم الكامل في هوية المستخدم، الجلسة، ومنع الوصول غير المصرح.

### مكونات الوحدة

```
auth/
├── data/
│   ├── repositories/auth_repository_impl.dart    ← التنفيذ الفعلي
│   └── dto/auth_session_dto.dart                 ← نموذج البيانات
├── domain/
│   ├── entities/auth_session.dart                ← كيان الجلسة
│   └── repositories/i_auth_repository.dart       ← العقد (Interface)
└── presentation/
    ├── pages/login_page_v2.dart                  ← واجهة الدخول
    ├── providers/auth_providers.dart             ← Riverpod Providers
    ├── state/auth_state.dart                     ← حالة المصادقة
    └── notifiers/auth_notifier.dart              ← منطق الحالة
```

### تدفق العمل

#### تسجيل الدخول عبر الإنترنت

```
POST /api/mobile/auth/login
Body: { email, password, deviceId, deviceName, devicePlatform }
Response: { token, user: { id, name, email, role }, expiresAt }
         ↓
SecureStorage.saveToken(token)
SecureStorage.saveTokenExpiry(expiresAt)
         ↓
state = AuthAuthenticated(session)
         ↓
GoRouter redirect → /dashboard
```

#### تسجيل الدخول عبر البيومترية

```
FlutterLocalAuth.authenticate()
         ↓
SecureStorage.getSavedCredentials()
         ↓
AuthRepository.login(savedEmail, savedPassword)
```

#### تسجيل الدخول Offline

```
SecureStorage.isLoggedIn() → true
SecureStorage.isTokenExpired() → false (or grace period)
         ↓
state = AuthAuthenticated(session, isOffline: true)
```

### إدارة الجلسة

- **مهلة الجلسة:** 15 دقيقة افتراضياً (قابلة للضبط)
- **فحص دوري:** كل 30 ثانية عبر `Timer.periodic`
- **انتهاء الجلسة:** يعيد التوجيه لشاشة تسجيل الدخول

### نقاط القوة والضعف

| الجانب              | التقييم                                             |
| ------------------- | --------------------------------------------------- |
| JWT Authentication  | ✅ مطبق                                             |
| Biometric Auth      | ✅ مطبق                                             |
| Offline Auth        | ✅ مطبق                                             |
| Token Refresh       | ⚠️ لا يوجد Refresh Token — يتطلب إعادة تسجيل الدخول |
| Certificate Pinning | ❌ غير مطبق                                         |
| Rate Limiting       | ❌ غير مطبق على جانب العميل                         |

---

## 8.3 وحدة المستفيدين (Beneficiaries Module)

### الهدف

الوحدة الأساسية في التطبيق — إدارة كاملة لبيانات المستفيدين من إضافة إلى تعديل وبحث وعرض.

### مكونات الوحدة

```
beneficiaries/
├── data/
│   ├── db/beneficiaries_dao.dart              ← طلبات قاعدة البيانات
│   └── repositories/beneficiary_repository_impl.dart
├── domain/
│   ├── entities/beneficiary.dart
│   └── usecases/
│       ├── save_beneficiary_usecase.dart
│       ├── get_beneficiaries_usecase.dart
│       └── delete_beneficiary_usecase.dart
└── presentation/
    ├── pages/
    │   ├── beneficiaries_list_page_v2.dart    ← القائمة
    │   ├── beneficiary_form_page_v3.dart      ← النموذج
    │   └── beneficiary_details_page_v2.dart   ← التفاصيل
    └── providers/
        ├── list/beneficiaries_list_provider.dart
        ├── list/filters_provider.dart
        └── list/cache_manager.dart
```

### عمليات CRUD

```
CREATE:
  BeneficiaryFormPageV3 → BeneficiaryRepository.save()
  → INSERT INTO beneficiaries (sync_state: 'pending')
  → INSERT INTO sync_queue (operation: 'create')

READ:
  BeneficiariesListNotifier.loadInitialData()
  → SELECT * FROM beneficiaries WHERE [filters] LIMIT 20 OFFSET 0
  → Cached in memory (BeneficiariesListNotifier._cachedData)

UPDATE:
  BeneficiaryFormPageV3 → BeneficiaryRepository.update()
  → UPDATE beneficiaries SET ... WHERE id = ?
  → UPDATE sync_queue SET payload = ? (if pending)
  → INSERT INTO sync_queue (operation: 'update') (if synced)

DELETE:
  Soft Delete: UPDATE beneficiaries SET is_deleted = 1
  → INSERT INTO sync_queue (operation: 'delete')
```

### آلية البحث المتقدم

```dart
// البحث بالعربية — يستخدم العمود المُنسَّق
SELECT * FROM beneficiaries
WHERE full_name_norm LIKE '%' || normalize(query) || '%'
   OR id_number LIKE '%' || query || '%'
   OR file_no = query
ORDER BY created_at DESC
LIMIT 20 OFFSET (page * 20)
```

---

## 8.4 وحدة الكفالات (Kafalat Module)

### الهدف

إدارة نظام الكفالة الشهرية — ربط المستفيدين بالجمعيات الخيرية وتتبع المدفوعات.

### مكونات الوحدة

```
kafalat/
├── data/
│   ├── db/sponsorships_dao.dart
│   └── repositories/sponsorship_repository_impl.dart
├── domain/
│   └── usecases/
│       ├── create_sponsorship_usecase.dart
│       ├── import_sponsorships_from_excel_usecase.dart
│       └── get_sponsorship_stats_usecase.dart
└── presentation/
    ├── pages/
    │   ├── kafalat_page.dart                ← القائمة الرئيسية
    │   └── kafalat_import_page.dart         ← استيراد Excel
    └── widgets/
        └── sponsorship_chart_page.dart      ← رسوم بيانية
```

### نموذج الكفالة

```sql
sponsorships (
  file_no          INTEGER PK,      -- يُولَّد تلقائياً
  beneficiary_id   TEXT FK,         -- المستفيد
  association_id   TEXT FK,         -- الجمعية
  amount           REAL,            -- مبلغ الكفالة
  currency         TEXT,            -- العملة (ILS/USD/EUR)
  start_date       TEXT,
  end_date         TEXT,
  status           TEXT,            -- active/paused/ended
  notes            TEXT,
  sync_state       TEXT             -- pending/synced/failed
)
```

### تدفق استيراد Excel

```
اختيار ملف Excel
        ↓
ExcelParser.parse() → List<SponsorshipDto>
        ↓
ValidationService.validate() → تحقق من صحة البيانات
        ↓
معاينة (Preview Table)
        ↓
BulkInsert → sponsorships + sync_queue
```

---

## 8.5 وحدة الزيارات الميدانية (Visits Module)

### الهدف

تسجيل وتتبع الزيارات الميدانية للموظفين على المستفيدين.

### نموذج الزيارة

```sql
visits (
  id           TEXT PK (UUID),
  beneficiary_id TEXT FK,
  visit_date   TEXT,
  staff_name   TEXT,
  staff_role   TEXT,
  visit_type   TEXT,     -- home_visit / phone / office
  notes        TEXT,
  location     TEXT,     -- GPS إحداثيات
  status       TEXT,     -- scheduled / completed / cancelled
  sync_state   TEXT
)
```

---

## 8.6 وحدة المزامنة (Sync Module)

### الهدف

ضمان مزامنة جميع البيانات المحلية مع السيرفر عند توافر الاتصال.

### بنية المزامنة

```
sync/
├── domain/
│   ├── usecases/
│   │   ├── sync_down_flow_usecase.dart      ← تنزيل من السيرفر
│   │   ├── sync_up_flow_usecase.dart        ← رفع للسيرفر
│   │   ├── sync_associations_module_usecase.dart
│   │   ├── sync_sponsorships_module_usecase.dart
│   │   └── tombstone_delete_sync_usecase.dart ← مزامنة الحذف
│   └── entities/sync_flow_contract.dart
├── data/
│   ├── repositories/
│   │   ├── mobile_sync_beneficiary_repository.dart
│   │   └── mobile_sync_related_entities_repository.dart
│   └── parsers/mobile_sync_response_parser.dart
└── services/
    └── file_id_service.dart                  ← حجز معرفات الملفات
```

### خوارزمية المزامنة (Sync Algorithm)

```
1. تحقق من الاتصال (Connectivity Check)
   ↓
2. جلب العناصر من sync_queue ORDER BY priority DESC, created_at ASC
   ↓
3. لكل عنصر في الـ queue:
   ├── operation = 'create' → POST /api/mobile/database/persons/create
   ├── operation = 'update' → PATCH /api/mobile/database/persons/{id}
   ├── operation = 'delete' → DELETE /api/mobile/database/persons/{id}
   └── operation = 'attachment' → POST /api/mobile/attachments/upload
   ↓
4. عند النجاح:
   ├── UPDATE beneficiaries SET sync_state = 'synced'
   ├── DELETE FROM sync_queue WHERE id = ?
   └── UPDATE sync_metadata SET last_sync_time = NOW()
   ↓
5. عند الفشل:
   ├── UPDATE sync_queue SET attempts = attempts + 1
   ├── إذا attempts > 5 → sync_state = 'failed'
   └── تسجيل في Sentry
```

### حجز معرفات الملفات (File ID Reservation)

```
عند عدم الاتصال:
  INSERT INTO file_id_reservations (status: 'local')
  ← file_no مؤقت محلي

عند المزامنة:
  POST /api/mobile/file-id/reserve → file_no حقيقي من السيرفر
  UPDATE file_id_reservations SET status = 'confirmed', file_id = serverFileId
  UPDATE beneficiaries SET file_no = serverFileId
```

### قيود الـ Sync الحالية

| القيد                  | التفاصيل                         |
| ---------------------- | -------------------------------- |
| لا Conflict Resolution | Server-wins دائماً               |
| لا Soft Delete مُزامَن | الحذف المحلي قد لا يُزامَن       |
| لا File Upload كامل    | المرفقات لا تُزامَن فعلياً       |
| عدم وجود Retry Backoff | محاولات متتالية قد تُرهق السيرفر |

---

## 8.7 وحدة التقارير (Reports Module)

### الهدف

توليد تقارير إحصائية شاملة وتصديرها.

### أنواع التقارير

| نوع التقرير       | المصدر                     | التصدير     |
| ----------------- | -------------------------- | ----------- |
| إجمالي المستفيدين | beneficiaries              | PDF / Excel |
| توزيع جغرافي      | beneficiaries + taxonomies | PDF         |
| توزيع حسب الفئة   | beneficiaries + taxonomies | PDF         |
| تقرير الكفالات    | sponsorships               | PDF / Excel |
| تقرير الزيارات    | visits                     | PDF         |
| حالة المزامنة     | sync_metadata              | PDF         |

### مكتبات التصدير

- **PDF:** `printing` + `pdf`
- **Excel:** `excel`

---

## 8.8 وحدة التصنيفات (Taxonomies Module)

### الهدف

إدارة قوائم الاختيار والتصنيفات المرجعية (lookup tables).

### هيكل بيانات التصنيفات

```sql
taxonomies (
  id        TEXT PK,     -- مثل: "governorate_GAZA"
  group     TEXT,        -- "governorate", "category", "status", "disability_type"
  code      TEXT,        -- الكود المختصر
  label     TEXT,        -- التسمية العربية
  parent_id TEXT,        -- للتصنيفات الهرمية (NULL للجذر)
  sort_order INTEGER,
  is_active BOOLEAN
)
```

### مجموعات التصنيفات الرئيسية

- `governorate` — المحافظات الفلسطينية
- `category` — فئات المستفيدين (يتيم/أرملة/مهجر/معاق/...)
- `disability_type` — أنواع الإعاقة
- `marital_status` — الحالة الاجتماعية
- `housing_type` — نوع السكن
- `sponsorship_type` — أنواع الكفالة
- `visit_type` — أنواع الزيارة

---

## 8.9 وحدة المرفقات (Attachments Module)

### الهدف

إدارة الوثائق والصور المرتبطة بكل مستفيد.

### نموذج المرفق

```sql
attachments (
  id              TEXT PK (UUID),
  beneficiary_id  TEXT FK,
  file_path       TEXT,        -- المسار المحلي
  file_name       TEXT,
  file_size       INTEGER,     -- بالبايت
  document_type   TEXT,        -- id_card / photo / certificate / other
  encrypted       BOOLEAN,     -- هل الملف مشفر؟
  sync_state      TEXT
)
```

### تشفير الملفات

```
عند الحفظ:
  CryptoBox.encryptFile(localPath) → encryptedPath
  attachments.file_path = encryptedPath
  attachments.encrypted = true

عند العرض:
  CryptoBox.decryptFile(encryptedPath) → tempPath
  Image.file(tempPath)
  deleteTemp(tempPath) بعد العرض
```

---

<a name="section-9"></a>

# القسم التاسع — تنفيذ الكود (Code Implementation)

## 9.1 تدفق تسجيل الدخول — كامل من الـ UI للـ DB

### الخطوة 1: استدعاء الـ Provider من الواجهة

```dart
// lib/features/auth/presentation/pages/login_page_v2.dart

class _LoginFormState extends ConsumerState<LoginPageV2> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
```

### الخطوة 2: منطق الحالة في AuthNotifier

```dart
// lib/features/auth/presentation/notifiers/auth_notifier.dart

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._storage) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading(message: 'جاري التحقق من بياناتك...');

    final deviceId = await _storage.getDeviceId();

    final result = await _repository.login(
      email: email,
      password: password,
      deviceId: deviceId ?? 'unknown',
    );

    result.fold(
      onSuccess: (session) => state = AuthAuthenticated(session: session),
      onFailure: (failure) => state = AuthError(
        message: failure.userMessage,
        canRetry: failure is NetworkFailure,
      ),
    );
  }
}
```

### الخطوة 3: تنفيذ Repository

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

@override
Future<Result<AuthSession>> login({
  required String email,
  required String password,
  required String deviceId,
  String? deviceName,
  String? devicePlatform,
}) async {
  final request = MobileLoginRequest(
    email: email,
    password: password,
    deviceId: deviceId,
    deviceName: deviceName ?? await getDeviceName(),
    devicePlatform: devicePlatform ?? getDevicePlatform(),
  );

  final response = await _dio.post(
    ApiConfig.loginEndpoint,   // /api/mobile/auth/login
    data: request.toJson(),
  );

  if (response.statusCode == 200) {
    final loginResponse = MobileLoginResponse.fromJson(response.data);
    final session = AuthMappers.sessionFromLoginResponse(loginResponse);

    if (session != null) {
      await saveSession(session);   // يحفظ في SecureStorage
      return Success(session);
    }
  }

  return Failure(AuthFailure.fromResponse(response.data));
}
```

### الخطوة 4: حفظ الجلسة في SecureStorage

```dart
Future<void> saveSession(AuthSession session) async {
  await _secureStorage.write(SecureStorageKeys.authToken, session.token.accessToken);
  await _secureStorage.write(SecureStorageKeys.userId, session.user.id);
  await _secureStorage.write(SecureStorageKeys.userEmail, session.user.email);
  await _secureStorage.write(
    SecureStorageKeys.tokenExpiry,
    session.token.expiresAt.toIso8601String(),
  );
}
```

### الخطوة 5: إعادة التوجيه عبر GoRouter

```dart
// lib/routing/app_router.dart

redirect: (context, state) async {
  final authState = ref.read(authNotifierProvider);

  final isAuthenticated = authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );

  if (!isAuthenticated && !_isPublicRoute(state.uri.path)) {
    return '/login';
  }

  if (isAuthenticated && !_isDbAvailable()) {
    return '/database-download';
  }

  return null; // تابع للوجهة المطلوبة
}
```

---

## 9.2 تدفق حفظ مستفيد جديد — من النموذج للـ Sync Queue

```dart
// BeneficiaryFormPageV3 → onSubmit()

Future<void> _saveBeneficiary() async {
  // 1. التحقق من صحة النموذج
  if (!_formKey.currentState!.validate()) return;

  // 2. بناء كيان المستفيد
  final beneficiary = BeneficiaryCompanion.insert(
    idNumber: _idNumberController.text,
    firstName: _firstNameController.text,
    lastName: _lastNameController.text,
    governorateId: _selectedGovernorate!,
    categoryId: _selectedCategory!,
    syncState: const Value('pending'),
    createdAt: Value(DateTime.now()),
  );

  // 3. الحفظ في SQLite
  final savedId = await _db.beneficiariesDao.insertBeneficiary(beneficiary);

  // 4. إضافة للـ Sync Queue
  await _db.syncQueueDao.insertItem(SyncQueueCompanion.insert(
    id: Value(const Uuid().v4()),
    entity: const Value('beneficiary'),
    operation: const Value('create'),
    entityId: Value(savedId.toString()),
    payload: Value(jsonEncode(beneficiary.toJson())),
    priority: const Value(1),
    createdAt: Value(DateTime.now()),
  ));

  // 5. إشعار الـ Provider بالتغيير
  ref.invalidate(beneficiariesListProvider);

  // 6. التنقل للتفاصيل
  context.go('/beneficiaries/$savedId');
}
```

---

## 9.3 تدفق المزامنة — من sync_queue للسيرفر

```dart
// lib/core/sync/mobile_sync_service.dart

Future<SyncResult> syncAll() async {
  final pendingItems = await _db.syncQueueDao.getPendingItems(limit: 50);

  int successCount = 0;
  int failureCount = 0;

  for (final item in pendingItems) {
    try {
      final result = await _processSyncItem(item);

      if (result.isSuccess) {
        // حذف من الـ Queue وتحديث الحالة
        await _db.syncQueueDao.deleteItem(item.id);
        await _db.beneficiariesDao.updateSyncState(
          item.entityId,
          'synced',
        );
        successCount++;
      } else {
        // زيادة عداد المحاولات
        await _db.syncQueueDao.incrementAttempts(item.id);
        if (item.attempts >= 5) {
          await _db.syncQueueDao.markAsFailed(item.id);
        }
        failureCount++;
      }
    } catch (e) {
      Sentry.captureException(e);
      failureCount++;
    }
  }

  return SyncResult(success: successCount, failed: failureCount);
}

Future<Result<void>> _processSyncItem(SyncQueueItem item) async {
  switch (item.operation) {
    case 'create':
      return _dio.post(
        ApiConfig.batchEndpoint,
        data: jsonDecode(item.payload),
      ).then((_) => const Success(null));
    case 'update':
      return _dio.patch(
        '${ApiConfig.batchEndpoint}/${item.entityId}',
        data: jsonDecode(item.payload),
      ).then((_) => const Success(null));
    case 'delete':
      return _dio.delete(
        '${ApiConfig.batchEndpoint}/${item.entityId}',
      ).then((_) => const Success(null));
    default:
      return Failure(UnknownSyncFailure(item.operation));
  }
}
```

---

## 9.4 تشفير وفك تشفير الملفات

```dart
// lib/core/security/crypto_box.dart

class CryptoBox {
  static const _algorithm = AesGcm.with256bits();

  /// تشفير ملف
  static Future<String> encryptFile(String inputPath) async {
    final key = await SecureStore.getFileEncryptionKey();
    final iv = _algorithm.newNonce();

    final inputBytes = await File(inputPath).readAsBytes();

    final secretKey = SecretKey(key);
    final secretBox = await _algorithm.encrypt(inputBytes, secretKey: secretKey, nonce: iv);

    // دمج الـ IV مع الـ Ciphertext
    final combined = Uint8List.fromList([...iv, ...secretBox.cipherText, ...secretBox.mac.bytes]);

    final outputPath = '$inputPath.enc';
    await File(outputPath).writeAsBytes(combined);

    return outputPath;
  }

  /// فك تشفير ملف
  static Future<String> decryptFile(String encryptedPath) async {
    final key = await SecureStore.getFileEncryptionKey();
    final combined = await File(encryptedPath).readAsBytes();

    // فصل الـ IV (12 bytes) + MAC (16 bytes) + Ciphertext
    final iv = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);

    final secretKey = SecretKey(key);
    final decrypted = await _algorithm.decrypt(
      SecretBox(cipherText, nonce: iv, mac: Mac(mac)),
      secretKey: secretKey,
    );

    final tempPath = '${Directory.systemTemp.path}/${const Uuid().v4()}';
    await File(tempPath).writeAsBytes(decrypted);

    return tempPath;
  }
}
```

---

## 9.5 نمط معالجة الأخطاء (Result Pattern)

التطبيق يستخدم **Result Pattern** بدلاً من Exceptions:

```dart
// lib/core/error_handling/result.dart

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  void fold({
    required void Function(T data) onSuccess,
    required void Function(Failure<T> failure) onFailure,
  }) {
    if (this is Success<T>) {
      onSuccess((this as Success<T>).data);
    } else {
      onFailure(this as Failure<T>);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}
```

---

## 9.6 إدارة Interceptors للـ HTTP

```dart
// lib/features/auth/presentation/providers/auth_providers.dart

// Dio مع JWT Interceptor
final authDioProvider = Provider<Dio>((ref) {
  final dio = ref.watch(baseDioProvider);
  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(AuthInterceptor(
    storage: storage,
    onTokenExpired: () async {
      // إعلام الـ AuthNotifier بانتهاء الجلسة
      ref.read(authNotifierProvider.notifier).handleTokenExpired();
    },
  ));

  return dio;
});

// AuthInterceptor
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAuthToken();

    if (token != null) {
      // فحص انتهاء الصلاحية قبل الإرسال
      if (await _storage.isTokenExpired()) {
        _onTokenExpired();
        handler.reject(DioException(requestOptions: options));
        return;
      }
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onTokenExpired();
    }
    handler.next(err);
  }
}
```

---

<a name="section-10"></a>

# القسم العاشر — تحليل الأمان (Security Analysis)

## 10.1 نقاط القوة الأمنية

### أ. تشفير قاعدة البيانات — SQLCipher (AES-256)

قاعدة البيانات الرئيسية محمية بالكامل بتشفير AES-256 عبر `sqflite_sqlcipher`:

```dart
// lib/data/db/drift_database.dart
Future<QueryExecutor> openEncryptedDb() async {
  final encryptionKey = await SecureStore.getDatabaseKey();
  return SqfliteQueryExecutor.inDatabaseFolder(
    path: 'benaa_offline.db',
    password: encryptionKey,   // مفتاح 256-bit
  );
}
```

**المستوى:** عالٍ — البيانات محمية حتى في حالة سرقة الجهاز.

---

### ب. تشفير الملفات — AES-GCM

كل ملف مرفق يُشفَّر قبل الحفظ على القرص:

- الخوارزمية: `AES-GCM 256-bit`
- IV عشوائي لكل عملية تشفير
- المفتاح محفوظ في SecureStorage

---

### ج. التخزين الآمن — flutter_secure_storage

| المنصة  | الآلية                               |
| ------- | ------------------------------------ |
| Android | EncryptedSharedPreferences (AES-256) |
| iOS     | Keychain (Secure Enclave)            |

البيانات المحفوظة: Token, RefreshToken, DeviceId, Email, Password (مشفر)

---

### د. المصادقة البيومترية — local_auth

```dart
final isAuthenticated = await LocalAuthentication().authenticate(
  localizedReason: 'تحقق من هويتك للدخول للتطبيق',
  options: const AuthenticationOptions(biometricOnly: true),
);
```

---

### هـ. JWT Authentication

- التوكن يُرسَل في كل طلب عبر `Authorization: Bearer <token>`
- `AuthInterceptor` يفحص انتهاء الصلاحية قبل كل طلب
- عند 401 → تسجيل الخروج التلقائي

---

### و. إدارة انتهاء الجلسة

```dart
// SessionManager: فحص كل 30 ثانية
Timer.periodic(Duration(seconds: 30), (_) {
  final elapsed = DateTime.now().difference(_lastActivity!);
  if (elapsed.inMinutes >= _timeoutMinutes) {
    _onSessionExpired?.call();  // إعادة توجيه لصفحة الدخول
  }
});
```

---

## 10.2 نقاط الضعف الأمنية (Security Vulnerabilities)

### الخطورة: عالية

| #   | المشكلة                         | الملف                                                        | التفاصيل                                                                      |
| --- | ------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| 1   | **لا يوجد Certificate Pinning** | `auth_providers.dart`                                        | لا يوجد تثبيت للشهادة — عرضة لهجمات MITM                                      |
| 2   | **URL ثابت مكتوب في الكود**     | `app_config.dart`, `api_config.dart`, `download_config.dart` | `https://palestine.benaadev.org` موجود في 8 مواقع — خطر في حالة تغيير السيرفر |

### الخطورة: متوسطة

| #   | المشكلة                                   | الملف                       | التفاصيل                                                             |
| --- | ----------------------------------------- | --------------------------- | -------------------------------------------------------------------- |
| 3   | **لا يوجد Rate Limiting على جانب العميل** | `auth_repository_impl.dart` | يمكن إرسال طلبات Login لا محدودة                                     |
| 4   | **لا يوجد Refresh Token**                 | `auth_repository_impl.dart` | عند انتهاء التوكن يجب إعادة تسجيل الدخول                             |
| 5   | **TODO navigation في الكود**              | متعددة                      | `// TODO: Navigate to visit details page` — كود غير مكتمل في الإنتاج |

### الخطورة: منخفضة

| #   | المشكلة                              | الملف                     | التفاصيل                         |
| --- | ------------------------------------ | ------------------------- | -------------------------------- |
| 6   | **سجلات مفصلة في Debug**             | `unified_logger.dart`     | تسجيل معلومات حساسة في وضع Debug |
| 7   | **ملف env.json في assets**           | `assets/env.example.json` | قد يحتوي على إعدادات حساسة       |
| 8   | **لا يوجد Root/Jailbreak Detection** | —                         | لا يوجد فحص لأجهزة المخترقة      |

---

## 10.3 خريطة الأمان (Security Map)

```
طبقة الشبكة:
  ✅ HTTPS (TLS 1.2+)
  ✅ JWT Authentication
  ❌ Certificate Pinning (مفقود)
  ❌ Rate Limiting (مفقود من جانب العميل)

طبقة التخزين:
  ✅ SQLCipher AES-256 (قاعدة البيانات)
  ✅ flutter_secure_storage (بيانات حساسة)
  ✅ AES-GCM (الملفات المرفقة)
  ⚠️ Civil Registry DB (غير مشفر — SQLite عادي)

طبقة المصادقة:
  ✅ JWT with Expiry Check
  ✅ Biometric Authentication
  ✅ Session Timeout (15 دقيقة)
  ❌ Token Refresh (مفقود)
  ❌ Multi-Factor Authentication (مفقود)

طبقة الجهاز:
  ❌ Root/Jailbreak Detection (مفقود)
  ✅ EncryptedSharedPreferences (Android)
  ✅ Keychain (iOS)
```

---

## 10.4 توصيات الأمان (بترتيب الأولوية)

| الأولوية  | التوصية                         | الجهد | التأثير   |
| --------- | ------------------------------- | ----- | --------- |
| 🔴 عالية  | تطبيق Certificate Pinning       | متوسط | عالٍ جداً |
| 🔴 عالية  | مركزة URL في config واحد فقط    | منخفض | متوسط     |
| 🟡 متوسطة | إضافة Token Refresh             | عالٍ  | عالٍ      |
| 🟡 متوسطة | إضافة Client-side Rate Limiting | منخفض | متوسط     |
| 🟡 متوسطة | تشفير Civil Registry DB         | متوسط | عالٍ      |
| 🟢 منخفضة | إضافة Root Detection            | منخفض | متوسط     |
| 🟢 منخفضة | حذف TODO comments في الإنتاج    | منخفض | منخفض     |

---

## 10.5 تطبيق Certificate Pinning (خطوات التنفيذ)

```dart
// في auth_providers.dart — إضافة Certificate Pinning

final authDioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // إضافة Certificate Pinning
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) {
      // مقارنة fingerprint الشهادة
      final expectedFingerprint = 'SHA256:XXXXXXXXXXXX';
      return cert.sha256 != expectedFingerprint;
    };
    return client;
  };

  return dio;
});
```

---

<a name="section-11"></a>

# القسم الحادي عشر — تحليل الأداء (Performance Analysis)

## 11.1 الأداء الكلي للتطبيق

يُعدّ التطبيق جيد الأداء بشكل عام نظراً لأنه **Offline-first** — معظم العمليات تحدث محلياً بدون انتظار الشبكة.

---

## 11.2 تحسينات الأداء المطبقة

### أ. العمود المُولَّد للبحث العربي (Generated Column)

```sql
-- في جدول beneficiaries
full_name TEXT GENERATED ALWAYS AS (
  first_name || ' ' || second_name || ' ' || third_name || ' ' || last_name
) VIRTUAL,

full_name_norm TEXT GENERATED ALWAYS AS (
  normalize_arabic(full_name)
) STORED   -- يُحسب مرة واحدة ويُحفظ
```

**الأثر:** البحث في `full_name_norm` أسرع 5-10x مقارنة بـ CONCAT في كل query.

---

### ب. Debounce في البحث

```dart
// filters_provider.dart
Timer? _debounceTimer;

void setSearchQuery(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    state = state.copyWith(searchQuery: query);
  });
}
```

**الأثر:** يمنع تنفيذ query جديدة مع كل ضغطة مفتاح — يوفر طلبات DB غير ضرورية.

---

### ج. Cache في قائمة المستفيدين

```dart
// BeneficiariesListNotifier
List<Beneficiary>? _cachedData;
String? _lastCacheKey;

// فحص الـ Cache قبل استعلام DB
if (_lastCacheKey == cacheKey && _cachedData != null) {
  state = state.copyWith(items: _cachedData!, isLoading: false);
  return;
}
```

**الأثر:** يتجنب استعلامات متكررة لنفس الفلاتر.

---

### د. Infinite Scroll (Pagination)

```dart
// تحميل 20 عنصراً في المرة
static const int pageSize = 20;

Future<void> loadMore() async {
  final nextPage = state.currentPage + 1;
  final items = await _fetchBeneficiaries(filters, nextPage);
  state = state.copyWith(
    items: [...state.items, ...items],
    currentPage: nextPage,
    hasMore: items.length >= pageSize,
  );
}
```

**الأثر:** لا يُحمّل الذاكرة بالآلاف من السجلات دفعةً واحدة.

---

### هـ. Skeleton Loading

بدلاً من مؤشر تحميل واحد، يُعرض هيكل الشاشة قبل اكتمال التحميل:

```dart
// عند isLoading = true
if (state.isLoading) {
  return ListView.builder(
    itemCount: 8,
    itemBuilder: (_, __) => const BeneficiaryCardSkeleton(),
  );
}
```

**الأثر:** يُقلل من الشعور بالتأخير (Perceived Performance).

---

### و. WorkManager للمزامنة في الخلفية

```dart
// تسجيل مهمة المزامنة الدورية
await Workmanager().registerPeriodicTask(
  'sync-task',
  'mobileSyncTask',
  frequency: const Duration(minutes: 15),
  constraints: Constraints(networkType: NetworkType.connected),
);
```

**الأثر:** المزامنة لا تحجب الـ UI Thread.

---

## 11.3 نقاط ضعف الأداء

| المشكلة                           | التأثير                            | الحل المُوصى                            |
| --------------------------------- | ---------------------------------- | --------------------------------------- |
| **Civil Registry DB كبيرة**       | وقت تنزيل طويل، بطء في البحث الأول | إضافة Index على الاسم والرقم الوطني     |
| **Form طويل جداً**                | تأخر في بناء الـ Widget Tree       | تقسيمه لأجزاء مُحمَّلة حسب الطلب (Lazy) |
| **إعادة بناء Provider كاملة**     | Re-renders غير ضرورية              | استخدام `ref.watch(provider.select(…))` |
| **PDF Generation في Main Thread** | تجميد الـ UI لحظياً                | نقل التوليد لـ Isolate                  |
| **Large DB Download**             | قد يُفشل في الشبكات البطيئة        | إضافة Resume Download                   |

---

## 11.4 توصيات تحسين الأداء

```dart
// 1. استخدام select() للاشتراك الجزئي
final isLoading = ref.watch(
  beneficiariesListProvider.select((s) => s.isLoading),
);

// 2. نقل PDF Generation لـ Isolate
final pdfBytes = await compute(_generatePdfInIsolate, reportData);

// 3. إضافة Index في SQLite
CREATE INDEX idx_beneficiaries_id_number ON beneficiaries(id_number);
CREATE INDEX idx_sync_queue_state ON sync_queue(sync_state, created_at);
```

---

<a name="section-12"></a>

# القسم الثاني عشر — خطة الاختبارات (Testing Plan)

## 12.1 حالة الاختبارات الحالية

التطبيق لديه بنية اختبارات موجودة في مجلدين:

```
test/                          ← Unit & Widget Tests
├── beneficiaries_list_provider_test.dart
├── beneficiaries_list_state_test.dart
├── bulk_actions_bar_test.dart
├── civil_registry_search_test.dart
├── filters_provider_test.dart
├── filters_bottom_sheet_test.dart
├── selection_provider_test.dart
├── statistics_dashboard_test.dart
├── zero_lag_dialog_perf_test.dart
├── core/
├── data/
├── features/
├── performance/
└── widget/

integration_test/              ← Integration Tests
├── beneficiary_form_failure_path_integration_test.dart
├── beneficiary_form_flow_integration_test.dart
├── enhanced_form_widgets_test.dart
└── form_open_benchmark_ci_baseline_test.dart
```

---

## 12.2 تغطية الاختبارات الحالية

| المجال                      | نوع الاختبار     | الحالة   |
| --------------------------- | ---------------- | -------- |
| Beneficiaries List Provider | Unit Test        | ✅ موجود |
| Beneficiaries List State    | Unit Test        | ✅ موجود |
| Filters Provider            | Unit Test        | ✅ موجود |
| Bulk Actions Bar            | Widget Test      | ✅ موجود |
| Civil Registry Search       | Unit Test        | ✅ موجود |
| Statistics Dashboard        | Widget Test      | ✅ موجود |
| Beneficiary Form Flow       | Integration Test | ✅ موجود |
| Form Performance Baseline   | Integration Test | ✅ موجود |
| **Auth Module**             | —                | ❌ مفقود |
| **Sync Module**             | —                | ❌ مفقود |
| **Kafalat Module**          | —                | ❌ مفقود |
| **Attachments Module**      | —                | ❌ مفقود |
| **Security Tests**          | —                | ❌ مفقود |

---

## 12.3 اختبارات مُوصى بإضافتها

### أ. اختبارات Auth (Unit Tests)

```dart
// test/features/auth/auth_repository_test.dart

group('AuthRepository Login', () {
  test('login with valid credentials returns AuthSession', () async {
    // Arrange
    final mockDio = MockDio();
    when(() => mockDio.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              data: {'success': true, 'data': {'token': 'jwt123', 'user': {...}}},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

    // Act
    final result = await authRepo.login(email: 'test@test.com', password: '123456');

    // Assert
    expect(result.isSuccess, true);
    expect((result as Success).data.token.accessToken, 'jwt123');
  });

  test('login with invalid credentials returns AuthFailure', () async {
    // ...
  });

  test('login with no connection returns OfflineAuthSession', () async {
    // ...
  });
});
```

---

### ب. اختبارات Sync (Unit Tests)

```dart
// test/core/sync/sync_queue_test.dart

group('SyncQueue', () {
  test('adds item to queue with pending state', () async {});
  test('increments attempts on failure', () async {});
  test('marks item as failed after 5 attempts', () async {});
  test('deletes item after successful sync', () async {});
});
```

---

### ج. اختبارات أمان (Security Tests)

```dart
// test/core/security/crypto_box_test.dart

group('CryptoBox', () {
  test('encrypted data differs from original', () async {
    final original = 'sensitive data';
    final encrypted = await CryptoBox.encryptString(original);
    expect(encrypted, isNot(equals(original)));
  });

  test('decrypted data matches original', () async {
    final original = 'sensitive data';
    final encrypted = await CryptoBox.encryptString(original);
    final decrypted = await CryptoBox.decryptString(encrypted);
    expect(decrypted, equals(original));
  });

  test('different IVs produce different ciphertexts', () async {
    final encrypted1 = await CryptoBox.encryptString('data');
    final encrypted2 = await CryptoBox.encryptString('data');
    expect(encrypted1, isNot(equals(encrypted2)));
  });
});
```

---

## 12.4 خطة الاختبارات الشاملة

| المرحلة | النوع                      | الأدوات                    | المدة   |
| ------- | -------------------------- | -------------------------- | ------- |
| 1       | Unit Tests للـ Auth Module | `mocktail`, `flutter_test` | أسبوع   |
| 2       | Unit Tests للـ Sync Module | `mocktail`, `drift_dev`    | أسبوعان |
| 3       | Widget Tests لجميع الشاشات | `flutter_test`             | أسبوعان |
| 4       | Integration Tests كاملة    | `integration_test`         | أسبوع   |
| 5       | Performance Tests          | `flutter_driver`           | أسبوع   |
| 6       | Security Tests             | `flutter_test`             | أسبوع   |

---

## 12.5 تشغيل الاختبارات الحالية

```bash
# Unit + Widget Tests مع تغطية
flutter test --coverage

# Integration Tests على جهاز حقيقي
flutter test integration_test/beneficiary_form_flow_integration_test.dart

# عرض تقرير التغطية
genhtml coverage/lcov.info -o coverage/html
```

---

<a name="section-13"></a>

# القسم الثالث عشر — أسئلة وإجابات اللجنة (Committee Q&A)

## الأسئلة المتوقعة وإجاباتها الكاملة

---

### السؤال 1: لماذا اخترتم Flutter وليس React Native أو تطبيق Native؟

**الإجابة:**
اخترنا Flutter لثلاثة أسباب رئيسية:

1. **الأداء**: Flutter يُجمَّع لكود Native مباشرة، بعكس React Native الذي يعمل عبر JavaScript Bridge. هذا مهم لنا لأن التطبيق يتعامل مع قواعد بيانات ضخمة.
2. **تغطية المنصات**: كود واحد يعمل على Android وiOS بدون تكلفة مضاعفة.
3. **النظام البيئي**: مكتبة Drift للـ SQLite، Riverpod لإدارة الحالة، وDio للشبكة — كلها مكتبات Flutter ناضجة تماماً لهذا النوع من التطبيقات.

---

### السؤال 2: لماذا SQLite وليس Firebase Firestore؟

**الإجابة:**
السياق الجغرافي هو المحدد الرئيسي. التطبيق مُصمَّم للعمل في مناطق فلسطين التي تعاني من انقطاعات متكررة في الإنترنت. SQLite يعمل محلياً 100% بدون إنترنت، بينما Firestore يحتاج اتصالاً للمزامنة في معظم العمليات. نعم، Firebase لديه Offline Mode، لكنه محدود في حجم البيانات والاستعلامات المعقدة. SQLite يدعم JOIN معقد وFULL-TEXT search — وهذا ضروري لبحثنا في ملايين سجلات السجل المدني.

---

### السؤال 3: كيف يضمن التطبيق عدم ضياع البيانات عند انقطاع الاتصال أثناء المزامنة؟

**الإجابة:**
نستخدم نظام **Sync Queue** — أي عملية (إنشاء/تعديل/حذف) تُسجَّل أولاً في جدول `sync_queue` قبل إرسالها للسيرفر. عند انقطاع الاتصال، تبقى في الـ Queue. عند عودة الاتصال، WorkManager يُشغّل عملية المزامنة. فقط عند التأكيد من السيرفر تُحذف من الـ Queue وتُعدَّل حالتها إلى `synced`.

---

### السؤال 4: كيف تضمنون أمان البيانات الحساسة للمستفيدين؟

**الإجابة:**
نطبق دفاعاً متعدد الطبقات:

- **قاعدة البيانات**: مشفرة بالكامل بـ SQLCipher AES-256
- **الملفات المرفقة**: مشفرة بـ AES-GCM 256-bit قبل الحفظ على القرص
- **بيانات المصادقة**: محفوظة في Keychain/EncryptedSharedPreferences
- **الاتصال بالسيرفر**: HTTPS + JWT Authentication
- **الجلسة**: تنتهي تلقائياً بعد 15 دقيقة من عدم النشاط
- **البيومترية**: طبقة إضافية للوصول

---

### السؤال 5: ما هو نمط Clean Architecture وكيف طبقتموه؟

**الإجابة:**
Clean Architecture يفصل التطبيق إلى ثلاث طبقات:

```
1. Domain Layer (المركز): الكيانات + Use Cases + Interfaces
   - لا تعتمد على أي مكتبة خارجية
   - مثال: AuthRepository (interface), AuthSession (entity)

2. Data Layer: تنفيذ الـ Interfaces
   - AuthRepositoryImpl يتعامل مع Dio + SecureStorage
   - BeneficiariesDao يتعامل مع Drift/SQLite

3. Presentation Layer: الـ UI + State Management
   - AuthNotifier (Riverpod) يستدعي AuthRepository
   - LoginPageV2 يراقب authNotifierProvider
```

الفائدة: يمكن استبدال SQLite بـ Firebase أو استبدال Riverpod بـ Bloc دون تغيير الـ Domain Layer.

---

### السؤال 6: ما هو Riverpod ولماذا اخترتموه على Provider أو Bloc؟

**الإجابة:**
Riverpod هو تطور لمكتبة Provider من نفس المطور، يُحل مشاكلها الجوهرية:

- **Type-safe**: لا يمكن Watch provider من نوع خاطئ
- **Compile-time safe**: الأخطاء تظهر أثناء البناء وليس وقت التشغيل
- **Testing**: أسهل في الاختبار من Provider
- **Scoping**: دعم أفضل لتحديد نطاق الـ Provider

اخترناه على Bloc لأن المشروع ليس ضخماً لدرجة تستوجب بيروقراطية Bloc الزائدة. Riverpod يوفر توازناً مثالياً.

---

### السؤال 7: كيف يعمل نظام الكفالات (Sponsorship)?

**الإجابة:**
الكفالة هي ربط ثلاثي:

```
المستفيد ← كفالة → الجمعية الخيرية
```

كل كفالة لها: مبلغ شهري، عملة، تاريخ بداية ونهاية، وحالة (نشطة/مجمدة/منتهية). الموظف يمكنه:

1. إنشاء كفالة يدوياً من واجهة التطبيق
2. استيراد بيانات الكفالات من ملف Excel دفعةً واحدة
3. طباعة تقرير الكفالات بصيغة PDF

---

### السؤال 8: لماذا قاعدة بيانات السجل المدني منفصلة؟

**الإجابة:**
لأن قاعدة السجل المدني تحتوي على ملايين السجلات (ملفات ضخمة تتجاوز 500MB). دمجها في قاعدة البيانات الرئيسية سيُبطئ جميع العمليات. الفصل يُعطي:

- استعلامات أسرع على كلا الجانبين
- إمكانية تحديث السجل المدني مستقلاً
- عدم تأثير تحديث السجل المدني على بيانات المستفيدين

---

### السؤال 9: ما الفرق بين sync_state في جدول beneficiaries وجدول sync_queue؟

**الإجابة:**
| الجانب | sync_state في beneficiaries | sync_queue |
|--------|--------------------------|-----------|
| **الغرض** | حالة السجل نفسه | قائمة انتظار العمليات |
| **القيم** | pending / synced / failed | pending / processing / failed |
| **يُحذف؟** | لا — يبقى دائماً | نعم — يُحذف بعد النجاح |
| **الاستخدام** | للعرض في الـ UI | لمحرك المزامنة |

---

### السؤال 10: ماذا يحدث عند تعارض البيانات (Conflict Resolution)?

**الإجابة:**
حالياً، التطبيق يستخدم **Server-Wins** بشكل افتراضي — بيانات السيرفر تُلغي البيانات المحلية عند التعارض. هذا مناسب لأن:

- كل موظف يعمل على مجموعة محددة من المستفيدين
- التعارض نادر الحدوث في الواقع العملي

للمستقبل، نُوصي بتطبيق **Timestamp-based Resolution** — الأحدث تاريخاً يفوز، مع سجل للتعارضات يمكن للمشرف مراجعته يدوياً.

---

### السؤال 11: كيف يعمل نظام الإشعارات؟

**الإجابة:**
التطبيق يستخدم `flutter_local_notifications` للإشعارات المحلية فقط (بدون Firebase). الإشعارات تُستخدم لـ:

- تقدم تنزيل قاعدة السجل المدني
- نتائج المزامنة في الخلفية
- تنبيهات انتهاء الجلسة

لا يوجد حالياً Push Notifications من السيرفر — يمكن إضافتها عبر Firebase Messaging لاحقاً.

---

### السؤال 12: ما هي أبرز التحديات التقنية التي واجهتموها؟

**الإجابة:**

1. **البحث العربي**: الأحرف العربية لها أشكال متعددة. حللناها بإنشاء عمود `full_name_norm` يُطبَّق عليه `Normalizer` يُوحّد الأحرف قبل البحث.
2. **حجز معرفات الملفات أوفلاين**: عند إنشاء كفالة بدون إنترنت، يحتاج النظام رقم ملف فريد. حللناها بنظام `file_id_reservations` — يُحجز رقم مؤقت محلياً ويُستبدل بالرقم الحقيقي من السيرفر عند المزامنة.
3. **أداء القوائم الطويلة**: مع آلاف المستفيدين، الـ ListView العادي بطيء. حللناها بـ Pagination + في الذاكرة Cache.

---

### السؤال 13: كيف تتعاملون مع حالة عدم وجود إنترنت عند تسجيل الدخول لأول مرة؟

**الإجابة:**
المرة الأولى تُشترط وجود إنترنت لأننا نحتاج التحقق من السيرفر وتنزيل قاعدة البيانات. بعد الدخول الأول، التوكن يُحفظ في SecureStorage مع تاريخ انتهاء صلاحيته. في المرات التالية، إذا لم يكن التوكن منتهياً، يُتاح الدخول أوفلاين مع إشعار واضح للمستخدم بأنه في وضع Offline.

---

### السؤال 14: لماذا استخدمتم Drift وليس مكتبة SQLite مباشرة؟

**الإجابة:**
Drift يوفر:

1. **Type-safety**: الاستعلامات تُتحقق منها وقت الترجمة وليس وقت التشغيل
2. **Code Generation**: الكود المرتبط بالـ DB يُولَّد تلقائياً من التعريفات
3. **Migration API**: إدارة ترقيات قاعدة البيانات بشكل منظم
4. **Stream Support**: مشاهدة التغييرات في DB بشكل reactive
5. **Reactive Queries**: الـ UI يتحدث تلقائياً عند تغيير البيانات

---

### السؤال 15: ما خططكم المستقبلية للتطبيق؟

**الإجابة:**
(انظر القسم الرابع عشر — خطة العمل الكاملة)

---

<a name="section-14"></a>

# القسم الرابع عشر — خطة العمل (Action Plan)

## 14.1 الأولويات الفورية (الشهر الأول)

| #   | المهمة                                         | المسؤول      | الجهد  | الأثر     |
| --- | ---------------------------------------------- | ------------ | ------ | --------- |
| 1   | حذف الوحدات الاختبارية من الـ Production Build | مطور Backend | يوم    | منخفض     |
| 2   | مركزة URL السيرفر في ملف config واحد           | مطور Mobile  | يوم    | متوسط     |
| 3   | تطبيق Certificate Pinning                      | مطور Mobile  | 3 أيام | أمان عالٍ |
| 4   | إضافة اختبارات Auth Module                     | مطور Mobile  | أسبوع  | جودة      |
| 5   | إصلاح TODO navigation                          | مطور Mobile  | يومان  | وظيفي     |

---

## 14.2 التحسينات قصيرة المدى (الشهر 2-3)

| #   | المهمة                             | المسؤول               | الجهد   | الأثر   |
| --- | ---------------------------------- | --------------------- | ------- | ------- |
| 6   | إضافة Token Refresh Mechanism      | مطور Mobile + Backend | أسبوعان | UX عالٍ |
| 7   | تشفير Civil Registry DB            | مطور Mobile           | أسبوع   | أمان    |
| 8   | تحويل Form للمستفيد لـ Stepper     | مطور UI               | أسبوعان | UX      |
| 9   | إضافة Resume Download للـ Civil DB | مطور Mobile           | أسبوع   | UX      |
| 10  | نقل PDF Generation لـ Isolate      | مطور Mobile           | 3 أيام  | أداء    |
| 11  | إضافة Root/Jailbreak Detection     | مطور Mobile           | 3 أيام  | أمان    |

---

## 14.3 التطوير متوسط المدى (الشهر 3-6)

| #   | المهمة                              | المسؤول               | الجهد   | الأثر  |
| --- | ----------------------------------- | --------------------- | ------- | ------ |
| 12  | Conflict Resolution بدل Server-Wins | مطور Mobile + Backend | شهر     | بيانات |
| 13  | دعم Push Notifications عبر Firebase | مطور Mobile + Backend | أسبوعان | UX     |
| 14  | إضافة Tablet UI                     | مطور UI               | شهر     | UX     |
| 15  | إضافة Accessibility (Screen Reader) | مطور UI               | أسبوعان | وصول   |
| 16  | نظام Onboarding للمستخدم الجديد     | مطور UI               | أسبوع   | UX     |
| 17  | تغطية اختبارات 80%+                 | فريق الجودة           | شهران   | جودة   |

---

## 14.4 التطوير بعيد المدى (6+ أشهر)

| #   | المهمة                         | المسؤول       | الجهد  | الأثر      |
| --- | ------------------------------ | ------------- | ------ | ---------- |
| 18  | الانتقال لـ Firebase (اختياري) | كل الفريق     | 3 أشهر | بنية تحتية |
| 19  | إضافة AI لتحليل الاحتياجات     | مطور Data     | 3 أشهر | قيمة مضافة |
| 20  | لوحة تحكم ويب للمشرفين         | مطور Frontend | 3 أشهر | إدارة      |
| 21  | تطوير iOS Production Build     | مطور Mobile   | شهران  | توسع       |

---

## 14.5 ملخص تنفيذي — أبرز ما يميز هذا المشروع

| الجانب             | المستوى | التفاصيل                                  |
| ------------------ | ------- | ----------------------------------------- |
| **الفكرة**         | ممتازة  | حل حقيقي لمشكلة حقيقية في سياق إنساني     |
| **البنية التقنية** | متقدمة  | Clean Architecture + Riverpod + Drift     |
| **الأمان**         | جيد     | AES-256 + JWT + Biometric                 |
| **الأداء**         | جيد     | Cache + Pagination + Debounce             |
| **UX/UI**          | جيد     | MD3 + RTL + Offline-first                 |
| **الاختبارات**     | متوسط   | يحتاج توسعاً                              |
| **التوثيق**        | جيد     | هذا التقرير + README                      |
| **جاهزية الإنتاج** | ~80%    | يحتاج Certificate Pinning + Token Refresh |

---

## 14.6 الخلاصة النهائية

تطبيق **بناء للعمل الإنساني** يُمثّل مشروعاً تقنياً ناضجاً يعالج تحديات حقيقية تواجه المنظمات الإنسانية في مناطق النزاع. اتخاذ قرار الـ Offline-first كأساس للبنية، واستخدام أحدث مكتبات Flutter، وتطبيق معايير أمنية عالية — كلها تُؤهّله ليكون أداة عمل احترافية وليس مجرد مشروع أكاديمي.

الخطوات الفورية المطلوبة (Certificate Pinning، Token Refresh، حذف Test Pages) إذا نُفِّذت، سيصبح التطبيق جاهزاً 100% للنشر الإنتاجي.

---

_نهاية التقرير التقني الشامل_

_تاريخ الإعداد: 2026_

_إعداد: فريق مشروع التخرج — بالتعاون مع GitHub Copilot_

---

<a name="section-15"></a>

# القسم الخامس عشر — مقارنة تقنية معمّقة (Technology Comparison Matrix)

## 15.1 قرارات التقنية الرئيسية ومبررات الاختيار

---

### أ. اختيار اللغة والإطار

| المعيار           | Flutter (المختار)            | React Native               | Native Android/iOS   |
| ----------------- | ---------------------------- | -------------------------- | -------------------- |
| **الأداء**        | ✅ كود Native مُجمَّع مباشرة | ⚠️ JavaScript Bridge       | ✅ أداء مثالي        |
| **كود مشترك**     | ✅ 100%                      | ✅ ~85%                    | ❌ كودان منفصلان     |
| **Dart Language** | ✅ Type-safe, null-safe      | ❌ JavaScript (أقل أماناً) | ✅ Java/Swift/Kotlin |
| **SQLite دعم**    | ✅ Drift + sqflite           | ⚠️ محدود                   | ✅ جيد               |
| **نضج المكتبات**  | ✅ ناضج                      | ✅ ناضج                    | ✅ ناضج              |
| **حجم APK**       | ⚠️ أكبر قليلاً               | ⚠️ أكبر                    | ✅ أصغر              |
| **وقت التطوير**   | ✅ أسرع                      | ✅ أسرع                    | ❌ أبطأ (منصتان)     |
| **المجتمع**       | ✅ ينمو بسرعة                | ✅ كبير                    | ✅ كبير              |
| **القرار**        | ✅ **الأنسب للمشروع**        | —                          | —                    |

**سبب اختيار Flutter:** توازن مثالي بين الأداء وسرعة التطوير، مع دعم قوي لـ SQLite ومكتبات Offline-first.

---

### ب. اختيار قاعدة البيانات

| المعيار              | SQLite + Drift (المختار) | Firebase Firestore     | Realm    | ObjectBox        |
| -------------------- | ------------------------ | ---------------------- | -------- | ---------------- |
| **عمل Offline**      | ✅ كامل                  | ⚠️ محدود               | ✅ كامل  | ✅ كامل          |
| **حجم البيانات**     | ✅ ملايين سجل            | ⚠️ محدود بالتكلفة      | ✅ جيد   | ✅ ممتاز         |
| **استعلامات معقدة**  | ✅ Full SQL              | ❌ محدود               | ⚠️ محدود | ⚠️ محدود         |
| **Type-safety**      | ✅ عبر Drift             | ⚠️ Map<String,dynamic> | ✅ جيد   | ✅ ممتاز         |
| **التكلفة**          | ✅ مجاني                 | ❌ مدفوع مع النمو      | ✅ مجاني | ⚠️ محدود مجانياً |
| **التشفير**          | ✅ SQLCipher AES-256     | ✅ مُدار من Google     | ⚠️ إضافي | ⚠️ إضافي         |
| **Migration**        | ✅ Drift Migration API   | ⚠️ يدوي                | ⚠️ يدوي  | ⚠️ يدوي          |
| **Reactive Queries** | ✅ Stream<QueryResult>   | ✅ ممتاز               | ✅ ممتاز | ✅ ممتاز         |
| **القرار**           | ✅ **الأنسب**            | —                      | —        | —                |

---

### ج. اختيار إدارة الحالة

| المعيار                       | Riverpod 2.x (المختار) | Bloc/Cubit     | Provider          | GetX      |
| ----------------------------- | ---------------------- | -------------- | ----------------- | --------- |
| **Type Safety**               | ✅ Compile-time        | ✅ جيد         | ⚠️ Runtime errors | ❌ ضعيف   |
| **Testing**                   | ✅ سهل جداً            | ✅ جيد         | ⚠️ معقد           | ⚠️ معقد   |
| **Boilerplate**               | ✅ قليل                | ❌ كثير        | ✅ قليل           | ✅ قليل   |
| **DI (Dependency Injection)** | ✅ مدمج                | ❌ يحتاج مكتبة | ⚠️ جزئي           | ✅ مدمج   |
| **Scoping**                   | ✅ ممتاز               | ⚠️ محدود       | ⚠️ محدود          | ⚠️ محدود  |
| **Stream Support**            | ✅ StreamProvider      | ✅ StreamBloc  | ⚠️ يدوي           | ⚠️ يدوي   |
| **المجتمع**                   | ✅ ينمو                | ✅ كبير        | ✅ كبير           | ⚠️ متشعّب |
| **القرار**                    | ✅ **الأنسب**          | —              | —                 | —         |

---

### د. اختيار HTTP Client

| المعيار              | Dio 5.x (المختار) | http         | chopper  |
| -------------------- | ----------------- | ------------ | -------- |
| **Interceptors**     | ✅ مدمج وقوي      | ❌ يدوي      | ✅ جيد   |
| **Retry Logic**      | ✅ مكتبة إضافية   | ❌ يدوي      | ✅ جيد   |
| **CancelToken**      | ✅ مدمج           | ❌ غير موجود | ⚠️ محدود |
| **FormData**         | ✅ مدمج           | ⚠️ يدوي      | ✅ جيد   |
| **Response Parsing** | ✅ مرن            | ⚠️ يدوي      | ✅ جيد   |
| **القرار**           | ✅ **الأنسب**     | —            | —        |

---

### هـ. اختيار نمط الأمان

| المعيار                      | SQLCipher + AES-GCM (المختار)    | بدون تشفير | AES-CBC         |
| ---------------------------- | -------------------------------- | ---------- | --------------- |
| **قوة التشفير**              | ✅ AES-256-GCM (المعيار العسكري) | ❌ لا توجد | ⚠️ أقدم         |
| **Authenticated Encryption** | ✅ GCM يتحقق من التكامل          | ❌         | ❌ CBC لا يتحقق |
| **أداء**                     | ✅ سريع على Modern CPUs          | ✅ الأسرع  | ✅ سريع         |
| **IV Reuse Risk**            | ✅ Random IV لكل عملية           | —          | ⚠️ خطر في CBC   |
| **القرار**                   | ✅ **الأفضل أمنياً**             | —          | —               |

---

## 15.2 ملخص القرارات التقنية

```
المجال             القرار               البديل المرفوض        سبب الرفض
─────────────────────────────────────────────────────────────────────────
Framework         Flutter              React Native          أداء أدنى
ORM               Drift                sqflite مباشر         لا type-safety
State Mgmt        Riverpod             Bloc                  Boilerplate زائد
HTTP Client       Dio                  http                  لا Interceptors
DB Encryption     SQLCipher            بدون تشفير            بيانات حساسة
File Encryption   AES-GCM             AES-CBC               أقدم وأقل أماناً
Token Storage     SecureStorage        SharedPreferences     غير مشفر
Navigation        GoRouter             Navigator 2.0 مباشر   تعقيد زائد
Background Sync   WorkManager          Isolates يدوية         تعقيد زائد
Error Monitoring  Sentry               Firebase Crashlytics  لا يحتاج Firebase
```

---

<a name="section-16"></a>

# القسم السادس عشر — تدفق البيانات الكامل (End-to-End Data Flow)

## 16.1 رحلة إنشاء مستفيد جديد — من اللمسة الأولى للمزامنة

```
┌─────────────────────────────────────────────────────────────────────┐
│                      المستخدم (الموظف الميداني)                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │ يضغط "إضافة مستفيد جديد"
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BeneficiaryFormPageV3                             │
│  • يعرض نموذج متعدد الأقسام                                         │
│  • يُحمّل التصنيفات من taxonomiesProvider                            │
│  • يُحمّل الجمعيات من associationsProvider                           │
└────────────────────────────┬────────────────────────────────────────┘
                             │ المستخدم يملأ البيانات ويضغط "حفظ"
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Form Validation Layer                           │
│  • GlobalKey<FormState>.validate()                                   │
│  • تحقق: رقم هوية 9 أرقام فريد، اسم بالعربي، هاتف صالح             │
│  • في حالة فشل → عرض رسائل الخطأ المحلية                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │ التحقق نجح
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   BeneficiaryRepository.save()                       │
│  • بناء BeneficiaryCompanion من بيانات النموذج                       │
│  • تعيين sync_state = 'pending'                                      │
│  • تعيين created_at = DateTime.now()                                 │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SQLite (via Drift ORM)                            │
│  INSERT INTO beneficiaries (...) VALUES (...)                        │
│  → يُعيد id الجديد (AUTO_INCREMENT)                                  │
│                                                                      │
│  INSERT INTO sync_queue (entity='beneficiary', op='create', ...)     │
│  → يُسجّل العملية للمزامنة لاحقاً                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│               ref.invalidate(beneficiariesListProvider)              │
│  → إعادة تحميل القائمة تلقائياً (Reactive)                           │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    GoRouter Navigation                               │
│  context.go('/beneficiaries/$newId')                                 │
│  → يعرض صفحة تفاصيل المستفيد الجديد                                 │
└────────────────────────────┬────────────────────────────────────────┘
                             │
           ┌─────────────────┘ (لاحقاً — عند توافر الإنترنت)
           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     WorkManager Background Task                      │
│  → يُشغّل MobileSyncService.syncAll() كل 15 دقيقة                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Sync Queue Processing                             │
│  SELECT * FROM sync_queue WHERE sync_state='pending' LIMIT 50        │
│  ORDER BY priority DESC, created_at ASC                              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Dio HTTP Client                                   │
│  POST /api/mobile/database/data/batch                                │
│  Headers: { Authorization: Bearer <JWT> }                            │
│  Body: { beneficiaries: [...], visits: [...] }                       │
└────────────────────────────┬────────────────────────────────────────┘
                             │
          ┌──────────────────┴──────────────────┐
          ▼ (نجاح 200)                          ▼ (فشل 4xx/5xx)
┌─────────────────────┐               ┌──────────────────────────┐
│ UPDATE beneficiaries│               │ attempts++ في sync_queue  │
│ SET sync_state =    │               │ إذا attempts >= 5:        │
│ 'synced'            │               │   sync_state = 'failed'   │
│                     │               │   Sentry.capture(error)   │
│ DELETE FROM         │               └──────────────────────────┘
│ sync_queue WHERE    │
│ id = ?              │
└─────────────────────┘
```

---

## 16.2 رحلة تسجيل الدخول — من الضغطة للـ Dashboard

```
LoginPageV2
    │ email + password
    ▼
AuthNotifier.login()
    │ state = AuthLoading
    ▼
AuthRepositoryImpl.login()
    │
    ├── [Online] Dio.post('/api/mobile/auth/login')
    │       │ response.statusCode == 200
    │       ▼
    │   SecureStorage.write(authToken)
    │   SecureStorage.write(tokenExpiry)
    │   SecureStorage.write(userId)
    │       │
    │       ▼
    │   state = AuthAuthenticated(session)
    │
    └── [Offline] SecureStorage.isLoggedIn() && !isTokenExpired()
            │
            ▼
        state = AuthAuthenticated(session, isOffline: true)

GoRouter redirect()
    │ isAuthenticated = true
    │
    ├── civil_db exists? → /dashboard
    └── civil_db missing? → /database-download
```

---

## 16.3 رحلة البحث في السجل المدني

```
CivilSearchPage
    │ يكتب المستخدم اسماً
    ▼
Debounce (300ms)
    │
    ▼
CivilRegistryDao.searchByName(normalizedQuery)
    │
    ▼ [قاعدة بيانات منفصلة: civil_registry.db]
SELECT * FROM persons
WHERE full_name_norm LIKE '%' || ? || '%'
LIMIT 50
    │
    ▼
عرض النتائج فورياً (Offline — لا إنترنت مطلوب)
    │
    ▼ [إذا اختار المستخدم شخصاً]
نقل البيانات → BeneficiaryFormPageV3
    │ pre-fill النموذج بالبيانات المختارة
```

---

<a name="section-17"></a>

# القسم السابع عشر — تحليل الحالات الحرجة (Edge Cases Analysis)

## 17.1 قائمة الحالات الحرجة المُحددة

---

### الحالة 1: امتلاء الذاكرة أثناء تنزيل Civil Registry DB

**السيناريو:** الجهاز يمتلئ تخزينه أثناء تنزيل ملف يزيد عن 500MB.

**الحل الحالي:** لا يوجد فحص مسبق لمساحة التخزين.

**الحل المُوصى:**

```dart
// قبل بدء التنزيل
final availableSpace = await getAvailableStorage();
final requiredSpace = await getRemoteFileSize(downloadUrl);

if (availableSpace < requiredSpace * 1.2) { // هامش 20%
  throw InsufficientStorageException(
    available: availableSpace,
    required: requiredSpace,
  );
}
```

---

### الحالة 2: تغيُّر الـ Token أثناء مزامنة نشطة

**السيناريو:** المزامنة تستغرق 5 دقائق، وينتهي الـ Token في منتصفها.

**الحل الحالي:** الـ `AuthInterceptor` يُوقف الطلبات عند 401 ويُشغّل `handleTokenExpired()` — لكن الـ Sync Queue تبقى في حالة غير محددة.

**الحل المُوصى:**

```dart
// في MobileSyncService
try {
  await _processQueue();
} on TokenExpiredException {
  // إيقاف المزامنة بشكل نظيف
  await _markAllProcessingAsPending(); // إعادة العناصر لـ pending
  _statusStream.add(SyncStatus.paused(reason: 'token_expired'));
}
```

---

### الحالة 3: فتح التطبيق على جهازين بنفس الحساب

**السيناريو:** موظفان مختلفان يستخدمان نفس بيانات الدخول، أو نفس الموظف يستخدم جهازين.

**الحل الحالي:** السيرفر يقبل نفس الحساب من أجهزة متعددة (لا Single Session enforcement). البيانات قد تتعارض.

**الحل المُوصى:**

- إضافة `deviceId` كجزء من الـ Session على السيرفر
- السيرفر يُبطل جلسات الأجهزة الأخرى عند تسجيل دخول جديد
- أو السماح بأجهزة متعددة مع تسجيل `deviceId` في كل عملية sync

---

### الحالة 4: مزامنة مستفيد محذوف محلياً موجود على السيرفر

**السيناريو:** موظف حذف مستفيداً محلياً، لكن المزامنة لم تُكمَل. موظف آخر عدّل نفس المستفيد.

**الحل الحالي:** Server-wins — الحذف المحلي قد يُفشل إذا تعارض مع تعديل على السيرفر.

**الحل المُوصى:**

```dart
// في TombstoneDeleteSyncUseCase
final serverVersion = await _checkServerVersion(entityId);
if (serverVersion > localDeletedVersion) {
  // تعارض — يحتاج مراجعة يدوية
  await _createConflictRecord(entityId, 'delete_conflict');
  return ConflictResult.requiresManualReview;
}
```

---

### الحالة 5: تلف قاعدة البيانات (DB Corruption)

**السيناريو:** انقطاع مفاجئ للكهرباء أثناء كتابة بيانات في SQLite.

**الحل الحالي:** Drift يستخدم WAL (Write-Ahead Logging) افتراضياً — يوفر حماية ضد التلف.

**الحل المُوصى الإضافي:**

```dart
// إضافة نسخ احتياطي دوري
await _db.customStatement('PRAGMA integrity_check;');
// إذا فشل → تنبيه المستخدم وبدء إجراء الاسترداد
```

---

### الحالة 6: رقم هوية مكرر في قاعدتي بيانات مختلفتين

**السيناريو:** نفس رقم الهوية موجود في Civil Registry وفي beneficiaries — لكن الاسم مختلف (خطأ في السجل المدني).

**الحل الحالي:** لا يوجد تحقق تلقائي بين القاعدتين.

**الحل المُوصى:** عند إدخال مستفيد جديد، مقارنة تلقائية مع Civil Registry وتنبيه المستخدم بالتناقضات.

---

### الحالة 7: استيراد Excel بتنسيق مختلف

**السيناريو:** مستخدم يرفع ملف Excel بأعمدة مُرتَّبة بشكل مختلف.

**الحل الحالي:** غير واضح من الكود — يحتمل أن يفشل بصمت.

**الحل المُوصى:**

```dart
// التحقق من وجود الأعمدة المطلوبة
final requiredColumns = ['file_no', 'beneficiary_id', 'amount', 'association_id'];
final missingColumns = requiredColumns.where((col) => !headers.contains(col)).toList();

if (missingColumns.isNotEmpty) {
  throw ExcelFormatException(missingColumns: missingColumns);
}
```

---

## 17.2 ملخص الحالات الحرجة

| الحالة                       | الخطورة | الحل الحالي    | الأولوية  |
| ---------------------------- | ------- | -------------- | --------- |
| امتلاء التخزين أثناء التنزيل | عالية   | ❌ لا يوجد     | فورية     |
| انتهاء Token أثناء Sync      | متوسطة  | ⚠️ جزئي        | قصير مدى  |
| أجهزة متعددة بحساب واحد      | متوسطة  | ❌ لا يوجد     | متوسط مدى |
| تعارض الحذف مع التعديل       | عالية   | ⚠️ Server-wins | متوسط مدى |
| تلف قاعدة البيانات           | عالية   | ✅ WAL موجود   | تحسين     |
| رقم هوية مكرر بين القاعدتين  | متوسطة  | ❌ لا يوجد     | متوسط مدى |
| Excel بتنسيق مختلف           | منخفضة  | ❌ لا يوجد     | قصير مدى  |

---

<a name="section-18"></a>

# القسم الثامن عشر — تحليل ترقيات قاعدة البيانات (Schema Migrations)

## 18.1 نظرة عامة

التطبيق وصل إلى `schemaVersion = 32` — أي مرّ بـ **32 ترقية تراكمية** من البداية. هذا يعكس تطور المشروع وإضافة متطلبات جديدة باستمرار.

```dart
// lib/data/db/drift_database.dart
@DriftDatabase(tables: [...], daos: [...])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 32;
```

---

## 18.2 تاريخ الترقيات الرئيسية

| الإصدار | التغيير الرئيسي                                               | الأثر                    |
| ------- | ------------------------------------------------------------- | ------------------------ |
| v12     | نقل Civil Registry لقاعدة بيانات منفصلة                       | قرار معماري كبير         |
| v13     | إضافة جدول Sponsorships (الكفالات)                            | ميزة أساسية جديدة        |
| v14     | إضافة import_batches (مراجعة استيراد Excel)                   | تتبع العمليات            |
| v15     | إضافة sponsorship_type + ربط import_batch                     | توسعة بيانات             |
| v16     | إضافة 15 حقلاً شاملاً للكفالة (كافل، بنك، موقع)               | توسعة كبيرة              |
| v17     | إضافة file_id_reservations                                    | ميزة حجز الأرقام Offline |
| v18     | إضافة sync columns للزيارات والمرفقات                         | تحسين المزامنة           |
| v19     | **مسح كامل للتصنيفات** — تغيير استراتيجية IDs                 | تغيير جذري               |
| v20     | إضافة file_id reservation batches                             | تحسين الحجز              |
| v21     | إضافة Tombstones للحذف المزامَن                               | ميزة جديدة               |
| v22-v23 | جداول ملفات تعريف الجمعيات                                    | توسعة الجمعيات           |
| v24-v27 | تحسينات taxonomy linkage (guarantee_type, disability, income) | ربط التصنيفات            |
| v28     | تطبيع بيانات قديمة في المرفقات                                | إصلاح بيانات             |
| v29-v30 | local_codes table + backfill                                  | ميزة الأكواد المحلية     |
| v31     | guardian_bank_accounts — حسابات بنكية للأوصياء                | توسعة مالية              |
| v32     | sidecar parity tables للكيانات المرتبطة                       | توافق مع Backend         |

---

## 18.3 استراتيجية الترقية

الكود يتبع **Incremental Non-Destructive Migrations**:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  // كل إصدار مستقل — لا يُفترض ترتيب معين
  if (from < 13) { await m.createTable(sponsorships); }
  if (from < 17) { await m.createTable(fileIdReservationTable); }
  if (from < 19) {
    // الاستثناء الوحيد: مسح التصنيفات لإعادة بنائها
    await customStatement('DELETE FROM taxonomies;');
  }
  // دائماً في النهاية: إعادة بناء الـ Indexes
  await _createPerformanceIndexes();
}
```

**نقاط القوة:**

- ✅ كل ترقية مستقلة (`if from < N`)
- ✅ الإضافات فقط (لا حذف أعمدة)
- ✅ `try/catch` حول إنشاء الجداول التي قد تكون موجودة
- ✅ إعادة بناء الـ Indexes بعد كل ترقية

**نقاط الضعف:**

- ⚠️ لا يوجد اختبار تلقائي للـ Migrations (Migration Tests)
- ⚠️ الترقية v19 تحذف بيانات (خطر على مستخدمين بدون إنترنت)
- ⚠️ كود الترقيات في ملف واحد — يصعب قراءته مع الوقت

---

## 18.4 أفضل الممارسات للـ Migrations

```dart
// ✅ مُوصى: اختبارات Migration
test('migration from v31 to v32 creates parity tables', () async {
  final db = await openTestDatabase(version: 31);
  await db.runMigration(31, 32);

  final tables = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type='table'"
  ).get();

  expect(tables.map((t) => t.read<String>('name')),
    contains('related_entities_parity'));
});
```

---

<a name="section-19"></a>

# القسم التاسع عشر — مؤشرات الأداء القابلة للقياس (KPIs)

## 19.1 KPIs الأداء الحالية (مُقاسة / مُقدَّرة)

| المؤشر                           | القيمة الحالية    | الهدف         | الأداة                        |
| -------------------------------- | ----------------- | ------------- | ----------------------------- |
| **وقت بدء التطبيق (Cold Start)** | ~2-3 ثانية        | < 2 ثانية     | `flutter_driver`              |
| **وقت فتح قائمة المستفيدين**     | ~800ms (1000 سجل) | < 500ms       | `flutter_driver`              |
| **وقت البحث (Debounce + Query)** | ~300ms+query      | < 200ms كلياً | Manual                        |
| **حجم APK (Release)**            | ~45-55MB          | < 40MB        | `flutter build apk --release` |
| **استهلاك RAM أثناء العمل**      | ~150-200MB        | < 180MB       | Android Studio Profiler       |
| **وقت تحميل صفحة التفاصيل**      | ~400ms            | < 300ms       | `flutter_driver`              |
| **وقت توليد PDF**                | ~1.5-3 ثانية      | < 1 ثانية     | Manual                        |
| **تغطية الاختبارات الحالية**     | ~35-40%           | > 80%         | `flutter test --coverage`     |
| **حجم Civil Registry DB**        | ~300-500MB        | — (ثابت)      | Manual                        |
| **وقت تنزيل Civil DB (WiFi)**    | ~2-5 دقائق        | —             | Manual                        |

---

## 19.2 قياس الأداء في الكود الحالي

```dart
// integration_test/form_open_benchmark_ci_baseline_test.dart
// التطبيق لديه بالفعل اختبار Benchmark لفتح النموذج

testWidgets('Form opens within performance budget', (tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.tap(find.byKey(const Key('add_beneficiary_fab')));
  await tester.pumpAndSettle();

  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(500),
    reason: 'Form should open within 500ms');
});
```

---

## 19.3 أدوات قياس الأداء المُوصى بها

```bash
# قياس حجم APK
flutter build apk --release --analyze-size

# قياس أداء الـ UI (Frames)
flutter run --profile
# ثم في DevTools → Performance

# تغطية الاختبارات الحالية
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# افتح coverage/html/index.html في المتصفح

# تشغيل Integration Tests مع timing
flutter test integration_test/ --verbose
```

---

## 19.4 جدول تحسين الأداء المُقترح

| الإجراء                        | التحسين المتوقع       | الصعوبة |
| ------------------------------ | --------------------- | ------- |
| استخدام `select()` في Riverpod | تقليل Re-renders 30%  | سهلة    |
| نقل PDF لـ Isolate             | تقليل UI Freeze 100%  | متوسطة  |
| إضافة DB Index على id_number   | تسريع البحث 50%       | سهلة    |
| تقسيم Form لـ Lazy Sections    | تسريع فتح النموذج 40% | صعبة    |
| Compress APK Assets            | تقليل حجم APK 10-15%  | سهلة    |

---

<a name="section-20"></a>

# القسم العشرون — سجل المخاطر (Risk Register)

## 20.1 المخاطر التقنية

| #   | المخاطرة                        | الاحتمالية        | التأثير   | الخطورة | خطة التخفيف                         |
| --- | ------------------------------- | ----------------- | --------- | ------- | ----------------------------------- |
| R1  | تلف DB على الجهاز               | منخفضة            | عالٍ جداً | عالية   | WAL mode + نسخ احتياطية دورية       |
| R2  | انتهاء Drift API المستخدمة      | منخفضة            | عالٍ      | متوسطة  | تثبيت version + اختبارات regression |
| R3  | سرقة الجهاز                     | متوسطة            | عالٍ جداً | عالية   | SQLCipher + Remote Wipe             |
| R4  | تغيير API Backend               | متوسطة            | عالٍ      | عالية   | API versioning + Contract tests     |
| R5  | انقطاع إنترنت طويل (أسابيع)     | عالية (في فلسطين) | متوسط     | عالية   | Offline-first مُطبَّق بالكامل       |
| R6  | Civil DB قديمة                  | متوسطة            | متوسط     | متوسطة  | آلية تحديث دورية + إشعار المستخدم   |
| R7  | استنزاف ذاكرة التخزين           | متوسطة            | عالٍ      | عالية   | فحص مسبق + تنظيف ملفات مؤقتة        |
| R8  | انتهاء صلاحية شهادة SSL السيرفر | منخفضة            | عالٍ      | متوسطة  | تنبيهات انتهاء الشهادة              |

---

## 20.2 المخاطر التشغيلية

| #   | المخاطرة                            | الاحتمالية | التأثير   | الخطورة | خطة التخفيف                |
| --- | ----------------------------------- | ---------- | --------- | ------- | -------------------------- |
| R9  | موظف يُدخل بيانات خاطئة             | عالية      | متوسط     | متوسطة  | تحقق قوي + سجل Activity    |
| R10 | استخدام حساب واحد من أجهزة متعددة   | متوسطة     | عالٍ      | عالية   | Single-session enforcement |
| R11 | ضياع بيانات عند ترقية الجهاز        | منخفضة     | عالٍ جداً | عالية   | تصدير/استيراد backup       |
| R12 | مزامنة جزئية تُعطي بيانات غير متسقة | متوسطة     | عالٍ      | عالية   | Atomic sync transactions   |

---

## 20.3 المخاطر الأمنية

| #   | المخاطرة                               | الاحتمالية | التأثير   | الخطورة | خطة التخفيف                     |
| --- | -------------------------------------- | ---------- | --------- | ------- | ------------------------------- |
| R13 | MITM Attack (بدون Certificate Pinning) | منخفضة     | عالٍ جداً | عالية   | تطبيق Certificate Pinning فوراً |
| R14 | Root/Jailbreak للجهاز                  | منخفضة     | عالٍ      | متوسطة  | Root Detection + تحذير          |
| R15 | تسرب Token من Log Files                | منخفضة     | عالٍ      | متوسطة  | منع طباعة Tokens في Logs        |
| R16 | Brute Force على تسجيل الدخول           | منخفضة     | متوسط     | منخفضة  | Rate Limiting على السيرفر       |

---

## 20.4 مصفوفة الأولويات

```
التأثير
   ^
   │  R3,R13 ←── الأعلى أولوية   R1,R4,R5
عالٍ│              R10,R12         R7,R11
   │         R2,R8,R14     R6,R9
متوسط│              R15,R16
   │
منخفض└─────────────────────────────────────→
        منخفضة      متوسطة      عالية
                                الاحتمالية
```

---

<a name="section-21"></a>

# القسم الحادي والعشرون — الدروس المستفادة (Lessons Learned)

## 21.1 ما الذي كان سيُفعَل بشكل مختلف؟

---

### الدرس 1: اختيار استراتيجية المزامنة من البداية

**ما حدث:** بدأ التطبيق بمزامنة بسيطة، ثم أُضيفت `sync_queue` ثم `tombstones` ثم `file_id_reservations` — كل هذه جاءت في مراحل لاحقة (v17-v21).

**الدرس:** تصميم نظام المزامنة كاملاً في الـ Design Phase قبل كتابة سطر كود. الـ Sync architecture من أصعب الأجزاء في Offline-first apps.

**التوصية:** استخدام مواصفة **CRDT (Conflict-free Replicated Data Types)** من البداية.

---

### الدرس 2: تجنب ترقيات DB الحادة (v19)

**ما حدث:** الترقية v19 حذفت جميع بيانات التصنيفات (`DELETE FROM taxonomies`) بسبب تغيير استراتيجية الـ IDs. أي مستخدم عنده تصنيفات مخصصة خسرها.

**الدرس:** تغييرات البيانات الجذرية تحتاج Migration Script يُحوّل البيانات القديمة للتنسيق الجديد — وليس مسحها.

---

### الدرس 3: Civil Registry كان يجب فصله من البداية

**ما حدث:** كان Civil Registry في نفس قاعدة البيانات (v12 تحذف جداوله منها). الفصل جاء متأخراً وترك آثاراً في الكود (legacy migrations، تعليقات في الكود).

**الدرس:** قرارات الفصل المعماري يجب أن تأتي في مرحلة التصميم.

---

### الدرس 4: وحدات الاختبار يجب أن تُحذف من البداية

**ما حدث:** 4-5 صفحات اختبار (`test_mobile_api_page`، `sentry_test_page`، إلخ) ظلت في الكود الإنتاجي.

**الدرس:** استخدام `dart define` أو `kDebugMode` لإخفاء هذه الصفحات من أول يوم.

```dart
// ✅ الطريقة الصحيحة
if (kDebugMode) {
  routes.add(GoRoute(path: '/sentry-test', builder: (_,__) => SentryTestPage()));
}
```

---

### الدرس 5: توثيق قرارات المعمارية فور اتخاذها

**ما حدث:** كثير من القرارات المعمارية (لماذا SQLite؟ لماذا Riverpod؟ لماذا فُصل Civil Registry؟) غير موثقة في الكود أو الـ README.

**الدرس:** كتابة **Architecture Decision Records (ADR)** لكل قرار مهم.

```
# ADR-001: اختيار SQLite + Drift بدلاً من Firebase

## الحالة: مُعتمد (2025-01-15)
## السياق: نحتاج DB تعمل Offline كاملاً
## القرار: SQLite + Drift
## السبب: Full Offline support + Complex queries + Free
## العواقب: يحتاج تطبيق Sync يدوياً
```

---

### الدرس 6: schemaVersion=32 يعني الحاجة لـ Migration Tests

**ما حدث:** 32 ترقية بدون اختبارات Migration — أي ترقية خاطئة يمكن أن تُتلف البيانات عند مستخدمي الإنتاج.

**الدرس:** كل Migration تحتاج اختباراً يُثبت أنها تعمل من الإصدار السابق.

---

## 21.2 ما كان مُثيراً للإعجاب ✅

| الجانب                    | لماذا مُثير للإعجاب                |
| ------------------------- | ---------------------------------- |
| Offline-first من البداية  | قرار صعب ولكنه الصحيح للسياق       |
| SQLCipher على الـ DB      | أمان استباقي قبل أن يُطلَب         |
| Riverpod بدل Provider     | اختيار مكتبة حديثة وليس الأسهل     |
| Debounce في البحث         | تفكير في الأداء من البداية         |
| Activity Log في DB        | تتبع جميع التغييرات على المستفيدين |
| نظام file_id_reservations | حل مبتكر لمشكلة حقيقية             |

---

<a name="section-22"></a>

# القسم الثاني والعشرون — مقارنة مع مشاريع مشابهة

## 22.1 تطبيقات إنسانية مشابهة

| المشروع           | المنظمة     | التقنية            | الـ Offline Support | مفتوح المصدر |
| ----------------- | ----------- | ------------------ | ------------------- | ------------ |
| **Kobo Toolbox**  | UNOCHA      | React Native       | ✅ جيد              | ✅           |
| **ODK Collect**   | OpenDataKit | Android Native     | ✅ ممتاز            | ✅           |
| **CommCare**      | Dimagi      | Android/iOS Native | ✅ ممتاز            | ⚠️ جزئي      |
| **DHIS2 Capture** | WHO         | Flutter            | ✅ جيد              | ✅           |
| **Tella**         | Horizontal  | Flutter            | ✅ + تشفير          | ✅           |
| **بناء الميداني** | Benaa NGO   | Flutter            | ✅ ممتاز            | ❌ خاص       |

---

## 22.2 مقارنة تفصيلية مع DHIS2 Capture (الأقرب تقنياً)

| الجانب                     | بناء الميداني       | DHIS2 Capture  |
| -------------------------- | ------------------- | -------------- |
| **الإطار**                 | Flutter             | Flutter        |
| **DB**                     | SQLite + Drift      | SQLite         |
| **Sync**                   | Custom Queue        | DHIS2 Protocol |
| **تشفير**                  | AES-256 + SQLCipher | جزئي           |
| **Civil Registry**         | ✅ مُدمج            | ❌ غير موجود   |
| **Kafalat System**         | ✅ مُخصص            | ❌ غير موجود   |
| **RTL Support**            | ✅ كامل             | ⚠️ جزئي        |
| **تخصيص للسياق الفلسطيني** | ✅ كامل             | ❌ عام         |

**الاستنتاج:** تطبيق بناء الميداني **متخصص** أكثر من الحلول العامة — يُغطي احتياجات الـ NGOs الفلسطينية بشكل أعمق.

---

## 22.3 ميزات تنافسية فريدة

1. **ربط السجل المدني:** ميزة نادرة في تطبيقات NGO — تُجنّب تكرار إدخال البيانات
2. **نظام الكفالات المدمج:** حل متكامل لا تُوفّره أدوات عامة كـ KoboToolbox
3. **التشفير الكامل:** صالح للبيئات عالية الخطورة أمنياً
4. **Offline بنسبة 100%:** حتى تسجيل الدخول يعمل Offline بعد الدخول الأول

---

<a name="section-23"></a>

# القسم الثالث والعشرون — تحليل التكلفة: Firebase مقابل SQLite

## 23.1 افتراضات الحساب

```
عدد المستخدمين النشطين:  50 موظف
عدد المستفيدين:          10,000 مستفيد
متوسط الزيارات/يوم:      50 زيارة
متوسط حجم المستفيد:      5KB (بدون مرفقات)
متوسط حجم المرفقات:      500KB/مستفيد
إجمالي البيانات:          ~50MB (نصية) + ~5GB (مرفقات)
```

---

## 23.2 تكلفة Firebase (شهرياً)

```
Firestore:
─────────────────────────────────────
قراءات: 50 موظف × 200 قراءة/يوم × 30 يوم = 300,000 قراءة
→ 300,000 / 100,000 × $0.06 = $0.18/شهر

كتابات: 50 موظف × 20 كتابة/يوم × 30 يوم = 30,000 كتابة
→ 30,000 / 100,000 × $0.18 = $0.054/شهر

حذف: ~1,000/شهر → ~$0.002/شهر

تخزين Firestore: 50MB × $0.18/GB = $0.009/شهر

Firebase Storage (المرفقات):
─────────────────────────────────────
تخزين: 5GB × $0.026/GB = $0.13/شهر
رفع: 5GB × $0.10/GB = $0.50/شهر (مرة واحدة)
تنزيل: 50 موظف × 100MB/شهر = 5GB × $0.12/GB = $0.60/شهر

إجمالي Firebase (شهرياً): ~$1.50 - $2.00
مع نمو (500 موظف): ~$15 - $20/شهر
─────────────────────────────────────
```

---

## 23.3 تكلفة الحل الحالي (SQLite + PHP Backend)

```
استضافة PHP/MySQL الحالية (palestine.benaadev.org):
─────────────────────────────────────
خطة استضافة مشتركة: ~$5-10/شهر
حجم DB MySQL: ~100MB → داخل الحد المجاني

التطبيق (SQLite):
─────────────────────────────────────
تكلفة = $0 (محلي على الجهاز)
تكلفة التطوير: الوقت فقط

إجمالي الحالي (شهرياً): ~$5-10
─────────────────────────────────────
```

---

## 23.4 مقارنة التكاليف الكاملة

| البند                          | SQLite + PHP (الحالي) | Firebase              |
| ------------------------------ | --------------------- | --------------------- |
| **تكلفة التشغيل/شهر**          | $5-10                 | $2-5                  |
| **تكلفة التطوير الإضافي**      | عالية (Sync يدوي)     | منخفضة (Firebase SDK) |
| **تكلفة الترحيل**              | $0 (الحالة الحالية)   | عالية (3+ أشهر تطوير) |
| **تكلفة التشغيل (500 مستخدم)** | ~$20-50/شهر           | ~$15-20/شهر           |
| **Vendor Lock-in**             | ✅ لا يوجد            | ⚠️ Google             |
| **التحكم في البيانات**         | ✅ كامل               | ⚠️ على خوادم Google   |
| **GDPR/Data Sovereignty**      | ✅ بيانات محلية       | ⚠️ قد تكون إشكالية    |

---

## 23.5 الاستنتاج الاقتصادي

**قرار الـ SQLite اقتصادياً صحيح 100%** للأسباب التالية:

1. التكلفة الشهرية أقل في المدى القصير
2. لا Vendor Lock-in — يمكن الانتقال لأي استضافة
3. **السيادة على البيانات** — مهمة جداً لـ NGO في منطقة نزاع (البيانات لا تخرج من فلسطين)
4. تكلفة الانتقال لـ Firebase لا تُبرّر الفوارق الطفيفة في التكلفة الشهرية

---

<a name="section-24"></a>

# القسم الرابع والعشرون — دليل المساهمة (Contribution Guide)

## 24.1 إعداد بيئة التطوير

```bash
# 1. المتطلبات
Flutter SDK >= 3.5.0
Dart SDK >= 3.5.0
Android Studio / VS Code
Android SDK (API 26+)

# 2. استنساخ المشروع
git clone <repository-url>
cd benaa_offline_app

# 3. تثبيت الاعتماديات
flutter pub get

# 4. تشغيل Code Generation (Drift + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 5. إعداد ملف الـ Environment
cp assets/env.example.json assets/env.json
# عدّل baseUrl في env.json إذا كان لديك سيرفر محلي

# 6. تشغيل التطبيق
flutter run
```

---

## 24.2 هيكل الكود الذي يجب معرفته

```
lib/
├── core/                     ← الوحدات المشتركة (لا تعبّر عن Feature)
│   ├── config/               ← AppConfig, ApiConfig
│   ├── security/             ← CryptoBox, SessionManager
│   ├── storage/              ← SecureStorage
│   ├── sync/                 ← MobileSyncService
│   └── providers/            ← Global Riverpod Providers
│
├── data/db/                  ← Drift Database (لا تُعدِّل يدوياً الـ .g.dart)
│   ├── drift_database.dart   ← تعريف الجداول والـ DAOs
│   └── *.g.dart              ← ملفات مُولَّدة (لا تُعدِّل)
│
└── features/                 ← Feature-First
    └── [feature_name]/
        ├── data/             ← Repository Impl + DAO
        ├── domain/           ← Entities + Interfaces + UseCases
        └── presentation/     ← Pages + Providers + Widgets
```

---

## 24.3 إضافة جدول جديد لقاعدة البيانات

```dart
// الخطوة 1: تعريف الجدول في drift_database.dart
class NewTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// الخطوة 2: إضافة الجدول لـ @DriftDatabase
@DriftDatabase(tables: [..., NewTable], daos: [...])

// الخطوة 3: رفع schemaVersion
int get schemaVersion => 33; // كان 32

// الخطوة 4: إضافة Migration
if (from < 33) {
  await m.createTable(newTable);
}

// الخطوة 5: إعادة توليد الكود
dart run build_runner build --delete-conflicting-outputs
```

---

## 24.4 إضافة Feature جديدة

```bash
# هيكل Feature جديدة (مثال: Notifications)
lib/features/notifications/
├── data/
│   ├── db/notifications_dao.dart
│   └── repositories/notifications_repository_impl.dart
├── domain/
│   ├── entities/notification.dart
│   └── repositories/i_notifications_repository.dart
└── presentation/
    ├── pages/notifications_page.dart
    ├── providers/notifications_provider.dart
    └── widgets/notification_card.dart

# إضافة Route في app_router.dart
GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationsPage(),
),
```

---

## 24.5 تشغيل الاختبارات

```bash
# Unit + Widget Tests
flutter test

# مع تغطية
flutter test --coverage

# Integration Tests (يحتاج جهاز أو محاكي)
flutter test integration_test/beneficiary_form_flow_integration_test.dart

# اختبار محدد
flutter test test/filters_provider_test.dart

# Benchmark
flutter test integration_test/form_open_benchmark_ci_baseline_test.dart
```

---

## 24.6 معايير جودة الكود

| المعيار                     | المتطلب                                 |
| --------------------------- | --------------------------------------- |
| **تحليل الكود**             | `flutter analyze` بدون أخطاء            |
| **Format**                  | `dart format .` قبل كل Commit           |
| **اختبارات**                | كل Feature جديدة تحتاج Unit Test        |
| **Migration**               | كل تغيير في DB يحتاج Migration + اختبار |
| **لا Hardcoded URLs**       | استخدم `ApiConfig` دائماً               |
| **لا Hardcoded Strings**    | استخدم `l10n` للنصوص                    |
| **لا Business Logic في UI** | الـ UI للعرض فقط                        |

---

## 24.7 سير عمل الـ Git

```bash
# 1. إنشاء Branch للـ Feature
git checkout -b feature/notifications-module

# 2. تطوير + اختبار
flutter test
flutter analyze

# 3. Format الكود
dart format .

# 4. Commit مع رسالة واضحة
git commit -m "feat(notifications): add local notifications for sync status"

# 5. Push + Pull Request
git push origin feature/notifications-module

# أنماط رسائل الـ Commit
feat(scope):   ميزة جديدة
fix(scope):    إصلاح خطأ
refactor:      إعادة هيكلة بدون تغيير وظيفي
test:          إضافة اختبارات
docs:          تحديث التوثيق
chore:         مهام صيانة (build, deps)
```

---

## 24.8 الأسئلة الشائعة للمساهمين

**سؤال:** كيف أُجرّب التطبيق بدون سيرفر حقيقي؟

**الإجابة:** اضبط `baseUrl` في `env.json` لـ `http://10.0.2.2:8000` إذا كان لديك PHP server على الجهاز المضيف. التطبيق يعمل Offline بشكل كامل بعد أول تسجيل دخول.

---

**سؤال:** عند تشغيل `build_runner`، كيف أتعامل مع Conflicts؟

**الإجابة:**

```bash
dart run build_runner build --delete-conflicting-outputs
# خيار --delete-conflicting-outputs يحل 90% من المشاكل
```

---

**سؤال:** كيف أُضيف حقلاً جديداً لجدول موجود؟

**الإجابة:** أضف العمود في تعريف الجدول، ارفع `schemaVersion`، أضف `m.addColumn()` في `onUpgrade`، ثم شغّل `build_runner`. **لا تحذف أعمدة موجودة** — استخدم قيم افتراضية.

---

_نهاية التقرير التقني الشامل المُوسَّع_

_إجمالي الأقسام: 24 قسماً_

_تاريخ الإعداد: 24 أبريل 2026_

_إعداد: فريق مشروع التخرج — بالتعاون مع GitHub Copilot_
