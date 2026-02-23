import 'package:flutter/material.dart';
import '../../domain/entities/civil_person.dart';

/// Gender Badge Widget - عرض الجنس بشكل أنيق
class GenderBadge extends StatelessWidget {
  final Gender gender;
  final bool compact;

  const GenderBadge({required this.gender, super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _getGenderColor(gender);
    final icon = _getGenderIcon(gender);
    // ⚡ Cache color calculations
    final bgColor = color.withOpacity(compact ? 0.1 : 0.15);
    final borderColor = color.withOpacity(compact ? 0.3 : 0.4);

    if (compact) {
      return Semantics(
        label: 'الجنس: ${gender.arabicLabel}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                gender.arabicLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: 'الجنس: ${gender.arabicLabel}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              gender.arabicLabel,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGenderColor(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Colors.blue;
      case Gender.female:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      default:
        return Icons.help_outline;
    }
  }
}
