import 'package:flutter/material.dart';

import '../form_constants.dart';
import 'bottom_navigation_buttons.dart';

/// 🎯 Form Bottom Navigation Widget (Separated for performance)
///
/// Only rebuilds when tab changes
class FormBottomNavWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final bool isLoading;

  const FormBottomNavWidget({
    required this.tabController, required this.onPrevious, required this.onNext, required this.onSave, required this.isLoading, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: tabController,
      builder: (context, _) {
        return RepaintBoundary(
          child: BottomNavigationButtons(
            currentTab: tabController.index,
            totalTabs: FormConstants.totalTabs,
            onPrevious: onPrevious,
            onNext: onNext,
            onSave: onSave,
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}
