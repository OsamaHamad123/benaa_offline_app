# Changelog

All notable changes to this project are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

On `develop`, waiting for the release merge into `main`.

### Fixed

- The app builds again with the current Flutter toolchain: Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20 and
  sentry_flutter 9.30.1.
- Compile errors, analyzer warnings and 46 out-of-date tests.
- Opening the activity log directly no longer crashes. It sorted the state's unmodifiable list in place.
- The reports summary shows real male and female counts. It matched labels the repository never emits, so both
  read 0.
- The visits filter chips scroll sideways instead of overflowing a phone-width screen.
- Search clears its pending debounce when the field is cleared, and filter chips show a touch ripple.

### Changed

- README feature list and links describe what the app actually does. Audit reports moved to `docs/reports/`.
- CI runs on pull requests to `develop` as well as `main`.

### Added

- `docs/ARCHITECTURE.md`, written from the code.
- README screenshots, rendered headlessly from the real UI with fictional data (`test/screenshots/`).
- A regression test for each fix above.
