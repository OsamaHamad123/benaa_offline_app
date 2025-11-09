import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/optimized_civil_search_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/form_widgets.dart';
import '../../data/models/civil_record.dart';

/// 🔍 صفحة البحث في السجل المدني - محسّنة وفخمة
///
/// ✨ Features:
/// - بحث سريع جداً مع Indexing
/// - Fuzzy Matching للأخطاء الإملائية
/// - Arabic Normalization
/// - Filters متقدمة (محافظة، جنس)
/// - Debouncing لتحسين الأداء
/// - Ranked Results حسب التطابق
/// - ربط مباشر مع إضافة المستفيد

class CivilSearchPageEnhanced extends ConsumerStatefulWidget {
  const CivilSearchPageEnhanced({super.key});

  @override
  ConsumerState<CivilSearchPageEnhanced> createState() =>
      _CivilSearchPageEnhancedState();
}

class _CivilSearchPageEnhancedState
    extends ConsumerState<CivilSearchPageEnhanced> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _searchQuery = '';
  bool _isSearching = false;
  bool _isInitialized = false;
  List<SearchResult> _searchResults = [];

  // Filters
  String? _selectedGovernorate;
  String? _selectedGender;

  // Statistics
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isInitialized = false);
    try {
      await OptimizedCivilSearchService.initialize();
      final stats = await OptimizedCivilSearchService.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل التهيئة: $e');
      }
    }
  }

  /// البحث مع Debouncing
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);

    // إلغاء المؤقت السابق
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // تأخير 300ms قبل البحث
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await OptimizedCivilSearchService.smartSearch(
        _searchQuery,
        governorate: _selectedGovernorate,
        gender: _selectedGender,
        limit: 50,
      );

      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      if (mounted) {
        _showError('خطأ في البحث: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _selectedGovernorate = null;
      _selectedGender = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// نسخ البيانات للحافظة
  void _copyToClipboard(CivilRecord record) {
    final text =
        '''
الاسم: ${record.fullName}
الرقم الوطني: ${record.nationalId}
اسم الأب: ${record.fatherName}
اسم الأم: ${record.motherName}
تاريخ الميلاد: ${record.birthDate}
الجنس: ${record.gender == 'male' ? 'ذكر' : 'أنثى'}
المحافظة: ${record.governorate}
القضاء: ${record.district}
''';
    Clipboard.setData(ClipboardData(text: text));
    _showSuccess('تم النسخ إلى الحافظة');
  }

  /// إضافة كمستفيد مباشرة
  void _addAsBeneficiary(CivilRecord record) {
    // الانتقال إلى صفحة الإضافة مع البيانات
    context.push('/beneficiaries/add', extra: record.toBeneficiaryData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rv = ResponsiveUtils.getValues(context);

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('السجل المدني')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar مع Gradient
          _buildSliverAppBar(theme),

          // Search Section
          SliverToBoxAdapter(child: _buildSearchSection(rv, theme)),

          // Filters
          if (_searchQuery.isNotEmpty)
            SliverToBoxAdapter(child: _buildFiltersSection(rv, theme)),

          // Results or Empty State
          _buildResults(rv, theme),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return SliverAppBar(
      expandedHeight: isMobile ? 180 : 200,
      floating: false,
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
              if (_stats != null)
                Positioned(
                  bottom: isMobile ? 50 : 60,
                  left: 8,
                  right: 8,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        '${_stats!['totalRecords']}',
                        'إجمالي',
                        Icons.people,
                      ),
                      _buildStatChip('${_stats!['males']}', 'ذكور', Icons.male),
                      _buildStatChip(
                        '${_stats!['females']}',
                        'إناث',
                        Icons.female,
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

  Widget _buildStatChip(String value, String label, IconData icon) {
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

  Widget _buildSearchSection(ResponsiveValues rv, ThemeData theme) {
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'مثال: محمد علي أو 12345678901',
              hintStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              prefixIcon: _isSearching
                  ? Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 14),
                      child: SizedBox(
                        width: isMobile ? 16 : 20,
                        height: isMobile ? 16 : 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
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
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ResponsiveValues rv, ThemeData theme) {
    final governorates = _stats!['governorates'] as List<String>;
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : rv.padding.horizontal,
      ),
      child: Wrap(
        spacing: isMobile ? 6 : 8,
        runSpacing: isMobile ? 6 : 8,
        children: [
          // Governorate Filter
          FilterChip(
            label: Text(
              _selectedGovernorate ?? 'المحافظة',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            selected: _selectedGovernorate != null,
            onSelected: (selected) async {
              if (!selected) {
                setState(() => _selectedGovernorate = null);
                _performSearch();
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
                setState(() => _selectedGovernorate = result);
                _performSearch();
              }
            },
            avatar: Icon(Icons.location_on, size: isMobile ? 16 : 18),
          ),

          // Gender Filter
          FilterChip(
            label: Text(
              _selectedGender == null
                  ? 'الجنس'
                  : _selectedGender == 'male'
                  ? 'ذكر'
                  : 'أنثى',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            selected: _selectedGender != null,
            onSelected: (selected) async {
              if (!selected) {
                setState(() => _selectedGender = null);
                _performSearch();
                return;
              }

              final result = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('اختر الجنس'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'male'),
                      child: const Text('ذكر'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'female'),
                      child: const Text('أنثى'),
                    ),
                  ],
                ),
              );

              if (result != null) {
                setState(() => _selectedGender = result);
                _performSearch();
              }
            },
            avatar: Icon(Icons.wc, size: isMobile ? 16 : 18),
          ),

          // Clear Filters
          if (_selectedGovernorate != null || _selectedGender != null)
            ActionChip(
              label: Text(
                'إزالة التصفية',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              onPressed: () {
                setState(() {
                  _selectedGovernorate = null;
                  _selectedGender = null;
                });
                _performSearch();
              },
              avatar: Icon(Icons.clear_all, size: isMobile ? 16 : 18),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(ResponsiveValues rv, ThemeData theme) {
    if (_searchQuery.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateCard(
          icon: Icons.search,
          title: 'ابحث عن مواطن',
          message: 'أدخل الاسم أو الرقم الوطني للبحث في السجل المدني',
        ),
      );
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return SliverFillRemaining(
        child: EmptyStateCard(
          icon: Icons.search_off,
          title: 'لا توجد نتائج',
          message: 'لم يتم العثور على نتائج مطابقة لـ "$_searchQuery"',
        ),
      );
    }

    return SliverPadding(
      padding: rv.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final result = _searchResults[index];
          return _CivilRecordCardEnhanced(
            result: result,
            onCopy: () => _copyToClipboard(result.record),
            onAddAsBeneficiary: () => _addAsBeneficiary(result.record),
          );
        }, childCount: _searchResults.length),
      ),
    );
  }
}

/// بطاقة سجل مدني محسّنة
class _CivilRecordCardEnhanced extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;

  const _CivilRecordCardEnhanced({
    required this.result,
    required this.onCopy,
    required this.onAddAsBeneficiary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final record = result.record;
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onAddAsBeneficiary,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      record.gender == 'male'
                          ? Icons.person
                          : Icons.person_outline,
                      color: theme.colorScheme.primary,
                      size: isMobile ? 24 : 32,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: isMobile ? 12 : 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${record.governorate} - ${record.district}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  fontSize: isMobile ? 11 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Match Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchColor(result.matchScore).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMatchIcon(result.matchScore),
                          size: 14,
                          color: _getMatchColor(result.matchScore),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(result.matchScore * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getMatchColor(result.matchScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Details
              _InfoRow(
                icon: Icons.badge,
                label: 'الرقم الوطني',
                value: record.nationalId,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.person,
                label: 'اسم الأب',
                value: record.fatherName,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'اسم الأم',
                value: record.motherName ?? 'غير محدد',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.cake,
                label: 'تاريخ الميلاد',
                value: record.birthDate != null
                    ? '${record.birthDate!.day}/${record.birthDate!.month}/${record.birthDate!.year}'
                    : 'غير محدد',
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('نسخ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onAddAsBeneficiary,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('إضافة كمستفيد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMatchColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.75) return Colors.blue;
    return Colors.orange;
  }

  IconData _getMatchIcon(double score) {
    if (score >= 0.9) return Icons.check_circle;
    if (score >= 0.75) return Icons.thumb_up;
    return Icons.search;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
