# 🔥 Firebase - خطوات الإعداد السريعة

## ✅ الخطوات التي يجب تنفيذها الآن

### 📋 الملفات التي تم تحديثها:

✅ `android/build.gradle.kts` - إضافة Firebase plugins
✅ `android/app/build.gradle.kts` - إضافة google-services plugin
✅ `android/Gemfile` - إضافة Firebase App Distribution gem
✅ `android/fastlane/Fastfile` - إضافة lanes للـ deployment
✅ `.github/workflows/deploy-production.yml` - نشر تلقائي على main
✅ `.github/workflows/deploy-staging.yml` - نشر تلقائي على develop
✅ `.gitignore` - حماية ملفات Firebase الحساسة
✅ `FIREBASE_SETUP_GUIDE.md` - دليل شامل

---

## 🚀 ابدأ الآن (15 دقيقة)

### الخطوة 1: إنشاء مشروع Firebase (5 دقائق)

```
1. افتح: https://console.firebase.google.com/
2. اضغط "Add project"
3. الاسم: benaa-offline-app
4. اقبل الشروط → Create project
5. اضغط أيقونة Android
6. Package name: com.example.benaa_offline_app
7. اضغط "Register app"
8. حمّل google-services.json
```

### الخطوة 2: ضع google-services.json (1 دقيقة)

```powershell
# انسخ الملف المحمّل إلى:
# android/app/google-services.json

# تأكد من المكان:
Test-Path android/app/google-services.json
# يجب أن يرجع: True
```

⚠️ **مهم:** لا ترفع هذا الملف على Git!

### الخطوة 3: تثبيت Firebase CLI (2 دقائق)

```powershell
# تثبيت
npm install -g firebase-tools

# تسجيل دخول
firebase login

# تحقق
firebase projects:list
```

### الخطوة 4: تفعيل App Distribution (2 دقائق)

```
1. في Firebase Console
2. Release & Monitor → App Distribution
3. اضغط "Get started"
4. Testers & Groups → إنشاء مجموعة "testers"
5. أضف emails للـ testers
```

### الخطوة 5: إنشاء Service Account (5 دقائق)

```
1. افتح: https://console.cloud.google.com/
2. اختر مشروعك (benaa-offline-app)
3. IAM & Admin → Service Accounts
4. Create Service Account
   - الاسم: github-actions-firebase
   - الدور: Firebase App Distribution Admin
5. Keys → Add Key → Create new key → JSON
6. احفظ الملف!
```

---

## 🔐 إضافة Secrets لـ GitHub

### 1. GOOGLE_SERVICES_JSON

```powershell
# افتح الملف:
cat android/app/google-services.json

# انسخ كامل المحتوى
```

على GitHub:
1. Settings → Secrets and variables → Actions
2. New repository secret
3. Name: `GOOGLE_SERVICES_JSON`
4. Value: الصق كامل محتوى الملف
5. Add secret

### 2. FIREBASE_SERVICE_ACCOUNT

```powershell
# افتح ملف Service Account JSON الذي حمّلته
cat path/to/your-service-account.json

# انسخ كامل المحتوى
```

على GitHub:
1. New repository secret
2. Name: `FIREBASE_SERVICE_ACCOUNT`
3. Value: الصق كامل محتوى الملف
4. Add secret

### 3. FIREBASE_APP_ID

```
1. Firebase Console → Project Settings → General
2. انزل لـ "Your apps"
3. انسخ "App ID" (يبدأ بـ 1:...)
```

على GitHub:
1. New repository secret
2. Name: `FIREBASE_APP_ID`
3. Value: الصق App ID
4. Add secret

---

## 🧪 الاختبار

### 1. تثبيت الـ gems الجديدة

```powershell
cd android
bundle install
```

### 2. اختبار محلي (اختياري)

⚠️ يحتاج Firebase CLI token:

```powershell
# احصل على token
firebase login:ci

# احفظ الـ token
$env:FIREBASE_TOKEN = "YOUR_TOKEN_HERE"
$env:FIREBASE_APP_ID = "YOUR_APP_ID"

# اختبر
bundle exec fastlane deploy_firebase
```

### 3. اختبار على GitHub Actions

```powershell
# Commit التغييرات
git add .
git commit -m "Add Firebase App Distribution"
git push origin search_section

# افتح PR على develop
# بعد merge على develop: سيتم deployment staging
# بعد merge على main: سيتم deployment production
```

---

## 📱 كيف يستلم الـ Testers التطبيق؟

### أول مرة:

1. سيصل email من Firebase App Distribution
2. يضغط على الرابط
3. يحمّل تطبيق "Firebase App Distribution" من Play Store
4. يفتح التطبيق ويسجل دخول بـ Google
5. يجد تطبيقك للتحميل

### التحديثات:

- إشعار تلقائي بكل نسخة جديدة
- تحميل مباشر من التطبيق

---

## 🎯 سير العمل الآن

### عند merge على main:

```
1. GitHub Actions يبدأ تلقائياً
2. يشغّل الـ tests
3. يبني APK
4. يرفعه على Firebase App Distribution
5. يرسل إشعار للـ production-testers
```

### عند merge على develop (اختياري):

```
1. نفس الخطوات
2. لكن يرسل للـ testers (مجموعة staging)
```

---

## ⚡ الأوامر المتاحة

```powershell
# من مجلد android:

# رفع على Firebase (محلياً)
bundle exec fastlane deploy_firebase

# رفع production (محلياً)
bundle exec fastlane deploy_production

# بناء فقط
bundle exec fastlane build_release
```

---

## ✅ Checklist

قبل أول deployment:

- [ ] أنشأت مشروع Firebase
- [ ] أضفت تطبيق Android
- [ ] حمّلت google-services.json ووضعته في `android/app/`
- [ ] تأكدت أن الملف **ليس** في Git
- [ ] ثبّت Firebase CLI: `npm install -g firebase-tools`
- [ ] سجّلت دخول: `firebase login`
- [ ] فعّلت App Distribution في Firebase Console
- [ ] أضفت مجموعة "testers" وأضفت emails
- [ ] أنشأت Service Account
- [ ] أضفت `GOOGLE_SERVICES_JSON` secret على GitHub
- [ ] أضفت `FIREBASE_SERVICE_ACCOUNT` secret على GitHub
- [ ] أضفت `FIREBASE_APP_ID` secret على GitHub
- [ ] شغّلت `bundle install` في مجلد android
- [ ] اختبرت أول deployment

---

## 🐛 مشاكل شائعة

### google-services.json not found

```powershell
# تأكد من المسار الصحيح:
Test-Path android/app/google-services.json
# يجب أن يكون True
```

### Firebase App ID not set

تأكد من إضافة `FIREBASE_APP_ID` في GitHub Secrets

### Permission denied

تأكد أن Service Account لديه دور: `Firebase App Distribution Admin`

### Fastlane error: firebase_app_distribution not found

```powershell
cd android
bundle install
```

---

## 📚 المزيد من المعلومات

اقرأ الدليل الشامل: `FIREBASE_SETUP_GUIDE.md`

---

## 🎉 مبروك!

بعد إتمام هذه الخطوات، كل merge على main سيرفع التطبيق تلقائياً! 🚀

---

**التالي:** merge التغييرات على develop، ثم main لترى السحر! ✨
