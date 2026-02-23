import 'package:flutter/material.dart';

/// Reusable card container for charts
class ChartSection extends StatelessWidget {
  final String title;
  final Widget chart;
  final EdgeInsets? padding;

  const ChartSection({
    required this.title, required this.chart, super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }
}
