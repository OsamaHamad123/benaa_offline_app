import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_flow_tracer.dart';

void main() {
  group('FormFlowTracer', () {
    test('supports step tracing without throwing', () {
      final tracer = FormFlowTracer.start('unit');

      expect(() {
        tracer.startStep('a');
        tracer.endStep('a');
        tracer.mark('checkpoint');
        tracer.end(result: 'ok');
      }, returnsNormally);
    });
  });
}
