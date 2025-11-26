# 🚀 Quick Start Guide

## إعداد سريع (5 دقائق)

### 1. تثبيت Ruby و Fastlane

```powershell
# قم بتحميل Ruby من: https://rubyinstaller.org/
# اختر: Ruby+Devkit 3.2.x (x64)

# بعد التثبيت:
gem install bundler
cd android
bundle install
```

### 2. تشغيل سكريبت الإعداد

```powershell
.\scripts\setup.ps1
```

### 3. تحميل Git Helpers

```powershell
. .\scripts\git-helpers.ps1
Show-GitHelp
```

---

## الأوامر اليومية

### بدء العمل

```powershell
# بدء ميزة جديدة
Start-NewFeature "add-new-screen"

# أو
git checkout develop
git pull origin develop
git checkout -b feature/add-new-screen
```

### أثناء العمل

```powershell
# فحص الكود قبل الـ commit
Test-BeforeCommit

# Commit سريع
Quick-Commit "Add: new screen UI"
```

### قبل فتح PR

```powershell
# تحديث من develop
Update-FromDevelop

# فحص الـ conflicts
Check-Conflicts

# Push
git push origin feature/add-new-screen
```

### بعد الـ Merge

```powershell
git checkout develop
git pull origin develop
Clean-MergedBranches
```

---

## Fastlane Commands

```bash
cd android

# اختبار
bundle exec fastlane test

# بناء APK
bundle exec fastlane build_debug

# نسخة للـ testers
bundle exec fastlane beta
```

---

## عند مواجهة مشكلة

### Merge Conflicts

```powershell
# حل يدوياً ثم:
git add .
git commit -m "Resolve conflicts"
git push
```

### Test Failures

```powershell
flutter test
# اصلح الأخطاء
Test-BeforeCommit
```

### Git Status مشوش

```powershell
Show-BranchStatus
```

---

## روابط مهمة

- 📖 [دليل Git الكامل](GIT_WORKFLOW_GUIDE.md)
- 🧪 [دليل Testing](TESTING_SETUP_GUIDE.md)
- 💻 [GitHub Actions](.github/workflows/)

---

**نصيحة اليوم:** استخدم `Show-GitHelp` لعرض جميع الأوامر المتاحة!
