import 'package:flutter/material.dart';

class SyncUiTokens {
  static const double cardRadius = 16;
  static const double sectionSpacing = 12;
  static const double contentPadding = 16;

  static Color toneContainer(BuildContext context, SyncTone tone) {
    final scheme = Theme.of(context).colorScheme;
    switch (tone) {
      case SyncTone.primary:
        return scheme.primaryContainer.withValues(alpha: 0.35);
      case SyncTone.secondary:
        return scheme.secondaryContainer.withValues(alpha: 0.35);
      case SyncTone.tertiary:
        return scheme.tertiaryContainer.withValues(alpha: 0.35);
      case SyncTone.success:
        return Colors.green.withValues(alpha: 0.10);
      case SyncTone.warning:
        return scheme.errorContainer.withValues(alpha: 0.35);
      case SyncTone.error:
        return scheme.errorContainer.withValues(alpha: 0.35);
      case SyncTone.surface:
        return scheme.surfaceContainerHighest.withValues(alpha: 0.35);
    }
  }

  static Color toneForeground(BuildContext context, SyncTone tone) {
    final scheme = Theme.of(context).colorScheme;
    switch (tone) {
      case SyncTone.primary:
        return scheme.onPrimaryContainer;
      case SyncTone.secondary:
        return scheme.onSecondaryContainer;
      case SyncTone.tertiary:
        return scheme.onTertiaryContainer;
      case SyncTone.success:
        return Colors.green.shade700;
      case SyncTone.warning:
        return scheme.onErrorContainer;
      case SyncTone.error:
        return scheme.error;
      case SyncTone.surface:
        return scheme.onSurface;
    }
  }
}

enum SyncTone {
  primary,
  secondary,
  tertiary,
  success,
  warning,
  error,
  surface,
}
