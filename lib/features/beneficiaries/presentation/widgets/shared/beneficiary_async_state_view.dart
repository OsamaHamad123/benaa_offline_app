import 'package:flutter/material.dart';

class BeneficiaryAsyncStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

  const BeneficiaryAsyncStateView.loading({
    super.key,
    this.message = 'جاري التحميل...',
    this.padding = const EdgeInsets.all(16),
  })  : icon = Icons.hourglass_top_rounded,
        onRetry = null,
        isLoading = true;

  const BeneficiaryAsyncStateView.error({
    required this.message,
    this.onRetry,
    this.padding = const EdgeInsets.all(16),
    super.key,
  })  : icon = Icons.error_outline_rounded,
        isLoading = false;

  const BeneficiaryAsyncStateView.empty({
    required this.message,
    this.padding = const EdgeInsets.all(16),
    super.key,
  })  : icon = Icons.info_outline_rounded,
        onRetry = null,
        isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (!isLoading && onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة المحاولة'),
              ),
          ],
        ),
      ),
    );
  }
}
