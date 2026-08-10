import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 💾 Form Draft - مسودة نموذج
class FormDraft {
  final String formType;
  final Map<String, dynamic> data;
  final DateTime savedAt;

  FormDraft({
    required this.formType,
    required this.data,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'formType': formType,
        'data': data,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FormDraft.fromJson(Map<String, dynamic> json) {
    return FormDraft(
      formType: json['formType'],
      data: Map<String, dynamic>.from(json['data']),
      savedAt: DateTime.parse(json['savedAt']),
    );
  }
}

/// 📝 Form Draft Manager - مدير المسودات
class FormDraftManager {
  static const String _keyPrefix = 'form_draft_';

  /// حفظ مسودة
  static Future<void> saveDraft({
    required String formType,
    required String formId,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${formType}_$formId';

    final draft = FormDraft(
      formType: formType,
      data: data,
      savedAt: DateTime.now(),
    );

    await prefs.setString(key, json.encode(draft.toJson()));
  }

  /// تحميل مسودة
  static Future<FormDraft?> loadDraft({
    required String formType,
    required String formId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${formType}_$formId';

    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final jsonData = json.decode(jsonString);
      return FormDraft.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// حذف مسودة
  static Future<void> deleteDraft({
    required String formType,
    required String formId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${formType}_$formId';
    await prefs.remove(key);
  }

  /// الحصول على جميع المسودات
  static Future<List<FormDraft>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));

    final drafts = <FormDraft>[];
    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final draft = FormDraft.fromJson(json.decode(jsonString));
          drafts.add(draft);
        } catch (e) {
          // Ignore invalid drafts
        }
      }
    }

    // Sort by savedAt descending
    drafts.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return drafts;
  }

  /// حذف المسودات القديمة (أكثر من 30 يوم)
  static Future<void> cleanupOldDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));

    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final draft = FormDraft.fromJson(json.decode(jsonString));
          if (draft.savedAt.isBefore(cutoffDate)) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Remove invalid drafts
          await prefs.remove(key);
        }
      }
    }
  }

  /// عدد المسودات
  static Future<int> getDraftsCount() async {
    final drafts = await getAllDrafts();
    return drafts.length;
  }
}

/// Provider للمسودات
final formDraftsProvider = FutureProvider<List<FormDraft>>((ref) async {
  return FormDraftManager.getAllDrafts();
});

final draftsCountProvider = FutureProvider<int>((ref) async {
  return FormDraftManager.getDraftsCount();
});

/// 🎯 Draft Mixin - خليط للمسودات
mixin FormDraftMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get formType;
  String get formId;

  /// حفظ البيانات كمسودة
  Future<void> saveDraft(Map<String, dynamic> data) async {
    await FormDraftManager.saveDraft(
      formType: formType,
      formId: formId,
      data: data,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ المسودة'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// تحميل المسودة
  Future<Map<String, dynamic>?> loadDraft() async {
    final draft = await FormDraftManager.loadDraft(
      formType: formType,
      formId: formId,
    );

    if (draft != null && mounted) {
      final shouldLoad = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('مسودة محفوظة'),
          content: Text(
            'تم العثور على مسودة محفوظة بتاريخ ${_formatDate(draft.savedAt)}\nهل تريد تحميلها؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );

      if (shouldLoad == true) {
        return draft.data;
      }
    }

    return null;
  }

  /// حذف المسودة
  Future<void> deleteDraft() async {
    await FormDraftManager.deleteDraft(formType: formType, formId: formId);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// 📋 Drafts Viewer - عارض المسودات
class DraftsViewer extends ConsumerWidget {
  const DraftsViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(formDraftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسودات المحفوظة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'حذف المسودات القديمة',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف المسودات القديمة'),
                  content: const Text(
                    'هل تريد حذف جميع المسودات الأقدم من 30 يوم؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await FormDraftManager.cleanupOldDrafts();
                ref.invalidate(formDraftsProvider);
                ref.invalidate(draftsCountProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المسودات القديمة')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: draftsAsync.when(
        data: (drafts) {
          if (drafts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drafts, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مسودات محفوظة',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return _buildDraftCard(context, ref, draft);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }

  Widget _buildDraftCard(BuildContext context, WidgetRef ref, FormDraft draft) {
    final date = draft.savedAt;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    String formTypeLabel;
    IconData icon;
    switch (draft.formType) {
      case 'visit':
        formTypeLabel = 'زيارة';
        icon = Icons.home_outlined;
        break;
      case 'beneficiary':
        formTypeLabel = 'مستفيد';
        icon = Icons.person_outline;
        break;
      case 'survey':
        formTypeLabel = 'استبيان';
        icon = Icons.assignment_outlined;
        break;
      default:
        formTypeLabel = draft.formType;
        icon = Icons.description_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          formTypeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateStr),
            const SizedBox(height: 4),
            Text(
              '${draft.data.length} حقل محفوظ',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('حذف المسودة'),
                content: const Text('هل تريد حذف هذه المسودة؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              // Extract formId from data (assuming it's stored there)
              final formId = draft.data['id']?.toString() ?? 'unknown';
              await FormDraftManager.deleteDraft(
                formType: draft.formType,
                formId: formId,
              );
              ref.invalidate(formDraftsProvider);
              ref.invalidate(draftsCountProvider);
            }
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// 🔔 Draft Indicator - مؤشر وجود مسودات
class DraftIndicator extends ConsumerWidget {
  const DraftIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(draftsCountProvider);

    return countAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        return Badge(
          label: Text('$count'),
          child: IconButton(
            icon: const Icon(Icons.drafts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DraftsViewer()),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
