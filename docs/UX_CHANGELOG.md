# UX Changelog

## 2026-03-03 (v1.9.0)

### Implemented

- Completed Beneficiary Form Wave 2 + 3 execution batch:
  - Friction reduction (guidance cards, focus-flow refinement, critical validation clarity).
  - Consistency/accessibility hardening (section semantics, helper microcopy normalization).
- Finalized tab navigation reliability behavior and stabilized focused form progression tests.
- Resolved constrained-layout tab header overflow in beneficiary form test paths.
- Added post-wave delta handoff report in docs.

### Notes

- See `docs/POST_WAVE_DELTA_REPORT_2026-03-03.md` for before/after summary, KPI instrumentation, and quality status.

## 2026-03-03 (v1.8.0)

### Implemented

- Reworked top app-bar action icons to a borderless soft style (cleaner visual hierarchy).
- Kept consistent icon rhythm across core pages while reducing visual noise from icon frames.
- Added Settings functional shortcuts: open Sync History and copy Weekly Quality KPI snapshot.
- Further compacted top app-bar action buttons for less crowding in the header.
- Reworked Dashboard taxonomy badge to soft style (no hard border) for better visual harmony.
- Unified Settings tile leading icon containers to the same compact style.
- Added a minimal visual variant for top action icons (no shadow) for cleaner, flatter header style.
- Flattened Dashboard section-title icon containers (no gradient) for full minimal consistency.
- Refined Settings section-header icon proportions to match the same minimal icon rhythm.

### Notes

- This release combines requested visual cleanup for icons with practical operational actions in settings.

## 2026-03-03 (v1.7.0)

### Implemented

- Increased inner spacing between top app-bar action icons and their frame.
- Refined top app-bar title icon proportions for cleaner balance.
- Unified icon size rhythm across Dashboard bottom navigation and section headers.
- Applied final pixel-level spacing tune for app-bar icon/title/end alignment.
- Improved app-bar icon/action contrast behavior in light/dark using `onPrimary`-based overlays.

### Notes

- This visual pass targets the core "main pages" icon clarity and consistency request.

## 2026-03-03 (v1.6.0)

### Implemented

- Normalized top app-bar icon sizes and action-button shapes across main pages (Dashboard/Sync/Settings).
- Switched Settings top action to the shared modern action button for visual consistency.
- Added PR template section for short release notes.
- Added Wave 3 release notes draft document.

### Notes

- This release finalizes visual consistency for top-level actions and improves release handoff quality.

## 2026-03-03 (v1.5.0)

### Implemented

- Standardized mixed RTL/LTR rendering for numeric/date value labels in Sync and Settings tiles.
- Added normalization for dynamic mixed values to improve readability in Arabic layouts.
- Enforced two-line-safe Arabic action labels on primary Sync action buttons.

### Notes

- This release covers Wave 3 items 45 and 46 baseline hardening on core operational screens.

## 2026-03-03 (v1.4.0)

### Implemented

- Added semantic labels to key Dashboard/Sync mode chips and Sync/Settings cards/tiles for screen readers.
- Improved Sync success color contrast behavior for both dark and light themes.
- Added text scaling safety (`maxLines` + overflow handling) for critical status and settings labels.
- Added fallback strings for empty dynamic Sync status and error messages.

### Notes

- This release covers a core slice of Wave 3 accessibility/i18n hardening items 41-44.

## 2026-03-03 (v1.3.0)

### Implemented

- Added centralized UX feature flags store backed by SharedPreferences.
- Added developer controls in settings to toggle rollout flags.
- Gated Dashboard Analytical mode behind feature flag.
- Gated Sync Diagnostic mode behind feature flag with operational fallback.

### Notes

- This release implements Wave 3 item 40 with safe defaults that preserve current behavior.

## 2026-03-03 (v1.2.0)

### Implemented

- Added settings interaction telemetry by section and session-end summary for drop-off analysis.
- Added manual retry-loop telemetry in Sync Hub when users repeat trigger actions.
- Added weekly quality KPI snapshot in analytics reporting (sync success rate, median duration, failure categories).

### Notes

- These metrics complete the first instrumentation slice for Wave 3 items 36, 37, and 39.

## 2026-03-03 (v1.1.0)

### Implemented

- Added dashboard `time-to-first-action` tracking after open.
- Added dashboard action telemetry for quick actions, filters, search, refresh, and export.
- Added sync funnel telemetry: hub open → trigger (sync up/down/full) → completion (success/failure).
- Added mode adoption telemetry for Dashboard (Operational/Analytical) and Sync Hub (Operational/Diagnostic).
- Added diagnostics export telemetry from Sync Hub with success/failure result.

### Notes

- This release starts Wave 3 product instrumentation without changing user-facing flows.

## 2026-03-03 (v1.0.0)

### Implemented

- Unified settings access to one primary route.
- Added dashboard shortcut from settings and direct Sync Hub entry.
- Introduced Sync Hub modes: Operational and Diagnostic.
- Simplified Sync Hub default view to action-first layout.
- Added compact operational stats summary with optional details expansion.
- Introduced Dashboard modes: Operational and Analytical.
- Reordered dashboard top information hierarchy to summary → quick actions → filters.

### Notes

- This changelog is versioned and should be updated with every UX-impacting PR.
- Pair each entry with screenshots in PR template core states.
