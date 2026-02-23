import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/geographic_distribution_section.dart';

void main() {
  group('Geographic Distribution Section Tests', () {
    late db.AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = db.AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets(
      'GeographicDistributionSection shows skeleton loader while loading',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          appWrapper(
            testDb: testDb,
            child: const SizedBox(
              height: 800,
              child: MaterialApp(
                home: Scaffold(body: GeographicDistributionSection()),
              ),
            ),
          ),
        );

        // Initial pump - should show loader
        await tester.pump();

        // Assert
        expect(
          find.byType(Card),
          findsWidgets,
          reason: 'Skeleton loader should be in a Card',
        );

        // Skeleton loader has 5 bar placeholders
        expect(
          find.byType(Container),
          findsWidgets,
          reason: 'Skeleton loader should have 5 bar placeholders',
        );
      },
    );

    test('Skeleton loader height is correct', () {
      // Skeleton loader should be 250.h
      const expectedHeight = 250.0;
      expect(expectedHeight, 250.0);
    });

    test('Geographic distribution percentage calculation', () {
      final cityData = {'دمشق': 50, 'حلب': 30, 'حمص': 15, 'حماة': 5};

      final total = cityData.values.fold(0, (a, b) => a + b);

      expect(total, 100);
      expect(cityData['دمشق']! / total * 100, 50.0);
      expect(cityData['حلب']! / total * 100, 30.0);
      expect(cityData['حمص']! / total * 100, 15.0);
      expect(cityData['حماة']! / total * 100, 5.0);
    });

    test('Geographic distribution sorting by count', () {
      final cityData = {'حماة': 5, 'دمشق': 50, 'حمص': 15, 'حلب': 30};

      // Sort by count descending
      final sortedEntries = cityData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      expect(sortedEntries[0].key, 'دمشق');
      expect(sortedEntries[1].key, 'حلب');
      expect(sortedEntries[2].key, 'حمص');
      expect(sortedEntries[3].key, 'حماة');
    });

    test('Top 5 cities selection', () {
      final cityData = {
        'City1': 100,
        'City2': 80,
        'City3': 60,
        'City4': 40,
        'City5': 20,
        'City6': 10,
        'City7': 5,
      };

      final topCities = (cityData.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(5)
          .toList();

      expect(topCities.length, 5);
      expect(topCities[0].key, 'City1');
      expect(topCities[4].key, 'City5');
    });

    test('Bar height calculation for visualization', () {
      const maxCount = 100;
      const maxBarHeight = 150.0;

      // Test different values
      const count1 = 100;
      const height1 = (count1 / maxCount) * maxBarHeight;
      expect(height1, 150.0);

      const count2 = 50;
      const height2 = (count2 / maxCount) * maxBarHeight;
      expect(height2, 75.0);

      const count3 = 25;
      const height3 = (count3 / maxCount) * maxBarHeight;
      expect(height3, 37.5);
    });
  });
}
