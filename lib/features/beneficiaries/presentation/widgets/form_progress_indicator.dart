import 'package:flutter/material.dart';
import '../../domain/entities/beneficiary.dart';

/// 📊 Form Progress Indicator Widget
///
/// Shows completion percentage with circular progress
class FormProgressIndicator extends StatelessWidget {
  final Beneficiary? beneficiary;

  const FormProgressIndicator({required this.beneficiary, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (beneficiary == null) {
      return const SizedBox.shrink();
    }

    final percentage = beneficiary!.completionPercentage;
    final isComplete = beneficiary!.isComplete;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? colorScheme.primary : colorScheme.secondary,
                  ),
                  strokeWidth: 4,
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isComplete ? 'مكتمل' : 'غير مكتمل',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isComplete
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                isComplete
                    ? 'جميع الحقول الإلزامية مكتملة'
                    : 'بعض الحقول لم تُملأ بعد',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
