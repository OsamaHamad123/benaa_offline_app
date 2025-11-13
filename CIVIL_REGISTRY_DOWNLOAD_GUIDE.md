# نظام تحميل قاعدة بيانات السجل المدني

## 📋 نظرة عامة

نظام متكامل لتحميل وإدارة قاعدة بيانات السجل المدني (4.5 GB) مع دعم:
- ✅ تحميل قابل للاستئناف (Resume Support)
- ✅ عرض التقدم الحي (Live Progress)
- ✅ التحقق من سلامة الملف (Checksum Verification)
- ✅ واجهة مستخدم فخمة
- ✅ إدارة ذكية للمساحة

---

## 🏗️ المكونات

### 1. **CivilDatabaseManager**
`lib/core/services/civil_database_manager.dart`

مدير قاعدة البيانات - يدير المسارات، التحقق، والإحصائيات.

```dart
// إنشاء instance
final prefs = await SharedPreferences.getInstance();
final dbManager = CivilDatabaseManager(prefs);

// التحقق من وجود القاعدة
final exists = await dbManager.isDatabaseExists();

// الحصول على الإحصائيات
final stats = await dbManager.getDatabaseStats();

// حذف القاعدة
await dbManager.deleteDatabase();
```

### 2. **CivilDatabaseDownloadNotifier**
`lib/core/services/civil_download_manager.dart`

مدير التحميل مع Riverpod State Management.

```dart
// استخدام Provider
final downloadProgress = ref.watch(civilDatabaseDownloadProvider);

// بدء التحميل
ref.read(civilDatabaseDownloadProvider.notifier).startDownload(
  downloadUrl: 'https://api.benaa.gov.iq/downloads/civil_registry.db',
  dbManager: dbManager,
  expectedChecksum: 'abc123...', // اختياري
);

// إيقاف مؤقت
ref.read(civilDatabaseDownloadProvider.notifier).pauseDownload();

// استئناف
ref.read(civilDatabaseDownloadProvider.notifier).resumeDownload(
  downloadUrl: downloadUrl,
  dbManager: dbManager,
);

// إلغاء
ref.read(civilDatabaseDownloadProvider.notifier).cancelDownload(dbManager);
```

### 3. **CivilDatabaseDownloadPage**
`lib/features/setup/civil_database_download_page.dart`

صفحة UI فخمة لعرض تقدم التحميل.

### 4. **InitialSetupPage**
`lib/features/setup/initial_setup_page.dart`

صفحة الإعداد الأولي مع معلومات شاملة.

### 5. **CivilDatabaseSetupHelper**
`lib/core/helpers/civil_database_setup_helper.dart`

Helper للدمج السهل مع التطبيق.

---

## 🚀 كيفية الاستخدام

### في `main.dart` أو شاشة البداية:

```dart
import 'package:flutter/material.dart';
import 'core/helpers/civil_database_setup_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    // تأخير للـ splash
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      // التحقق من قاعدة البيانات وإظهار صفحة الإعداد إذا لزم
      await CivilDatabaseSetupHelper.checkAndShowSetupIfNeeded(context);
      
      // الانتقال للصفحة الرئيسية
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### في صفحة الإعدادات:

```dart
// زر لفتح صفحة تحميل/إدارة قاعدة البيانات
ElevatedButton(
  onPressed: () {
    CivilDatabaseSetupHelper.openSetupPage(context);
  },
  child: Text('إدارة قاعدة السجل المدني'),
)

// عرض معلومات القاعدة
ElevatedButton(
  onPressed: () {
    CivilDatabaseSetupHelper.showDatabaseInfo(context);
  },
  child: Text('معلومات القاعدة'),
)

// حذف القاعدة
ElevatedButton(
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد'),
        content: Text('هل تريد حذف قاعدة البيانات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await CivilDatabaseSetupHelper.deleteDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف قاعدة البيانات')),
      );
    }
  },
  child: Text('حذف قاعدة البيانات'),
)
```

---

## ⚙️ الإعدادات المطلوبة

### تحديث URL التحميل:

في `lib/core/helpers/civil_database_setup_helper.dart`:

```dart
static const String DOWNLOAD_URL = 
    'https://YOUR_SERVER.com/downloads/civil_registry.db';

// اختياري - للتحقق من سلامة الملف
static const String? EXPECTED_CHECKSUM = 
    'abc123def456...'; // MD5 checksum
```

---

## 📁 هيكل الملفات على الجهاز

```
/storage/emulated/0/Android/data/com.benaa.offline/files/
└── databases/
    ├── civil_registry.db (4.5 GB) - القاعدة الكاملة
    ├── civil_registry.db-shm (ملف مساعد SQLite)
    ├── civil_registry.db-wal (ملف مساعد SQLite)
    └── deltas/ (للتحديثات المستقبلية)
```

---

## 🔗 الربط مع Drift Database

في `lib/data/db/drift_database.dart`:

```dart
// عند فتح التطبيق، ربط قاعدة السجل المدني
Future<void> attachCivilRegistry() async {
  final prefs = await SharedPreferences.getInstance();
  final dbManager = CivilDatabaseManager(prefs);
  
  final civilDbPath = await dbManager.getCivilDatabasePath();
  
  if (await dbManager.isDatabaseExists()) {
    await customStatement(
      "ATTACH DATABASE ? AS civil_registry",
      [civilDbPath],
    );
    
    debugPrint('✅ تم ربط قاعدة السجل المدني');
  } else {
    debugPrint('⚠️ قاعدة السجل المدني غير موجودة');
  }
}

// فصل القاعدة عند الإغلاق
Future<void> detachCivilRegistry() async {
  await customStatement("DETACH DATABASE civil_registry");
}
```

---

## 🎨 تخصيص الواجهة

يمكنك تخصيص الألوان والنصوص في:

1. **InitialSetupPage**: العنوان، الوصف، الأيقونات
2. **CivilDatabaseDownloadPage**: الألوان، الأيقونات، الرسائل

---

## 📊 مراقبة التقدم

```dart
// الاستماع لحالة التحميل
ref.listen(civilDatabaseDownloadProvider, (previous, next) {
  if (next.state == DownloadState.completed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ اكتمل التحميل بنجاح!')),
    );
  } else if (next.state == DownloadState.failed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ فشل التحميل: ${next.error}')),
    );
  }
});
```

---

## 🔄 التحديثات التزايدية (مستقبلاً)

يمكن استخدام **Delta Sync** لتحديث البيانات الجديدة فقط:

```dart
// في civil_registry_sync_service.dart
await syncIncremental(
  lastSyncTime: await dbManager.getLastSyncTime(),
  batchSize: 1000,
);
```

---

## ✅ Checklist للإنتاج

- [ ] تحديث `DOWNLOAD_URL` برابط السيرفر الفعلي
- [ ] إضافة `EXPECTED_CHECKSUM` للتحقق من سلامة الملف
- [ ] اختبار التحميل على شبكة بطيئة
- [ ] اختبار Resume عند قطع الاتصال
- [ ] اختبار مع ملفات كبيرة (4.5 GB)
- [ ] إضافة Analytics لمتابعة نجاح/فشل التحميل
- [ ] إضافة Crash Reporting (Firebase Crashlytics)
- [ ] اختبار على أجهزة مختلفة (Android/iOS)

---

## 🐛 استكشاف الأخطاء

### المشكلة: "مساحة التخزين غير كافية"
**الحل**: تأكد من توفر 5+ GB على الجهاز قبل التحميل.

### المشكلة: "فشل التحقق من سلامة الملف"
**الحل**: 
1. تحقق من صحة `EXPECTED_CHECKSUM`
2. أعد التحميل
3. تحقق من استقرار الاتصال

### المشكلة: "التحميل بطيء جداً"
**الحل**:
1. تحقق من سرعة الإنترنت
2. استخدم شبكة Wi-Fi
3. قسّم الملف إلى أجزاء أصغر

---

## 📝 ملاحظات مهمة

1. **لا تُضمّن** ملف 4.5 GB في `assets/` - سيزيد حجم APK بشكل ضخم
2. **استخدم Wi-Fi** للتحميل الأولي
3. **التحديثات** يجب أن تكون تزايدية (Delta files)
4. **النسخ الاحتياطي** للقاعدة مهم قبل التحديث

---

## 🎯 الخطوات التالية

1. ✅ تطبيق النظام الحالي
2. ⏳ إضافة Delta Sync للتحديثات
3. ⏳ إضافة Compression/Decompression للملفات المضغوطة
4. ⏳ إضافة Background Download (WorkManager)
5. ⏳ إضافة Notification للتقدم

---

تم إنشاء النظام بواسطة **GitHub Copilot** 🤖✨
