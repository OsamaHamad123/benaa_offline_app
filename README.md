# Benaa Offline App# benaa_offline_app



تطبيق Flutter للعمل الميداني مع قدرات كاملة للعمل أوفلاين، مع مزامنة دورية وقاعدة بيانات مشفرة.A new Flutter project.



## المميزات## Getting Started



- ✅ عمل كامل بدون إنترنت أثناء العمل الميدانيThis project is a starting point for a Flutter application.

- ✅ قاعدة بيانات SQLite مشفرة عبر SQLCipher

- ✅ مزامنة تلقائية ودفعات عند توفر الإنترنتA few resources to get you started if this is your first Flutter project:

- ✅ بحث سريع بالرقم الوطني/رقم الملف (< 200ms)

- ✅ بحث نصي كامل FTS5 للأسماء (< 800ms على 100k سجل)- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- ✅ تشفير المرفقات (صور وPDF)- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- ✅ رفع المرفقات مجزأة (512KB لكل جزء)

- ✅ توليد تقارير PDF وExcelFor help getting started with Flutter development, view the

- ✅ مصادقة JWT[online documentation](https://docs.flutter.dev/), which offers tutorials,

samples, guidance on mobile development, and a full API reference.

## الإعداد السريع

### 1. تثبيت التبعيات

```bash
flutter pub get
```

### 2. توليد الكود

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. تشغيل التطبيق

```bash
flutter run -d windows
```

## البنية التقنية

- **Drift + SQLCipher**: قاعدة بيانات مشفرة
- **Riverpod**: إدارة الحالة
- **GoRouter**: التنقل
- **Dio**: طلبات HTTP
- **FlutterSecureStorage**: تخزين آمن

## للمزيد من المعلومات

راجع الملفات في المجلد `lib/` لرؤية البنية الكاملة.

## الأوامر المهمة

```bash
# توليد الكود
dart run build_runner build --delete-conflicting-outputs

# تشغيل التطبيق
flutter run -d windows

# فحص التطبيق
flutter analyze
```
