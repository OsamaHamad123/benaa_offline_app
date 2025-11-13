import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📝 Notes Tab Widget
///
/// Contains: Notes field with character count
class NotesTab extends StatelessWidget {
  final TextEditingController notesController;

  const NotesTab({super.key, required this.notesController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: 'أضف أي ملاحظات إضافية هنا...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 15,
            minLines: 10,
          ),
          const SizedBox(height: 8),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: notesController,
            builder: (context, value, child) {
              final characterCount = value.text.length;
              return Text(
                'عدد الحروف: $characterCount',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // نصائح للملاحظات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نصائح للملاحظات:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem(
                  '• سجل أي معلومات إضافية قد تكون مفيدة',
                  colorScheme,
                ),
                _buildTipItem(
                  '• اذكر الاحتياجات الخاصة أو الظروف الاستثنائية',
                  colorScheme,
                ),
                _buildTipItem('• سجل تاريخ الزيارات والمتابعات', colorScheme),
                _buildTipItem(
                  '• أضف أي توصيات أو اقتراحات للمساعدة',
                  colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
