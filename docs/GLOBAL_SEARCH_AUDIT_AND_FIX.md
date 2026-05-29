# Global Search — Audit & Fix Report

**Date:** 2025  
**Phase:** 1 of 5  
**Status:** ✅ Complete

---

## Audit Summary

| الصفحة                           | المشكلة                                                             | الإصلاح                                                         |
| -------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------- |
| `associations_list_page_v2.dart` | `setState` مباشرة على كل حرف، بلا debounce ولا Arabic normalization | ✅ أضفنا `Timer` 300ms + `ArabicNormalizer`                     |
| `unsponsored_tab.dart`           | `setState` مباشرة على كل حرف، بلا debounce                          | ✅ أضفنا `Timer` 300ms + `ArabicNormalizer`                     |
| `visits_list_page.dart`          | لا يوجد بحث أصلاً                                                   | ✅ أضفنا search bar كامل في الـ AppBar + `_filteredVisits`      |
| `taxonomy_management_page.dart`  | لا يوجد بحث ولا فلتر                                                | ✅ أضفنا search + `FilterChip('نشط فقط')`                       |
| `beneficiaries_report_page.dart` | `setState` مباشرة على كل حرف، بلا debounce                          | ✅ أضفنا `Timer` 300ms + `TextEditingController` + clear button |
| `beneficiaries_list_page.dart`   | يستخدم `Debouncer` بالفعل ✅                                        | لا تغيير                                                        |
| `kafalat_sponsored_tab.dart`     | يستخدم `EnhancedSearchBar` مع debounce داخلي 300ms ✅               | لا تغيير                                                        |
| `civil_search_page.dart`         | محرك بحث كامل مع debounce ✅                                        | لا تغيير                                                        |

---

## Changes Made

### 1. `lib/features/associations/presentation/pages/associations_list_page_v2.dart`

- Added `import 'dart:async'`
- Added `import '../../../../core/utils/arabic_normalizer.dart'`
- Added `Timer? _searchDebounce` field
- Updated `dispose()` to cancel timer
- Replaced `onChanged: (v) => setState(...)` with debounced `_onSearchChanged()`
- Added `_contains()` helper using `ArabicNormalizer.normalize`

### 2. `lib/features/kafalat/presentation/widgets/tabs/unsponsored_tab.dart`

- Added `import 'dart:async'`
- Added `import '../../../../../core/utils/arabic_normalizer.dart'`
- Added `Timer? _searchDebounce` field
- Replaced direct setState with 300ms debounce
- Critical: this tab queries DB via provider — debounce prevents hammering DB on every keypress

### 3. `lib/features/visits/presentation/pages/visits_list_page.dart`

- Added complete search bar in `PreferredSize` AppBar bottom (104px height)
- Fields: `TextEditingController _searchController`, `String _searchQuery`, `Timer? _searchDebounce`
- `_filteredVisits` getter filters by `staffName`, `notes`, `syncState`
- Empty state with "مسح البحث" button when no results

### 4. `lib/features/taxonomies/presentation/pages/taxonomy_management_page.dart`

- Converted `_TaxonomyGroupList` from `ConsumerWidget` → `ConsumerStatefulWidget`
- Added search `TextField` + `FilterChip('نشط فقط')` in a `Row`
- Inline filter: by label/code + isActive status
- Empty state for no results

### 5. `lib/features/reports/presentation/pages/beneficiaries_report_page.dart`

- Added `TextEditingController _searchController` + `Timer? _searchDebounce`
- Replaced `onChanged: setState` with `_onSearchChanged()` (300ms debounce)
- Added clear button in search field
- Fixed reset button to also clear controller

---

## Flutter Analyze Result (Phase 1)

```
Errors: 0   Warnings: 0
```
