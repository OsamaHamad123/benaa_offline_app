import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/repositories/recent_searches_repository.dart';

/// 🔍 Recent Searches Repository Implementation - Data Layer
///
/// Clean Architecture: Concrete implementation using SharedPreferences
class RecentSearchesRepositoryImpl implements RecentSearchesRepository {
  final SharedPreferences _prefs;
  static const String _key = 'recent_searches';
  static const int _maxSearches = 5;

  const RecentSearchesRepositoryImpl(this._prefs);

  @override
  Future<List<RecentSearch>> getRecentSearches() async {
    try {
      final jsonString = _prefs.getString(_key);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => RecentSearch.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveSearch(RecentSearch search) async {
    try {
      final searches = await getRecentSearches();

      // Remove if exists (to update position)
      searches.removeWhere((s) => s.query == search.query);

      // Add to front
      searches.insert(0, search);

      // Keep only max items
      if (searches.length > _maxSearches) {
        searches.removeRange(_maxSearches, searches.length);
      }

      // Save
      final jsonList = searches.map((s) => s.toJson()).toList();
      await _prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // Fail silently - not critical
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    await _prefs.remove(_key);
  }

  @override
  Future<void> removeSearch(String query) async {
    try {
      final searches = await getRecentSearches();
      searches.removeWhere((s) => s.query == query);

      final jsonList = searches.map((s) => s.toJson()).toList();
      await _prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // Fail silently
    }
  }
}
