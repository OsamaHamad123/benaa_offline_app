# 📋 دليل إعداد نظام المزامنة الكامل

تم إنشاء جميع الملفات المطلوبة لنظام المزامنة! 🎉

---

## ✅ الملفات التي تم إنشاؤها

### 1. **الإعدادات والتكوين**
- ✅ `lib/core/config/api_config.dart` - إعدادات الـ API وروابط السيرفر
- ✅ `lib/core/storage/secure_storage.dart` - تخزين آمن للبيانات الحساسة

### 2. **DTOs (Data Transfer Objects)**
- ✅ `lib/data/dto/sync_dto.dart` - جميع ال DTOs للمزامنة والمصادقة

### 3. **خدمات الشبكة**
- ✅ `lib/data/api/sync_api_client.dart` - عميل API للاتصال بالسيرفر
- ✅ `lib/data/services/auth_service.dart` - خدمة المصادقة

### 4. **إدارة المزامنة**
- ✅ `lib/core/sync/new_sync_manager.dart` - مدير المزامنة الرئيسي
- ✅ `lib/core/sync/background_sync_worker.dart` - موجود مسبقاً (محدّث)

### 5. **قاعدة البيانات**
- ✅ جداول المزامنة موجودة مسبقاً (`sync_queue`, `sync_metadata`)

---

## 🚀 خطوات التشغيل

### **الخطوة 1: تشغيل build_runner**

```powershell
dart run build_runner build --delete-conflicting-outputs
```

✅ **تم بالفعل!** الملفات المولدة جاهزة.

---

### **الخطوة 2: إضافة Dependencies المفقودة**

افتح `pubspec.yaml` وتأكد من وجود:

```yaml
dependencies:
  # موجود بالفعل ✅
  flutter_secure_storage: ^9.2.2
  dio: ^5.7.0
  connectivity_plus: ^6.1.1
  workmanager: ^0.9.0+3
  
  # إضافة هذا إذا لم يكن موجود:
  device_info_plus: ^10.1.2
  json_annotation: ^4.9.0  # موجود ✅

dev_dependencies:
  json_serializable: ^6.9.2  # موجود ✅
  build_runner: ^2.4.13      # موجود ✅
```

إذا أضفت `device_info_plus`، شغّل:

```powershell
flutter pub get
```

---

### **الخطوة 3: إعداد ApiConfig**

افتح `lib/core/config/api_config.dart` وحدّث:

```dart
static const String defaultBaseUrl = 'https://your-actual-server.com';
```

**ضع رابط السيرفر الفعلي هنا!** 👆

---

### **الخطوة 4: إنشاء LoginScreen**

سأنشئ لك واجهة تسجيل الدخول الآن...

---

## 📱 كيفية الاستخدام

### **1. في main.dart - التهيئة**

```dart
import 'package:flutter/material.dart';
import 'core/storage/secure_storage.dart';
import 'data/services/auth_service.dart';
import 'core/sync/new_sync_manager.dart';
import 'core/sync/background_sync_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الخدمات
  final authService = AuthService();
  final storage = SecureStorage();
  
  // التحقق من تسجيل الدخول
  final isLoggedIn = await storage.isLoggedIn();
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق بناء',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      // ابدأ بشاشة تسجيل الدخول إذا لم يكن مسجلاً
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
```

---

### **2. في LoginScreen - تسجيل الدخول**

```dart
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../core/sync/new_sync_manager.dart';
import '../../core/sync/background_sync_worker.dart';
import '../../data/db/drift_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverUrlController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;
  bool _showServerUrl = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      serverUrl: _showServerUrl ? _serverUrlController.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      // تهيئة المزامنة بعد تسجيل الدخول
      final database = AppDatabase(); // أو احصل عليها من Provider
      await NewSyncManager().initialize(database);
      await BackgroundSyncWorker.initialize();

      // الانتقال للشاشة الرئيسية
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'فشل تسجيل الدخول'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(
                    Icons.apartment,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'تطبيق بناء',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة السر',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة السر';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Server URL Toggle
                  CheckboxListTile(
                    title: const Text('استخدام رابط سيرفر مخصص'),
                    value: _showServerUrl,
                    onChanged: (value) {
                      setState(() => _showServerUrl = value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Server URL Field
                  if (_showServerUrl) ...[
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: 'رابط السيرفر',
                        prefixIcon: Icon(Icons.cloud),
                        border: OutlineInputBorder(),
                        hintText: 'https://api.example.com',
                      ),
                      validator: (value) {
                        if (_showServerUrl && (value == null || value.isEmpty)) {
                          return 'الرجاء إدخال رابط السيرفر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }
}
```

---

### **3. إضافة تغيير معلق عند الإنشاء/التعديل**

```dart
// مثال: عند إنشاء مستفيد جديد
final beneficiary = BeneficiaryModel(...);

// حفظ في قاعدة البيانات المحلية
await database.beneficiariesDao.createBeneficiary(beneficiary);

// إضافة للقائمة المعلقة
await NewSyncManager().addPendingChange(
  entityType: 'beneficiary',
  entityId: beneficiary.id,
  operation: 'create',
  data: beneficiary.toJson(),
  priority: 9, // عالي
);
```

---

### **4. المزامنة اليدوية**

```dart
// في أي مكان في التطبيق
ElevatedButton(
  onPressed: () async {
    final success = await NewSyncManager().syncAll();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ تمت المزامنة بنجاح' : '❌ فشلت المزامنة',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  },
  child: const Text('مزامنة الآن'),
)
```

---

### **5. عرض حالة المزامنة**

```dart
// في HomePage أو أي صفحة
ListenableBuilder(
  listenable: NewSyncManager().statusNotifier,
  builder: (context, _) {
    final notifier = NewSyncManager().statusNotifier;
    
    return Card(
      child: ListTile(
        leading: Icon(
          notifier.isSyncing
              ? Icons.sync
              : Icons.cloud_done,
          color: notifier.error != null
              ? Colors.red
              : Colors.green,
        ),
        title: Text(notifier.statusText),
        subtitle: notifier.pendingItems > 0
            ? Text('${notifier.pendingItems} تغيير معلق')
            : null,
        trailing: notifier.isSyncing
            ? const CircularProgressIndicator()
            : null,
      ),
    );
  },
)
```

---

## 🔐 ما الذي يجب عليك فعله الآن؟

### **1. إعداد السيرفر**

على السيرفر الخاص بك، يجب أن يكون لديك:

#### **POST /api/auth/login**
```json
// Request
{
  "email": "user@example.com",
  "password": "password123",
  "deviceId": "device_12345"
}

// Response (Success)
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1...",
  "refreshToken": "refresh_token_here",
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "أحمد محمد",
    "role": "admin"
  }
}

// Response (Failure)
{
  "success": false,
  "message": "البريد الإلكتروني أو كلمة السر غير صحيحة",
  "errorCode": "INVALID_CREDENTIALS"
}
```

#### **POST /api/sync**
```json
// Request
{
  "lastSyncTime": "2024-11-20T10:30:00Z",
  "pendingChanges": [
    {
      "entityType": "beneficiary",
      "entityId": "ben_123",
      "operation": "create",
      "data": { ... },
      "timestamp": "2024-11-20T11:00:00Z",
      "priority": 9
    }
  ],
  "deviceInfo": {
    "deviceId": "device_12345",
    "appVersion": "1.0.0",
    "platform": "android"
  },
  "userId": "user_123"
}

// Response
{
  "success": true,
  "updatedData": [
    {
      "entityType": "beneficiary",
      "id": "ben_456",
      "data": { ... },
      "updatedAt": "2024-11-20T11:05:00Z"
    }
  ],
  "deletedIds": ["ben_789"],
  "serverTimestamp": "2024-11-20T11:10:00Z",
  "failedChanges": [],
  "stats": {
    "receivedCount": 1,
    "sentCount": 1,
    "deletedCount": 1,
    "failedCount": 0
  }
}
```

---

### **2. اختبار النظام**

1. **شغّل التطبيق**:
   ```powershell
   flutter run
   ```

2. **سجّل الدخول** باستخدام بيانات حقيقية

3. **أنشئ مستفيد جديد** - سيُضاف للقائمة المعلقة

4. **اضغط "مزامنة"** - سترى الطلبات في الـ console

5. **تحقق من الـ logs** في Debug Console

---

## 🎯 الخطوات التالية

- [ ] تحديث `ApiConfig.defaultBaseUrl` برابط السيرفر الفعلي
- [ ] إضافة `device_info_plus` dependency إذا لزم الأمر
- [ ] تشغيل `flutter pub get`
- [ ] تنفيذ API endpoints على السيرفر
- [ ] اختبار تسجيل الدخول
- [ ] اختبار المزامنة
- [ ] إضافة معالجة التعارضات (Conflict Resolution)
- [ ] تنفيذ Offline-First Strategy

---

## 📞 إذا واجهت مشاكل

1. **تأكد من:**
   - رابط السيرفر صحيح
   - السيرفر يعمل ويستجيب
   - بيانات تسجيل الدخول صحيحة

2. **تحقق من الـ logs:**
   - افتح Debug Console
   - ابحث عن رسائل `DebugLogger`

3. **الأخطاء الشائعة:**
   - `UNAUTHORIZED`: تحقق من الـ token
   - `CONNECTION_ERROR`: تحقق من الاتصال بالإنترنت
   - `TIMEOUT`: زد من قيمة timeout في `ApiConfig`

---

🎉 **النظام جاهز! جربه الآن!**
