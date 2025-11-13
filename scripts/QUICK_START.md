# استيراد السجل المدني - دليل سريع

## الخطوات:

### 1. تثبيت المكتبات (مرة واحدة)
```powershell
cd c:\Dev\benaa_offline_app
flutter pub get
```

### 2. تشغيل السكريبت
```powershell
# ضع كلا الملفين في نفس المجلد:
# - F:\new and clean\persons.sql
# - F:\new and clean\relations.sql

# شغل السكريبت
dart run scripts/import_civil_registry.dart "F:\new and clean"
```

### 3. نقل القاعدة
```powershell
# للتطوير (assets)
copy "F:\new and clean\civil_registry.db" "..\assets\databases\civil_registry.db"

# للجهاز (ADB)
adb push "F:\new and clean\civil_registry.db" /sdcard/Download/
```

### 4. تجربة في التطبيق
- شغل التطبيق
- اذهب: "البحث في السجل المدني"
- ابحث عن رقم وطني أو اسم

## البنية

التطبيق **متوافق تماماً** مع بنية MySQL:

| MySQL Table | SQLite Table | الاستخدام |
|------------|--------------|-----------|
| `persons` | `persons` | معلومات الأشخاص |
| `relations` | `relations` | العلاقات العائلية |
| `category_of_relations` | `category_of_relations` | أنواع العلاقات |
| `city` | `city` | المدن والمحافظات |

الحقول:
- `CI_ID_NUM` → الرقم الوطني
- `CI_FIRST_ARB` → الاسم الأول
- `CI_FATHER_ARB` → اسم الأب
- `CI_FAMILY_ARB` → اسم العائلة
- `MOTHER_NAME1` → اسم الأم
- `CI_BIRTH_DT` → تاريخ الميلاد
- `CITY`, `STREET`, `HOUSE_NO` → العنوان

## الوقت المتوقع

- ملف 718 MB: 5-10 دقائق
- ملف 4.5 GB: 30-45 دقيقة

## الـ Indexes

السكريبت ينشئ تلقائياً:
- `idx_ci_id_num` → للبحث بالرقم الوطني
- `idx_full_name` → للبحث بالاسم
- `idx_birth_date` → للتصفية بتاريخ الميلاد
- `idx_cf_id_num` → للعلاقات
- `idx_cf_id_relative` → للعلاقات
- `idx_cf_relative_cd` → لأنواع العلاقات

## استكشاف الأخطاء

### "sqlite3 غير موجود"
```powershell
winget install SQLite.SQLite
```

### "فشل الاستيراد"
- تحقق من مساحة القرص (على الأقل 1 GB فارغة)
- تحقق من صيغة SQL صحيحة
- جرب تشغيل PowerShell كـ Administrator

### "البحث بطيء"
افتح القاعدة:
```powershell
sqlite3 "F:\new and clean\civil_registry.db"
```

نفذ:
```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;
```
