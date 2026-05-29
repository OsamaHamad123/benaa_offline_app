# PAGINATION STRATEGY

**Date:** 2026-05-28  
**Auditor:** GitHub Copilot  
**Scope:** All list-based features in the app

---

## 1. CURRENT STATE

### 1.1 PaginationService (exists)

`lib/core/pagination/pagination_service.dart` provides:

- `PaginationResult<T>` model
- `PaginationService.applyPagination()` — applies limit/offset to Drift queries
- `PaginationParams` — page, pageSize, searchQuery, filters, sortBy

### 1.2 DashboardNotifier (partial pagination)

```dart
// Activities use pagination:
int _currentPage = 0;
static const int _pageSize = 10;
// ✅ loadMoreActivities() implemented
```

### 1.3 Unknown: Beneficiaries List

Need to verify if beneficiaries list uses `PaginationService`.

---

## 2. PAGINATION REQUIREMENTS BY FEATURE

### 2.1 Beneficiaries List

**Priority: HIGH** — largest dataset, most critical for performance.

| Parameter         | Value                                       |
| ----------------- | ------------------------------------------- |
| Default page size | 20                                          |
| Sort              | `updatedAt DESC` (most recent first)        |
| Search            | By name, nationalId, phone — debounce 400ms |
| Filters           | Category, governorate, syncStatus           |
| Local source      | SQLite via Drift                            |
| Remote source     | Firestore (future)                          |

**Implementation:**

```dart
// Provider with params:
final beneficiariesPageProvider = FutureProvider.autoDispose
  .family<PaginationResult<Beneficiary>, PaginationParams>((ref, params) async {
    final db = ref.watch(databaseProvider);
    final total = await db.beneficiariesDao.countBeneficiaries(
      searchQuery: params.searchQuery,
      filters: params.filters,
    );
    final items = await db.beneficiariesDao.getBeneficiariesPage(
      offset: PaginationService.getOffset(params.page, params.pageSize),
      limit: params.pageSize,
      searchQuery: params.searchQuery,
      filters: params.filters,
    );
    return PaginationService.createResult(
      items: items,
      currentPage: params.page,
      totalItems: total,
      pageSize: params.pageSize,
    );
  });

// StateNotifier for scroll-based infinite loading:
class BeneficiariesListNotifier extends StateNotifier<BeneficiariesListState> {
  List<Beneficiary> _loaded = [];
  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadNextPage() async {
    if (!_hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    // ... load page, append to _loaded
  }

  Future<void> search(String query) async {
    // Reset pagination on new search
    _currentPage = 1;
    _loaded = [];
    _hasMore = true;
    // Load first page with query
  }
}
```

### 2.2 Visits List

**Priority: MEDIUM**

| Parameter         | Value                                                       |
| ----------------- | ----------------------------------------------------------- |
| Default page size | 20                                                          |
| Sort              | `scheduledAt ASC` (upcoming first), then `createdAt DESC`   |
| Filters           | Status (pending/completed/missed), beneficiaryId, dateRange |
| Special           | Today's visits should be first                              |

```dart
final visitsPageProvider = FutureProvider.autoDispose
  .family<PaginationResult<Visit>, VisitsPaginationParams>((ref, params) async {
    // ... paginated visits query
  });
```

### 2.3 Sponsorships / Kafalat

**Priority: MEDIUM**

| Parameter         | Value                                                    |
| ----------------- | -------------------------------------------------------- |
| Default page size | 20                                                       |
| Sort              | `updatedAt DESC`                                         |
| Filters           | Status (active/pending/completed/expired), associationId |

### 2.4 Associations

**Priority: LOW-MEDIUM**

| Parameter         | Value                                   |
| ----------------- | --------------------------------------- |
| Default page size | 20                                      |
| Search            | By Arabic name, English name, shortName |
| Sort              | By name alphabetically                  |

### 2.5 Dashboard Previews

**Priority: HIGH** — affects initial load time.

| Section           | Max Items  | "View All" Route               |
| ----------------- | ---------- | ------------------------------ |
| Recent Activities | 5          | `/activities`                  |
| Today's Visits    | 3          | `/visits?filter=today`         |
| Urgent Cases      | 3          | `/beneficiaries?filter=urgent` |
| Pending Uploads   | count only | `/sync`                        |

---

## 3. SCROLL-BASED INFINITE LOADING PATTERN

```dart
// In list pages — add scroll listener:
class _BeneficiariesListPageState extends ConsumerState<BeneficiariesListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load next page when 80% scrolled
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(beneficiariesListProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 4. SEARCH DEBOUNCING

```dart
// Debounce search in widgets:
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 400), () {
    ref.read(beneficiariesListProvider.notifier).search(query);
  });
}
```

Or use a dedicated search provider with debounce:

```dart
final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = Provider<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  // Debounce via timer in notifier
  return query;
});
```

---

## 5. LOADING STATES PATTERN

Each paginated list should show:

1. **Initial load**: Full skeleton/shimmer
2. **Loading more**: Small spinner at bottom of list
3. **Error**: Retry card (keeps existing data visible)
4. **Empty**: Empty state illustration
5. **End of list**: "لا توجد نتائج أخرى" text

```dart
Widget build(BuildContext context) {
  return ListView.builder(
    itemCount: items.length + 1, // +1 for footer
    itemBuilder: (context, index) {
      if (index < items.length) {
        return BeneficiaryListTile(item: items[index]);
      }
      // Footer
      if (isLoadingMore) return const CircularProgressIndicator();
      if (!hasMore) return const Text('لا توجد نتائج أخرى');
      return const SizedBox.shrink();
    },
  );
}
```

---

## 6. LOCAL DB PAGINATION (DRIFT)

### 6.1 Drift Query Pattern

```dart
// In BeneficiariesDao:
Future<List<BeneficiaryData>> getBeneficiariesPage({
  required int offset,
  required int limit,
  String? searchQuery,
  Map<String, dynamic>? filters,
}) {
  var query = select(beneficiaries);

  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query..where((b) =>
      b.fullName.contains(searchQuery) |
      b.nationalId.contains(searchQuery) |
      b.phone.contains(searchQuery)
    );
  }

  // Apply filters...

  return (query
    ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)])
    ..limit(limit, offset: offset))
    .get();
}
```

### 6.2 Count Query for Total

```dart
Future<int> countBeneficiaries({String? searchQuery}) {
  var query = selectOnly(beneficiaries)..addColumns([beneficiaries.id.count()]);
  // Apply same search/filter conditions
  return query.map((row) => row.read(beneficiaries.id.count())!).getSingle();
}
```

---

## 7. FIRESTORE PAGINATION (FUTURE)

When remote browsing is added:

```dart
// Use startAfterDocument for cursor-based pagination:
Query<Map<String, dynamic>> nextPage = firestore
  .collection('beneficiaries')
  .orderBy('updated_at', descending: true)
  .startAfterDocument(lastDocument)
  .limit(20);
```

---

## 8. CACHING STRATEGY

| Data                 | Cache Duration                        | Invalidation Trigger |
| -------------------- | ------------------------------------- | -------------------- |
| Dashboard counts     | 30 seconds (FutureProvider keepAlive) | After sync           |
| Beneficiaries page 1 | 60 seconds                            | After add/edit       |
| Search results       | No cache                              | Always fresh         |
| Today's visits       | 5 minutes                             | After add/edit visit |
| Associations list    | 5 minutes                             | After sync           |

---

## 9. IMPLEMENTATION ROADMAP

### Phase A (Now — Dashboard optimization)

- [x] Dashboard activities: already paginated (page size 10)
- [ ] Dashboard previews: cap at 3-5 items with "View All"
- [ ] Dashboard counts: use lightweight count queries only

### Phase B (Next sprint)

- [ ] Beneficiaries list: implement scroll-based infinite loading
- [ ] Search: debounce 400ms
- [ ] Filters: don't reset on filter change, re-page from start

### Phase C (Future)

- [ ] Visits list pagination
- [ ] Sponsorships pagination
- [ ] Associations search pagination
- [ ] Firestore cursor-based pagination for remote mode

---

## IMPLEMENTED / REMAINING (2026-05-28)

### Implemented
- Dashboard previews load max 5 items: state.activities.take(5).toList() in RecentActivitiesList
- 	rendChartDataProvider not loaded in operational mode (conditional watch)

### Remaining
- **Beneficiaries list**: still loads all rows — full pagination not implemented
- **Visits list**: pagination not implemented
- **Sponsorships list**: pagination not implemented
- **Associations list**: pagination not implemented
- Search debounce: needs implementation per feature
- Offset-based pagination in Drift DAOs: needs implementation
