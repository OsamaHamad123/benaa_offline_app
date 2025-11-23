# 🚀 دليل التشغيل السريع - Quick Setup Guide

## ✅ الخطوات النهائية قبل التشغيل

### الخطوة 1: ضغط قاعدة البيانات 📦

على السيرفر أو جهازك:

```bash
# Linux/Mac
gzip -c persons.db > persons.db.gz

# Windows - استخدم 7-Zip أو WinRAR
# Right-click → Add to archive → Choose .gz format
```

**النتيجة**: الملف سيتقلص من ~420 MB إلى ~150-200 MB ✅

---

### الخطوة 2: رفع الملف على السيرفر ☁️

رفّع `persons.db.gz` على:
- ✅ سيرفرك الخاص
- ✅ Google Cloud Storage
- ✅ AWS S3
- ✅ Azure Blob Storage
- ✅ أي CDN

**مثال URLs**:
```
https://your-server.com/downloads/persons.db.gz
https://storage.googleapis.com/your-bucket/persons.db.gz
https://s3.amazonaws.com/your-bucket/persons.db.gz
```

---

### الخطوة 3: تحديث URL في التطبيق 🔧

**افتح الملف**:
```
lib/features/civil_db_download/presentation/pages/config/download_config.dart
```

**غيّر السطر**:
```dart
static const String downloadUrl = 'YOUR_SERVER_URL_HERE';
```

**إلى رابطك الحقيقي**:
```dart
static const String downloadUrl = 'https://your-server.com/persons.db.gz';
```

**✅ هذا كل شيء! التطبيق جاهز الآن**

---

## 🎯 كيف يعمل التطبيق

### عند أول فتح:
```
1. 🚀 Splash Screen (2 ثانية)
2. 🔍 فحص: هل قاعدة البيانات موجودة؟
   ├─ نعم → ✅ الذهاب للـ Dashboard
   └─ لا  → 📥 الذهاب لصفحة التحميل
3. 📥 تحميل تلقائي + Progress Bar
4. 📦 فك الضغط
5. ✅ التحقق من سلامة الملف
6. ✅ الذهاب للـ Dashboard
```

### الفتحات التالية:
```
🚀 Splash → ✅ Dashboard مباشرة (فوري!)
```

---

## 🧪 الاختبار

### Test 1: أول تثبيت
```bash
# احذف التطبيق تماماً من الجهاز
# ثبّت من جديد
# افتح → يجب أن يبدأ التحميل تلقائياً ✅
```

### Test 2: بعد التحميل
```bash
# أغلق التطبيق
# افتحه مجدداً
# يجب أن يدخل مباشرة للـ Dashboard ✅
```

---

## ⚙️ الملفات المهمة

```
lib/
  routing/
    app_router.dart                    ← ✅ Routes جاهزة
  
  features/
    civil_db_download/
      presentation/
        pages/
          config/
            download_config.dart       ← ⚠️ عدّل URL هنا!
          database_download_page.dart  ← UI التحميل
      data/
        datasources/
          database_download_service.dart ← خدمة التحميل
    
    initialization/
      presentation/
        pages/
          app_initialization_page.dart ← Splash Screen
```

---

## 📊 المسارات (Routes)

```dart
/app-init            → Splash Screen + Check
/database-download   → صفحة التحميل (إذا DB غير موجود)
/dashboard          → Dashboard (إذا DB موجود)

// Legacy routes (محفوظة للتوافق)
/welcome
/download-civil-db
```

---

## 🔧 خيارات متقدمة (Optional)

### تغيير الحجم المتوقع:
في `download_config.dart`:
```dart
static const int expectedSizeMB = 420; // غيّره حسب حجم ملفك
```

### إضافة روابط احتياطية:
```dart
static const List<String> fallbackUrls = [
  'https://backup-cdn.com/persons.db.gz',
  'https://mirror.example.com/persons.db.gz',
];
```

---

## ❓ استكشاف الأخطاء

### المشكلة: "⚠️ يرجى تحديث URL التحميل"
**الحل**: غيّر `YOUR_SERVER_URL_HERE` في `download_config.dart`

### المشكلة: التحميل يفشل
**الأسباب المحتملة**:
1. ✅ تأكد من الرابط يعمل (افتحه بالمتصفح)
2. ✅ تأكد من HTTPS (مش HTTP)
3. ✅ تأكد من السيرفر يدعم CORS
4. ✅ تأكد من سرعة الإنترنت جيدة

### المشكلة: "Database verification failed"
**الأسباب المحتملة**:
1. ✅ الملف تالف (حمّل مرة ثانية)
2. ✅ الضغط غلط (استخدم gzip بس)
3. ✅ الحجم صغير جداً (<100 MB)

---

## 📝 Checklist - قبل النشر

- [ ] ✅ Dependencies مثبتة (`dio`, `archive`, `path_provider`)
- [ ] ✅ قاعدة البيانات مضغوطة (.gz)
- [ ] ✅ الملف مرفوع على السيرفر
- [ ] ✅ URL محدّث في `download_config.dart`
- [ ] ✅ اختبار التحميل من أول تثبيت
- [ ] ✅ اختبار الفتح الثاني (بدون تحميل)
- [ ] ✅ اختبار البحث بعد التحميل

---

## 🎉 النتيجة النهائية

```
✅ حجم APK: ~30-50 MB (بدون DB)
✅ التحميل: ~150-200 MB (مضغوط)
✅ الحجم النهائي: ~450-500 MB (بعد فك الضغط)
✅ Google Play يقبل (APK < 150 MB)
✅ العمل offline بشكل كامل
✅ تجربة مستخدم ممتازة
```

---

**آخر تحديث**: 23 نوفمبر 2025
**الحالة**: ✅ Ready to Deploy!

**بقى عليك فقط**: تحديث URL في `download_config.dart` 🚀
