import 'package:flutter/material.dart';

/// شريط التطبيق عند حدوث خطأ
class ErrorAppBar extends StatelessWidget {
  const ErrorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('السجل المدني'),
        background: Container(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
