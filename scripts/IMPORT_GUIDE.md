# دليل استيراد السجل المدني

## الخطوة 1: تثبيت SQLite

### Windows:
```powershell
# الطريقة الأولى: عبر winget
winget install SQLite.SQLite

# الطريقة الثانية: تحميل يدوي
# 1. اذهب الى: https://www.sqlite.org/download.html
# 2. حمل: sqlite-tools-win-x64-*.zip
# 3. فك الضغط واضف المجلد الى PATH
```

### للتحقق من التثبيت:
```powershell
sqlite3 --version
```

## الخطوة 2: تشغيل السكريبت

### الطريقة الأولى (مسار الملف الافتراضي):
```powershell
cd c:\Dev\benaa_offline_app\scripts
.\import_civil_registry.bat
```

### الطريقة الثانية (تحديد مسار مخصص):
```powershell
cd c:\Dev\benaa_offline_app\scripts
.\import_civil_registry.bat "F:\new and clean\persons.sql"
```

## الخطوة 3: نقل قاعدة البيانات

### للتطوير (استخدام مع الـ Emulator):
```powershell
# انسخ الملف الى assets
copy "F:\new and clean\civil_registry.db" "c:\Dev\benaa_offline_app\assets\databases\civil_registry.db"
```

### للجهاز الحقيقي:
```powershell
# استخدم ADB
adb push "F:\new and clean\civil_registry.db" /sdcard/Download/civil_registry.db
```

## الخطوة 4: تجربة البحث

1. شغل التطبيق
2. اذهب الى: "البحث في السجل المدني"
3. جرب البحث عن:
   - رقم وطني
   - اسم كامل
   - محافظة

## معلومات تقنية

### البنية المتوقعة لـ persons.sql:

هذا ملف MySQL dump يحتوي على جدولين:

```sql
-- جدول الأشخاص
CREATE TABLE `persons` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `CI_ID_NUM` bigint unsigned NOT NULL,  -- الرقم الوطني
  `CI_FIRST_ARB` varchar(255),           -- الاسم الأول
  `CI_FATHER_ARB` varchar(255),          -- اسم الأب
  `CI_GRAND_FATHER_ARB` varchar(255),    -- اسم الجد
  `CI_FAMILY_ARB` varchar(255),          -- اسم العائلة
  `CI_BIRTH_TB_CD` bigint unsigned,
  `CI_BIRTH_CD` bigint unsigned,
  `CI_BIRTH_DT` datetime,                -- تاريخ الميلاد
  `CI_SEX_CD` bigint unsigned,           -- الجنس
  `CI_PERSONAL_CD` bigint unsigned,
  `CI_DEAD_DT` datetime,                 -- تاريخ الوفاة
  `MOTHER_NAME1` varchar(255),           -- اسم الأم
  `CITY` varchar(255),                   -- المدينة
  `STREET` varchar(255),                 -- الشارع
  `HOUSE_NO` varchar(255),               -- رقم البيت
  `created_at` timestamp,
  `updated_at` timestamp,
  PRIMARY KEY (`ID`),
  UNIQUE KEY (`CI_ID_NUM`)
);

-- جدول العلاقات (أبناء، زوجة، إلخ)
CREATE TABLE `relations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `CF_ID_NUM` bigint unsigned,           -- الرقم الوطني للشخص
  `CF_RELATIVE_CD` bigint unsigned,      -- نوع العلاقة (1=أب، 2=أم، 3=ابن، إلخ)
  `CF_ID_RELATIVE` bigint unsigned,      -- الرقم الوطني للقريب
  PRIMARY KEY (`id`),
  FOREIGN KEY (`CF_ID_NUM`) REFERENCES `persons` (`CI_ID_NUM`),
  FOREIGN KEY (`CF_ID_RELATIVE`) REFERENCES `persons` (`CI_ID_NUM`)
);

INSERT INTO `persons` VALUES (1, 926759127, 'ميسون', 'محمود', 'موسي', 'الزاملي', ...);
INSERT INTO `relations` VALUES (1, 926759127, 3, 429918030);
```

السكريبت يحول هذا MySQL dump إلى SQLite تلقائياً.

### Indexes للأداء:
السكريبت ينشئ تلقائيا:
- `idx_national_id` - للبحث بالرقم الوطني (الأسرع)
- `idx_full_name` - للبحث بالاسم
- `idx_governorate` - للتصفية بالمحافظة

## استكشاف الأخطاء

### المشكلة: "sqlite3 غير مثبت"
```powershell
winget install SQLite.SQLite
# او
scoop install sqlite
```

### المشكلة: "فشل الاستيراد"
تحقق من:
1. صيغة SQL صحيحة (CREATE TABLE + INSERT)
2. حجم الذاكرة كافي (~1 GB RAM حر)
3. مساحة القرص كافية (~1 GB)

### المشكلة: البحث بطيء
```sql
-- نفذ هذا الكود مباشرة على القاعدة:
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;
PRAGMA temp_store = MEMORY;
```

## تقدير الوقت

- ملف 718 MB: ~5-8 دقائق
- ملف 1 GB: ~8-12 دقيقة
- ملف 4.5 GB: ~30-45 دقيقة

يعتمد على:
- سرعة القرص (SSD أسرع من HDD)
- المعالج
- الذاكرة المتوفرة

## اختبار الأداء

بعد الاستيراد، جرب هذه الاستعلامات:

```sql
-- اختبار سرعة البحث بالرقم الوطني
SELECT * FROM persons WHERE national_id = '123456789';

-- اختبار سرعة البحث بالاسم
SELECT * FROM persons WHERE full_name LIKE '%محمد%';

-- اختبار عدد السجلات
SELECT COUNT(*) FROM persons;

-- اختبار حجم القاعدة
SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size();
```

## التكامل مع التطبيق

⚠️ **مهم جداً**: بنية القاعدة الحالية (`persons` و `relations`) تختلف عن بنية التطبيق!

### البنية الحالية (MySQL):
```
persons: ID, CI_ID_NUM, CI_FIRST_ARB, CI_FATHER_ARB, ...
relations: CF_ID_NUM, CF_RELATIVE_CD, CF_ID_RELATIVE
```

### البنية المطلوبة في التطبيق (Drift):
```dart
class CivilRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nationalId => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get motherName => text().nullable()();
  // ... الخ
}
```

### خياران للتكامل:

#### **الخيار 1: تحديث السكريبت (موصى به)**
- عدّل `_convertCreateTable()` لإنشاء جداول تطابق `drift_database.dart`
- دمج `CI_FIRST_ARB + CI_FATHER_ARB + CI_FAMILY_ARB` في `fullName`
- ربط `persons.CI_ID_NUM` بـ `civil_records.national_id`

#### **الخيار 2: تحديث التطبيق**
- عدّل `drift_database.dart` لقراءة من `persons` و `relations` مباشرة
- حدّث `CivilSearchService` للبحث في `CI_FIRST_ARB` بدلاً من `full_name`

### بعد التكامل:

1. **CivilDatabaseManager** سيكتشفها تلقائيا في:
   - `assets/databases/civil_registry.db`
   - او `/sdcard/Download/civil_registry.db`

2. **OptimizedCivilSearchService** سيستخدم:
   - Indexes للسرعة (تم إنشاؤها مسبقاً)
   - Fuzzy matching للأخطاء الإملائية
   - Arabic normalization

3. **AddBeneficiaryPage** سيملأ تلقائيا:
   - الاسم من `CI_FIRST_ARB + CI_FATHER_ARB + CI_GRAND_FATHER_ARB + CI_FAMILY_ARB`
   - الرقم الوطني من `CI_ID_NUM`
   - اسم الأم من `MOTHER_NAME1`
   - تاريخ الميلاد من `CI_BIRTH_DT`
   - العنوان من `CITY + STREET + HOUSE_NO`

## الملاحظات

- الملف الناتج (.db) عادة أكبر من SQL (~30-50% زيادة)
- استخدم WAL mode للأداء الأفضل
- Indexes تزيد الحجم لكن تسرع البحث كثيرا
- النسخ الاحتياطي مهم قبل الاستيراد
