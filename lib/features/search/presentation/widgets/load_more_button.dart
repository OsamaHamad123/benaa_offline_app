import 'package:flutter/material.dart';

/// زر تحميل المزيد من النتائج
class LoadMoreButton extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onPressed;

  const LoadMoreButton({
    super.key,
    required this.isSearching,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isSearching
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_downward),
                label: const Text('تحميل المزيد'),
              ),
      ),
    );
  }
}
