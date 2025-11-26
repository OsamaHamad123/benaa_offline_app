# 🎯 دليل الرفع على Firebase - خطوة بخطوة

## ✅ الخطوات المطلوبة بالترتيب

---

## المرحلة 1: إعداد Firebase (10 دقائق)

### الخطوة 1: تسجيل الدخول لـ Firebase CLI

```powershell
# تثبيت Firebase CLI (إذا لم يكن مثبت)
npm install -g firebase-tools

# تسجيل دخول
firebase login
```

سيفتح المتصفح، سجل دخول بحساب Google الخاص بك.

---

### الخطوة 2: إنشاء مشروع Firebase

```powershell
# إنشاء مشروع جديد
firebase projects:create benaa-offline-app

# أو استخدم مشروع موجود
firebase projects:list
```

**أو** من المتصفح:
1. افتح: https://console.firebase.google.com/
2. اضغط "Add project"
3. اسم المشروع: `benaa-offline-app`
4. اقبل الشروط → Create

---

### الخطوة 3: تهيئة Firebase في المشروع

```powershell
# من مجلد المشروع
firebase init

# اختر:
# - Hosting (مسافة للاختيار)
# - اختر المشروع: benaa-offline-app
# - Public directory: build/web
# - Single-page app: Yes
# - Automatic builds: No
```

---

### الخطوة 4: إضافة تطبيق Android

**من المتصفح:**
1. Firebase Console → Project Overview
2. اضغط أيقونة Android
3. Package name: `com.example.benaa_offline_app`
4. App nickname: `Benaa Offline App`
5. اضغط "Register app"
6. **حمّل google-services.json**
7. احفظ الملف

---

### الخطوة 5: وضع google-services.json

```powershell
# انسخ الملف المحمّل إلى:
# android/app/google-services.json

# تأكد من المكان:
Test-Path android/app/google-services.json
# يجب أن يرجع: True
```

⚠️ **مهم:** هذا الملف محمي في .gitignore ولن يُرفع على Git

---

### الخطوة 6: تفعيل App Distribution

**من Firebase Console:**
1. من القائمة: Release & Monitor → App Distribution
2. اضغط "Get started"
3. اضغط "Testers & Groups"
4. اضغط "Create group"
5. اسم المجموعة: `testers`
6. أضف emails للـ testers (افصل بفاصلة)
7. احفظ

---

## المرحلة 2: إعداد Service Account (5 دقائق)

### الخطوة 7: إنشاء Service Account

1. افتح: https://console.cloud.google.com/
2. اختر مشروعك `benaa-offline-app`
3. من القائمة: IAM & Admin → Service Accounts
4. اضغط "Create Service Account"
5. اسم الحساب: `github-actions-firebase`
6. اضغط "Create and Continue"
7. اختر الدور: **Firebase App Distribution Admin**
8. اضغط "Continue" ثم "Done"

---

### الخطوة 8: إنشاء JSON Key

1. من قائمة Service Accounts، اضغط على الحساب الجديد
2. تبويب "Keys"
3. اضغط "Add Key" → "Create new key"
4. نوع المفتاح: **JSON**
5. اضغط "Create"
6. سيتم تحميل ملف JSON - **احفظه بأمان!**

---

### الخطوة 9: الحصول على Firebase App ID

**من Firebase Console:**
1. Project Settings (⚙️ بجانب Project Overview)
2. تبويب "General"
3. انزل لـ "Your apps"
4. انسخ **App ID** (يبدأ بـ `1:...`)

---

## المرحلة 3: إضافة GitHub Secrets (3 دقائق)

### الخطوة 10: إضافة GOOGLE_SERVICES_JSON

```powershell
# اعرض محتوى الملف
Get-Content android/app/google-services.json | Set-Clipboard
# تم نسخه للـ clipboard
```

**على GitHub:**
1. اذهب لـ Repository
2. Settings → Secrets and variables → Actions
3. اضغط "New repository secret"
4. Name: `GOOGLE_SERVICES_JSON`
5. Value: الصق المحتوى (Ctrl+V)
6. اضغط "Add secret"

---

### الخطوة 11: إضافة FIREBASE_SERVICE_ACCOUNT

```powershell
# انسخ محتوى ملف Service Account JSON الذي حمّلته
Get-Content "C:\Downloads\benaa-offline-app-xxxxx.json" | Set-Clipboard
```

**على GitHub:**
1. New repository secret
2. Name: `FIREBASE_SERVICE_ACCOUNT`
3. Value: الصق المحتوى
4. Add secret

---

### الخطوة 12: إضافة FIREBASE_APP_ID

**على GitHub:**
1. New repository secret
2. Name: `FIREBASE_APP_ID`
3. Value: الصق App ID (من الخطوة 9)
4. Add secret

---

## المرحلة 4: حل مشاكل Git (10 دقائق)

### الخطوة 13: حفظ التغييرات الحالية

```powershell
# نشوف الوضع
git status

# نضيف كل التغييرات
git add .

# نعمل commit
git commit -m "Add Firebase App Distribution + CI/CD setup"
```

---

### الخطوة 14: جلب آخر تحديثات main

```powershell
# نجلب التحديثات
git fetch origin main

# نشوف الفرق
git log --oneline HEAD..origin/main

# نشوف إذا في conflicts محتملة
git diff origin/main
```

---

### الخطوة 15: حل الـ Conflicts (إذا وجدت)

**الطريقة الآمنة:**

```powershell
# نعمل backup للتغييرات
git branch backup-search-section

# نحاول merge من main
git merge origin/main

# إذا طلعت conflicts:
# سيظهر لك الملفات المتعارضة
git status

# افتح كل ملف وحل الـ conflict يدوياً
# ابحث عن:
# <<<<<<< HEAD
# كودك
# =======
# كود من main
# >>>>>>> origin/main

# بعد الحل:
git add .
git commit -m "Resolve merge conflicts with main"
```

**أو الطريقة البديلة (Rebase):**

```powershell
# rebase على main
git rebase origin/main

# إذا في conflicts:
# حلها ملف بملف ثم:
git add .
git rebase --continue

# إذا بدك تلغي:
# git rebase --abort
```

---

### الخطوة 16: رفع على main

**الطريقة المباشرة (إذا ما في branch protection):**

```powershell
# تأكد إنك على search_section
git branch

# ادمج في main
git checkout main
git pull origin main
git merge search_section

# ارفع
git push origin main
```

**الطريقة الصحيحة (عبر PR):**

```powershell
# ارفع search_section
git push origin search_section

# افتح GitHub في المتصفح
# اعمل Pull Request من search_section إلى main
# انتظر CI checks
# اعمل Merge
```

---

## المرحلة 5: الاختبار النهائي

### الخطوة 17: اختبار محلي (اختياري)

```powershell
# ثبّت الـ gems
cd android
bundle install

# احصل على Firebase token
firebase login:ci
# انسخ الـ token الظاهر

# جرب الرفع
$env:FIREBASE_TOKEN = "YOUR_TOKEN_HERE"
$env:FIREBASE_APP_ID = "1:xxxxx:android:xxxxx"
bundle exec fastlane deploy_firebase
```

---

### الخطوة 18: مراقبة GitHub Actions

بعد الـ merge على main:

1. اذهب لـ GitHub Repository
2. تبويب "Actions"
3. شاهد workflow "Production Deployment"
4. تأكد من نجاح كل الخطوات

---

### الخطوة 19: التحقق من Firebase

1. افتح Firebase Console
2. App Distribution
3. يجب أن ترى release جديد!
4. تأكد من إرسال الإشعارات للـ testers

---

## ✅ Checklist النهائي

قبل الرفع على main:

- [ ] سجّلت دخول Firebase: `firebase login`
- [ ] أنشأت مشروع Firebase
- [ ] أضفت تطبيق Android
- [ ] حمّلت google-services.json
- [ ] وضعته في android/app/
- [ ] تأكدت أنه ليس في Git: `Test-Path android/app/google-services.json`
- [ ] فعّلت App Distribution
- [ ] أنشأت مجموعة testers
- [ ] أضفت emails للـ testers
- [ ] أنشأت Service Account
- [ ] حمّلت JSON Key
- [ ] نسخت App ID
- [ ] أضفت GOOGLE_SERVICES_JSON على GitHub Secrets
- [ ] أضفت FIREBASE_SERVICE_ACCOUNT على GitHub Secrets
- [ ] أضفت FIREBASE_APP_ID على GitHub Secrets
- [ ] شغّلت bundle install
- [ ] حفظت كل تغييرات Git
- [ ] حللت أي conflicts مع main
- [ ] رفعت على main (مباشرة أو عبر PR)
- [ ] راقبت GitHub Actions
- [ ] تحققت من Firebase Console

---

## 🎉 بعد النجاح

كل merge على main سيرفع التطبيق تلقائياً!

الـ testers سيستلمون:
1. Email من Firebase
2. رابط للتحميل
3. يحملون تطبيق Firebase App Distribution من Play Store
4. يسجلون دخول
5. يحملون التطبيق

---

## 🐛 مشاكل شائعة

### google-services.json not found

```powershell
Test-Path android/app/google-services.json
# إذا False: حمّله من Firebase Console
```

### Firebase token expired

```powershell
firebase login
```

### Conflicts في Git

```powershell
# شوف الملفات المتعارضة
git status

# حلها يدوياً
# ثم:
git add .
git commit
```

### GitHub Actions failed

1. اقرأ اللوغ بعناية
2. تأكد من الـ Secrets
3. تأكد من google-services.json

---

**ابدأ الآن من الخطوة 1! 🚀**
