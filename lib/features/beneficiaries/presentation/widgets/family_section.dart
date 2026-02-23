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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الإحصائيات
        FamilyStatisticsWidget(beneficiaryId: beneficiaryId),

        const SizedBox(height: 16),

        // القوائم التفاعلية
        FamilyListWidget(beneficiaryId: beneficiaryId),
      ],
    );
  }
}
