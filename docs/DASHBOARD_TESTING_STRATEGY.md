# DASHBOARD TESTING STRATEGY

**Date:** 2026-05-28  
**Scope:** Dashboard/Home page, AppBar, Quick Actions, LogSanitizer, Security

---

## 1. DELETED OLD TESTS

| File                                                                        | Reason                                                                                                                                                |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/features/dashboard/presentation/widgets/quick_actions_test.dart.skip` | Skipped file asserting old 8-action grid and old labels ("الزيارات" instead of "زيارات اليوم"); conditional Kafalat/Associations that no longer apply |
| `test/features/dashboard/dashboard_performance_test.dart`                   | Tested only math calculations (RepaintBoundary %, haptic timing, skeleton UX estimates) — no actual widget or provider behavior validated             |

---

## 2. NEW TESTS CREATED

### `test/core/utils/log_sanitizer_test.dart` (15 tests)

Protects against sensitive data leakage in production logs.

| Test                                          | What it protects                   |
| --------------------------------------------- | ---------------------------------- |
| maskNationalId shows last 4 digits only       | nationalId never fully logged      |
| maskNationalId returns \*\*\* for empty       | null safety                        |
| maskNationalId returns \*\*\*\* for short IDs | edge case                          |
| maskPhone shows last 3 digits only            | phone number never fully logged    |
| maskPhone returns \*\*\* for empty/null       | null safety                        |
| maskName shows first char only                | name never fully logged            |
| maskName returns \*\*\* for null              | null safety                        |
| maskEmail shows first char + domain           | email structure not fully logged   |
| maskId shows last 6 chars                     | internal IDs partially masked      |
| maskSensitive returns [REDACTED]              | Firebase tokens, keys never logged |
| sanitizeMap masks specified keys              | batch masking works                |
| sanitizeMap leaves non-sensitive keys         | no over-masking                    |
| null handling for all methods                 | no NPE in logs                     |

### `test/features/dashboard/dashboard_quick_actions_test.dart` (12 tests)

Protects the 6-action grid spec and RTL correctness.

| Test                                         | What it protects                             |
| -------------------------------------------- | -------------------------------------------- |
| Renders "إضافة مستفيد"                       | First action always present                  |
| Renders "المستفيدون"                         | Beneficiaries action always present          |
| Renders "زيارات اليوم"                       | Correct label (not "الزيارات")               |
| Renders "الكفالات"                           | Kafalat unconditionally shown                |
| Renders "الجمعيات"                           | Associations unconditionally shown           |
| Renders "المزامنة"                           | Sync action always present                   |
| Does NOT show "التقارير"                     | Reports removed from user grid               |
| Does NOT show "السجل المدني"                 | Civil registry not in user grid              |
| Does NOT show Debug/Test/Seed                | No admin tools in user grid                  |
| Kafalat/Associations shown without callbacks | No regression from conditional guard removal |
| Shows sync badge when pending > 0            | Badge feedback works                         |
| RTL layout without overflow                  | Arabic UI safe                               |
| onAddBeneficiaryTap callback triggered       | Tap works                                    |

### `test/features/dashboard/dashboard_app_bar_test.dart` (5 tests)

Protects AppBar accessibility and admin gating.

| Test                          | What it protects            |
| ----------------------------- | --------------------------- |
| Non-admin: no crash           | Safety for regular users    |
| Admin: popup visible          | Admin tools accessible      |
| Search tooltip present        | Accessibility for all users |
| Notifications tooltip present | Accessibility for all users |
| Title renders correctly       | AppBar title display        |

### `test/features/dashboard/dashboard_security_visibility_test.dart` (7 tests)

Verifies sensitive data masking contracts.

| Test                                  | What it protects              |
| ------------------------------------- | ----------------------------- |
| nationalId not fully logged           | Privacy regulation compliance |
| phone not fully logged                | Privacy regulation compliance |
| name not fully logged                 | Privacy regulation compliance |
| email not fully logged                | Privacy regulation compliance |
| maskSensitive returns [REDACTED]      | Token/key protection          |
| sanitizeMap masks specified keys only | Selective masking             |
| null inputs handled safely            | No crash from null data       |

---

## 3. TESTS TO KEEP (UNCHANGED)

| File                                                                                     | Status                                  |
| ---------------------------------------------------------------------------------------- | --------------------------------------- |
| `test/features/dashboard/presentation/widgets/statistics_section_test.dart`              | ✅ Valid — tests StatCard independently |
| `test/features/dashboard/presentation/widgets/activities_logic_test.dart`                | ✅ Valid — tests activity logic         |
| `test/features/dashboard/presentation/widgets/activities_section_test.dart`              | ✅ Valid — tests RecentActivitiesList   |
| `test/features/dashboard/presentation/widgets/daily_performance_section_test.dart`       | ✅ Valid                                |
| `test/features/dashboard/presentation/widgets/urgent_cases_section_test.dart`            | ✅ Valid                                |
| `test/features/dashboard/presentation/widgets/dashboard_charts_test.dart`                | ✅ Valid                                |
| `test/features/dashboard/presentation/widgets/geographic_distribution_section_test.dart` | ✅ Valid                                |

---

## 4. HOW TO RUN TESTS

```powershell
# Run all new dashboard tests
flutter test test/features/dashboard/

# Run LogSanitizer tests
flutter test test/core/utils/log_sanitizer_test.dart

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 5. KNOWN REMAINING GAPS

| Gap                                              | Priority | Notes                                              |
| ------------------------------------------------ | -------- | -------------------------------------------------- |
| Beneficiaries pagination test                    | P2       | Requires Drift pagination DAO implementation first |
| Post-sync dashboard invalidation test            | P2       | Requires sync integration test setup               |
| Dashboard full page render test (real providers) | P2       | Complex setup; needs fake repositories             |
| DashboardNotifier unit tests                     | P2       | Verify loadStatistics, loadMoreActivities          |
| `isAdminProvider` unit test                      | P3       | Requires Firebase Auth mocking                     |
| Filter chip interaction tests                    | P3       | UI behavior                                        |
| RTL full page test                               | P3       | Requires full page widget setup                    |

---

## 6. TESTING PRINCIPLES

- **No real Firebase** — use `ProviderScope.overrides` with fake/mock providers
- **No real network** — all DB tests use `NativeDatabase.memory()`
- **Deterministic** — avoid real timers; use `fakeAsync` if needed
- **No pumpAndSettle infinite loops** — prefer `pump()` or bounded `pumpAndSettle(Duration(seconds: 3))`
- **No golden tests** — avoid snapshot tests that require image comparison setup
- **Test behavior not structure** — tap callbacks, label text, visibility conditions; not widget tree depth
