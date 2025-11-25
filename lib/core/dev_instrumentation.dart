import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Minimal developer instrumentation for test runs. Kept off in production.
bool _isTestBinding() => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

final Map<String, int> _devTimingStarts = {};

void devRecordStart(String key) {
  if (!kDebugMode || !_isTestBinding()) return;
  _devTimingStarts[key] = DateTime.now().millisecondsSinceEpoch;
}

void devRecordEnd(String key) {
  if (!kDebugMode || !_isTestBinding()) return;
  final start = _devTimingStarts.remove(key);
  if (start == null) return;
  final delta = DateTime.now().millisecondsSinceEpoch - start;
  debugPrint('DEV_TIMING $key: ${delta}ms');
}

void devPrint(String msg) {
  if (!kDebugMode || !_isTestBinding()) return;
  debugPrint('DEV: $msg');
}
