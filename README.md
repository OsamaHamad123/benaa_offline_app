# Benaa Offline App

تطبيق Flutter للعمل الميداني مع قدرات كاملة للعمل أوفلاين، مع مزامنة دورية وقاعدة بيانات مشفرة.

---

## ⚠️ GitHub Safe Demo Version

> **هذه نسخة آمنة للـ GitHub — جميع الاتصالات بالسيرفر القديم مُعطّلة.**

### ما الذي تغيّر في هذه النسخة؟

| الجانب                   | الحالة                                                        |
| ------------------------ | ------------------------------------------------------------- |
| روابط API القديمة        | ✅ تم حذفها واستبدالها بـ `disabled-api.example.com`          |
| تسجيل الدخول عبر السيرفر | ✅ مُعطّل — يعمل الآن في وضع Demo المحلي                      |
| مزامنة البيانات (Sync)   | ✅ مُعطّلة — لا يُرسل أي طلب للسيرفر القديم                   |
| تحميل قاعدة السجل المدني | ✅ مُعطّل — لا اتصال بسجلات المواطنين                         |
| مفاتيح Sentry            | ✅ محذوفة — استبدلها بمشروع Sentry الخاص                      |
| Firebase                 | 🔜 مخطط — ملفات placeholder جاهزة في `lib/services/firebase/` |

### تسجيل الدخول في وضع Demo

- شاشة تسجيل الدخول تعمل بشكل طبيعي.
- أي اسم مستخدم وكلمة مرور غير فارغين سيمرران تسجيل الدخول.
- **لا يُرسل أي بيانات إلى أي سيرفر خارجي.**

### للبدء بتشغيل التطبيق

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### للتطوير المستقبلي — دمج Firebase

1. أنشئ مشروع Firebase على [console.firebase.google.com](https://console.firebase.google.com)
2. ثبّت FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. شغّل: `flutterfire configure`
4. طوّر الخدمات الموجودة في `lib/services/firebase/`
5. استبدل منطق تسجيل الدخول المحلي في `lib/features/auth/login_page.dart`

### الملفات الحساسة المستثناة من Git

الملفات التالية **مُدرجة في `.gitignore`** ويجب **عدم** رفعها:

- `assets/env.json` — يحتوي رابط API الحقيقي
- `sentry.properties` — يحتوي Sentry auth token
- `android/app/google-services.json` — Firebase config
- `ios/Runner/GoogleService-Info.plist` — Firebase config (iOS)
- `lib/firebase_options.dart` — Firebase options
- `*.keystore`, `*.jks` — ملفات توقيع التطبيق

استخدم `assets/env.example.json` كقالب لإنشاء `assets/env.json` الخاص بك.

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
- ✅ قاعدة بيانات SQLite مشفرة عبر SQLCipher
- ✅ مزامنة تلقائية ودفعات عند توفر الإنترنت
- ✅ بحث سريع بالرقم الوطني/رقم الملف (< 200ms)
- ✅ بحث نصي كامل FTS5 للأسماء (< 800ms على 100k سجل)
- ✅ تشفير المرفقات (صور وPDF)
- ✅ رفع المرفقات مجزأة (512KB لكل جزء)
- ✅ توليد تقارير PDF وExcel
- ✅ مصادقة JWT
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

اقرأ `TESTING_SETUP_GUIDE.md` للتفاصيل الكاملة.

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

### إعداد سريع

```powershell
# اقرأ الدليل السريع
cat FIREBASE_QUICK_START.md
```

### الخطوات الأساسية:

1. إنشاء مشروع Firebase
2. تحميل `google-services.json` ووضعه في `android/app/`
3. إضافة GitHub Secrets
4. Merge على main → النشر التلقائي!

اقرأ `FIREBASE_SETUP_GUIDE.md` للتفاصيل الكاملة.

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

اقرأ `GIT_WORKFLOW_GUIDE.md` لسير العمل الكامل.

---

## 📚 التوثيق

| الملف                                   | الوصف                                  |
| --------------------------------------- | -------------------------------------- |
| `START_HERE.md`                         | 🚀 ابدأ من هنا!                        |
| `FIREBASE_QUICK_START.md`               | 🔥 إعداد Firebase السريع               |
| `FIREBASE_SETUP_GUIDE.md`               | 🔥 دليل Firebase الشامل                |
| `GIT_WORKFLOW_GUIDE.md`                 | دليل شامل للعمل مع Git وتجنب Conflicts |
| `TESTING_SETUP_GUIDE.md`                | إعداد نظام Testing و CI/CD             |
| `QUICK_START.md`                        | دليل البدء السريع                      |
| `DATABASE_PATHS_GUIDE.md`               | دليل قاعدة البيانات                    |
| `COMPLETE_ENHANCEMENTS_FINAL_REPORT.md` | تقرير التحسينات                        |

---

## 🏗️ البنية التقنية

- **Drift + SQLCipher**: قاعدة بيانات مشفرة
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
- ✅ اتباع `GIT_WORKFLOW_GUIDE.md`

---

## 📝 License

This project is private and proprietary.

---

## 📞 الدعم

للمشاكل والأسئلة، افتح [Issue](https://github.com/OsamaHamad123/benaa_offline_app/issues) على GitHub.

flutter analyze

```

```
