# 🔄 دليل المزامنة - Sync System Guide

## 📋 نظرة عامة

نظام المزامنة يدعم وضعين:
1. **Mock API** - سيرفر وهمي محلي للتجربة والتطوير
2. **Real API** - API حقيقي (عند التوفر)

---

## 🎭 Mock API Server

### ما هو؟
سيرفر وهمي يعمل محلياً على جهازك، يحفظ البيانات في `SharedPreferences` ويحاكي سلوك API حقيقي.

### الميزات:
- ✅ محاكاة تأخير الشبكة (Network Delay)
- ✅ محاكاة أخطاء عشوائية
- ✅ اكتشاف التعارضات (Conflict Detection)
- ✅ حفظ دائم للبيانات
- ✅ لا يحتاج اتصال بالإنترنت

### كيفية الاستخدام:

#### 1. تفعيل Mock API
```dart
// في الإعدادات
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('use_mock_api', true);
```

أو من واجهة الإعدادات:
- افتح **صفحة إعدادات المزامنة**
- فعّل **"استخدام Mock API"**
- احفظ الإعدادات

#### 2. إضافة بيانات تجريبية
```dart
final apiClient = ref.read(apiClientWithMockProvider).value;
await apiClient.seedMockTestData();
```

أو من الواجهة:
- اضغط **"إضافة بيانات تجريبية"** في صفحة الإعدادات

#### 3. تجربة المزامنة
```dart
// افتح صفحة المزامنة واضغط "مزامنة الآن"
// أو
final syncManager = ref.read(syncManagerProvider);
await syncManager.syncAll();
```

---

## ⚙️ إعدادات Mock Server

### تأخير الشبكة (Network Delay)
- **تفعيل/تعطيل**: يحاكي زمن الاستجابة الواقعي
- **التأخير الأدنى**: 0 - 3000 ms (الافتراضي: 500 ms)
- **التأخير الأقصى**: 0 - 5000 ms (الافتراضي: 2000 ms)

```dart
apiClient.configureMockServer(
  simulateNetworkDelay: true,
  minDelayMs: 500,
  maxDelayMs: 2000,
);
```

### نسبة الأخطاء (Error Rate)
- **النطاق**: 0% - 50%
- **الافتراضي**: 10%
- يحاكي فشل الطلبات بشكل عشوائي

```dart
apiClient.configureMockServer(
  errorRate: 0.1, // 10%
);
```

### محاكاة التعارضات (Conflict Simulation)
- **الوصف**: يكتشف إذا السيرفر عنده نسخة أحدث
- **متى يحدث**: عند المزامنة إذا تم تعديل نفس السجل محلياً وعلى السيرفر

```dart
apiClient.configureMockServer(
  simulateConflicts: true,
);
```

---

## 🔄 سيناريوهات التجربة

### السيناريو 1: مزامنة بيانات جديدة
```
1. أضف مستفيد جديد محلياً
2. افتح صفحة المزامنة
3. اضغط "مزامنة الآن"
4. شاهد progress bar والحالة
5. تحقق من نجاح المزامنة
```

### السيناريو 2: تعارض البيانات
```
1. أضف بيانات تجريبية للسيرفر الوهمي
2. سنكرن بيانات محلية قديمة لنفس المستفيد
3. سيظهر تعارض (Conflict)
4. اختر كيف تحل التعارض:
   - استخدم البيانات المحلية
   - استخدم بيانات السيرفر
   - دمج البيانات يدوياً
```

### السيناريو 3: محاكاة فشل الشبكة
```
1. ارفع نسبة الأخطاء إلى 50%
2. حاول المزامنة
3. بعض الطلبات ستفشل
4. شاهد Retry mechanism
5. راقب exponential backoff
```

### السيناريو 4: جلب بيانات من السيرفر
```
1. أضف بيانات تجريبية للسيرفر
2. اسحب للأسفل (Pull to Refresh)
3. البيانات الجديدة ستنزل للجهاز
```

---

## 🧪 اختبارات يدوية

### ✅ Checklist للتجربة

- [ ] إضافة مستفيد → مزامنة → تحقق من الـ server_id
- [ ] تعديل مستفيد → مزامنة → تحقق من التحديث
- [ ] حذف مستفيد → مزامنة → تحقق من الحذف
- [ ] إضافة مرفقات → مزامنة → تحقق من رفع الملفات
- [ ] تجربة تأخير الشبكة (500ms - 2000ms)
- [ ] تجربة فشل عشوائي (10% error rate)
- [ ] محاكاة تعارض → حل التعارض
- [ ] جلب بيانات من السيرفر
- [ ] مسح بيانات السيرفر → إعادة المزامنة

---

## 📊 مراقبة المزامنة

### من الكود:
```dart
// راقب حالة المزامنة
ref.listen(syncStatusProvider, (previous, next) {
  next.when(
    data: (status) {
      print('Syncing: ${status.isSyncing}');
      print('Progress: ${status.progress}');
      print('Current: ${status.currentEntity}');
      if (status.lastError != null) {
        print('Error: ${status.lastError}');
      }
    },
    loading: () => print('Loading sync status...'),
    error: (error, stack) => print('Error: $error'),
  );
});
```

### من الواجهة:
- افتح **صفحة المزامنة**
- شاهد:
  - Progress indicator
  - عدد العناصر المتبقية
  - الأخطاء (إن وجدت)
  - آخر مزامنة ناجحة

---

## 🔧 استكشاف الأخطاء

### المشكلة: "Mock server not initialized"
**الحل**: تأكد من تفعيل Mock API في الإعدادات

### المشكلة: التعارضات لا تظهر
**الحل**: فعّل "محاكاة التعارضات" في الإعدادات

### المشكلة: المزامنة سريعة جداً
**الحل**: فعّل "محاكاة تأخير الشبكة"

### المشكلة: كل الطلبات تنجح
**الحل**: ارفع "نسبة الأخطاء" لتجربة الفشل

---

## 🚀 الانتقال للـ Real API

عندما يتوفر API حقيقي:

1. **عطّل Mock API**:
```dart
await prefs.setBool('use_mock_api', false);
```

2. **اضبط API URL** في `app_config.dart`:
```dart
apiBaseUrl: 'https://your-api-server.com/api/v1'
```

3. **أعد تشغيل التطبيق**

4. **كل شيء سيعمل تلقائياً!** 🎉

---

## 📝 ملاحظات مهمة

1. **بيانات Mock Server محلية فقط**: محفوظة في `SharedPreferences`، تبقى حتى بعد إعادة التشغيل

2. **الانتقال للـ Real API سهل**: نفس الكود، فقط بدّل الإعداد

3. **اختبر كل السيناريوهات**: استخدم Mock Server لاختبار جميع الحالات قبل الإنتاج

4. **التعارضات واقعية**: النظام يحاكي تعارضات حقيقية ممكن تحصل على سيرفر حقيقي

---

## 🎯 أمثلة كود

### مثال 1: مزامنة يدوية
```dart
ElevatedButton(
  onPressed: () async {
    final syncManager = ref.read(syncManagerProvider);
    await syncManager.syncAll();
  },
  child: const Text('مزامنة الآن'),
)
```

### مثال 2: عرض حالة المزامنة
```dart
Consumer(
  builder: (context, ref, child) {
    final syncStatus = ref.watch(syncStatusProvider);
    
    return syncStatus.when(
      data: (status) {
        if (status.isSyncing) {
          return CircularProgressIndicator(
            value: status.progress,
          );
        }
        return const Icon(Icons.check_circle, color: Colors.green);
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Icon(Icons.error, color: Colors.red),
    );
  },
)
```

### مثال 3: إعدادات متقدمة
```dart
// سرّع المزامنة للتطوير
apiClient.configureMockServer(
  simulateNetworkDelay: false,
  errorRate: 0,
  simulateConflicts: false,
);

// زيادة الواقعية للاختبار
apiClient.configureMockServer(
  simulateNetworkDelay: true,
  minDelayMs: 1000,
  maxDelayMs: 3000,
  errorRate: 0.2, // 20% فشل
  simulateConflicts: true,
);
```

---

## 📚 مصادر إضافية

- **الكود**: `lib/core/network/mock_api_server.dart`
- **الإعدادات**: `lib/features/sync/sync_settings_page.dart`
- **المزامنة**: `lib/core/sync/sync_manager.dart`

---

**استمتع بالتجربة! 🎉**
