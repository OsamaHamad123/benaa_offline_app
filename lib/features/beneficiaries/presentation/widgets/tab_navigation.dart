import 'package:flutter/material.dart';

/// 📑 Tab Navigation Widget
///
/// Custom tab bar with icons and labels
class BeneficiaryTabNavigation extends StatelessWidget {
  final TabController controller;
  final List<TabData> tabs;

  const BeneficiaryTabNavigation({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: tabs.map((tab) {
          return Tab(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon),
                if (tab.badge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tab.badgeColor ?? colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tab.badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            text: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Tab data model
class TabData {
  final String label;
  final IconData icon;
  final String? badge;
  final Color? badgeColor;

  const TabData({
    required this.label,
    required this.icon,
    this.badge,
    this.badgeColor,
  });
}
