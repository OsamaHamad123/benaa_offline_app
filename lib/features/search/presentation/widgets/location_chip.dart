import 'package:flutter/material.dart';

/// Location Chip Widget - عرض الموقع الجغرافي
class LocationChip extends StatelessWidget {
  final String? city;
  final String? governorate;
  final bool showIcon;

  const LocationChip({
    super.key,
    this.city,
    this.governorate,
    this.showIcon = true,
  });

  String _buildLocationText() {
    if (city != null && governorate != null) {
      return '$city، $governorate';
    } else if (city != null) {
      return city!;
    } else {
      return governorate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (city == null && governorate == null) {
      return const SizedBox.shrink();
    }

    final locationText = _buildLocationText();
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'الموقع: $locationText',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.location_on,
                color: colorScheme.onSecondaryContainer,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                locationText,
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
