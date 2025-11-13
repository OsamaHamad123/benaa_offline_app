import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'civil_search_page_enhanced.dart';

/// 🔍 Civil Search Page - Clean Architecture
///
/// Presentation layer following Clean Architecture:
/// - Uses domain entities (CivilPerson)
/// - Communicates via use cases (through providers)
/// - Independent of data layer implementation
/// - Enhanced with modern UI and performance optimizations
class CivilSearchPage extends ConsumerWidget {
  const CivilSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CivilSearchPageEnhanced();
  }
}
