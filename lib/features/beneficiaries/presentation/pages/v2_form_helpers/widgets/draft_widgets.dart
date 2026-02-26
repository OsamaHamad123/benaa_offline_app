import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📝 Draft Indicator Badge
///
/// Shows draft status in UI
class DraftIndicator extends StatelessWidget {
  final bool isDraft;
  final DateTime? lastSaved;
  final VoidCallback? onTap;

  const DraftIndicator({
    super.key,
    this.isDraft = false,
    this.lastSaved,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDraft) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final timeAgo = lastSaved != null ? _getTimeAgo(lastSaved!) : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drafts_outlined, size: 16.sp, color: Colors.orange),
            SizedBox(width: 6.w),
            Text(
              'مسودة',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            if (timeAgo.isNotEmpty) ...[
              SizedBox(width: 6.w),
              Text(
                '• $timeAgo',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

/// 📋 Resume Draft Dialog
class ResumeDraftDialog extends StatelessWidget {
  final List<Map<String, dynamic>> drafts;
  final Function(String draftId) onResume;
  final Function(String draftId) onDelete;

  const ResumeDraftDialog({
    required this.drafts,
    required this.onResume,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.drafts_rounded, color: theme.colorScheme.primary),
          SizedBox(width: 8.w),
          const Text('استكمال مسودة'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: drafts.length,
          separatorBuilder: (context, index) => Divider(height: 16.h),
          itemBuilder: (context, index) {
            final draft = drafts[index];
            final savedAt = DateTime.tryParse((draft['savedAt'] ?? '').toString());
            final name = (draft['firstName']?.toString().trim().isNotEmpty ?? false)
                ? draft['firstName'].toString().trim()
                : 'بدون اسم';
            final draftId = (draft['draftId'] ?? '').toString().trim();
            final savedAtLabel = savedAt != null ? _formatDateTime(savedAt) : 'غير معروف';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.orange,
                  size: 20.sp,
                ),
              ),
              title: Text(
                name,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                savedAtLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    onPressed: draftId.isEmpty ? null : () => onDelete(draftId),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                ],
              ),
              onTap: () {
                if (draftId.isEmpty) return;
                Navigator.of(context).pop();
                onResume(draftId);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'اليوم ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
