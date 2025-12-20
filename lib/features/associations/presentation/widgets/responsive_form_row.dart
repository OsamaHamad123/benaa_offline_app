import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 📏 Responsive Form Row - تقسيم الحقول على عمودين في التابلت
class ResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveFormRow({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.mediumSpace;

    // موبايل أو حقل واحد: عمود واحد
    if (ResponsiveUtils.isMobile(context) || children.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.expand((child) => [child, if (child != children.last) SizedBox(height: spacing)]).toList(),
      );
    }

    // تابلت+: صفين مع مراعاة الحقول الفردية
    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب عرض كل عمود مع spacing
        final availableWidth = constraints.maxWidth;
        final colWidth = (availableWidth - spacing) / 2;

        // إذا كان عدد الحقول فردي، آخر حقل ياخذ السطر كامل
        final hasOddCount = children.length % 2 != 0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // كل الحقول ما عدا الأخير (إذا كان فردي)
            for (var i = 0; i < (hasOddCount ? children.length - 1 : children.length); i++)
              SizedBox(
                width: colWidth,
                child: children[i],
              ),
            // آخر حقل (إذا فردي) ياخذ السطر كامل
            if (hasOddCount)
              SizedBox(
                width: availableWidth,
                child: children.last,
              ),
          ],
        );
      },
    );
  }
}
