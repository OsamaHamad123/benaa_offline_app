# 🚀 استيراد السجل المدني - خطوات سريعة

## 📁 التحضير

ضع الملفين في نفس المجلد:
```
F:\new and clean\
├── persons.sql (718 MB)
└── relations.sql (354 MB)
```

## ▶️ التشغيل

```powershell
# 1. افتح PowerShell
cd c:\Dev\benaa_offline_app\scripts

# 2. شغل السكريبت (يستورد كلا الملفين تلقائياً)
dart run import_civil_registry.dart "F:\new and clean"
```

## ⏱️ الانتظار

- الوقت المتوقع: **10-15 دقيقة**
- سترى:
  ```
  📥 استيراد جدول الأشخاص...
     تقدم: 50000 شخص
  
  📥 استيراد جدول العلاقات...
     تقدم: 100000 علاقة
  ```

## ✅ النتيجة

```
📊 الإحصائيات النهائية:
   👥 عدد الأشخاص: ~750,000
   🔗 عدد العلاقات: ~7,480,729
   💾 حجم القاعدة: ~900 MB
   ⏱️  الوقت: 12:34

🎉 تم بنجاح! القاعدة جاهزة للاستخدام
📍 الموقع: F:\new and clean\civil_registry.db
```

## 📋 نقل القاعدة

```powershell
# للتطوير
copy "F:\new and clean\civil_registry.db" "c:\Dev\benaa_offline_app\assets\databases\"

# للجهاز
adb push "F:\new and clean\civil_registry.db" /sdcard/Download/
```

## 🔍 الجداول المُنشأة

| الجدول | الأعمدة | الاستخدام |
|-------|---------|-----------|
| **persons** | 18 عمود | معلومات الأشخاص |
| **relations** | 4 أعمدة | العلاقات العائلية |
| **category_of_relations** | 4 أعمدة | أنواع العلاقات |

## 🎯 الفهارس (9 indexes)

للبحث السريع:
- ✅ `idx_ci_id_num` - الرقم الوطني (أسرع بحث)
- ✅ `idx_full_name` - الاسم الكامل
- ✅ `idx_first_name` - الاسم الأول
- ✅ `idx_father_name` - اسم الأب
- ✅ `idx_family_name` - اسم العائلة
- ✅ `idx_city` - المدينة
- ✅ `idx_cf_id_num` - البحث في العلاقات
- ✅ `idx_cf_id_relative` - القريب
- ✅ `idx_cf_relative_cd` - نوع العلاقة

## 🧪 التجربة

```powershell
# افتح التطبيق
flutter run

# اذهب إلى: "البحث في السجل المدني"
# جرب:
# - البحث بالرقم الوطني: 926759127
# - البحث بالاسم: ميسون
# - عرض العلاقات (الأبناء، الزوجة، إلخ)
```

## ⚠️ استكشاف الأخطاء

### "Out of memory"
```powershell
# قلل حجم الـ batch
# في السكريبت، غير:
final maxBatchSize = 1000;
# إلى:
final maxBatchSize = 500;
```

### "Database is locked"
```powershell
# أغلق أي برنامج يستخدم القاعدة
# أو احذفها وأعد الاستيراد:
del "F:\new and clean\civil_registry.db"
```

### البحث بطيء
```dart
// الفهارس موجودة بالفعل!
// لكن يمكنك تحسين الأداء:
await db.execute('PRAGMA journal_mode=WAL');
await db.execute('PRAGMA cache_size=-64000');
```

## 💡 ملاحظات

- ✅ السكريبت يحافظ على أسماء الأعمدة الأصلية (`CI_ID_NUM`, `CI_FIRST_ARB`)
- ✅ متوافق 100% مع `drift_database.dart`
- ✅ يستورد كلا الملفين تلقائياً
- ✅ ينشئ الفهارس تلقائياً
- ✅ يعرض progress أثناء الاستيراد
- ✅ ينظف الذاكرة بعد كل 1000 صف
