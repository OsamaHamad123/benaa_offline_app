# نظام المزامنة (Sync System)

## نظرة عامة

نظام المزامنة مصمم للعمل في بيئة offline-first حيث يتم تسجيل جميع التعديلات محلياً أولاً، ثم مزامنتها مع السيرفر عند توفر الإنترنت.

## المكونات الرئيسية

### 1. جدول طابور المزامنة (Sync Queue Table)

```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  entity TEXT NOT NULL,           -- 'beneficiary', 'visit', 'attachment'
  entity_id TEXT NOT NULL,         -- معرف السجل المحلي
  operation TEXT NOT NULL,         -- 'create', 'update', 'delete', 'upload'
  payload TEXT NOT NULL,           -- JSON data
  priority INTEGER DEFAULT 0,      -- أولوية المزامنة
  attempts INTEGER DEFAULT 0,      -- عدد محاولات المزامنة
  last_error TEXT,                 -- آخر خطأ حدث
  created_at DATETIME NOT NULL,    -- تاريخ الإضافة للطابور
  scheduled_at DATETIME            -- موعد إعادة المحاولة
);
```

### 2. أولويات المزامنة

| الأولوية | النوع | الوصف |
|----------|-------|-------|
| 10 | Authentication | تسجيل دخول/خروج |
| 9 | Beneficiary | المستفيدين |
| 8 | Visit | الزيارات |
| 7 | Attachment | المرفقات |
| 6 | Taxonomy | التصنيفات |

### 3. حالات المزامنة (Sync States)

- **pending**: في انتظار المزامنة
- **syncing**: جاري المزامنة الآن
- **synced**: تمت المزامنة بنجاح
- **failed**: فشلت المزامنة

## آلية العمل

### 1. إضافة للطابور

عند إنشاء أو تعديل أي سجل:

```dart
// مثال: إضافة مستفيد جديد
await db.insertBeneficiary(beneficiary);

// إضافة للطابور
await syncManager.queueBeneficiary(
  beneficiary.id,
  'create',
  beneficiary.toJson(),
);
```

### 2. المزامنة التلقائية

- تعمل كل 5 دقائق تلقائياً
- تتحقق من الاتصال بالإنترنت أولاً
- تجلب العناصر مرتبة حسب الأولوية

```dart
// تبدأ تلقائياً عند إنشاء SyncManager
final syncManager = SyncManager(db);
```

### 3. المزامنة اليدوية

```dart
// مزامنة فورية
await syncManager.syncAll();
```

### 4. معالجة الأخطاء

- **Exponential Backoff**: تأخير متزايد بين المحاولات
- **Maximum Attempts**: حد أقصى للمحاولات
- **Error Logging**: تسجيل الأخطاء في الطابور

```dart
// عند فشل المزامنة
scheduledAt = now + (5 minutes × attempts)
```

## حقول المزامنة في الجداول

### Beneficiaries

```dart
TextColumn get serverId => text().nullable();      // ID من السيرفر
DateTimeColumn get lastSyncedAt => dateTime().nullable();
```

### Visits

```dart
TextColumn get serverId => text().nullable();
DateTimeColumn get lastSyncedAt => dateTime().nullable();
```

### Attachments

```dart
TextColumn get serverUrl => text().nullable();     // URL على السيرفر
DateTimeColumn get lastSyncedAt => dateTime().nullable();
```

## استخدام في واجهة المستخدم

### 1. شريط حالة المزامنة

```dart
Scaffold(
  body: Column(
    children: [
      SyncStatusBar(), // يظهر عند المزامنة أو الأخطاء
      // ... باقي المحتوى
    ],
  ),
)
```

### 2. زر المزامنة

```dart
AppBar(
  actions: [
    SyncButton(), // يعرض عدد العناصر في الانتظار
  ],
)
```

### 3. شاشة تفاصيل المزامنة

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => SyncDetailsPage(),
  ),
);
```

## مراقبة حالة المزامنة

```dart
// استخدام Provider للمراقبة
final syncStatus = ref.watch(syncStatusProvider);

syncStatus.when(
  data: (status) {
    if (status.isSyncing) {
      // عرض مؤشر التقدم
      return CircularProgressIndicator(
        value: status.progress,
      );
    }
    
    if (status.lastError != null) {
      // عرض رسالة خطأ
      return Text('Error: ${status.lastError}');
    }
    
    // كل شيء على ما يرام
    return Icon(Icons.check_circle);
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

## سيناريوهات الاستخدام

### سيناريو 1: العمل بدون إنترنت

1. الموظف يزور مستفيد في الميدان
2. يسجل بيانات جديدة (بدون إنترنت)
3. البيانات تُحفظ محلياً وتُضاف للطابور
4. عند توفر الإنترنت، تتم المزامنة تلقائياً

### سيناريو 2: تعارض البيانات

```dart
// TODO: Implement conflict resolution
// - Last-write-wins
// - Server-wins
// - Client-wins
// - Manual resolution
```

### سيناريو 3: مزامنة كبيرة (Bulk Sync)

```dart
// معالجة دفعات (batches) لتحسين الأداء
const batchSize = 50;
final items = await db.getSyncQueue(limit: batchSize);

for (final item in items) {
  await _syncItem(item);
}
```

## الأداء والتحسينات

### 1. Indexes

```sql
-- لتسريع استعلامات الطابور
CREATE INDEX idx_sync_queue_priority 
ON sync_queue(priority DESC, created_at ASC);

-- لتسريع البحث بالكيان
CREATE INDEX idx_sync_queue_entity 
ON sync_queue(entity, entity_id);
```

### 2. Transactions

```dart
// استخدام transactions لضمان consistency
await db.transaction(() async {
  await db.insertBeneficiary(beneficiary);
  await syncManager.queueBeneficiary(...);
});
```

### 3. Background Processing

```dart
// TODO: Implement background sync using WorkManager
// - Android: WorkManager
// - iOS: Background Fetch
```

## إدارة التصنيفات (Pull from Server)

```dart
// جلب التصنيفات من السيرفر
await syncManager.syncTaxonomiesFromServer();

// التصنيفات تُحدث محلياً
final governorates = await db.getTaxonomiesByGroup('governorate');
```

## الأمان

### 1. التشفير

- جميع البيانات المحلية مشفرة (SQLCipher)
- الاتصال مع API يستخدم HTTPS
- Token-based authentication

### 2. الصلاحيات

```dart
// TODO: Implement permission checks
// - User can only sync their own data
// - Admin can sync all data
```

## المراقبة والتسجيل

```dart
// تسجيل أحداث المزامنة
logger.info('Sync started: ${items.length} items');
logger.warning('Sync failed for item ${item.id}: $error');
logger.info('Sync completed: ${completedItems}/${totalItems}');
```

## الاختبار

### Unit Tests

```dart
test('should queue beneficiary for sync', () async {
  await syncManager.queueBeneficiary(...);
  
  final queue = await db.getSyncQueue();
  expect(queue.length, 1);
  expect(queue.first.entity, 'beneficiary');
});
```

### Integration Tests

```dart
testWidgets('should show sync progress', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Trigger sync
  await tester.tap(find.byIcon(Icons.sync));
  await tester.pump();
  
  // Verify progress shown
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## خارطة الطريق

- [ ] Conflict resolution strategy
- [ ] Background sync (WorkManager/Background Fetch)
- [ ] Retry policy configuration
- [ ] Sync analytics and monitoring
- [ ] Partial sync (delta sync)
- [ ] Compression for large payloads
- [ ] Multi-user sync coordination
- [ ] Offline change detection

## المراجع

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod State Management](https://riverpod.dev/)
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus)
