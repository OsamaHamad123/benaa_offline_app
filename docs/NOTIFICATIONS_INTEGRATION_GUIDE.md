# 🔔 دليل تكامل نظام الإشعارات
## Notifications Integration Guide

---

## 📋 المتطلبات

### 1. Android Configuration

في ملف `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- إضافة صلاحيات الإشعارات -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application>
        <!-- إضافة receiver للإشعارات -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

### 2. iOS Configuration

في ملف `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

---

## 🚀 الاستخدام

### 1. التهيئة في main.dart

```dart
import 'package:benaa_offline_app/core/notifications/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الإشعارات
  await NotificationsService.initialize();
  
  // طلب الصلاحيات
  await NotificationsService.requestPermissions();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. استخدام Provider في Widget

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/notifications/notifications.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsStateProvider);
    final notificationsNotifier = ref.read(notificationsStateProvider.notifier);
    
    return Scaffold(
      body: Column(
        children: [
          // عرض حالة التهيئة
          if (notificationsState.isInitializing)
            CircularProgressIndicator(),
            
          // عرض عدد الإشعارات المجدولة
          Text('إشعارات مجدولة: ${notificationsState.scheduledCount}'),
          
          // زر لإرسال إشعار فوري
          ElevatedButton(
            onPressed: () async {
              await NotificationsService.showNotification(
                id: 1,
                title: 'عنوان الإشعار',
                body: 'نص الإشعار',
              );
            },
            child: Text('إرسال إشعار'),
          ),
        ],
      ),
    );
  }
}
```

### 3. جدولة إشعار بزيارة

```dart
// عند إنشاء أو تعديل زيارة
await ref.read(notificationsStateProvider.notifier).scheduleVisitReminder(
  beneficiaryId: beneficiary.id,
  beneficiaryName: beneficiary.fullName,
  visitDate: visit.scheduledDate,
);
```

### 4. إشعار بانتهاء مستند

```dart
// عند إضافة مستند أو تحديثه
if (document.expiryDate != null) {
  await ref.read(notificationsStateProvider.notifier).scheduleDocumentExpiryReminder(
    beneficiaryId: beneficiary.id,
    beneficiaryName: beneficiary.fullName,
    documentType: document.type,
    expiryDate: document.expiryDate!,
  );
}
```

### 5. إشعار بانتهاء كفالة

```dart
// عند إنشاء كفالة جديدة
await ref.read(notificationsStateProvider.notifier).scheduleSponsorshipExpiryReminder(
  sponsorshipId: sponsorship.id,
  beneficiaryName: beneficiary.fullName,
  endDate: sponsorship.endDate,
);
```

---

## 📱 أمثلة الاستخدام في الصفحات

### في صفحة إضافة زيارة (Add Visit Page)

```dart
class AddVisitPage extends ConsumerStatefulWidget {
  @override
  _AddVisitPageState createState() => _AddVisitPageState();
}

class _AddVisitPageState extends ConsumerState<AddVisitPage> {
  DateTime? _selectedDate;
  
  Future<void> _saveVisit() async {
    // حفظ الزيارة في قاعدة البيانات
    final visit = await ref.read(visitsProvider.notifier).addVisit(
      beneficiaryId: widget.beneficiaryId,
      visitDate: _selectedDate!,
    );
    
    // جدولة إشعار تذكير
    await ref.read(notificationsStateProvider.notifier).scheduleVisitReminder(
      beneficiaryId: widget.beneficiaryId,
      beneficiaryName: widget.beneficiaryName,
      visitDate: _selectedDate!,
    );
    
    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الزيارة وجدولة التذكير')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة زيارة')),
      body: Column(
        children: [
          // Date picker...
          ElevatedButton(
            onPressed: _saveVisit,
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
```

### في صفحة إضافة كفالة (Add Sponsorship Page)

```dart
class AddSponsorshipPage extends ConsumerStatefulWidget {
  @override
  _AddSponsorshipPageState createState() => _AddSponsorshipPageState();
}

class _AddSponsorshipPageState extends ConsumerState<AddSponsorshipPage> {
  DateTime? _endDate;
  
  Future<void> _saveSponsorship() async {
    // حفظ الكفالة
    final sponsorship = await ref.read(sponsorshipsProvider.notifier).addSponsorship(
      beneficiaryId: widget.beneficiaryId,
      endDate: _endDate!,
    );
    
    // جدولة إشعار تذكير بانتهاء الكفالة
    await ref.read(notificationsStateProvider.notifier).scheduleSponsorshipExpiryReminder(
      sponsorshipId: sponsorship.id,
      beneficiaryName: widget.beneficiaryName,
      endDate: _endDate!,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الكفالة وجدولة التذكير')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // UI implementation...
    return Scaffold(/* ... */);
  }
}
```

### في SyncService

```dart
class SyncService {
  final Ref ref;
  
  SyncService(this.ref);
  
  Future<void> syncData() async {
    try {
      // عملية المزامنة...
      final result = await _performSync();
      
      // إشعار نجاح المزامنة
      await NotificationsService.showSyncSuccessNotification(
        itemsSynced: result.syncedCount,
      );
    } catch (e) {
      // إشعار فشل المزامنة
      await NotificationsService.showSyncFailureNotification(
        error: e.toString(),
      );
    }
  }
}
```

### في BackupService

```dart
class BackupService {
  Future<void> performBackup() async {
    try {
      // عملية النسخ الاحتياطي...
      await _createBackup();
      
      // إشعار نجاح النسخ
      await NotificationsService.showBackupSuccessNotification();
    } catch (e) {
      // إشعار فشل النسخ
      await NotificationsService.showBackupFailureNotification(
        error: e.toString(),
      );
    }
  }
}
```

---

## 🎯 صفحة إعدادات الإشعارات

```dart
class NotificationsSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsStateProvider);
    final notificationsNotifier = ref.read(notificationsStateProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الإشعارات'),
      ),
      body: ListView(
        children: [
          // حالة التهيئة
          ListTile(
            leading: Icon(
              notificationsState.isInitialized 
                ? Icons.check_circle 
                : Icons.error,
              color: notificationsState.isInitialized 
                ? Colors.green 
                : Colors.red,
            ),
            title: Text('حالة الإشعارات'),
            subtitle: Text(
              notificationsState.isInitialized 
                ? 'مفعّلة' 
                : 'غير مفعّلة',
            ),
          ),
          
          Divider(),
          
          // الصلاحيات
          SwitchListTile(
            title: Text('تفعيل الإشعارات'),
            subtitle: Text('السماح بإرسال إشعارات التطبيق'),
            value: notificationsState.hasPermissions,
            onChanged: (value) async {
              if (value) {
                await notificationsNotifier.requestPermissions();
              }
            },
          ),
          
          Divider(),
          
          // عدد الإشعارات المجدولة
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('الإشعارات المجدولة'),
            trailing: Chip(
              label: Text('${notificationsState.scheduledCount}'),
            ),
          ),
          
          Divider(),
          
          // إلغاء جميع الإشعارات
          ListTile(
            leading: Icon(Icons.clear_all, color: Colors.red),
            title: Text('إلغاء جميع الإشعارات'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('تأكيد'),
                  content: Text('هل تريد إلغاء جميع الإشعارات المجدولة؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('نعم'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await notificationsNotifier.cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إلغاء جميع الإشعارات')),
                );
              }
            },
          ),
          
          // اختبار الإشعارات
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('اختبار الإشعارات'),
            onTap: () async {
              await NotificationsService.showNotification(
                id: DateTime.now().millisecondsSinceEpoch,
                title: 'إشعار تجريبي',
                body: 'هذا إشعار تجريبي من تطبيق بناء',
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 الأخطاء الشائعة وحلولها

### 1. الإشعارات لا تعمل على Android 13+

**المشكلة:** Android 13 يتطلب صلاحيات جديدة للإشعارات

**الحل:**
```dart
// طلب الصلاحيات في بداية التطبيق
final granted = await NotificationsService.requestPermissions();
if (!granted) {
  // إظهار رسالة للمستخدم
  showDialog(/* ... */);
}
```

### 2. الإشعارات المجدولة لا تظهر

**المشكلة:** قد يكون الـ timezone غير مهيأ

**الحل:**
```dart
// التأكد من تهيئة timezone
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // مهم!
  await NotificationsService.initialize();
  runApp(MyApp());
}
```

### 3. الإشعارات تختفي بعد إعادة تشغيل الجهاز

**المشكلة:** يجب إضافة BOOT_COMPLETED receiver

**الحل:** راجع قسم Android Configuration أعلاه

---

## ✅ Checklist للتكامل

- [ ] إضافة Permissions في AndroidManifest.xml
- [ ] إضافة Permissions في Info.plist (iOS)
- [ ] تهيئة NotificationsService في main.dart
- [ ] طلب صلاحيات الإشعارات
- [ ] دمج Provider في ProviderScope
- [ ] إضافة إشعارات الزيارات
- [ ] إضافة إشعارات المستندات
- [ ] إضافة إشعارات الكفالات
- [ ] إضافة إشعارات المزامنة
- [ ] إضافة إشعارات النسخ الاحتياطي
- [ ] إنشاء صفحة إعدادات الإشعارات
- [ ] اختبار الإشعارات على Android
- [ ] اختبار الإشعارات على iOS

---

## 📝 ملاحظات

1. **الإشعارات المجدولة**: يتم جدولتها قبل الموعد بفترة محددة (1 يوم للزيارات، 7 أيام للمستندات، 14 يوم للكفالات)

2. **IDs الإشعارات**: 
   - 1000-1999: إشعارات الزيارات
   - 2000-2999: إشعارات المستندات
   - 3000-3999: إشعارات الكفالات
   - 9996-9999: إشعارات النظام

3. **Payload**: كل إشعار يحمل payload لتحديد الإجراء عند الضغط عليه

4. **Background Work**: للعمل المجدول في الخلفية، استخدم `workmanager` package

---

Created: 20 ديسمبر 2025  
Version: 1.0.0
