import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_open_benchmark.dart';

void main() {
  group('FormOpenBenchmark', () {
    test('records elapsed duration and tag', () async {
      final benchmark = FormOpenBenchmark(tag: 'test-open');
      benchmark.start();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final result = benchmark.stopAndReport();

      expect(result.tag, 'test-open');
      expect(result.elapsedMs, greaterThanOrEqualTo(0));
    });
  });
}
