import 'package:flutter/foundation.dart';

/// ⏱️ Lightweight flow tracer for save/delete/load operations.
class FormFlowTracer {
  final String operation;
  final String correlationId;
  final Stopwatch _totalStopwatch = Stopwatch()..start();
  final Map<String, Stopwatch> _stepWatches = {};

  FormFlowTracer._({
    required this.operation,
    required this.correlationId,
  }) {
    if (kDebugMode) {
      debugPrint('[BeneficiaryFormTrace][$operation][$correlationId] start');
    }
  }

  factory FormFlowTracer.start(String operation) {
    final now = DateTime.now();
    final correlationId = '${now.microsecondsSinceEpoch}_${operation.hashCode.abs()}';
    return FormFlowTracer._(operation: operation, correlationId: correlationId);
  }

  void startStep(String step) {
    _stepWatches[step] = Stopwatch()..start();
  }

  void endStep(String step) {
    final watch = _stepWatches[step];
    if (watch == null) return;
    watch.stop();
    if (kDebugMode) {
      debugPrint('[BeneficiaryFormTrace][$operation][$correlationId] step=$step ms=${watch.elapsedMilliseconds}');
    }
  }

  void mark(String message) {
    if (kDebugMode) {
      debugPrint('[BeneficiaryFormTrace][$operation][$correlationId] $message');
    }
  }

  int end({String? result}) {
    _totalStopwatch.stop();
    final elapsedMs = _totalStopwatch.elapsedMilliseconds;
    if (kDebugMode) {
      debugPrint(
        '[BeneficiaryFormTrace][$operation][$correlationId] end result=${result ?? 'ok'} totalMs=$elapsedMs',
      );
    }
    return elapsedMs;
  }
}
