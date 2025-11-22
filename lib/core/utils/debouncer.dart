import 'dart:async';
import 'package:flutter/foundation.dart';

/// 🚀 Debouncer للحد من عدد الاستدعاءات المتكررة
///
/// يستخدم لتأخير تنفيذ دالة حتى يتوقف المستخدم عن الإدخال
/// مثالي للبحث والـ auto-complete
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(delay: Duration(milliseconds: 300));
///
/// TextField(
///   onChanged: (value) {
///     debouncer(() {
///       // تنفيذ البحث هنا
///       performSearch(value);
///     });
///   },
/// );
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// تنفيذ الدالة بعد انتهاء فترة التأخير
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// إلغاء أي timer قيد الانتظار
  void cancel() {
    _timer?.cancel();
  }

  /// تنظيف الموارد
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 🎯 Throttler للحد من معدل التنفيذ
///
/// يضمن عدم تنفيذ الدالة أكثر من مرة في فترة زمنية محددة
/// مثالي للـ scroll events والـ button presses
///
/// Example:
/// ```dart
/// final throttler = Throttler(interval: Duration(seconds: 1));
///
/// onScroll: () {
///   throttler(() {
///     // تحميل المزيد من البيانات
///     loadMore();
///   });
/// }
/// ```
class Throttler {
  final Duration interval;
  DateTime? _lastExecutionTime;

  Throttler({required this.interval});

  /// تنفيذ الدالة إذا مر الوقت الكافي منذ آخر تنفيذ
  void call(VoidCallback action) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      _lastExecutionTime = now;
      action();
    }
  }

  /// إعادة تعيين الوقت لتمكين التنفيذ الفوري
  void reset() {
    _lastExecutionTime = null;
  }
}
