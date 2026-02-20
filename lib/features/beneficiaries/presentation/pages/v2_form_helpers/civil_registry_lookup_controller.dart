import 'dart:async';

import 'package:flutter/foundation.dart';

/// Shared controller for civil registry lookup behavior in form tabs.
class CivilRegistryLookupController {
  Timer? _debounceTimer;
  Timer? _postAutofillHideTimer;

  bool _showPreview = false;
  bool _hasAutofilled = false;
  String? _lastQueuedNationalId;

  bool get showPreview => _showPreview;
  bool get hasAutofilled => _hasAutofilled;

  void dispose() {
    _debounceTimer?.cancel();
    _postAutofillHideTimer?.cancel();
  }

  void togglePreview(VoidCallback requestRebuild) {
    _showPreview = !_showPreview;
    requestRebuild();
  }

  void dismissPreview(VoidCallback requestRebuild) {
    if (!_showPreview) return;
    _showPreview = false;
    requestRebuild();
  }

  void onAutofillCompleted({
    required VoidCallback requestRebuild,
    Duration hideAfter = const Duration(milliseconds: 1500),
  }) {
    _postAutofillHideTimer?.cancel();
    _postAutofillHideTimer = Timer(hideAfter, () {
      _showPreview = false;
      _hasAutofilled = true;
      requestRebuild();
    });
  }

  void onNationalIdChanged({
    required String nationalId,
    required bool canUseCivilRegistry,
    required int nationalIdLength,
    required Duration debounceDuration,
    required Future<void> Function(String nationalId) fetchByNationalId,
    required bool isLookupInProgressForId,
    required VoidCallback resetProvider,
    required VoidCallback requestRebuild,
  }) {
    _debounceTimer?.cancel();

    if (nationalId.length < nationalIdLength) {
      _lastQueuedNationalId = null;
      _showPreview = false;
      _hasAutofilled = false;
      requestRebuild();
      resetProvider();
      return;
    }

    if (!canUseCivilRegistry) {
      return;
    }

    if (nationalId.length > nationalIdLength) {
      return;
    }

    if (_lastQueuedNationalId == nationalId) {
      return;
    }

    _debounceTimer = Timer(debounceDuration, () async {
      if (nationalId.length != nationalIdLength) {
        return;
      }

      if (isLookupInProgressForId) {
        return;
      }

      _lastQueuedNationalId = nationalId;
      await fetchByNationalId(nationalId);
    });
  }
}
