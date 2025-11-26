# دليل إعداد نظام Testing & CI/CD

## 🚀 الملفات التي تم إنشاؤها

### 1. GitHub Actions Workflows
- `.github/workflows/ci.yml` - فحص تلقائي عند كل push/PR
- `.github/workflows/pr-checks.yml` - فحص Pull Requests
- `.github/dependabot.yml` - تحديث تلقائي للـ dependencies
- `.github/labeler.yml` - وضع labels تلقائية للـ PRs

### 2. Fastlane (Ruby)
- `android/Gemfile` - إدارة Ruby gems
- `android/fastlane/Fastfile` - أوامر الـ build والـ testing
- `android/fastlane/Appfile` - إعدادات التطبيق

### 3. التوثيق
- `GIT_WORKFLOW_GUIDE.md` - دليل شامل للعمل مع Git

---

## 📋 خطوات الإعداد

### الخطوة 1: تثبيت Ruby و Fastlane

```powershell
# 1. تحميل وتثبيت Ruby
# اذهب إلى: https://rubyinstaller.org/downloads/
# حمّل: Ruby+Devkit 3.2.x (x64)
# ثبّت مع الإعدادات الافتراضية

# 2. بعد التثبيت، افتح PowerShell جديد وتحقق:
ruby --version
gem --version

# 3. تثبيت Bundler
gem install bundler

# 4. تثبيت Fastlane
cd android
bundle install
```

### الخطوة 2: إعداد GitHub Branch Protection

اذهب إلى GitHub → Settings → Branches → Add rule:

**للـ `main` branch:**
```
Branch name pattern: main

☑️ Require a pull request before merging
  ☑️ Require approvals (1)
  ☑️ Dismiss stale pull request approvals when new commits are pushed

☑️ Require status checks to pass before merging
  ☑️ Require branches to be up to date before merging
  اختر: test, build-android, validate-pr

☑️ Do not allow bypassing the above settings
```

**للـ `develop` branch:**
```
Branch name pattern: develop

☑️ Require a pull request before merging
☑️ Require status checks to pass before merging
  اختر: test, validate-pr
```

### الخطوة 3: اختبار النظام

```powershell
# اختبر Fastlane
cd android
bundle exec fastlane test

# اختبر البناء
bundle exec fastlane build_debug
```

---

## 🔄 سير العمل الجديد

### للمطورين:

```bash
# 1. ابدأ ميزة جديدة
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# 2. اعمل التغييرات المطلوبة
# ... code ...

# 3. اختبر محلياً
cd android
bundle exec fastlane check  # يشغل analyze + test

# 4. commit و push
git add .
git commit -m "Add: feature description"
git push origin feature/my-feature

# 5. افتح Pull Request على GitHub
# سيتم تشغيل CI تلقائياً

# 6. بعد الموافقة والـ merge
git checkout develop
git pull origin develop
git branch -d feature/my-feature
```

### للـ Testers:

```bash
# بناء نسخة للاختبار
cd android
bundle exec fastlane beta

# ستجد الـ APK في مجلد builds/
```

---

## 🛠️ أوامر Fastlane المتاحة

```bash
cd android

# اختبار
bundle exec fastlane test              # تشغيل Flutter tests
bundle exec fastlane analyze           # فحص الكود
bundle exec fastlane check             # test + analyze

# بناء
bundle exec fastlane build_debug       # بناء debug APK
bundle exec fastlane build_release     # بناء release APK
bundle exec fastlane beta              # بناء نسخة للـ testers
bundle exec fastlane deploy_internal   # نشر داخلي
```

---

## 🔍 ماذا يحدث تلقائياً؟

### عند Push على أي branch:
✅ فحص formatting الكود
✅ تشغيل `flutter analyze`
✅ تشغيل جميع الـ tests
✅ جمع coverage report

### عند فتح Pull Request:
✅ كل الفحوصات السابقة
✅ فحص الـ conflicts مع الـ base branch
✅ بناء APK تجريبي
✅ وضع labels تلقائية حسب الملفات المعدلة

### عند Merge على main:
✅ بناء release APK
✅ حفظ الـ APK كـ artifact لمدة 7 أيام

---

## 📊 مراقبة الـ CI/CD

### على GitHub:
1. اذهب إلى تبويب "Actions"
2. شاهد جميع الـ workflows قيد التشغيل
3. انقر على أي workflow لرؤية التفاصيل

### معلومات مفيدة:
- 🟢 Green check: نجح الـ workflow
- 🔴 Red X: فشل الـ workflow (اقرأ اللوغ)
- 🟡 Yellow dot: قيد التشغيل

---

## 🐛 حل المشاكل الشائعة

### Fastlane لا يعمل:
```powershell
# تأكد من تثبيت Ruby
ruby --version

# أعد تثبيت الـ gems
cd android
bundle install
```

### CI fails على GitHub:
1. اقرأ اللوغ بعناية
2. شغّل نفس الأمر محلياً:
   ```bash
   flutter analyze
   flutter test
   ```
3. اصلح الأخطاء وارفع من جديد

### Merge conflicts:
اتبع الدليل في `GIT_WORKFLOW_GUIDE.md`

---

## 📚 مصادر إضافية

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)

---

## ✅ Checklist للتحقق من الإعداد

- [ ] Ruby مثبت ويعمل
- [ ] Fastlane مثبت (`bundle exec fastlane --version`)
- [ ] GitHub Actions workflows موجودة في `.github/workflows/`
- [ ] Branch protection rules مفعلة على `main` و `develop`
- [ ] الفريق يعرف سير العمل الجديد
- [ ] تم اختبار `fastlane test` بنجاح
- [ ] تم اختبار `fastlane build_debug` بنجاح

---

## 🎯 الخطوات التالية

1. ✅ شارك `GIT_WORKFLOW_GUIDE.md` مع الفريق
2. ✅ فعّل Branch Protection Rules على GitHub
3. ✅ ثبّت Ruby و Fastlane على أجهزة الفريق
4. ✅ اعمل test run للـ CI/CD بفتح PR تجريبي
5. ✅ وثّق أي إعدادات إضافية خاصة بالمشروع

---

**Good luck! 🚀**
