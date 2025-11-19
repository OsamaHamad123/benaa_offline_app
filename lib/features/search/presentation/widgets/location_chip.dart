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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.location_on, color: Colors.teal, size: 16),
            SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              locationText,
              style: TextStyle(
                color: Colors.teal.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
