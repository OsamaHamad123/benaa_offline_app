class FormFlowMetricsSummary {
  final String operation;
  final int count;
  final int p50Ms;
  final int p95Ms;
  final int maxMs;

  const FormFlowMetricsSummary({
    required this.operation,
    required this.count,
    required this.p50Ms,
    required this.p95Ms,
    required this.maxMs,
  });
}

/// 📊 Session-level metrics collector for form flows.
class FormFlowMetricsCollector {
  final Map<String, List<int>> _durationsByOperation = {};

  void record({
    required String operation,
    required int durationMs,
  }) {
    if (durationMs < 0) return;
    final values = _durationsByOperation.putIfAbsent(operation, () => <int>[]);
    values.add(durationMs);
  }

  FormFlowMetricsSummary? summarize(String operation) {
    final values = _durationsByOperation[operation];
    if (values == null || values.isEmpty) return null;

    final sorted = List<int>.from(values)..sort();
    final p50 = _percentile(sorted, 0.50);
    final p95 = _percentile(sorted, 0.95);

    return FormFlowMetricsSummary(
      operation: operation,
      count: sorted.length,
      p50Ms: p50,
      p95Ms: p95,
      maxMs: sorted.last,
    );
  }

  List<FormFlowMetricsSummary> summarizeAll() {
    return _durationsByOperation.keys.map(summarize).whereType<FormFlowMetricsSummary>().toList(growable: false);
  }

  int _percentile(List<int> sorted, double percentile) {
    if (sorted.isEmpty) return 0;
    final rank = (percentile * (sorted.length - 1)).round();
    return sorted[rank.clamp(0, sorted.length - 1)];
  }
}
