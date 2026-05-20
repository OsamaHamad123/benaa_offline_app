# Firebase Setup - Benaa Offline App

## 1) تفعيل الخدمات

- أنشئ Firebase Project.
- فعّل Authentication (Email/Password).
- فعّل Cloud Firestore.
- فعّل Cloud Storage.

## 2) ربط Flutter بالتطبيق

- تأكد من وجود:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_storage`
- أنشئ ملفات إعداد Firebase للمنصات المستهدفة (Android/iOS/Web/Windows عند الحاجة).

## 3) نشر قواعد الأمان

- Firestore rules من الملف:
  - `firestore.rules`
- Storage rules من الملف:
  - `storage.rules`

مثال أوامر (Firebase CLI):

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

## 4) الأدوار (Admin vs User)

- التطبيق يعتمد على Custom Claims في Firebase Auth token:
  - `admin == true` أو `role == "admin"`.
- المستخدم العادي:
  - create/update beneficiaries + visits + attachments metadata.
- الأدمن:
  - إدارة taxonomies + associations.

## 5) التحقق السريع قبل الديمو

- تسجيل دخول مستخدم عادي يعمل.
- إنشاء مستفيد محليًا بدون إنترنت يعمل.
- المزامنة بعد عودة الإنترنت تعمل.
- رفع مرفق صورة/PDF أقل من 10MB يعمل.
- ملف غير مسموح أو أكبر من 10MB يتم رفضه.
