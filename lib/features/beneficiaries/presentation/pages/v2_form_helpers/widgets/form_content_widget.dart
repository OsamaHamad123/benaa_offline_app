import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../form_controllers.dart';
import '../form_constants.dart';
import 'form_tabs_4_merged.dart';

/// 📝 Form Content Widget (Separated for performance)
///
/// Contains TabBar and TabBarView - rebuilt only when needed
/// Search state is local to prevent parent rebuilds
class FormContentWidget extends StatefulWidget {
  final TabController tabController;
  final BeneficiaryFormControllers controllers;
  final VoidCallback onBirthDateTap;
  final FocusNode firstFieldFocusNode;
  final String? beneficiaryId;
  final bool showFieldHelpers;
  final VoidCallback? onFinalSave; // 🆕 Callback for final save from review tab

  const FormContentWidget({
    super.key,
    required this.tabController,
    required this.controllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
    required this.showFieldHelpers,
    this.onFinalSave,
  });

  @override
  State<FormContentWidget> createState() => _FormContentWidgetState();
}

class _FormContentWidgetState extends State<FormContentWidget> {
  // ⚡ Local state - prevents parent rebuilds
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 🔍 Quick Search Bar (if active)
        if (_searchQuery.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: theme.colorScheme.primaryContainer,
            child: QuickSearchInput(
              controller: _searchController,
              hint: 'ابحث في الحقول...',
              onSearch: (query) {
                setState(() => _searchQuery = query); // Local setState only!
              },
            ),
          ),

        // Simple TabBar without stats
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: TabBar(
            controller: widget.tabController,
            tabs: FormTabs.tabs.map((tab) => Tab(text: tab.title)).toList(),
          ),
        ),

        // ⚡ TabBarView with proper sizing - NO ScrollView!
        Expanded(
          child: BeneficiaryFormTabs4Merged(
            controller: widget.tabController,
            formControllers: widget.controllers,
            onBirthDateTap: widget.onBirthDateTap,
            firstFieldFocusNode: widget.firstFieldFocusNode,
            beneficiaryId: widget.beneficiaryId,
            onFinalSave: widget.onFinalSave, // 🆕 Pass callback
          ),
        ),
      ],
    );
  }
}

/// 🔍 Quick Search Input Widget
class QuickSearchInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSearch;

  const QuickSearchInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      onChanged: onSearch,
    );
  }
}
