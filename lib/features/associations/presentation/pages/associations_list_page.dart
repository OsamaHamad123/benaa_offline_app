import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/associations_provider.dart';
import '../widgets/association_card.dart';
import 'association_form_page.dart';

/// 🏢 Associations List Page
///
/// صفحة عرض قائمة الجمعيات مع إمكانية البحث والإضافة
class AssociationsListPage extends ConsumerStatefulWidget {
  const AssociationsListPage({super.key});

  @override
  ConsumerState<AssociationsListPage> createState() => _AssociationsListPageState();
}

class _AssociationsListPageState extends ConsumerState<AssociationsListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(associationsProvider.notifier).loadAssociations();
      ref.read(associationsProvider.notifier).loadRepresentatives();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(associationsProvider.notifier).searchAssociations(query);
  }

  Future<void> _navigateToForm({String? associationId}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AssociationFormPage(associationId: associationId),
      ),
    );

    // إذا تم الحفظ بنجاح، إعادة تحميل القائمة
    if (result == true && mounted) {
      ref.read(associationsProvider.notifier).loadAssociations();
    }
  }

  Future<void> _confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "$name"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(associationsProvider.notifier).deleteAssociation(id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الجمعية بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(associationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏢 إدارة الجمعيات'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'بحث عن جمعية...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Associations List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(associationsProvider.notifier).loadAssociations(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : state.associations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_outlined, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد جمعيات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ابدأ بإضافة جمعية جديدة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(associationsProvider.notifier).loadAssociations(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.associations.length,
                              itemBuilder: (context, index) {
                                final association = state.associations[index];
                                final representative = state.representatives.firstWhere(
                                  (r) => r.id == association.representativeId,
                                  orElse: () => null as dynamic,
                                );

                                return AssociationCard(
                                  association: association,
                                  representativeName: representative?.name,
                                  onEdit: () => _navigateToForm(associationId: association.id),
                                  onDelete: () => _confirmDelete(association.id, association.name),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: const Text('إضافة جمعية'),
      ),
    );
  }
}
