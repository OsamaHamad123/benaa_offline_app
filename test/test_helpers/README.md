# 🔍 FieldFinderHelper - Test Utility

**Quick Reference Guide**

## 🚀 Quick Start

```dart
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/field_finder_helper.dart';

testWidgets('example test', (tester) async {
  // Fill single field
  await tester.fillField('الاسم الأول', 'محمد');
  
  // Fill multiple fields
  await tester.fillMultipleFields({
    'الاسم الأول': 'محمد',
    'اسم الأب': 'أحمد',
    'اللقب': 'العلي',
  });
  
  // Debug all fields
  tester.debugFields();
});
```

## 📚 Files

- **`field_finder_helper.dart`** - Main helper class with 15+ functions
- **`field_finder_helper_examples.dart`** - 10 complete examples
- **`FIELD_FINDER_GUIDE.md`** - Full documentation (Arabic)

## ✨ Key Features

✅ Works with Material3 components  
✅ Handles validation & input formatters  
✅ Extension methods for cleaner code  
✅ Multiple search methods (label, icon, index)  
✅ Debug utilities  
✅ Arabic RTL support  

## 🎯 Main Functions

| Function | Description |
|----------|-------------|
| `findFieldByLabel()` | Find by label text |
| `fillField()` | Fill single field |
| `fillMultipleFields()` | Fill many fields |
| `findRequiredFields()` | Find all required fields |
| `hasFieldError()` | Check validation errors |
| `debugFields()` | Print all fields |

## 📖 Full Documentation

See **[FIELD_FINDER_GUIDE.md](FIELD_FINDER_GUIDE.md)** for complete guide in Arabic.

## 🧪 Test Results

**387/387 tests passing** ✅

---

**Created:** November 2025  
**Version:** 1.0.0
