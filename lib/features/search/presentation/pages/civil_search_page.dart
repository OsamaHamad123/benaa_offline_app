import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/civil_person.dart';
import '../providers/search_provider.dart';
import '../widgets/widgets.dart';

/// 🔍 Civil Search Page - Clean Architecture
///
/// Presentation layer following Clean Architecture:
/// - Uses domain entities (CivilPerson)
/// - Communicates via use cases (through providers)
/// - Independent of data layer implementation
class CivilSearchPage extends ConsumerStatefulWidget {
  const CivilSearchPage({super.key});

  @override
  ConsumerState<CivilSearchPage> createState() => _CivilSearchPageState();
}

class _CivilSearchPageState extends ConsumerState<CivilSearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(statsAsync),
          _buildSearchBar(searchState),
          if (searchState.query.isNotEmpty)
            _buildFilters(searchState, statsAsync),
          _buildResults(searchState),
        ],
      ),
    );
  }

  /// Build app bar with statistics
  Widget _buildAppBar(AsyncValue statsAsync) {
    return statsAsync.when(
      data: (stats) => CivilSearchAppBar(
        totalPersons: stats.totalPersons,
        malesCount: stats.malesCount,
        femalesCount: stats.femalesCount,
      ),
      loading: () => const LoadingAppBar(),
      error: (_, __) => const ErrorAppBar(),
    );
  }

  /// Build search bar section
  Widget _buildSearchBar(searchState) {
    return SearchBarSection(
      controller: _searchController,
      onChanged: _onSearchChanged,
      onClear: _clearSearch,
      isSearching: searchState.isSearching,
      query: searchState.query,
    );
  }

  /// Build filters section
  Widget _buildFilters(searchState, AsyncValue statsAsync) {
    return statsAsync.when(
      data: (stats) {
        return SliverToBoxAdapter(
          child: CivilSearchFilters(
            selectedGovernorate: searchState.filter.governorate,
            selectedGender: searchState.filter.gender?.arabicLabel,
            governorates: stats.governorates,
            onGovernorateChanged: _onGovernorateChanged,
            onGenderChanged: _onGenderChanged,
            onClearFilters: _onClearFilters,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  /// Build search results
  Widget _buildResults(searchState) {
    // Empty state - no query
    if (searchState.query.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search,
          title: 'ابحث عن مواطن',
          message: 'أدخل الاسم أو الرقم الوطني للبحث في السجل المدني',
        ),
      );
    }

    // Empty state - no results
    if (searchState.isEmpty && !searchState.isSearching) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'لا توجد نتائج',
          message: searchState.error ?? 'لم يتم العثور على نتائج',
        ),
      );
    }

    // Results list with pagination
    final rv = ResponsiveUtils.getValues(context);
    return SliverPadding(
      padding: rv.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Results
            if (index < searchState.results.length) {
              final person = searchState.results[index];
              return ResultCard(
                person: person,
                onCopy: () => _copyToClipboard(person),
                onAddAsBeneficiary: () => _addAsBeneficiary(person),
              );
            }

            // Load more button
            if (index == searchState.results.length && searchState.hasMore) {
              return LoadMoreButton(
                isSearching: searchState.isSearching,
                onPressed: () {
                  ref.read(searchProvider.notifier).loadMore();
                },
              );
            }

            return const SizedBox.shrink();
          },
          childCount:
              searchState.results.length + (searchState.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  /// Event Handlers

  void _onSearchChanged(String value) {
    final notifier = ref.read(searchProvider.notifier);
    notifier.setQuery(value);
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      notifier.clearSearch();
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => notifier.search(reset: true),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
  }

  void _onGovernorateChanged(String? governorate) {
    final notifier = ref.read(searchProvider.notifier);
    notifier.setGovernorate(governorate);
    notifier.search(reset: true);
  }

  void _onGenderChanged(String? gender) {
    final notifier = ref.read(searchProvider.notifier);
    notifier.setGender(gender);
    notifier.search(reset: true);
  }

  void _onClearFilters() {
    final notifier = ref.read(searchProvider.notifier);
    notifier.clearFilters();
    notifier.search(reset: true);
  }

  void _copyToClipboard(CivilPerson person) {
    final text =
        '''
الاسم: ${person.fullName}
الرقم الوطني: ${person.nationalId}
الجنس: ${person.gender.arabicLabel}
المدينة: ${person.city ?? 'غير محدد'}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ إلى الحافظة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addAsBeneficiary(CivilPerson person) {
    context.push(
      '/beneficiaries/add',
      extra: {
        'name': person.fullName,
        'nationalId': person.nationalId,
        'gender': person.gender.arabicLabel,
      },
    );
  }
}
