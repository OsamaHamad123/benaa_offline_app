# 🔥 Firebase App Distribution - ملخص الإضافة

## ✅ ما تم إضافته

### 📁 ملفات جديدة:

1. **`.github/workflows/deploy-production.yml`**
   - نشر تلقائي على Firebase عند merge على main

2. **`.github/workflows/deploy-staging.yml`**
   - نشر تلقائي على Firebase عند merge على develop

3. **`FIREBASE_SETUP_GUIDE.md`**
   - دليل شامل لإعداد Firebase

4. **`FIREBASE_QUICK_START.md`**
   - خطوات سريعة للإعداد (15 دقيقة)

5. **`android/app/google-services.json.example`**
   - مثال لملف google-services.json

### 🔧 ملفات محدّثة:

1. **`android/build.gradle.kts`**
   - إضافة Firebase plugins

2. **`android/app/build.gradle.kts`**
   - إضافة google-services plugin

3. **`android/Gemfile`**
   - إضافة firebase_app_distribution gem

4. **`android/fastlane/Fastfile`**
   - إضافة lanes جديدة:
     - `deploy_firebase` - نشر على Firebase
     - `deploy_production` - نشر production

5. **`.gitignore`**
   - حماية ملفات Firebase الحساسة

6. **`README.md`**
   - إضافة قسم Firebase

---

## 🎯 كيف يعمل؟

### عند Merge على Main:

```
1. GitHub Actions يبدأ تلقائياً
2. ✅ يشغّل الـ tests
3. ✅ يبني APK release
4. 🔥 يرفع على Firebase App Distribution
5. 📧 يرسل إشعار للـ testers
```

### عند Merge على Develop (اختياري):

```
نفس الخطوات لكن لمجموعة staging
```

---

## 📋 الخطوات المطلوبة منك

### 1️⃣ إنشاء مشروع Firebase (5 دقائق)

```
https://console.firebase.google.com/
→ Add project
→ benaa-offline-app
→ Add Android app
→ Package: com.example.benaa_offline_app
→ Download google-services.json
```

### 2️⃣ وضع google-services.json

```powershell
# ضع الملف المحمّل في:
android/app/google-services.json
```

⚠️ **لا ترفعه على Git!** (محمي في .gitignore)

### 3️⃣ تثبيت Firebase CLI

```powershell
npm install -g firebase-tools
firebase login
```

### 4️⃣ تفعيل App Distribution

```
Firebase Console
→ Release & Monitor
→ App Distribution
→ Get started
→ Testers & Groups
→ Create group "testers"
→ Add emails
```

### 5️⃣ إنشاء Service Account

```
https://console.cloud.google.com/
→ IAM & Admin → Service Accounts
→ Create Service Account
→ Name: github-actions-firebase
→ Role: Firebase App Distribution Admin
→ Keys → Add Key → JSON
→ Download
```

### 6️⃣ إضافة GitHub Secrets

على GitHub Repository → Settings → Secrets:

**Secret 1: GOOGLE_SERVICES_JSON**
```powershell
# انسخ محتوى:
cat android/app/google-services.json
```

**Secret 2: FIREBASE_SERVICE_ACCOUNT**
```powershell
# انسخ محتوى ملف Service Account JSON
```

**Secret 3: FIREBASE_APP_ID**
```
من Firebase Console → Project Settings
انسخ App ID (يبدأ بـ 1:...)
```

### 7️⃣ تثبيت Gems الجديدة

```powershell
cd android
bundle install
```

---

## 🧪 الاختبار

### محلياً (اختياري):

```powershell
cd android

# تحتاج Firebase token:
firebase login:ci
# احفظ الـ token

$env:FIREBASE_TOKEN = "YOUR_TOKEN"
$env:FIREBASE_APP_ID = "YOUR_APP_ID"

bundle exec fastlane deploy_firebase
```

### على GitHub:

```powershell
# بعد إتمام كل الخطوات:
git add .
git commit -m "Add Firebase App Distribution"
git push

# Merge على develop → staging deployment
# Merge على main → production deployment
```

---

## 📱 للـ Testers

### أول مرة:

1. Email من Firebase App Distribution
2. تحميل تطبيق Firebase من Play Store
3. تسجيل دخول
4. تحميل التطبيق

### التحديثات:

- إشعار تلقائي بكل نسخة
- تحميل مباشر

---

## 🛠️ الأوامر الجديدة

```powershell
cd android

# رفع على Firebase
bundle exec fastlane deploy_firebase

# رفع production
bundle exec fastlane deploy_production
```

---

## 📊 سير العمل الجديد

```
Feature Branch
    ↓
[PR to develop]
    ↓
Merge to develop
    ↓
🔥 Auto deploy to Firebase (staging)
    ↓
[PR to main]
    ↓
Merge to main
    ↓
🔥 Auto deploy to Firebase (production)
    ↓
📧 Testers receive notification
```

---

## ✅ Checklist السريع

- [ ] أنشأت مشروع Firebase
- [ ] حمّلت google-services.json
- [ ] وضعته في android/app/
- [ ] أضفت GOOGLE_SERVICES_JSON secret
- [ ] أضفت FIREBASE_SERVICE_ACCOUNT secret
- [ ] أضفت FIREBASE_APP_ID secret
- [ ] أضفت testers في Firebase Console
- [ ] شغّلت bundle install

---

## 🐛 مشاكل؟

اقرأ: `FIREBASE_SETUP_GUIDE.md`

أو:

```powershell
# تأكد من google-services.json
Test-Path android/app/google-services.json

# أعد تثبيت gems
cd android
bundle install

# تحقق من Firebase CLI
firebase --version
```

---

## 📚 الدلائل

| الملف | الغرض |
|-------|-------|
| `FIREBASE_QUICK_START.md` | خطوات سريعة (15 دقيقة) |
| `FIREBASE_SETUP_GUIDE.md` | دليل شامل |
| `START_HERE.md` | نقطة البداية |

---

## 🎉 الفوائد

### قبل:
- ❌ رفع APK يدوي
- ❌ إرسال ملفات للـ testers يدوياً
- ❌ لا يوجد tracking للإصدارات

### الآن:
- ✅ رفع تلقائي عند merge
- ✅ إشعار تلقائي للـ testers
- ✅ tracking كامل للإصدارات
- ✅ analytics عن التحميلات
- ✅ توزيع سهل وسريع

---

**ابدأ الآن:** `FIREBASE_QUICK_START.md` 🚀

_تاريخ: 26 نوفمبر 2025_
