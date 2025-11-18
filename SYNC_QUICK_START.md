# 🚀 البداية السريعة - المزامنة (Quick Start Guide)

## ⏱️ 15 دقيقة للبدء

### خطوة 1: تثبيت المكتبات المطلوبة (5 دقائق)

أضف للـ `pubspec.yaml`:
```yaml
dependencies:
  json_annotation: ^4.8.1
  connectivity_plus: ^5.0.2

dev_dependencies:
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
```

نفّذ:
```bash
flutter pub get
```

---

### خطوة 2: Generate Code (3 دقائق)

```bash
# Generate DTOs
dart run build_runner build --delete-conflicting-outputs

# Generate Drift Database
flutter pub run drift_dev make-migrations
```

---

### خطوة 3: تحديث الـ Database (2 دقائق)

افتح `lib/data/db/drift_database.dart` وأضف:

```dart
import 'tables/sync_metadata_table.dart';
import 'daos/sync_metadata_dao.dart';

@DriftDatabase(
  tables: [
    // ... existing tables
    SyncMetadataTable, // ← أضف هذا
  ],
  daos: [
    // ... existing daos
    SyncMetadataDao, // ← أضف هذا
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}
```

---

### خطوة 4: اختبار بسيط (5 دقائق)

أنشئ ملف اختبار:

```dart
// test/sync_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sync Models', () {
    test('SyncRequest serialization', () {
      final request = SyncRequest(
        changes: [
          SyncChange(
            clientId: 'uuid-123',
            action: 'create',
            data: {'name': 'Test'},
            timestamp: DateTime(2025, 11, 18),
          ),
        ],
        timestamp: DateTime.now(),
      );

      final json = request.toJson();
      final decoded = SyncRequest.fromJson(json);

      expect(decoded.changes.length, 1);
      expect(decoded.changes.first.clientId, 'uuid-123');
    });

    test('SyncResponse parsing', () {
      final json = {
        'success': [
          {
            'client_id': 'uuid-123',
            'server_id': 456,
            'status': 'created',
          }
        ],
        'conflicts': [],
        'errors': [],
      };

      final response = SyncResponse.fromJson(json);
      
      expect(response.isFullySuccessful, true);
      expect(response.success.length, 1);
    });
  });
}
```

نفّذ الاختبار:
```bash
flutter test test/sync_test.dart
```

---

## 🎯 المرحلة التالية

بعد ما تخلص الخطوات الأربع، انتقل لـ:

### Option A: عندك باك إند جاهز؟
📖 اقرأ `SYNC_IMPLEMENTATION_GUIDE.md` - Phase 3 & 4

### Option B: ما عندك باك إند؟
📖 استخدم Mock API:
1. اقرأ `lib/core/network/mock_api_server.dart`
2. أضف sync endpoints
3. اختبر offline-first mode

---

## ✅ Checklist

- [ ] المكتبات مثبّتة (`flutter pub get`)
- [ ] Code generated بدون أخطاء
- [ ] Database migration نجحت
- [ ] الاختبار يمر بنجاح
- [ ] قرأت الـ full guide

---

## ❓ مشاكل شائعة

### ❌ Build runner fails
```bash
# حل:
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### ❌ Drift migration error
```bash
# حل:
rm -rf .dart_tool/drift_dev
flutter pub run drift_dev make-migrations
```

### ❌ JSON serialization error
تأكد إن كل model فيها:
```dart
part 'filename.g.dart';
```

---

**الوقت المتوقع:** 15 دقيقة  
**الصعوبة:** ⭐⭐⭐ متوسطة  
**المتطلبات:** Flutter 3.0+, Dart 3.0+

🎉 **بالتوفيق!**
