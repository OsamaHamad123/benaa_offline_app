import 'package:flutter/material.dart';

/// 📥 Civil Data Loader Widget
///
/// Button to load data from civil registry
class CivilDataLoaderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const CivilDataLoaderButton({
    required this.onPressed, required this.isLoading, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FilledButton.tonalIcon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: Text(isLoading ? 'جاري التحميل...' : 'تحميل من السجل المدني'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// 📥 Civil Data Loader Dialog Widget
///
/// Shows dialog to enter national ID and load data
class CivilDataLoaderDialog extends StatefulWidget {
  final Function(String) onLoad;

  const CivilDataLoaderDialog({required this.onLoad, super.key});

  @override
  State<CivilDataLoaderDialog> createState() => _CivilDataLoaderDialogState();
}

class _CivilDataLoaderDialogState extends State<CivilDataLoaderDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLoad(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download),
          SizedBox(width: 8),
          Text('تحميل من السجل المدني'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أدخل الرقم الوطني لتحميل البيانات من السجل المدني:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'الرقم الوطني',
                hintText: '12345678901',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الرقم الوطني';
                }
                if (value.trim().length < 8) {
                  return 'الرقم الوطني يجب أن يكون على الأقل 8 أرقام';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('تحميل')),
      ],
    );
  }
}
