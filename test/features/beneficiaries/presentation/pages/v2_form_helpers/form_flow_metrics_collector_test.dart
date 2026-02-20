import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_flow_metrics_collector.dart';

void main() {
  group('FormFlowMetricsCollector', () {
    test('returns null summary when no samples exist', () {
      final collector = FormFlowMetricsCollector();
      expect(collector.summarize('save'), isNull);
    });

    test('computes p50 and p95 for operation samples', () {
      final collector = FormFlowMetricsCollector();
      for (final ms in [120, 90, 200, 150, 80, 100, 300, 110, 140, 160]) {
        collector.record(operation: 'save', durationMs: ms);
      }

      final summary = collector.summarize('save');
      expect(summary, isNotNull);
      expect(summary!.count, 10);
      expect(summary.p50Ms, inInclusiveRange(100, 150));
      expect(summary.p95Ms, inInclusiveRange(160, 300));
      expect(summary.maxMs, 300);
    });

    test('summarizeAll returns entries for all operations', () {
      final collector = FormFlowMetricsCollector();
      collector.record(operation: 'save', durationMs: 100);
      collector.record(operation: 'delete', durationMs: 50);

      final all = collector.summarizeAll();
      expect(all.length, 2);
      expect(all.map((e) => e.operation), containsAll(<String>['save', 'delete']));
    });
  });
}
