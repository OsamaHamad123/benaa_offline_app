# Beneficiary Details — Raw JSON / Metadata Cleanup

**Date:** 2026-05-28  
**Scope:** Presentation-only display filter — no database/sync changes.

---

## 1. Problem Summary

The Beneficiary Details screen has/had two concrete display issues and a missing safety layer:

| Issue                                                                                                              | Location                                                                   | Risk                                 |
| ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------- | ------------------------------------ |
| "Additional Contact Info" section always rendered, even when `altPhoneNumber = 0` — showing "رقم هاتف بديل: 0"     | `view_beneficiary_page.dart` (legacy, not in router)                       | Low — page is not reached via router |
| Raw integer zero shown for `idNumber`, `phoneNumber`, `sectionId`, `province`, `city` when unset                   | `beneficiary_relations_tabs_page.dart` (active, reached from details page) | Medium — users see "0"               |
| No formal display-layer filter to prevent raw technical keys from being rendered if new dynamic sections are added | Missing utility                                                            | Preventive                           |

The **active details page** (`BeneficiaryDetailsPageV2` at `/beneficiaries/:id`) was already clean:

- `InfoBuilders` renders only explicitly named fields.
- `NeedsSection` uses `NotesNeedsFormatter` which already strips `#meta:` suffix and filters technical keys from the `notes` JSON blob.

---

## 2. Files Inspected

| File                                                                                        | Notes                                                                    |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `lib/features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart`            | Active details page — already clean                                      |
| `lib/features/beneficiaries/presentation/pages/details_widgets/helpers/info_builders.dart`  | Builds explicit named InfoItem lists — no raw iteration                  |
| `lib/features/beneficiaries/presentation/pages/details_widgets/sections/needs_section.dart` | Uses `NotesNeedsFormatter` — already safe                                |
| `lib/features/beneficiaries/presentation/formatters/notes_needs_formatter.dart`             | Already filters technical keys from notes JSON                           |
| `lib/features/beneficiaries/view_beneficiary_page.dart`                                     | Legacy page — not in router — had unconditional altPhoneNumber rendering |
| `lib/features/beneficiaries/presentation/pages/beneficiary_relations_tabs_page.dart`        | Active tab — had raw integer-zero rendering                              |
| `lib/routing/app_router.dart`                                                               | Confirmed router uses `BeneficiaryDetailsPageV2` only                    |

---

## 3. Where Raw Metadata Was Rendered

### A — `view_beneficiary_page.dart` (legacy, not in router)

"Additional Contact Info" section was always shown, even when `altPhoneNumber` is `0` (the DB default when no alt phone is stored), so users would see:

```
رقم هاتف بديل: 0
```

### B — `beneficiary_relations_tabs_page.dart` (active)

Overview tab called:

```dart
_kv('الرقم الوطني', b.idNumber.toString())   // showed "0" if unset
_kv('الهاتف', b.phoneNumber.toString())       // showed "0" if unset
_kv('التصنيف', b.sectionId?.toString() ?? 'غير محدد')  // showed raw numeric code
_kv('المحافظة', b.province?.toString() ?? 'غير محدد')  // showed raw code
_kv('المدينة', b.city?.toString() ?? 'غير محدد')       // showed raw code
```

The `notes` field in `BeneficiaryDetailsPageV2` stores extended metadata as a `\n\n#meta:{json}` suffix. The `NotesNeedsFormatter` already strips this before display — this was already safe.

---

## 4. Selected Fix

**Low-risk, presentation-only. No database/sync/model changes.**

1. **Created** `lib/features/beneficiaries/presentation/utils/beneficiary_display_field_filter.dart`:
   - `shouldDisplayBeneficiaryField(key)` — hides technical/internal keys
   - `beneficiaryFieldLabel(key)` — maps common keys to Arabic labels
   - `normalizeBeneficiaryFieldValue(key, value)` — safe display value (hides Maps, raw JSON, null, empty)
2. **Fixed** `view_beneficiary_page.dart` — made "Additional Contact Info" conditional on `altPhoneNumber != 0`.

3. **Fixed** `beneficiary_relations_tabs_page.dart` — zero-integer fields now hidden instead of showing "0".

---

## 5. What Is Intentionally NOT Changed

- Database schema — unchanged
- Sync payloads — unchanged
- `notes` field content — unchanged (metadata suffix still stored, just filtered on display)
- `NotesNeedsFormatter` — already correct, not touched
- `InfoBuilders` — already correct, not touched
- `BeneficiaryDetailsPageV2` main layout — unchanged
- Security/auth/log-sanitizer logic — unchanged

---

## 6. Tests Run

| Test                                                                                | Result                  |
| ----------------------------------------------------------------------------------- | ----------------------- |
| `test/features/beneficiaries/beneficiary_display_field_filter_test.dart` (37 tests) | ✅ All passed           |
| Analyzer on 3 changed files                                                         | ✅ 0 errors, 0 warnings |

---

## 7. Rollback Notes

All changes are presentation-only:

- Delete `lib/features/beneficiaries/presentation/utils/beneficiary_display_field_filter.dart` to remove the helper.
- In `view_beneficiary_page.dart`: remove the `if (beneficiary.altPhoneNumber != 0)` guard to restore unconditional rendering.
- In `beneficiary_relations_tabs_page.dart`: restore original `.toString()` calls.
- No database migration needed. No sync pipeline changes needed.

---

## 8. Deferred Items

- `view_beneficiary_page.dart` is legacy (not in router) — consider deleting it in a future cleanup.
- `beneficiary_relations_tabs_page.dart` `province`/`city` fields show raw taxonomy codes — taxonomy label resolution is deferred (requires TaxonomyBridgeProvider wiring in that tab context).
- Apply `beneficiaryFieldLabel()` and `shouldDisplayBeneficiaryField()` to any future dynamic rendering sections if added.
