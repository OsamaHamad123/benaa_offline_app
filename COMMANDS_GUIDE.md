# 🛠️ دليل الأوامر والأدوات المفيدة

## تطبيق Benaa Offline App - نسخة الإصلاح

---

## 🚀 البدء السريع

```bash
# 1. الانتقال للمشروع
cd C:\Dev\benaa_offline_app

# 2. تحديث الحزم
flutter pub get

# 3. توليد الكود
dart run build_runner build --delete-conflicting-outputs

# 4. تشغيل التطبيق
flutter run
```

---

## 🧪 أوامر الاختبار

### تشغيل جميع الاختبارات

```bash
flutter test
```

### تشغيل اختبارات محددة

```bash
# اختبار ملف واحد
flutter test test/widget_test.dart

# اختبار مجلد كامل
flutter test test/data/
flutter test test/core/
flutter test test/features/

# اختبارات محددة
flutter test test/core/accessibility/accessibility_widgets_test.dart
flutter test test/features/kafalat/widgets/stats_dashboard_widget_test.dart
```

### اختبارات مع خيارات

```bash
# مع التغطية
flutter test --coverage

# مع تفاصيل مفصلة
flutter test --verbose

# مع توقف عند أول فشل
flutter test --fail-fast

# اختبار معين بالاسم
flutter test --name "AccessibleListTile"

# اختبار بدون تتبع الأخطاء
flutter test --plain-name "test name"
```

---

## 📊 التحليل والفحص

### تحليل ثابت

```bash
# فحص شامل
flutter analyze

# فحص مع تفاصيل
flutter analyze --verbose

# فحص ملف محدد
flutter analyze lib/app.dart
```

### الإصلاح التلقائي

```bash
# إصلاح جميع الملفات
dart fix --apply

# عرض الإصلاحات بدون تطبيق
dart fix

# إصلاح ملف واحد
dart fix --apply lib/app.dart

# إصلاح مجلد
dart fix --apply lib/core/
```

### تنسيق الكود

```bash
# تنسيق جميع الملفات
dart format lib/ test/

# تنسيق ملف واحد
dart format lib/app.dart

# عرض الاختلافات
dart format --output=show lib/
```

---

## 🔍 البحث والتصحيح

### البحث عن مشاكل محددة

```bash
# البحث عن استيرادات غير مستخدمة
grep -r "unused_import" --include="*.dart" lib/

# البحث عن deprecated members
grep -r "deprecated" --include="*.dart" lib/

# البحث عن ScreenUtil
grep -r "ScreenUtil" --include="*.dart" lib/ test/
```

### التحقق من الأخطاء

```bash
# جميع الأخطاء
flutter analyze 2>&1 | grep "error"

# جميع التحذيرات
flutter analyze 2>&1 | grep "warning"

# عدد التحذيرات
flutter analyze 2>&1 | grep -c "warning"
```

---

## 🏗️ البناء والتطوير

### تشغيل في وضع التطوير

```bash
# تشغيل عادي
flutter run

# مع Hot Reload فقط
flutter run --no-fast-start

# مع Hot Restart
flutter run

# بدون إعلانات
flutter run -q
```

### البناء الإنتاجي

```bash
# بناء APK للاختبار
flutter build apk --debug

# بناء APK للإنتاج
flutter build apk --release

# بناء iOS
flutter build ios --release

# بناء Web
flutter build web --release

# بناء Windows
flutter build windows --release
```

### تنظيف المشروع

```bash
# تنظيف شامل
flutter clean

# حذف build
rm -rf build/

# حذف coverage
rm -rf coverage/

# إعادة التبعيات
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 🔧 أوامر الصيانة

### تحديث التبعيات

```bash
# عرض التبعيات المتقادمة
flutter pub outdated

# تحديث جميع التبعيات
flutter pub upgrade

# تحديث لأحدث إصدار (قد تكسر التوافق)
flutter pub upgrade --major-versions

# تحديث حزمة محددة
flutter pub upgrade firebase_core
```

### العمل مع build_runner

```bash
# بناء الكود المولد
dart run build_runner build

# حذف الملفات المتضاربة وإعادة البناء
dart run build_runner build --delete-conflicting-outputs

# مراقبة التغييرات وإعادة البناء
dart run build_runner watch

# حذف الملفات المولدة
dart run build_runner clean
```

---

## 📦 إدارة الملفات

### استكشاف المشروع

```bash
# عرض حجم الملفات
du -sh lib/

# عرض عدد الملفات
find lib -name "*.dart" | wc -l

# عرض أكبر الملفات
find lib -name "*.dart" -exec wc -l {} + | sort -rn | head -10

# عرض ملفات الاختبار
find test -name "*_test.dart" -type f
```

### التنظيف المتقدم

```bash
# حذف الملفات المولدة (.g.dart)
find . -name "*.g.dart" -delete

# حذف ملفات الـ coverage
find . -name "*.lcov" -delete

# حذف mocks
find . -name "mock*.dart" -delete
```

---

## 📝 سير العمل مع Git

### الحالة والتتبع

```bash
# حالة المشروع
git status

# عرض الفروقات
git diff lib/app.dart

# عرض السجل
git log --oneline -n 10
```

### الالتزام والدفع

```bash
# إضافة الملفات
git add .

# الالتزام
git commit -m "fix: resolve test failures"

# الدفع
git push origin main
```

---

## 🐛 التصحيح والتحليل

### Debugging

```bash
# تشغيل مع DevTools
flutter run --devtools-startup-mode=defer

# عرض logs
flutter logs

# تصحيح مع breakpoints
# استخدم VS Code/Android Studio
```

### Performance Analysis

```bash
# تحليل الأداء
flutter run --profile

# قياس الأداء
flutter run --trace-startup

# عرض frame rendering
flutter run --profile --display-skaialog
```

---

## 💻 أوامر النظام المفيدة

### التنقل والملفات (PowerShell في Windows)

```powershell
# الانتقال للمشروع
cd C:\Dev\benaa_offline_app

# عرض المحتويات
Get-ChildItem -Path lib

# عد الملفات
(Get-ChildItem -Path lib -Recurse -Filter "*.dart").Count

# البحث
Get-ChildItem -Path lib -Recurse -Filter "*_test.dart"
```

---

## 📊 أمثلة عملية

### إصلاح الاختبارات

```bash
# 1. تشغيل اختبار محدد
flutter test test/core/accessibility/accessibility_widgets_test.dart --verbose

# 2. بعد الإصلاح، تشغيل مجدداً
flutter test test/core/accessibility/

# 3. تشغيل جميع الاختبارات
flutter test

# 4. عرض التغطية
flutter test --coverage
```

### تنظيف الكود

```bash
# 1. فحص المشاكل
flutter analyze

# 2. إصلاح تلقائي
dart fix --apply

# 3. تنسيق
dart format lib/ test/

# 4. التحقق النهائي
flutter analyze
```

### دورة التطوير الكاملة

```bash
# 1. الحصول على أحدث كود
git pull origin main

# 2. تحديث التبعيات
flutter pub get

# 3. توليد الكود
dart run build_runner build --delete-conflicting-outputs

# 4. الاختبار
flutter test

# 5. التحليل
flutter analyze

# 6. الإصلاح
dart fix --apply
dart format lib/

# 7. الاختبار النهائي
flutter test

# 8. الالتزام والدفع
git add .
git commit -m "chore: code cleanup and fixes"
git push origin main
```

---

## ⚡ اختصارات مفيدة

### عرض المساعدة

```bash
# Flutter commands
flutter --help
flutter test --help

# Dart commands
dart --help
dart fix --help
```

---

## 🔗 الموارد المفيدة

### التوثيق الرسمي

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Dart Documentation](https://dart.dev/guides)

### أدوات مفيدة

- [VS Code Extensions](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Android Studio Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)
- [DevTools](https://flutter.dev/docs/development/tools/devtools/overview)

---

## 💡 نصائح مهمة

✅ شغّل الاختبارات بانتظام
✅ استخدم `--fail-fast` عند الإصلاح
✅ راقب `flutter analyze` دائماً
✅ استخدم `dart fix` للإصلاح التلقائي
✅ نسّق الكود بانتظام
✅ اختبر على أجهزة حقيقية

---

**آخر تحديث**: 7 يناير 2026
