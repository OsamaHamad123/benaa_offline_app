import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/kafalat_providers.dart';

/// Dropdown مشترك لاختيار المؤسسة الكافلة.
///
/// يعالج تلقائياً:
/// - حالة التحميل  (loading)
/// - حالة الخطأ    (error)
/// - حالة القائمة الفارغة (empty)
///
/// مقاوم للـ overflow:
/// - [isExpanded: true] يمنع تجاوز عرض الحقل.
/// - [TextOverflow.ellipsis] + [maxLines: 1] لكل بند.
/// - [selectedItemBuilder] يعرض الاسم المختصر داخل الحقل.
/// - [Tooltip] يعرض الاسم الكامل عند الضغط المطوّل على البند.
class SponsorOrganizationDropdown extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String label;
  final bool enabled;
  final String? Function(String?)? validator;
  final String? hintText;

  const SponsorOrganizationDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'المؤسسة الكافلة',
    this.enabled = true,
    this.validator,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final associationsAsync = ref.watch(kafalatActiveAssociationsProvider);
    final theme = Theme.of(context);

    return associationsAsync.when(
      // ─── تحميل ──────────────────────────────────────────────────────────
      loading: () => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: const LinearProgressIndicator(minHeight: 2),
      ),

      // ─── خطأ ────────────────────────────────────────────────────────────
      error: (e, _) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: 'فشل تحميل المؤسسات',
        ),
        child: const SizedBox.shrink(),
      ),

      // ─── بيانات ─────────────────────────────────────────────────────────
      data: (associations) {
        // حالة فارغة
        if (associations.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            child: Text(
              'لا توجد مؤسسات كافلة متاحة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }

        return DropdownButtonFormField<String>(
          // ── overflow ────────────────────────────────────
          isExpanded: true,

          // ── value ───────────────────────────────────────
          initialValue: value,

          // ── decoration ──────────────────────────────────
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),

          // ── selectedItemBuilder ──────────────────────────
          // يعرض الاسم المقطوع داخل الحقل فقط (ليس في القائمة)
          selectedItemBuilder: (ctx) => associations
              .map(
                (a) => Text(
                  a.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium,
                ),
              )
              .toList(),

          // ── items ────────────────────────────────────────
          items: associations
              .map(
                (a) => DropdownMenuItem<String>(
                  value: a.id,
                  child: Tooltip(
                    message: a.name,
                    preferBelow: true,
                    child: Text(
                      a.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              )
              .toList(),

          // ── callbacks ────────────────────────────────────
          onChanged: enabled ? onChanged : null,
          validator: validator,
        );
      },
    );
  }
}
