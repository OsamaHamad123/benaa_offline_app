import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🚫 Empty state widget - Reusable component
///
/// يعرض رسالة فارغة مع أيقونة وزر action
class BeneficiariesEmptyState extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const BeneficiariesEmptyState({
    super.key,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon ?? Icons.people_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                message ?? 'لا يوجد مستفيدين',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (actionText != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed:
                      onAction ?? () => context.push('/beneficiaries/add'),
                  icon: const Icon(Icons.person_add),
                  label: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ⚠️ Error state widget - Reusable component
///
/// يعرض رسالة خطأ مع زر إعادة محاولة
class BeneficiariesErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const BeneficiariesErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'خطأ: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
