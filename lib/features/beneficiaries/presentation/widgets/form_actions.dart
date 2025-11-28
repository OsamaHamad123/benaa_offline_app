import 'package:flutter/material.dart';

/// 🎬 Form Actions Widget
///
/// Bottom action buttons (Save, Cancel, Delete)
class FormActions extends StatelessWidget {
  final bool canSave;
  final bool isSaving;
  final bool isNew;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  const FormActions({
    super.key,
    required this.canSave,
    required this.isSaving,
    required this.isNew,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancel button
            Expanded(
              child: Semantics(
                label: 'إلغاء التعديلات',
                hint: 'الرجوع بدون حفظ',
                button: true,
                enabled: !isSaving,
                child: OutlinedButton(
                  onPressed: isSaving ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Save button
            Expanded(
              flex: 2,
              child: Semantics(
                label: isSaving ? 'جاري حفظ البيانات' : 'حفظ البيانات',
                hint: 'اضغط لحفظ جميع التغييرات',
                button: true,
                enabled: canSave && !isSaving,
                child: FilledButton.icon(
                  onPressed: canSave && !isSaving ? onSave : null,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Delete button (only for existing records)
            if (!isNew && onDelete != null) ...[
              const SizedBox(width: 12),
              Semantics(
                label: 'حذف المستفيد',
                hint: 'حذف نهائي للسجل',
                button: true,
                enabled: !isSaving,
                child: IconButton(
                  onPressed: isSaving ? null : onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'حذف',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🗑️ Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String beneficiaryName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.beneficiaryName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colorScheme.error,
        size: 48,
      ),
      title: const Text('تأكيد الحذف'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'هل أنت متأكد من حذف المستفيد؟',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            beneficiaryName,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يمكن التراجع عن هذا الإجراء',
            style: TextStyle(fontSize: 12, color: colorScheme.error),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
