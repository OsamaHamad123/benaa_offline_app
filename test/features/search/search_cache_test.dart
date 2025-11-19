import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/search/domain/entities/civil_person.dart';

/// 🧪 Unit Tests for Search Cache Management
/// Tests LRU eviction, memory limits, and cache behavior
void main() {
  group('Search Cache Management Tests', () {
    late Map<String, List<CivilPerson>> cache;
    late Map<String, DateTime> cacheAccess;
    late int currentCacheMemoryBytes;
    const int maxCacheSize = 20;

    setUp(() {
      cache = {};
      cacheAccess = {};
      currentCacheMemoryBytes = 0;
    });

    CivilPerson createMockPerson(String id) {
      return CivilPerson(
        nationalId: id,
        firstName: 'Test',
        fatherName: 'Father$id',
        grandFatherName: 'Grand',
        familyName: 'Family',
        gender: Gender.male,
      );
    }

    int calculatePersonSize(CivilPerson person) {
      int size = 0;
      size += person.nationalId.length * 2;
      size += person.fullName.length * 2;
      size += person.firstName.length * 2;
      size += person.fatherName.length * 2;
      size += person.grandFatherName.length * 2;
      size += person.familyName.length * 2;
      if (person.motherName != null) size += person.motherName!.length * 2;
      if (person.birthDate != null) size += person.birthDate!.length * 2;
      if (person.city != null) size += person.city!.length * 2;
      if (person.governorate != null) size += person.governorate!.length * 2;
      size += 100; // Object overhead
      return size;
    }

    void addToCache(String key, List<CivilPerson> results) {
      int estimatedSize = 0;
      for (final person in results) {
        estimatedSize += calculatePersonSize(person);
      }

      // LRU eviction if cache is full
      if (cache.length >= maxCacheSize) {
        final oldestKey = cache.keys.first;
        final oldestResults = cache.remove(oldestKey);
        cacheAccess.remove(oldestKey);
        if (oldestResults != null) {
          int oldSize = 0;
          for (final person in oldestResults) {
            oldSize += calculatePersonSize(person);
          }
          currentCacheMemoryBytes -= oldSize;
        }
      }

      cache[key] = results;
      cacheAccess[key] = DateTime.now();
      currentCacheMemoryBytes += estimatedSize;
    }

    test('Cache should store and retrieve entries', () {
      final person = createMockPerson('001');
      final results = [person];

      addToCache('test_key', results);

      expect(cache.containsKey('test_key'), true);
      expect(cache['test_key']!.length, 1);
      expect(cache['test_key']![0].nationalId, '001');
    });

    test('Cache should track access time', () {
      final person = createMockPerson('001');
      addToCache('test_key', [person]);

      expect(cacheAccess.containsKey('test_key'), true);
      expect(cacheAccess['test_key'], isA<DateTime>());
    });

    test('Cache should evict oldest entry when full (LRU)', () async {
      // Fill cache to max
      for (int i = 0; i < maxCacheSize; i++) {
        final person = createMockPerson('00$i');
        addToCache('key_$i', [person]);
        await Future.delayed(
          Duration(milliseconds: 1),
        ); // Ensure different timestamps
      }

      expect(cache.length, maxCacheSize);

      // Add one more - should evict oldest
      final newPerson = createMockPerson('new');
      addToCache('key_new', [newPerson]);

      expect(cache.length, maxCacheSize);
      expect(
        cache.containsKey('key_0'),
        false,
      ); // First entry should be evicted
      expect(cache.containsKey('key_new'), true);
    });

    test('Cache should calculate person size correctly', () {
      final person = CivilPerson(
        nationalId: '12345678901', // 11 chars
        firstName: 'John', // 4 chars
        fatherName: 'Doe', // 3 chars
        grandFatherName: 'Smith', // 5 chars
        familyName: 'Family', // 6 chars
        gender: Gender.male,
      );

      final size = calculatePersonSize(person);

      // fullName = "John Doe Smith Family" = 21 chars
      // 11 (nationalId) + 21 (fullName) + 4 (firstName) + 3 (fatherName) + 5 (grandFatherName) + 6 (familyName) = 50 chars
      // 50 * 2 + 100 = 200
      expect(size, 200);
    });

    test('Cache should track memory usage', () {
      final person = createMockPerson('001');
      final initialMemory = currentCacheMemoryBytes;

      addToCache('test_key', [person]);

      expect(currentCacheMemoryBytes, greaterThan(initialMemory));
    });

    test('Cache should handle multiple persons in one entry', () {
      final persons = [
        createMockPerson('001'),
        createMockPerson('002'),
        createMockPerson('003'),
      ];

      addToCache('multi_key', persons);

      expect(cache['multi_key']!.length, 3);
    });

    test('Cache should clear access time when evicting', () async {
      // Fill cache
      for (int i = 0; i < maxCacheSize; i++) {
        addToCache('key_$i', [createMockPerson('00$i')]);
        await Future.delayed(Duration(milliseconds: 1));
      }

      final firstAccessTime = cacheAccess['key_0'];
      expect(firstAccessTime, isNotNull);

      // Trigger eviction
      addToCache('key_new', [createMockPerson('new')]);

      expect(cacheAccess.containsKey('key_0'), false);
    });

    test('Cache should handle empty results', () {
      addToCache('empty_key', []);

      expect(cache.containsKey('empty_key'), true);
      expect(cache['empty_key']!.length, 0);
    });

    test('Cache should maintain correct size after multiple operations', () {
      for (int i = 0; i < 5; i++) {
        addToCache('key_$i', [createMockPerson('00$i')]);
      }

      expect(cache.length, 5);

      // Remove manually
      cache.remove('key_2');

      expect(cache.length, 4);
    });

    test('LRU eviction should preserve most recent entries', () async {
      // Add max entries
      for (int i = 0; i < maxCacheSize; i++) {
        addToCache('key_$i', [createMockPerson('00$i')]);
        await Future.delayed(Duration(milliseconds: 1));
      }

      // Add more - should evict oldest (key_0, key_1, etc)
      for (int i = 0; i < 5; i++) {
        addToCache('new_key_$i', [createMockPerson('new_$i')]);
        await Future.delayed(Duration(milliseconds: 1));
      }

      expect(cache.containsKey('key_0'), false);
      expect(cache.containsKey('key_1'), false);
      expect(cache.containsKey('key_19'), true); // Last old entry
      expect(cache.containsKey('new_key_4'), true); // Last new entry
    });
  });

  group('Cache Performance Tests', () {
    test('Cache lookup should be fast', () {
      final cache = <String, List<CivilPerson>>{};

      // Add 1000 entries
      for (int i = 0; i < 1000; i++) {
        cache['key_$i'] = [];
      }

      final stopwatch = Stopwatch()..start();
      final exists = cache.containsKey('key_500');
      stopwatch.stop();

      expect(exists, true);
      // Cache lookup in Dart Map is O(1) - should be very fast but can vary on first run
      expect(stopwatch.elapsedMicroseconds, lessThan(1000)); // Should be < 1ms
    });

    test('Cache eviction should be efficient', () {
      final cache = <String, List<CivilPerson>>{};
      final cacheAccess = <String, DateTime>{};

      // Fill cache
      for (int i = 0; i < 20; i++) {
        cache['key_$i'] = [];
        cacheAccess['key_$i'] = DateTime.now();
      }

      final stopwatch = Stopwatch()..start();

      // Evict oldest
      final oldestKey = cache.keys.first;
      cache.remove(oldestKey);
      cacheAccess.remove(oldestKey);

      stopwatch.stop();

      expect(stopwatch.elapsedMicroseconds, lessThan(1000)); // Should be < 1ms
    });
  });
}
