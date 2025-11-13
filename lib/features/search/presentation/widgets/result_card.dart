import 'package:flutter/material.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/civil_person.dart';

/// بطاقة عرض نتيجة البحث - Clean Architecture
class ResultCard extends StatelessWidget {
  final CivilPerson person;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;

  const ResultCard({
    super.key,
    required this.person,
    required this.onCopy,
    required this.onAddAsBeneficiary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: InkWell(
        onTap: onAddAsBeneficiary,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.fullName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              InfoRow(
                icon: Icons.badge,
                label: 'الرقم الوطني',
                value: person.nationalId,
              ),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.wc,
                label: 'الجنس',
                value: person.gender.arabicLabel,
              ),
              if (person.city != null && person.city!.isNotEmpty) ...[
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.location_city,
                  label: 'المدينة',
                  value: person.city!,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy),
                      label: const Text('نسخ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onAddAsBeneficiary,
                      icon: const Icon(Icons.person_add),
                      label: const Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
