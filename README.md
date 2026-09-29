# Benaa Offline App

تطبيق Flutter للعمل الميداني مع قدرات كاملة للعمل أوفلاين، مع مزامنة دورية ومرفقات مشفرة.

[![Flutter CI](https://github.com/OsamaHamad123/benaa_offline_app/actions/workflows/flutter_ci.yml/badge.svg?branch=develop)](https://github.com/OsamaHamad123/benaa_offline_app/actions/workflows/flutter_ci.yml)

---

## Screenshots

![Benaa app overview: dashboard, insights, beneficiaries list and activity log](docs/screenshots/overview.png)

The screens are rendered headlessly from the real Flutter UI (Arabic, RTL) with fictional sample data; see `test/screenshots/`.

---

## 📋 المحتويات

- [المميزات](#المميزات)
- [البدء السريع](#البدء-السريع)
- [Firebase App Distribution](#firebase-app-distribution)
- [نظام Testing و CI/CD](#نظام-testing-و-cicd)
- [سير العمل مع Git](#سير-العمل-مع-git)
- [التوثيق](#التوثيق)

---

## المميزات

- ✅ عمل كامل بدون إنترنت أثناء العمل الميداني
- ✅ قاعدة بيانات SQLite محلية عبر Drift
- ✅ مزامنة يدوية باتجاهين من شاشة المزامنة (تنزيل على صفحات، ورفع السجلات المعدّلة)
- ✅ بحث سريع برقم الملف (< 200ms)
- ✅ بحث بالأسماء العربية مع تطبيع النص
- ✅ مرفقات (صور وPDF) مخزنة على الجهاز
- ✅ تسجيل دخول بدون إنترنت (PBKDF2)
- ✅ توليد تقارير PDF وExcel
- ✅ مصادقة برمز Bearer مُجزّأ على الخادم
- ✅ CI/CD تلقائي مع GitHub Actions
- ✅ Testing آلي مع Fastlane
- ✅ Firebase App Distribution للنشر التلقائي

---

## 🚀 البدء السريع

### المتطلبات

- Flutter SDK 3.24.0 أو أحدث
- Ruby 3.2+ (للـ Fastlane)
- Android Studio / VS Code
- Git

### إعداد المشروع

```bash
# 1. استنساخ المشروع
git clone https://github.com/OsamaHamad123/benaa_offline_app.git
cd benaa_offline_app

# 2. تثبيت التبعيات
flutter pub get

# 3. توليد الكود
dart run build_runner build --delete-conflicting-outputs

# 4. تشغيل التطبيق
flutter run
```

### إعداد نظام Testing

```powershell
# تشغيل سكريبت الإعداد
.\scripts\setup.ps1
```

خطوات الـ CI كلها في [`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml).

---

## 🧪 نظام Testing و CI/CD

### الاختبار المحلي

```bash
# تشغيل جميع الاختبارات
flutter test

# فحص الكود
flutter analyze

# تنسيق الكود
dart format .
```

### Fastlane

```bash
cd android

# تشغيل الاختبارات
bundle exec fastlane test

# فحص الكود
bundle exec fastlane analyze

# جميع الفحوصات
bundle exec fastlane check

# بناء APK للاختبار
bundle exec fastlane build_debug

# بناء نسخة beta
bundle exec fastlane beta

# رفع على Firebase
bundle exec fastlane deploy_firebase
```

### GitHub Actions

تتم العمليات التالية تلقائياً:
- ✅ عند كل Push: تشغيل tests، analyze، formatting check
- ✅ عند كل PR: فحص conflicts، تشغيل tests، بناء APK
- ✅ عند Merge على main: بناء release APK + نشر على Firebase
- ✅ عند Merge على develop: نشر نسخة staging (اختياري)

---

## 🔥 Firebase App Distribution

### الخطوات الأساسية:

1. إنشاء مشروع Firebase
2. تحميل `google-services.json` ووضعه في `android/app/`
3. إضافة GitHub Secrets
4. Merge على main → النشر التلقائي!

النشر معرّف في [`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml) و [`android_fastlane_firebase.yml`](.github/workflows/android_fastlane_firebase.yml).

---

## 🔀 سير العمل مع Git

### هيكل الـ Branches

```
main (protected) ← develop ← feature/* branches
```

### البدء بميزة جديدة

```powershell
# تحميل Git helpers
. .\scripts\git-helpers.ps1

# بدء ميزة جديدة
Start-NewFeature "feature-name"

# أو يدوياً:
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
```

### قبل الـ Commit

```powershell
# فحص الكود
Test-BeforeCommit

# Commit
Quick-Commit "Add: feature description"
```

### تحديث من develop

```powershell
Update-FromDevelop
```

اقرأ [`.github/BRANCH_STRATEGY.md`](.github/BRANCH_STRATEGY.md) لسير العمل الكامل.

---

## 📚 التوثيق

| الملف | الوصف |
|-------|-------|
| [`.github/BRANCH_STRATEGY.md`](.github/BRANCH_STRATEGY.md) | سير العمل مع الفروع و Pull Requests |
| [`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml) | الـ CI: التحليل والاختبارات والبناء والنشر |
| [`docs/`](docs) | أدلة الوحدات وتصميمها |
| [`docs/reports/`](docs/reports) | تقارير المراجعة والتدقيق السابقة |
| [`SECURITY.md`](SECURITY.md) | سياسة الأمان |

---

## 🏗️ البنية التقنية

- **Drift**: قاعدة بيانات SQLite محلية
- **Riverpod**: إدارة الحالة
- **GoRouter**: التنقل
- **Dio**: طلبات HTTP
- **FlutterSecureStorage**: تخزين آمن
- **Fastlane**: أتمتة Build و Testing
- **GitHub Actions**: CI/CD
- **Firebase App Distribution**: نشر تلقائي للتطبيق
- **GoRouter**: التنقل
- **Dio**: طلبات HTTP
- **FlutterSecureStorage**: تخزين آمن
- **Fastlane**: أتمتة Build و Testing
- **GitHub Actions**: CI/CD

---

## 🛠️ الأوامر المهمة

```bash
# توليد الكود
dart run build_runner build --delete-conflicting-outputs

# تشغيل على أجهزة مختلفة
flutter run -d windows
flutter run -d android

# فحص وتنسيق
flutter analyze
dart format .
flutter test

# بناء
flutter build apk --release
flutter build windows --release
```

---

## 👥 المساهمة

1. Fork المشروع
2. أنشئ feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit تغييراتك (`git commit -m 'Add some AmazingFeature'`)
4. Push إلى Branch (`git push origin feature/AmazingFeature`)
5. افتح Pull Request

تأكد من:
- ✅ تشغيل `Test-BeforeCommit` قبل الـ push
- ✅ كتابة tests للكود الجديد
- ✅ تحديث التوثيق إذا لزم الأمر
- ✅ اتباع [`.github/BRANCH_STRATEGY.md`](.github/BRANCH_STRATEGY.md)

---

## 📝 License

All rights reserved. The source is public for viewing only; no license to use, copy or modify it is granted.

---

## 📞 الدعم

للمشاكل والأسئلة، افتح [Issue](https://github.com/OsamaHamad123/benaa_offline_app/issues) على GitHub.

flutter analyze
```
