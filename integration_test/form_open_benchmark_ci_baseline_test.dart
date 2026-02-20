import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_open_benchmark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Form Open Benchmark CI Baseline', () {
    testWidgets('stays under CI baseline threshold', (tester) async {
      const baselineFromEnv = int.fromEnvironment('FORM_OPEN_BASELINE_MS', defaultValue: 2500);
      final baselineMs = max(100, baselineFromEnv);

      final benchmark = FormOpenBenchmark(tag: 'ci-baseline');
      benchmark.start();
      await tester.pump();
      final result = benchmark.stopAndReport();

      expect(
        result.elapsedMs,
        lessThanOrEqualTo(baselineMs),
        reason: 'Form-open benchmark exceeded baseline ($baselineMs ms).',
      );
    });
  });
}
