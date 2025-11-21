import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver();
    });

    test('should use newerWins as default strategy', () {
      expect(resolver.defaultStrategy, ConflictStrategy.newerWins);
    });

    test('can create custom resolver with specific strategy', () {
      final customResolver = ConflictResolver(
        defaultStrategy: ConflictStrategy.serverWins,
      );
      expect(customResolver.defaultStrategy, ConflictStrategy.serverWins);
    });
  });

  group('ConflictStrategy', () {
    test('should have all expected strategies', () {
      expect(ConflictStrategy.values.length, 4);
      expect(ConflictStrategy.values, contains(ConflictStrategy.serverWins));
      expect(ConflictStrategy.values, contains(ConflictStrategy.localWins));
      expect(ConflictStrategy.values, contains(ConflictStrategy.newerWins));
      expect(ConflictStrategy.values, contains(ConflictStrategy.askUser));
    });
  });

  group('ConflictResolution', () {
    test(
      'should create resolution with userInterventionRequired default false',
      () {
        final resolution = ConflictResolution<int>(
          resolvedData: 42,
          strategyUsed: ConflictStrategy.serverWins,
        );

        expect(resolution.resolvedData, 42);
        expect(resolution.strategyUsed, ConflictStrategy.serverWins);
        expect(resolution.userInterventionRequired, false);
      },
    );

    test('should create resolution with userInterventionRequired true', () {
      final resolution = ConflictResolution<String>(
        resolvedData: 'test',
        strategyUsed: ConflictStrategy.askUser,
        userInterventionRequired: true,
      );

      expect(resolution.resolvedData, 'test');
      expect(resolution.strategyUsed, ConflictStrategy.askUser);
      expect(resolution.userInterventionRequired, true);
    });
  });
}
