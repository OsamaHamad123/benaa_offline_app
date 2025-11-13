import 'package:flutter/material.dart';

/// شريط التطبيق أثناء التحميل
class LoadingAppBar extends StatelessWidget {
  const LoadingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('السجل المدني'),
        background: Container(
          color: Theme.of(context).colorScheme.primary,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
