import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recent_search.dart';
import 'search_dependencies.dart';

/// 🔍 Recent Searches Provider - Presentation Layer
///
/// Clean Architecture: Presentation layer uses domain use cases
final recentSearchesProvider = FutureProvider<List<RecentSearch>>((ref) async {
  final getRecentSearches = ref.watch(getRecentSearchesUseCaseProvider);
  return await getRecentSearches();
});
