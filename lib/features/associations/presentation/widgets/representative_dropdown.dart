import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/associations_provider.dart';

/// 👤 Representative Dropdown Widget
///
/// قائمة منسدلة لاختيار مندوب جمعية مع إمكانية الإضافة
class RepresentativeDropdown extends ConsumerStatefulWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const RepresentativeDropdown({
    super.key,
    this.selectedId,
    required this.onChanged,
  });

  @override
  ConsumerState<RepresentativeDropdown> createState() => _RepresentativeDropdownState();
}

class _RepresentativeDropdownState extends ConsumerState<RepresentativeDropdown> {
  @override
  void initState() {
    super.initState();
    // تحميل المندوبين عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(associationsProvider.notifier).loadRepresentatives();
    });
  }

  Future<void> _addNewRepresentative() async {
    final nameController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مندوب جديد'),
        content: TextField(
          controller: nameController,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            labelText: 'اسم المندوب',
            hintText: 'أحمد محمد',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      final representative = await ref.read(associationsProvider.notifier).createRepresentative(name);

      if (representative != null && mounted) {
        widget.onChanged(representative.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المندوب بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(associationsProvider);
    final representatives = state.representatives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: widget.selectedId,
          decoration: InputDecoration(
            labelText: 'مندوب الجمعية',
            hintText: 'اختر المندوب',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: representatives.map((rep) {
            return DropdownMenuItem(
              value: rep.id,
              child: Text(rep.name),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addNewRepresentative,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('إضافة مندوب جديد'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }
}
