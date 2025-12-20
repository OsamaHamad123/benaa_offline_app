import 'package:flutter/material.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';

/// 🆔 National ID Field with Civil Registry
///
/// حقل الرقم الوطني مع زر البحث في السجل المدني
class NationalIdWithCivilRegistry extends StatelessWidget {
  final TextEditingController nationalIdController;
  final bool isFetching;
  final String? statusMessage;
  final VoidCallback onFetch;
  final ValueChanged<String> onChanged;
  final bool hideButtonAfterFetch;

  const NationalIdWithCivilRegistry({
    super.key,
    required this.nationalIdController,
    required this.isFetching,
    required this.statusMessage,
    required this.onFetch,
    required this.onChanged,
    this.hideButtonAfterFetch = false,
  });

  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'الرقم الوطني',
      icon: Icons.badge_rounded,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: M3TextField(
                controller: nationalIdController,
                label: 'الرقم الوطني',
                prefixIcon: Icons.badge,
                keyboardType: TextInputType.number,
                maxLength: 9,
                isRequired: true,
                onChanged: onChanged,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'مطلوب';
                  if (v!.length != 9) return '9 أرقام';
                  return null;
                },
              ),
            ),
            if (!hideButtonAfterFetch) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: FilledButton.tonalIcon(
                    onPressed: isFetching ? null : onFetch,
                    icon: isFetching
                        ? const SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search, size: 18.0),
                    label: const Text('بحث', style: TextStyle(fontSize: 11.0)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: 12.0),
          CivilRegistryStatus(message: statusMessage!),
        ],
      ],
    );
  }
}

/// حالة نتيجة البحث في السجل المدني
class CivilRegistryStatus extends StatelessWidget {
  final String message;

  const CivilRegistryStatus({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.contains('✅');

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            size: 18.0,
            color: isSuccess ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
