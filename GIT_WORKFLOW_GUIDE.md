# Git Workflow & Conflict Prevention Guide

## نظام العمل مع Git - تجنب الـ Conflicts

### هيكل الـ Branches

```
main (protected)
  ↑
develop (integration branch)
  ↑
feature/* (feature branches)
```

### القواعد الأساسية

#### 1. الـ Main Branch
- **محمي بالكامل** - لا يمكن الـ push المباشر
- يتم الـ merge فقط من `develop` عبر Pull Request
- يجب موافقة reviewer واحد على الأقل
- يجب نجاح جميع الـ CI checks

#### 2. الـ Develop Branch
- branch التكامل الرئيسي
- يتم الـ merge من feature branches عبر PR
- يجب نجاح الـ tests قبل الـ merge

#### 3. Feature Branches
- تسمية: `feature/اسم-الميزة` أو `fix/اسم-الإصلاح`
- يتم إنشاؤها من `develop`
- يتم حذفها بعد الـ merge

---

## خطوات العمل اليومية

### بدء ميزة جديدة

```bash
# 1. التأكد من أنك على develop وتحديثه
git checkout develop
git pull origin develop

# 2. إنشاء branch جديد
git checkout -b feature/new-feature

# 3. العمل والـ commit
git add .
git commit -m "Add: وصف التغيير"

# 4. رفع التغييرات
git push origin feature/new-feature
```

### تحديث الـ Branch قبل الـ Merge (تجنب الـ Conflicts)

```bash
# 1. احفظ عملك الحالي
git add .
git commit -m "WIP: current work"

# 2. جلب آخر تحديثات develop
git checkout develop
git pull origin develop

# 3. العودة لـ branch الخاص بك
git checkout feature/new-feature

# 4. دمج التحديثات
git merge develop

# 5. حل أي conflicts إذا ظهرت
# ثم
git add .
git commit -m "Merge develop into feature branch"

# 6. رفع التحديثات
git push origin feature/new-feature
```

### إنشاء Pull Request

1. اذهب إلى GitHub
2. اضغط "New Pull Request"
3. اختر:
   - Base: `develop`
   - Compare: `feature/your-branch`
4. اكتب وصف واضح للتغييرات
5. اطلب Review من زميل
6. انتظر نجاح الـ CI checks
7. Merge بعد الموافقة

---

## حل الـ Conflicts

### عند ظهور conflict:

```bash
# 1. افتح الملفات المتعارضة في VS Code
# ستجد علامات مثل:
<<<<<<< HEAD
كودك الحالي
=======
الكود من develop
>>>>>>> develop

# 2. اختر الكود الصحيح أو ادمجهما يدوياً

# 3. بعد الحل
git add .
git commit -m "Resolve merge conflicts"
git push
```

---

## أوامر مفيدة

### عرض حالة الـ branches

```bash
# Branches محلية
git branch

# Branches على GitHub
git branch -r

# كل الـ branches
git branch -a
```

### حذف branch بعد الـ merge

```bash
# محلي
git branch -d feature/old-feature

# على GitHub
git push origin --delete feature/old-feature
```

### التراجع عن التغييرات

```bash
# التراجع عن ملف معين (قبل الـ commit)
git checkout -- filename

# التراجع عن آخر commit (الاحتفاظ بالتغييرات)
git reset --soft HEAD~1

# التراجع عن آخر commit (حذف التغييرات)
git reset --hard HEAD~1
```

---

## نظام الـ Testing مع Fastlane

### تثبيت Ruby و Fastlane

```bash
# 1. تثبيت Ruby (إذا لم يكن مثبت)
# قم بتحميل من: https://rubyinstaller.org/

# 2. تثبيت Bundler
gem install bundler

# 3. تثبيت Fastlane
cd android
bundle install
```

### استخدام Fastlane

```bash
cd android

# تشغيل الـ tests
bundle exec fastlane test

# فحص الكود
bundle exec fastlane analyze

# تشغيل كل الفحوصات
bundle exec fastlane check

# بناء APK للاختبار
bundle exec fastlane build_debug

# بناء نسخة release
bundle exec fastlane build_release

# نسخة beta للـ testers
bundle exec fastlane beta
```

---

## GitHub Branch Protection Rules

### إعدادات يجب تفعيلها على `main`:

1. اذهب إلى: Settings → Branches → Add rule
2. فعّل:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1)
   - ✅ Require status checks to pass (CI tests)
   - ✅ Require branches to be up to date
   - ✅ Do not allow bypassing the above settings

### إعدادات على `develop`:

1. نفس الإعدادات لكن أقل صرامة
2. يمكن السماح بـ merge بدون approval للـ core team

---

## Tips لتجنب المشاكل

### ✅ افعل:
- اسحب آخر تحديثات `develop` قبل البدء بأي عمل
- اعمل commits صغيرة ومتكررة
- اكتب commit messages واضحة
- حدّث branch الخاص بك يومياً من `develop`
- اطلب review من زميل

### ❌ لا تفعل:
- تعمل push مباشر على `main`
- تترك branch مفتوح لأسابيع بدون merge
- تعمل merge لـ branch قديم بدون تحديثه
- تتجاهل الـ CI failures
- تعمل force push على branches مشتركة

---

## Workflow السريع

```bash
# صباح كل يوم:
git checkout develop && git pull

# عند البدء بميزة:
git checkout -b feature/my-feature

# عند الانتهاء:
git add . && git commit -m "Complete feature"
git checkout develop && git pull
git checkout feature/my-feature && git merge develop
git push origin feature/my-feature
# ثم افتح PR على GitHub

# بعد الـ merge:
git checkout develop && git pull
git branch -d feature/my-feature
```

---

## CI/CD Automated Checks

عند كل PR، سيتم تلقائياً:
1. ✅ تشغيل `flutter analyze`
2. ✅ تشغيل جميع الـ tests
3. ✅ فحص الـ formatting
4. ✅ التأكد من عدم وجود conflicts
5. ✅ بناء APK تجريبي

---

## الحصول على المساعدة

إذا واجهت مشكلة:
1. اقرأ رسالة الخطأ بعناية
2. جرب `git status` لمعرفة الوضع الحالي
3. استخدم `git log --oneline` لرؤية آخر commits
4. اطلب مساعدة من الفريق
