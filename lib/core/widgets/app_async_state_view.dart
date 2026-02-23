import 'package:flutter/material.dart';

class AppAsyncStateView extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool loading;
  final EdgeInsetsGeometry padding;

  const AppAsyncStateView.loading({
    super.key,
    this.message = 'جاري التحميل...',
    this.padding = const EdgeInsets.all(16),
  })  : icon = Icons.hourglass_top_rounded,
        onRetry = null,
        loading = true;

  const AppAsyncStateView.error({
    required this.message,
    this.onRetry,
    this.padding = const EdgeInsets.all(16),
    super.key,
  })  : icon = Icons.error_outline_rounded,
        loading = false;

  const AppAsyncStateView.empty({
    required this.message,
    this.padding = const EdgeInsets.all(16),
    super.key,
  })  : icon = Icons.inbox_outlined,
        onRetry = null,
        loading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

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
            if (loading)
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
                style: textStyle?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (!loading && onRetry != null)
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
