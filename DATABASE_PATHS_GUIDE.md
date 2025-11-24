# 📂 دليل مسارات قاعدة البيانات - Database Paths Guide

**آخر تحديث**: 24 نوفمبر 2025

---

## 🎯 ملخص سريع

### الملف المطلوب:
- **الاسم**: `civil_registry.db` (ملف SQLite)
- **الضغط**: ZIP (civil_registry.zip)
- **الحجم المضغوط**: ~150-200 MB
- **الحجم بعد فك الضغط**: ~420 MB
- **المصدر**: `https://palestine.benaadev.org/api/persons-file/download`

### المسار في التطبيق:
```
Android: /data/data/com.example.benaa_offline_app/app_flutter/databases/civil_registry.db
iOS:     /var/mobile/Containers/Data/Application/{UUID}/Documents/databases/civil_registry.db
```

---

## 🔄 آلية العمل

### 1️⃣ **أول مرة تشغيل**:
```
✓ التطبيق يفتح
✓ يتحقق من وجود: /databases/civil_registry.db
✗ الملف مش موجود
→ ينتقل لصفحة التنزيل
→ يعرض زر "تنزيل قاعدة البيانات"
```

### 2️⃣ **عند الضغط على التنزيل**:
```
1. Checking (0%)        - يتصل بالسيرفر
2. Downloading (1-89%)  - ينزل civil_registry.zip
3. Extracting (90-94%)  - يفك ضغط ZIP → civil_registry.db
4. Verifying (95-99%)   - يتحقق من SQLite header
5. Completed (100%)     - جاهز! ✅
```

### 3️⃣ **عند الفشل**:
```
❌ إذا فشل التنزيل أو التحقق:
→ يحذف civil_registry.zip
→ يحذف civil_registry.db (الجزئي)
→ ينظف كل شيء
→ جاهز لإعادة المحاولة من الصفر
```

### 4️⃣ **التشغيلات القادمة**:
```
✓ التطبيق يفتح
✓ يتحقق من وجود: /databases/civil_registry.db
✓ الملف موجود!
→ ينتقل مباشرة للشاشة الرئيسية
```

---

## 📍 الملفات والمسارات الكاملة

### تكوين التنزيل:
**الملف**: `lib/features/civil_db_download/presentation/pages/config/download_config.dart`
```dart
static const String downloadUrl = 'https://palestine.benaadev.org/api/persons-file/download';
```

### خدمة التنزيل:
**الملف**: `lib/features/civil_db_download/data/datasources/database_download_service.dart`
```dart
// المسار المؤقت أثناء التنزيل
final tempPath = '${dbDirectory.path}/civil_registry.db.tmp';

// المسار النهائي
final finalPath = '${dbDirectory.path}/civil_registry.db';
```

### مدير قاعدة البيانات:
**الملف**: `lib/core/services/civil_database_manager.dart`
```dart
static const String CIVIL_DB_NAME = 'civil_registry.db';

Future<String> getCivilDatabasePath() async {
  final dbDir = await getDatabaseDirectory();
  return '${dbDir.path}/civil_registry.db';
}
```

---

## ⚙️ إعدادات التحقق

### الحد الأدنى للحجم:
```dart
// في download_config.dart
static const int minAcceptableSizeMB = 100;  // 100 MB

// في database_download_service.dart
if (size < 100 * 1024 * 1024) {
  return false; // الملف صغير جداً
}
```

### فحص SQLite:
```dart
// يتحقق من أن الملف SQLite صحيح
final bytes = await file.openRead(0, 16).first;
final header = String.fromCharCodes(bytes);

if (!header.startsWith('SQLite format')) {
  return false; // مش ملف SQLite
}
```

---

## 🐛 حل المشاكل

### ✅ **المشكلة 1: التوقف عند 99%**

**السبب الأول**: كان الكود يحاول فك ضغط gzip لكن الملف zip!

**الحل**:
```dart
// الآن يدعم ZIP
await _extractZipFile(downloadPath, dbDirectory.path);
```

**السبب الثاني**: الملف مش SQLite صحيح

**الحل**:
```dart
// التحقق من SQLite header
final bytes = await file.openRead(0, 16).first;
final header = String.fromCharCodes(bytes);

if (!header.startsWith('SQLite format')) {
  throw Exception('Invalid SQLite file');
}
```

---

### ✅ **المشكلة 2: إعادة التنزيل من الصفر عند الفشل**

**السبب**: الملفات الجزئية ما كانت تنحذف

**الحل المُطبّق**:
```dart
// في حالة الفشل، ينظف كل شيء
try {
  // حذف ZIP
  final zipFile = File('civil_registry.zip');
  if (await zipFile.exists()) {
    await zipFile.delete();
  }
  
  // حذف DB الجزئي
  final partialDb = File('civil_registry.db');
  if (await partialDb.exists()) {
    await partialDb.delete();
  }
} catch (e) {
  // ...
}
```

**النتيجة**: 
- ✅ عند الفشل، كل شيء ينحذف
- ✅ المحاولة القادمة تبدأ من 0%
- ✅ لا ملفات جزئية متبقية

---

## 📊 حالات التنزيل

### `DownloadStatus`:
```dart
enum DownloadStatus {
  idle,        // غير نشط
  checking,    // يتحقق من السيرفر (0%)
  downloading, // ينزّل (1-94%)
  verifying,   // يتحقق من السلامة (95%)
  completed,   // اكتمل (100%)
  failed,      // فشل
  cancelled,   // ملغي
}
```

---

## 🧪 اختبار المسارات

### للتحقق من المسار في Runtime:
```dart
final manager = CivilDatabaseManager(prefs);
final path = await manager.getCivilDatabasePath();
print('📂 Database path: $path');

final exists = await manager.isDatabaseAvailable();
print('✅ Database exists: $exists');
```

### للتحقق اليدوي:
**Android**:
```bash
adb shell run-as com.example.benaa_offline_app
cd app_flutter/databases
ls -lh civil_registry.db
```

**iOS**:
```bash
# استخدم Xcode → Devices → Download Container
# ثم افتح: /Documents/databases/civil_registry.db
```

---

## 🔐 الأمان والتشفير

### ⚠️ **ملاحظة مهمة**:
قاعدة بيانات السجل المدني **غير مشفرة** (read-only).

فقط قاعدة بيانات التطبيق الرئيسية مشفرة:
```dart
// المشفرة ✅
final appDb = AppDatabase(openEncryptedDb());

// غير مشفرة (للقراءة فقط)
await appDb.attachCivilRegistry(civilDbPath);
```

---

## 📝 الخلاصة

### ✅ ما تحتاج تعرفه:

1. **الملف**: `civil_registry.db` (SQLite)
2. **الضغط**: ZIP format
3. **المسار**: `/databases/civil_registry.db`
4. **الرابط**: `https://palestine.benaadev.org/api/persons-file/download`
5. **الحجم**: ~420 MB (بعد فك الضغط)
6. **التشفير**: لا يوجد (read-only)

### 🚀 الخطوات:

1. ✅ السيرفر يرسل `civil_registry.zip`
2. ✅ التطبيق ينزله بنسبة (1-89%)
3. ✅ يفك الضغط → `civil_registry.db` (90-94%)
4. ✅ يتحقق من SQLite header (95-99%)
5. ✅ جاهز للاستخدام! (100%)

### 🔧 عند الفشل:

1. ❌ ينظف `civil_registry.zip`
2. ❌ ينظف `civil_registry.db` (الجزئي)
3. 🔄 جاهز لإعادة المحاولة من الصفر

---

**آخر تحديث**: 24 نوفمبر 2025  
**الحالة**: ✅ **يدعم ZIP - جاهز للإنتاج**
