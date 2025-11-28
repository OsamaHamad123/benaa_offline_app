# 🚀 Debouncer Integration Guide

## 📌 Overview
دليل شامل لتطبيق `Debouncer` و `Throttler` في التطبيق لتحسين الأداء وتجربة المستخدم.

---

## 🎯 What is Debouncer?

**Debouncer** يؤخر تنفيذ دالة حتى يمر وقت معين بدون استدعاءات جديدة.

**مثال:** عند الكتابة في search field:
- المستخدم يكتب: `م` → `مح` → `محم` → `محمد`
- **بدون debouncer:** 4 استعلامات قاعدة بيانات
- **مع debouncer:** استعلام واحد فقط بعد انتهاء الكتابة

**Throttler** يضمن عدم تنفيذ دالة أكثر من مرة في فترة زمنية محددة.

**مثال:** scroll events
- **بدون throttler:** 100+ حدث في الثانية
- **مع throttler:** 10 أحداث فقط في الثانية

---

## 📂 Priority 1: Search Fields (10+ locations)

### 1. Civil Search Page

**File:** `lib/features/search/presentation/pages/civil_search_page_enhanced.dart`

#### Current Implementation (❌ Problematic):
```dart
TextField(
  onChanged: (value) {
    // ❌ يستدعي البحث مع كل حرف!
    _performSearch(value);
  },
)
```

#### Fixed Implementation (✅ Optimized):
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

class CivilSearchPageEnhanced extends StatefulWidget {
  // ...
}

class _CivilSearchPageEnhancedState extends State<CivilSearchPageEnhanced> {
  final _searchDebouncer = Debouncer(delay: Duration(milliseconds: 300));
  
  @override
  void dispose() {
    _searchDebouncer.dispose(); // ⚠️ مهم: تنظيف الموارد
    super.dispose();
  }
  
  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        // ✅ ينتظر 300ms بعد آخر حرف قبل البحث
        _searchDebouncer(() {
          _performSearch(value);
        });
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن شخص...',
      ),
    );
  }
}
```

**Impact:**
- تقليل استعلامات قاعدة البيانات بنسبة 80-90%
- استجابة أسرع
- استهلاك طاقة أقل

---

### 2. Beneficiaries List Search

**File:** `lib/features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart`

#### Implementation:
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

class BeneficiariesListPageV2 extends ConsumerStatefulWidget {
  // ...
}

class _BeneficiariesListPageV2State extends ConsumerState<BeneficiariesListPageV2> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer(delay: Duration(milliseconds: 300));
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }
  
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        _searchDebouncer(() {
          // Update filter state
          ref.read(beneficiariesFilterProvider.notifier).updateSearchQuery(query);
        });
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن مستفيد...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
```

---

### 3. All Search Bars Template

**Template for any search field:**
```dart
class MySearchPage extends StatefulWidget {
  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  // 1️⃣ Create debouncer instance
  final _searchDebouncer = Debouncer(
    delay: Duration(milliseconds: 300), // 300ms for search
  );
  
  // 2️⃣ Clean up on dispose
  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
  
  // 3️⃣ Use in search field
  Widget _buildSearchField() {
    return TextField(
      onChanged: (query) {
        _searchDebouncer(() {
          // Your search logic here
          performSearch(query);
        });
      },
    );
  }
}
```

---

## 📂 Priority 2: Auto-Save Forms (5+ locations)

### 1. Beneficiary Form (Fix Existing)

**File:** `lib/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart`

#### Current Implementation (❌ Manual Timer):
```dart
Timer? _autoSaveDebouncer;

void _scheduleAutoSave() {
  // Cancel previous debouncer
  _autoSaveDebouncer?.cancel();
  
  // Schedule new save
  _autoSaveDebouncer = Timer(const Duration(seconds: 2), () async {
    await _saveFormData();
  });
}

@override
void dispose() {
  _autoSaveDebouncer?.cancel(); // Cancel debouncer on dispose
  super.dispose();
}
```

#### Fixed Implementation (✅ Using Debouncer):
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

// Replace Timer with Debouncer
final _autoSaveDebouncer = Debouncer(delay: Duration(seconds: 2));

void _scheduleAutoSave() {
  // ✅ Much cleaner!
  _autoSaveDebouncer(() async {
    await _saveFormData();
  });
}

@override
void dispose() {
  _autoSaveDebouncer.dispose(); // ✅ Single dispose call
  super.dispose();
}
```

**Benefits:**
- Cleaner code (less boilerplate)
- Automatic timer management
- Less chance of memory leaks

---

### 2. Record Visit Form

**File:** `lib/features/visits/presentation/pages/record_visit_page_enhanced.dart`

#### Implementation:
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

class RecordVisitPageEnhanced extends StatefulWidget {
  // ...
}

class _RecordVisitPageEnhancedState extends State<RecordVisitPageEnhanced> {
  final _autoSaveDebouncer = Debouncer(delay: Duration(seconds: 2));
  
  // Form fields
  final _notesController = TextEditingController();
  final _visitTypeController = TextEditingController();
  
  @override
  void dispose() {
    _autoSaveDebouncer.dispose();
    _notesController.dispose();
    _visitTypeController.dispose();
    super.dispose();
  }
  
  void _onFieldChanged() {
    _autoSaveDebouncer(() {
      _saveDraft();
    });
  }
  
  Future<void> _saveDraft() async {
    // Save form data as draft
    final draft = {
      'notes': _notesController.text,
      'visitType': _visitTypeController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Save to local storage or database
    await _draftService.saveDraft(draft);
  }
  
  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      onChanged: (_) => _onFieldChanged(),
      decoration: InputDecoration(
        hintText: 'ملاحظات الزيارة...',
      ),
      maxLines: 5,
    );
  }
}
```

---

## 📂 Priority 3: Scroll Events (ListView, GridView)

### 1. Infinite Scroll with Throttler

**File:** `lib/features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart`

#### Implementation:
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

class _BeneficiariesListPageV2State extends ConsumerState<BeneficiariesListPageV2> {
  final _scrollController = ScrollController();
  final _scrollThrottler = Throttler(interval: Duration(milliseconds: 100));
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // ✅ Only triggers once every 100ms, even if scroll events fire 60+ times/second
    _scrollThrottler(() {
      final position = _scrollController.position;
      
      // Load more when near bottom
      if (position.pixels >= position.maxScrollExtent * 0.8) {
        _loadMoreBeneficiaries();
      }
    });
  }
  
  void _loadMoreBeneficiaries() {
    // Load next page
    ref.read(beneficiariesProvider.notifier).loadMore();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: beneficiaries.length,
      itemBuilder: (context, index) {
        return BeneficiaryCard(beneficiary: beneficiaries[index]);
      },
    );
  }
}
```

**Impact:**
- Reduces scroll event processing by 90%
- Smoother scrolling
- Less CPU usage

---

### 2. Search Results with Scroll Position

```dart
class SearchResultsList extends StatefulWidget {
  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  final _scrollController = ScrollController();
  final _scrollThrottler = Throttler(interval: Duration(milliseconds: 200));
  
  bool _showBackToTop = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    _scrollThrottler(() {
      final offset = _scrollController.offset;
      final shouldShow = offset > 500; // Show after 500px
      
      if (shouldShow != _showBackToTop) {
        setState(() => _showBackToTop = shouldShow);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          children: _buildResults(),
        ),
        
        // Back to top button
        if (_showBackToTop)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward),
            ),
          ),
      ],
    );
  }
}
```

---

## 📂 Priority 4: API Calls & Network Requests

### 1. Search Suggestions from API

```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';

class SearchSuggestionsWidget extends StatefulWidget {
  @override
  State<SearchSuggestionsWidget> createState() => _SearchSuggestionsWidgetState();
}

class _SearchSuggestionsWidgetState extends State<SearchSuggestionsWidget> {
  final _suggestionDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  final _searchController = TextEditingController();
  
  List<String> _suggestions = [];
  bool _isLoading = false;
  
  @override
  void dispose() {
    _suggestionDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _fetchSuggestions(String query) {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    
    setState(() => _isLoading = true);
    
    _suggestionDebouncer(() async {
      try {
        final results = await _apiService.fetchSuggestions(query);
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _fetchSuggestions,
          decoration: InputDecoration(
            hintText: 'ابحث...',
            suffixIcon: _isLoading ? CircularProgressIndicator() : null,
          ),
        ),
        
        // Suggestions list
        if (_suggestions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_suggestions[index]),
                onTap: () => _searchController.text = _suggestions[index],
              );
            },
          ),
      ],
    );
  }
}
```

---

## 📋 Implementation Checklist

### Phase 1: Search Fields (Week 1)
- [ ] `civil_search_page_enhanced.dart` - Add debouncer to main search
- [ ] `beneficiaries_list_page_v2.dart` - Add debouncer to filter search
- [ ] All other search bars (find with grep: `TextField.*onChanged`)

### Phase 2: Auto-Save Forms (Week 1)
- [ ] `beneficiary_form_page_v3.dart` - Replace Timer with Debouncer
- [ ] `record_visit_page_enhanced.dart` - Add auto-save debouncer
- [ ] Any other forms with auto-save

### Phase 3: Scroll Events (Week 2)
- [ ] `beneficiaries_list_page_v2.dart` - Add scroll throttler
- [ ] `civil_search_page_enhanced.dart` - Add scroll handling
- [ ] Dashboard scrollable lists

### Phase 4: Testing & Optimization
- [ ] Test debouncer delays (300ms vs 500ms)
- [ ] Test throttler intervals (100ms vs 200ms)
- [ ] Measure performance improvements
- [ ] User feedback

---

## 🎯 Best Practices

### 1. Delay Times
```dart
// ✅ Recommended delays:
- Search fields: 300-500ms
- Auto-save: 1-2 seconds
- Form validation: 500ms
- Scroll events (throttle): 100-200ms
- API calls: 500ms-1s
```

### 2. Always Dispose
```dart
@override
void dispose() {
  _debouncer.dispose(); // ⚠️ IMPORTANT!
  _throttler.dispose(); // ⚠️ IMPORTANT!
  super.dispose();
}
```

### 3. Cancel When Needed
```dart
// Cancel debouncer manually if needed
_debouncer.cancel();

// Example: User presses "Search Now" button
ElevatedButton(
  onPressed: () {
    _searchDebouncer.cancel(); // Cancel waiting
    _performSearch(_searchController.text); // Search immediately
  },
  child: Text('بحث الآن'),
)
```

### 4. Reset Throttler
```dart
// Reset throttler to allow immediate execution
_scrollThrottler.reset();
```

---

## 📊 Expected Results

### Before Debouncer:
```
User types "محمد":
م → Query 1
مح → Query 2
محم → Query 3
محمد → Query 4

Total: 4 database queries
Time: ~200ms
```

### After Debouncer (300ms):
```
User types "محمد":
م → (waiting...)
مح → (waiting...)
محم → (waiting...)
محمد → (300ms delay) → Query 1

Total: 1 database query
Time: ~50ms
Improvement: 75% faster, 75% fewer queries
```

### Scroll Events - Before Throttler:
```
Scroll events per second: 60-100
Callbacks fired: 60-100
CPU usage: High
```

### After Throttler (100ms):
```
Scroll events per second: 60-100
Callbacks fired: 10
CPU usage: Low
Improvement: 90% fewer callbacks
```

---

## 🚀 Quick Start

**1. Import:**
```dart
import 'package:benaa_offline_app/core/utils/debouncer.dart';
```

**2. Create instance:**
```dart
final _debouncer = Debouncer(delay: Duration(milliseconds: 300));
```

**3. Use it:**
```dart
_debouncer(() {
  // Your code here
});
```

**4. Dispose:**
```dart
@override
void dispose() {
  _debouncer.dispose();
  super.dispose();
}
```

---

**Author:** GitHub Copilot  
**Last Updated:** Now  
**Priority:** 🔥 Critical - Implement ASAP
