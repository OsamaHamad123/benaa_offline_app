# Notifications — Audit & Enable Report

**Date:** 2025  
**Phase:** 2 of 5  
**Status:** ✅ Fixed (pending route navigation)

---

## Audit Summary

### ما كان موجوداً ✅

| المكوّن                                        | الملف                                                | الحالة  |
| ---------------------------------------------- | ---------------------------------------------------- | ------- |
| Local Notifications setup                      | `lib/core/notifications/notifications_service.dart`  | ✅ كامل |
| `showNotification()`, `scheduleNotification()` | نفس الملف                                            | ✅      |
| `scheduleVisitReminder()`                      | نفس الملف                                            | ✅      |
| `scheduleDocumentExpiryReminder()`             | نفس الملف                                            | ✅      |
| In-app notification stream                     | `lib/core/notifications/notification_service.dart`   | ✅      |
| Notifications provider                         | `lib/core/notifications/notifications_provider.dart` | ✅      |
| Smart notifications page                       | `/kafalat/notifications`                             | ✅      |

### المشكلة المكتشفة ❌

```dart
// قبل الإصلاح — دالة فارغة تماماً
static void _onNotificationTap(NotificationResponse response) {
  // TODO: Handle notification tap - navigate to relevant screen
  final payload = response.payload;
  if (payload != null) {
    // Navigate based on payload
    // Example: router.push('/beneficiary/$id')
  }
}
```

---

## الحل المُطبَّق

### نمط "Pending Route"

نظراً لأن `NotificationsService` هو singleton ثابت بلا `BuildContext`، وأن GoRouter لا يوجد له `navigatorKey` معرّف عالمياً، استخدمنا نمط **pending route**:

```dart
// في notifications_service.dart:
static String? _pendingRoute;

static String? consumePendingRoute() {
  final route = _pendingRoute;
  _pendingRoute = null;
  return route;
}

static void _onNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return;

  String route;
  if (payload.startsWith('route:')) {
    route = payload.replaceFirst('route:', '');
  } else if (payload.startsWith('/')) {
    route = payload;
  } else {
    route = '/';
  }
  _pendingRoute = route;
}
```

### معالجة في app.dart

```dart
// في BenaaApp.build():
WidgetsBinding.instance.addPostFrameCallback((_) {
  final pendingRoute = NotificationsService.consumePendingRoute();
  if (pendingRoute != null && pendingRoute.isNotEmpty) {
    router.go(pendingRoute);
  }
});
```

---

## كيفية استخدام Payload في الإشعارات

```dart
// إشعار يوجّه لصفحة المستفيد
await NotificationsService.showNotification(
  id: 1,
  title: 'تذكير زيارة',
  body: 'موعد زيارة أحمد محمد غداً',
  payload: '/visits/123',  // أو: 'route:/visits/123'
);

// إشعار يوجّه لصفحة الإشعارات
await NotificationsService.showNotification(
  id: 2,
  title: 'تنبيه كفالة',
  body: 'كفالة منتهية الصلاحية',
  payload: '/kafalat/notifications',
);
```

---

## ملاحظات

- نمط pending route يعمل عند فتح التطبيق من إشعار (cold start)
- عند فتح التطبيق من الخلفية يعمل مباشرة عبر `addPostFrameCallback`
- إضافة `navigatorKey` عالمي لـ GoRouter تتيح navigation أسرع — ممكن كتحسين مستقبلي
