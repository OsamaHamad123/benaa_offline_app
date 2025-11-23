# 📥 نظام تحميل قاعدة بيانات السجل المدني - Setup Guide

## 🎯 الهدف
تحميل قاعدة بيانات السجل المدني (420 MB) من السيرفر عند أول استخدام للتطبيق، مع دعم العمل offline بشكل كامل.

---

## 🏗️ البنية المعمارية - Architecture

```
lib/features/
  civil_db_download/
    domain/
      entities/
        download_progress.dart          # حالة التحميل
    data/
      datasources/
        database_download_service.dart  # خدمة التحميل
    presentation/
      providers/
        database_download_provider.dart # State Management
      pages/
        database_download_page.dart     # صفحة التحميل
  
  initialization/
    presentation/
      pages/
        app_initialization_page.dart    # Splash Screen + Check
```

---

## ✅ الميزات - Features

### 1. **Smart Download System**
- ✅ تحميل تلقائي عند أول استخدام
- ✅ عرض التقدم (Progress %)
- ✅ عرض السرعة (MB/s)
- ✅ إمكانية الإلغاء
- ✅ إعادة المحاولة عند الفشل

### 2. **Database Management**
- ✅ ضغط الملف (Gzip) لتقليل حجم التحميل
- ✅ فك الضغط تلقائياً
- ✅ التحقق من سلامة الملف (Verification)
- ✅ حذف الملف المضغوط بعد الاستخراج

### 3. **User Experience**
- ✅ Splash Screen جميل
- ✅ Progress Bar مع معلومات التحميل
- ✅ رسائل واضحة بالعربي
- ✅ تصميم Material 3

### 4. **Error Handling**
- ✅ معالجة أخطاء الشبكة
- ✅ معالجة أخطاء التخزين
- ✅ رسائل خطأ واضحة
- ✅ إمكانية إعادة المحاولة

---

## 🚀 خطوات التطبيق - Implementation Steps

### **الخطوة 1: إضافة Dependencies**

أضف في `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0              # لتحميل الملفات مع Progress
  archive: ^3.4.10         # لفك ضغط Gzip
  path_provider: ^2.1.2    # للوصول لمجلد التطبيق
  # الباقي موجود فعلاً ✅
```

**ثم شغّل**:
```bash
flutter pub get
```

---

### **الخطوة 2: ضغط قاعدة البيانات**

على السيرفر، ضغط الملف:

```bash
# Linux/Mac
gzip -c persons.db > persons.db.gz

# Windows (PowerShell)
# استخدم 7-Zip أو WinRAR لإنشاء .gz
```

**النتيجة**:
```
persons.db     (420 MB)  →  persons.db.gz  (~150-200 MB)
توفير: ~50% من الحجم! ✅
```

---

### **الخطوة 3: رفع الملف على السيرفر**

رفّع `persons.db.gz` على سيرفرك واحصل على الرابط:

```
https://your-server.com/downloads/persons.db.gz
```

**ملاحظة**: تأكد من:
- ✅ السيرفر يدعم HTTPS
- ✅ الملف يُحمّل بدون مشاكل CORS
- ✅ السيرفر سريع (CDN أفضل)

---

### **الخطوة 4: تحديث URL في الكود**

في `lib/features/civil_db_download/presentation/pages/database_download_page.dart`:

```dart
// TODO: Replace with your actual server URL
static const String _downloadUrl = 'https://your-server.com/persons.db.gz';
```

**غيّر الرابط لرابطك الحقيقي!** ⚠️

---

### **الخطوة 5: إضافة Routes**

في `lib/core/router/app_router.dart` (أو حيث routes):

```dart
GoRoute(
  path: '/',
  builder: (context, state) => const AppInitializationPage(),
),
GoRoute(
  path: '/database-download',
  builder: (context, state) => const DatabaseDownloadPage(),
),
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardPage(), // موجودة فعلاً
),
```

---

### **الخطوة 6: تحديث Civil Database Manager**

في `lib/core/services/civil_database_manager.dart`:

```dart
import 'package:path_provider/path_provider.dart';

class CivilDatabaseManager {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Get database from downloaded location ✅
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/database/persons.db';

    _database = await openDatabase(
      dbPath,
      readOnly: true, // Read-only for civil registry
    );

    return _database!;
  }
}
```

---

## 📱 Flow Chart - تدفق التطبيق

```
📱 App Start
    ↓
🚀 AppInitializationPage (Splash)
    ↓
🔍 Check: Database exists?
    ↓
   YES → ✅ Go to Dashboard
    ↓
   NO  → 📥 Go to DatabaseDownloadPage
    ↓
📥 Start Download (Auto)
    ↓
⬇️  Download Progress (Show %)
    ↓
📦 Extract Gzip
    ↓
✅ Verify Database
    ↓
✅ Go to Dashboard
```

---

## 🎨 Screenshots (Expected)

### 1. Splash Screen
```
┌─────────────────────┐
│                     │
│    🏛️  بناء         │
│                     │
│  ⭕ جاري التهيئة... │
└─────────────────────┘
```

### 2. Download Screen
```
┌─────────────────────────────┐
│  ☁️ جاري تحميل بيانات      │
│     السجل المدني            │
│                             │
│  ▰▰▰▰▰▰▰▰▱▱  75.3%        │
│                             │
│  315 MB / 420 MB            │
│  السرعة: 5.2 MB/s          │
│                             │
│  ⚠️ يُرجى عدم إغلاق        │
│     التطبيق                 │
│                             │
│  [  إلغاء التحميل  ]       │
└─────────────────────────────┘
```

### 3. Complete Screen
```
┌─────────────────────────────┐
│  ✅ تم التحميل بنجاح!       │
│                             │
│  يمكنك الآن البدء           │
│  باستخدام التطبيق           │
│                             │
│  [  ابدأ الاستخدام →  ]    │
└─────────────────────────────┘
```

---

## 🧪 Testing - الاختبار

### Test 1: First Install
```dart
// 1. احذف التطبيق تماماً
// 2. ثبّت من جديد
// 3. افتح التطبيق
// ✅ يجب أن يظهر Splash → Download Page
```

### Test 2: Download Success
```dart
// 1. تأكد من وجود اتصال إنترنت جيد
// 2. راقب التقدم
// ✅ Progress يجب أن يتحدث بسلاسة
// ✅ السرعة تظهر بشكل صحيح
// ✅ بعد الانتهاء ينقلك للـ Dashboard
```

### Test 3: Download Failure
```dart
// 1. اقطع الإنترنت أثناء التحميل
// ✅ يجب أن يظهر خطأ
// ✅ زر "إعادة المحاولة" يعمل
```

### Test 4: Existing Database
```dart
// 1. بعد التحميل بنجاح
// 2. أغلق التطبيق وافتحه مجدداً
// ✅ يجب أن يدخل مباشرة للـ Dashboard (بدون تحميل)
```

---

## ⚡ Performance Tips

### 1. **استخدم CDN**
```
بدل: https://your-server.com/persons.db.gz
استخدم: https://cdn.your-server.com/persons.db.gz

✅ سرعة أعلى
✅ تكلفة bandwidth أقل
```

### 2. **Compression Options**
```bash
# أفضل ضغط (أبطأ لكن حجم أصغر)
gzip -9 persons.db

# ضغط سريع (أسرع لكن حجم أكبر قليلاً)
gzip -1 persons.db

# الافتراضي (متوازن) ✅ الأفضل
gzip persons.db
```

### 3. **Database Optimization**
```sql
-- قبل رفع القاعدة، شغّل:
VACUUM;           -- تقليل حجم الملف
ANALYZE;          -- تحسين الأداء
PRAGMA optimize;  -- تحسين indexes
```

---

## 🔧 Advanced Features (Optional)

### 1. **Resume Download** (متقدم)
```dart
// إضافة دعم استكمال التحميل بعد الانقطاع
// يحتاج Range Requests من السيرفر
```

### 2. **Delta Updates** (مستقبلي)
```dart
// بدل تحميل كامل القاعدة كل مرة
// تحميل فقط التحديثات الجديدة
```

### 3. **Multiple Servers** (تحسين)
```dart
// قائمة سيرفرات بديلة
const mirrors = [
  'https://cdn1.server.com/db.gz',
  'https://cdn2.server.com/db.gz',
];
// جرب الأول، إذا فشل جرب الثاني
```

---

## ❓ FAQ - الأسئلة الشائعة

### Q: حجم التطبيق سيصير كم؟
**A**: 
- APK: ~30-50 MB (بدون قاعدة البيانات)
- بعد التحميل: ~450-500 MB (مع قاعدة البيانات)
- ✅ Google Play يقبل لأن APK < 150 MB

### Q: لو المستخدم عنده إنترنت بطيء؟
**A**: 
- التحميل سيكون بطيء لكن سيعمل
- يمكن إضافة resume download لاحقاً
- يمكن إضافة WiFi-only option

### Q: أمان البيانات؟
**A**:
- ✅ استخدم HTTPS
- ✅ تحقق من SQLite header
- ✅ يمكن إضافة checksum verification

### Q: تحديث القاعدة لاحقاً؟
**A**:
```dart
// في Settings
await ref.read(databaseDownloadProvider.notifier)
    .deleteAndRedownload(newUrl);
```

---

## ✅ Checklist - قبل النشر

- [ ] رفعت `persons.db.gz` على السيرفر
- [ ] حدثت `_downloadUrl` في الكود
- [ ] أضفت Dependencies في pubspec.yaml
- [ ] شغّلت flutter pub get
- [ ] أضفت Routes في app_router
- [ ] حدثت CivilDatabaseManager
- [ ] اختبرت first install
- [ ] اختبرت download success
- [ ] اختبرت download failure
- [ ] اختبرت existing database
- [ ] فحصت أداء البحث بعد التحميل

---

## 📊 Expected Results

```
التحميل الأول: 5-10 دقائق (حسب سرعة الإنترنت)
حجم التحميل: ~150-200 MB (مضغوط)
حجم بعد الاستخراج: ~420 MB
الفتح التالي: فوري (<1 ثانية) ✅
```

---

## 🎉 الخلاصة

**نظام تحميل قاعدة البيانات جاهز بالكامل!** ✅

الآن التطبيق:
- ✅ حجمه صغير على Play Store (<50 MB)
- ✅ يحمل البيانات عند أول استخدام
- ✅ يعمل offline بشكل كامل
- ✅ تجربة مستخدم ممتازة

**بقى عليك فقط**:
1. رفع persons.db.gz على السيرفر
2. تحديث URL في الكود
3. الاختبار!

---

**آخر تحديث**: 23 نوفمبر 2025
**الحالة**: ✅ Ready for Production
