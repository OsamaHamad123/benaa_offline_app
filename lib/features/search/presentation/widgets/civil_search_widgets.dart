import 'package:flutter/material.dart';

/// 📊 Statistics Chip Widget - const optimized
class StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatChip({
    required this.value, required this.label, required this.icon, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Custom Sliver App Bar
class CivilSearchAppBar extends StatelessWidget {
  final int totalPersons;
  final int malesCount;
  final int femalesCount;

  const CivilSearchAppBar({
    required this.totalPersons, required this.malesCount, required this.femalesCount, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return SliverAppBar(
      expandedHeight: isMobile ? 180 : 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'السجل المدني',
          style: TextStyle(fontSize: isMobile ? 16 : 20),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.search,
                  size: isMobile ? 150 : 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: isMobile ? 50 : 60,
                left: 8,
                right: 8,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    StatChip(
                      value: '$totalPersons',
                      label: 'إجمالي',
                      icon: Icons.people,
                    ),
                    StatChip(
                      value: '$malesCount',
                      label: 'ذكور',
                      icon: Icons.male,
                    ),
                    StatChip(
                      value: '$femalesCount',
                      label: 'إناث',
                      icon: Icons.female,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔍 Search Bar Widget
class CivilSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool isSearching;
  final String query;

  const CivilSearchBar({
    required this.controller, required this.onChanged, required this.onClear, required this.isSearching, required this.query, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ابحث في السجل المدني',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 24,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            'أدخل الاسم أو الرقم الوطني للبحث',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'مثال: محمد علي أو 12345678901',
              hintStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              prefixIcon: isSearching
                  ? Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 14),
                      child: SizedBox(
                        width: isMobile ? 16 : 20,
                        height: isMobile ? 16 : 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
        ],
      ),
    );
  }
}

/// 🔧 Filter Chips Widget
class CivilSearchFilters extends StatelessWidget {
  final String? selectedGovernorate;
  final String? selectedGender;
  final List<String> governorates;
  final Function(String?) onGovernorateChanged;
  final Function(String?) onGenderChanged;
  final VoidCallback onClearFilters;

  const CivilSearchFilters({
    required this.selectedGovernorate, required this.selectedGender, required this.governorates, required this.onGovernorateChanged, required this.onGenderChanged, required this.onClearFilters, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: Wrap(
        spacing: isMobile ? 6 : 8,
        runSpacing: isMobile ? 6 : 8,
        children: [
          // Governorate Filter
          FilterChip(
            label: Text(
              selectedGovernorate ?? 'المحافظة',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            selected: selectedGovernorate != null,
            onSelected: (selected) async {
              if (!selected) {
                onGovernorateChanged(null);
                return;
              }

              final result = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children: governorates.map((gov) {
                    return ListTile(
                      title: Text(gov),
                      onTap: () => Navigator.pop(context, gov),
                    );
                  }).toList(),
                ),
              );

              if (result != null) {
                onGovernorateChanged(result);
              }
            },
            avatar: Icon(Icons.location_on, size: isMobile ? 16 : 18),
          ),

          // Gender Filter
          FilterChip(
            label: Text(
              selectedGender ?? 'الجنس',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            selected: selectedGender != null,
            onSelected: (selected) async {
              if (!selected) {
                onGenderChanged(null);
                return;
              }

              final result = await showDialog<String>(
                context: context,
                builder: (context) => const SimpleDialog(
                  title: Text('اختر الجنس'),
                  children: [
                    SimpleDialogOption(child: Text('ذكر')),
                    SimpleDialogOption(child: Text('أنثى')),
                  ],
                ),
              );

              if (result != null) {
                onGenderChanged(result);
              }
            },
            avatar: Icon(Icons.wc, size: isMobile ? 16 : 18),
          ),

          // Clear Filters
          if (selectedGovernorate != null || selectedGender != null)
            ActionChip(
              label: Text(
                'إزالة التصفية',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              onPressed: onClearFilters,
              avatar: Icon(Icons.clear_all, size: isMobile ? 16 : 18),
            ),
        ],
      ),
    );
  }
}
