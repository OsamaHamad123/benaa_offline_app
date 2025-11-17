# 🔄 دليل تشغيل السكريبت لتحديث السجلات القديمة

## الطريقة الأولى: من داخل التطبيق (الأسهل) ⚡

### 1️⃣ افتح صفحة المستفيدين

### 2️⃣ أضف هذا الكود في `initState` أو في زر للتجربة:

```dart
// في BeneficiariesListPageV2 أو أي صفحة
Future<void> _runOneTimeMigration() async {
  final dao = ref.read(databaseProvider).beneficiariesDao;
  
  // فحص كم سجل محتاج تحديث
  final needsUpdate = await dao.countRecordsNeedingFullNameNormUpdate();
  print('📊 عدد السجلات التي تحتاج تحديث: $needsUpdate');
  
  if (needsUpdate > 0) {
    // تحديث جميع السجلات
    final total = await dao.updateAllFullNameNorm();
    print('✅ تم تحديث $total سجل بنجاح!');
    
    // فحص بعد التحديث
    final remaining = await dao.countRecordsNeedingFullNameNormUpdate();
    print('📊 السجلات المتبقية: $remaining');
  } else {
    print('✅ جميع السجلات محدثة!');
  }
}
```

### 3️⃣ شغل الكود مرة واحدة فقط

بعد ما تشوف في console:
```
✅ تم تحديث 1500 سجل بنجاح!
📊 السجلات المتبقية: 0
```

**احذف الكود!** لأنه one-time migration فقط.

---

## الطريقة الثانية: من Flutter DevTools 🛠️

### 1️⃣ شغل التطبيق في Debug Mode

### 2️⃣ افتح Flutter DevTools

### 3️⃣ اذهب لـ Console Tab

### 4️⃣ اكتب:

```dart
final db = WidgetsBinding.instance.rootElement!
  .findAncestorWidgetOfExactType<ProviderScope>()!
  .read(databaseProvider);

final dao = db.beneficiariesDao;

// فحص
final needsUpdate = await dao.countRecordsNeedingFullNameNormUpdate();
print('محتاج تحديث: $needsUpdate');

// تحديث
if (needsUpdate > 0) {
  final total = await dao.updateAllFullNameNorm();
  print('تم تحديث: $total');
}
```

---

## الطريقة الثالثة: SQL مباشرة (متقدم) 🗄️

إذا عندك access للـ SQLite database file:

### 1️⃣ حدد مكان الملف:

**Android Emulator:**
```bash
adb shell
run-as com.your.app
cd /data/data/com.your.app/app_flutter/
ls *.db
```

**Windows (Desktop):**
```
C:\Users\<YourUsername>\AppData\Roaming\com.your.app\
```

### 2️⃣ افتح الملف في SQLite Browser أو:

```bash
sqlite3 benaa_database.db
```

### 3️⃣ شغل السكريبت:

```sql
-- فحص كم سجل محتاج تحديث
SELECT COUNT(*) as needs_update
FROM beneficiaries 
WHERE full_name_norm IS NULL 
   OR full_name_norm = '' 
   OR full_name_norm = ' ';

-- تحديث جميع السجلات
UPDATE beneficiaries 
SET full_name_norm = LOWER(
  TRIM(
    COALESCE(first_name, '') || ' ' || 
    COALESCE(father_name, '') || ' ' || 
    COALESCE(grand_father_name, '') || ' ' || 
    COALESCE(family_name, '')
  )
)
WHERE full_name_norm IS NULL 
   OR full_name_norm = '' 
   OR full_name_norm = ' ';

-- تحقق بعد التحديث
SELECT COUNT(*) as remaining
FROM beneficiaries 
WHERE full_name_norm IS NULL 
   OR full_name_norm = '' 
   OR full_name_norm = ' ';
```

---

## ✅ كيف تتأكد إنه اشتغل؟

### جرب البحث بالاسم:

1. افتح صفحة المستفيدين
2. اكتب اسم في خانة البحث (مثلاً: "محمد")
3. المفروض يظهر لك نتائج!

### قبل التحديث:
```
🔍 البحث عن "محمد" → 0 نتائج ❌
```

### بعد التحديث:
```
🔍 البحث عن "محمد" → 150 نتيجة ✅
```

---

## 🎯 الطريقة الموصى بها

**للتطوير:** استخدم **الطريقة الأولى** (من داخل التطبيق)

**للإنتاج:** السكريبت يشتغل تلقائياً! الـ triggers الجديدة تحدث `full_name_norm` تلقائياً لكل سجل جديد.

---

## ⚠️ ملاحظات مهمة

1. ✅ **السكريبت آمن** - يحدث فقط السجلات اللي `full_name_norm` فيها فاضية
2. ✅ **السجلات الجديدة** - ما تحتاج السكريبت، الـ triggers تشتغل تلقائياً
3. ✅ **يشتغل مرة واحدة فقط** - بعدها احذف الكود
4. ⚠️ **لو عندك 10,000+ سجل** - ممكن ياخذ 2-3 ثواني

---

## 📞 مشاكل؟

إذا واجهت مشكلة:

```dart
// تحقق من السجلات:
final all = await dao.getAllBeneficiaries();
print('إجمالي السجلات: ${all.length}');

for (var b in all.take(5)) {
  print('${b.fullName} → ${b.fullNameNorm}');
}
```

المفروض تشوف:
```
محمد أحمد علي → محمد أحمد علي
فاطمة سعيد → فاطمة سعيد
```
