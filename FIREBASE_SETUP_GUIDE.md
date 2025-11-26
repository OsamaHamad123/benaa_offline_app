# 🔥 Firebase App Distribution Setup Guide

دليل شامل لإعداد Firebase App Distribution لرفع التطبيق تلقائياً

---

## 📋 المتطلبات

- ✅ حساب Firebase
- ✅ مشروع Firebase (أو سننشئ واحد)
- ✅ Firebase CLI
- ✅ Google account

---

## 🚀 الخطوة 1: إنشاء مشروع Firebase

### 1. اذهب إلى Firebase Console

افتح: https://console.firebase.google.com/

### 2. أنشئ مشروع جديد (أو استخدم موجود)

1. اضغط "Add project"
2. اسم المشروع: `benaa-offline-app`
3. اقبل الشروط
4. فعّل Google Analytics (اختياري)
5. اضغط "Create project"

### 3. أضف تطبيق Android

1. من Dashboard، اضغط على أيقونة Android
2. Android package name: `com.benaa.offline` (أو حسب تطبيقك)
3. App nickname: `Benaa Offline App`
4. SHA-1 (اختياري الآن)
5. اضغط "Register app"

---

## 🚀 الخطوة 2: تنزيل google-services.json

### 1. حمّل الملف

بعد تسجيل التطبيق، ستظهر صفحة لتحميل `google-services.json`

### 2. ضع الملف في المكان الصحيح

```
android/app/google-services.json
```

⚠️ **مهم جداً:** 
- الملف يجب أن يكون في `android/app/` وليس `android/`
- لا ترفع هذا الملف على Git العام (حساس)

---

## 🚀 الخطوة 3: تثبيت Firebase CLI

```powershell
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# التحقق من التثبيت
firebase --version
```

---

## 🚀 الخطوة 4: إعداد Firebase في Android

### 1. تحديث `android/build.gradle.kts`

أضف في أول الملف (قبل allprojects):

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 2. تحديث `android/app/build.gradle.kts`

أضف في آخر الملف:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

---

## 🚀 الخطوة 5: تفعيل App Distribution

### 1. من Firebase Console

1. اذهب إلى: **Release & Monitor** → **App Distribution**
2. اضغط "Get started"
3. اتبع الخطوات

### 2. أضف Testers

1. من App Distribution، اضغط "Testers & Groups"
2. أنشئ مجموعة: `testers`
3. أضف emails للـ testers

---

## 🚀 الخطوة 6: إعداد Service Account لـ CI/CD

### 1. إنشاء Service Account

1. اذهب إلى: https://console.cloud.google.com/
2. اختر مشروعك
3. اذهب إلى: **IAM & Admin** → **Service Accounts**
4. اضغط "Create Service Account"
5. الاسم: `github-actions-firebase`
6. الدور: `Firebase App Distribution Admin`
7. اضغط "Create"

### 2. إنشاء Key

1. من قائمة Service Accounts، اضغط على الحساب الجديد
2. اذهب إلى تبويب "Keys"
3. اضغط "Add Key" → "Create new key"
4. اختر نوع: **JSON**
5. احفظ الملف (سنحتاجه لاحقاً)

### 3. إضافة الـ Key لـ GitHub Secrets

1. اذهب إلى GitHub Repository
2. Settings → Secrets and variables → Actions
3. اضغط "New repository secret"
4. الاسم: `FIREBASE_SERVICE_ACCOUNT`
5. القيمة: انسخ **كامل محتوى** ملف JSON
6. احفظ

### 4. إضافة Firebase App ID

1. من Firebase Console → Project Settings → General
2. انسخ "App ID" (يبدأ بـ `1:...`)
3. على GitHub → New repository secret
4. الاسم: `FIREBASE_APP_ID`
5. القيمة: الصق App ID
6. احفظ

---

## 🚀 الخطوة 7: تحديث Fastlane

تم إضافة دعم Firebase في `android/fastlane/Fastfile` تلقائياً!

لاستخدامه محلياً:

```bash
# من مجلد android
bundle exec fastlane deploy_firebase
```

---

## 🚀 الخطوة 8: تحديث .gitignore

تأكد من إضافة:

```
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
firebase-credentials.json
```

⚠️ **لا ترفع google-services.json على Git العام!**

---

## ✅ الاختبار

### 1. اختبار محلي

```powershell
cd android
bundle exec fastlane deploy_firebase
```

### 2. على GitHub Actions

سيتم تلقائياً:
- عند كل merge على `main`: رفع نسخة production
- عند كل PR على `develop`: رفع نسخة staging (اختياري)

---

## 📱 استلام التطبيق (للـ Testers)

### 1. أول مرة

1. سيصل email من Firebase
2. اضغط على الرابط
3. حمّل Firebase App Distribution من Play Store
4. افتح التطبيق وسجّل دخول
5. ستجد التطبيق للتحميل

### 2. التحديثات

- سيصل إشعار تلقائي بكل نسخة جديدة
- يمكن التحميل مباشرة

---

## 🔧 الأوامر المفيدة

```bash
# رفع نسخة للـ testers
cd android
bundle exec fastlane deploy_firebase

# رفع لمجموعة محددة
bundle exec fastlane deploy_firebase groups:"beta-testers"

# رفع مع ملاحظات
bundle exec fastlane deploy_firebase release_notes:"New features added"
```

---

## 🐛 حل المشاكل

### google-services.json not found

```bash
# تأكد من المسار:
ls android/app/google-services.json
```

### Firebase CLI not authenticated

```bash
firebase login
```

### Service Account permission denied

تأكد من إضافة الدور: `Firebase App Distribution Admin`

---

## 📊 المراقبة

### من Firebase Console

1. اذهب إلى App Distribution
2. شاهد:
   - عدد التحميلات
   - نسبة التبني
   - Crashes (إذا فعّلت Crashlytics)

---

## 🎯 الخطوات التالية (اختياري)

### 1. Firebase Crashlytics

لتتبع الأخطاء تلقائياً:

```yaml
# في pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.9
```

### 2. Firebase Analytics

لتتبع الاستخدام:

```yaml
dependencies:
  firebase_analytics: ^10.8.0
```

### 3. Remote Config

للتحكم بالميزات عن بعد:

```yaml
dependencies:
  firebase_remote_config: ^4.3.10
```

---

## 📝 Checklist

قبل أول deployment:

- [ ] أنشأت مشروع Firebase
- [ ] أضفت تطبيق Android
- [ ] حمّلت google-services.json ووضعته في android/app/
- [ ] عدّلت android/build.gradle.kts
- [ ] عدّلت android/app/build.gradle.kts
- [ ] ثبّت Firebase CLI
- [ ] سجّلت دخول: `firebase login`
- [ ] أنشأت Service Account
- [ ] أضفت FIREBASE_SERVICE_ACCOUNT لـ GitHub Secrets
- [ ] أضفت FIREBASE_APP_ID لـ GitHub Secrets
- [ ] أضفت testers في Firebase Console
- [ ] اختبرت محلياً: `bundle exec fastlane deploy_firebase`
- [ ] اختبرت على GitHub Actions

---

## 🎉 مبروك!

الآن كل merge على main سيرفع التطبيق تلقائياً على Firebase! 🚀

---

**ملاحظة:** هذا الدليل يفترض استخدام Android. لـ iOS، الخطوات مشابهة مع بعض الاختلافات.
