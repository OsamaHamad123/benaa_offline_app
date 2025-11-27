# دليل Firebase App Distribution

## التغييرات المطبّقة

### 1. تحديث Dependencies
- تحديث `sqflite_sqlcipher` من `^3.0.0` إلى `^3.2.0` لحل مشاكل التوافق مع Android Gradle Plugin

### 2. تحديث Gemfile
تم تبسيط `android/Gemfile` ليتطابق مع المشروع السابق الناجح:
```ruby
source "https://rubygems.org"

gem "fastlane", "~> 2.0"
gem "fastlane-plugin-firebase_app_distribution"
gem "abbrev"
```

### 3. تحديث Fastfile
تم تبسيط `android/fastlane/Fastfile`:
```ruby
lane :firebase_distribution do
  sh "flutter clean"
  sh "flutter build apk --release --no-tree-shake-icons"
  firebase_app_distribution(
    app: ENV["FIREBASE_APP_ID"],
    firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"],
    android_artifact_type: "APK",
    android_artifact_path: "../build/app/outputs/flutter-apk/app-release.apk",
    testers: ENV["FIREBASE_TESTERS"],
    release_notes: "Benaa Offline App - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
  )
end
```

### 4. GitHub Actions Workflow
تم إنشاء `.github/workflows/android_fastlane_firebase.yml`

## الـ Secrets المطلوبة في GitHub

يجب إضافة الـ Secrets التالية في GitHub Repository Settings:

1. **FIREBASE_CLI_TOKEN**
   - احصل عليه من خلال تشغيل: `firebase login:ci`

2. **FIREBASE_APP_ID**
   - مثال: `1:323120566751:android:279ba6246486c41d13346a`
   - تجده في Firebase Console > Project Settings > Your apps

3. **FIREBASE_TESTERS** (اختياري)
   - قائمة بـ emails المختبرين مفصولة بفواصل
   - مثال: `test1@example.com, test2@example.com`

## كيفية إضافة Secrets في GitHub

1. اذهب إلى Repository Settings
2. اضغط على **Secrets and variables** > **Actions**
3. اضغط **New repository secret**
4. أضف كل secret على حدة

## التشغيل المحلي (اختياري)

لاختبار البناء محلياً:

```bash
cd android
bundle install
bundle exec fastlane android build_release
```

## ملاحظات مهمة

- الـ Workflow يشتغل تلقائياً عند Push على branch `main`
- تأكد من تفعيل Firebase App Distribution في Firebase Console
- تأكد من إضافة SHA-1 fingerprint في Firebase Console للـ Android App
- الـ APK يتم بناؤه بصيغة Release بدون obfuscation

## استكشاف الأخطاء

### إذا فشل Build بسبب Gradle
1. تأكد من تحديث Flutter SDK: `flutter upgrade`
2. نظف الـ build cache: `flutter clean`
3. تأكد من Java version 17

### إذا فشل Firebase Distribution
1. تحقق من صحة FIREBASE_CLI_TOKEN
2. تحقق من صحة FIREBASE_APP_ID
3. تأكد من تفعيل Firebase App Distribution API

## المراجع

- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [Fastlane Firebase Plugin](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution)
- [GitHub Actions Flutter](https://docs.flutter.dev/deployment/cd#github-actions)
