import 'package:flutter/material.dart';
import 'family_statistics_widget.dart';
import 'family_list_widget.dart';

/// قسم متكامل لعرض وإدارة بيانات أفراد العائلة
/// يُستخدم داخل صفحة تفاصيل المستفيد
class FamilySection extends StatelessWidget {
  final int beneficiaryId;

  const FamilySection({required this.beneficiaryId, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.family_restroom,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة أفراد العائلة والمتوفين',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    'عرض سريع + قوائم تفصيلية + إجراءات مباشرة',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // الإحصائيات
        FamilyStatisticsWidget(beneficiaryId: beneficiaryId),

        const SizedBox(height: 16),

        // القوائم التفاعلية
        FamilyListWidget(beneficiaryId: beneficiaryId),
      ],
    );
  }
}
