import 'package:flutter/foundation.dart';

class FormOpenBenchmarkResult {
  final int elapsedMs;
  final String tag;

  const FormOpenBenchmarkResult({
    required this.elapsedMs,
    required this.tag,
  });
}

/// 📈 Benchmark helper for tracking form-open regressions in debug/tests.
class FormOpenBenchmark {
  final Stopwatch _stopwatch = Stopwatch();
  final String tag;

  FormOpenBenchmark({this.tag = 'BeneficiaryFormOpen'});

  void start() {
    _stopwatch
      ..reset()
      ..start();
  }

  FormOpenBenchmarkResult stopAndReport() {
    _stopwatch.stop();
    final result = FormOpenBenchmarkResult(
      elapsedMs: _stopwatch.elapsedMilliseconds,
      tag: tag,
    );

    if (kDebugMode) {
      debugPrint('[FormBenchmark][$tag] openMs=${result.elapsedMs}');
    }

    return result;
  }
}
