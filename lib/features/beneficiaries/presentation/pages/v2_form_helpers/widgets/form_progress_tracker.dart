import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 Form Progress Tracker
///
/// Smart progress tracking system with motivational messages
///
/// Features:
/// - Section-by-section progress
/// - Required vs optional field indicators
/// - Visual progress bars
/// - Motivational messages
/// - Completion estimation
///
/// Usage:
/// ```dart
/// FormProgressTracker(
///   sections: [
///     FormSection(name: 'المعلومات الشخصية', requiredFields: 5, completedFields: 3),
///   ],
/// )
/// ```

/// Form section data
class FormSection {
  final String name;
  final IconData icon;
  final int requiredFields;
  final int optionalFields;
  final int completedRequiredFields;
  final int completedOptionalFields;
  final Color color;

  const FormSection({
    required this.name,
    this.icon = Icons.text_fields,
    required this.requiredFields,
    this.optionalFields = 0,
    this.completedRequiredFields = 0,
    this.completedOptionalFields = 0,
    this.color = Colors.blue,
  });

  /// Get progress percentage (0-100)
  double get progress {
    final total = requiredFields + optionalFields;
    if (total == 0) return 100.0;
    final completed = completedRequiredFields + completedOptionalFields;
    return (completed / total * 100).clamp(0.0, 100.0);
  }

  /// Get required fields progress percentage
  double get requiredProgress {
    if (requiredFields == 0) return 100.0;
    return (completedRequiredFields / requiredFields * 100).clamp(0.0, 100.0);
  }

  /// Check if section is complete (all required fields filled)
  bool get isComplete => completedRequiredFields >= requiredFields;

  /// Get remaining required fields
  int get remainingRequired => requiredFields - completedRequiredFields;

  /// Get remaining optional fields
  int get remainingOptional => optionalFields - completedOptionalFields;

  /// Copy with updated values
  FormSection copyWith({
    String? name,
    IconData? icon,
    int? requiredFields,
    int? optionalFields,
    int? completedRequiredFields,
    int? completedOptionalFields,
    Color? color,
  }) {
    return FormSection(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      requiredFields: requiredFields ?? this.requiredFields,
      optionalFields: optionalFields ?? this.optionalFields,
      completedRequiredFields:
          completedRequiredFields ?? this.completedRequiredFields,
      completedOptionalFields:
          completedOptionalFields ?? this.completedOptionalFields,
      color: color ?? this.color,
    );
  }
}

/// Form progress tracker widget
class FormProgressTracker extends StatelessWidget {
  final List<FormSection> sections;
  final bool showMotivationalMessage;
  final bool showCompactView;
  final VoidCallback? onTapIncomplete;

  const FormProgressTracker({
    super.key,
    required this.sections,
    this.showMotivationalMessage = true,
    this.showCompactView = false,
    this.onTapIncomplete,
  });

  /// Calculate overall progress
  double get overallProgress {
    if (sections.isEmpty) return 0;

    int totalRequired = 0;
    int completedRequired = 0;
    int totalOptional = 0;
    int completedOptional = 0;

    for (var section in sections) {
      totalRequired += section.requiredFields;
      completedRequired += section.completedRequiredFields;
      totalOptional += section.optionalFields;
      completedOptional += section.completedOptionalFields;
    }

    final total = totalRequired + totalOptional;
    if (total == 0) return 100;

    final completed = completedRequired + completedOptional;
    return (completed / total * 100).clamp(0.0, 100.0);
  }

  /// Get completion status color
  Color get statusColor {
    final progress = overallProgress;
    if (progress >= 100) return Colors.green;
    if (progress >= 75) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Get motivational message based on progress
  String get motivationalMessage {
    final progress = overallProgress;

    if (progress >= 100) {
      return '🎉 ممتاز! لقد أكملت جميع الحقول المطلوبة!';
    } else if (progress >= 90) {
      return '💪 تقريباً انتهيت! بقي القليل جداً!';
    } else if (progress >= 75) {
      return '👍 جيد جداً! استمر هكذا!';
    } else if (progress >= 50) {
      return '📝 أنت في منتصف الطريق! واصل التقدم!';
    } else if (progress >= 25) {
      return '🚀 بداية جيدة! لنكمل معاً!';
    } else if (progress > 0) {
      return '✨ رائع! لقد بدأت، الآن واصل!';
    } else {
      return '👋 مرحباً! لنبدأ بملء البيانات';
    }
  }

  /// Get emoji based on progress
  String get progressEmoji {
    final progress = overallProgress;
    if (progress >= 100) return '🎉';
    if (progress >= 75) return '😊';
    if (progress >= 50) return '🙂';
    if (progress >= 25) return '😐';
    return '😕';
  }

  @override
  Widget build(BuildContext context) {
    if (showCompactView) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildFullView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with overall progress
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(progressEmoji, style: TextStyle(fontSize: 32.sp)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقدم النموذج',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${overallProgress.toStringAsFixed(0)}% مكتمل',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Overall progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: overallProgress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 12.h,
                  ),
                ),

                // Motivational message
                if (showMotivationalMessage) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      motivationalMessage,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Sections list
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: sections
                  .map((section) => _buildSectionCard(section))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              value: overallProgress / 100,
              strokeWidth: 4.w,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),

          SizedBox(width: 12.w),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقدم النموذج',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${overallProgress.toStringAsFixed(0)}% مكتمل',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Emoji
          Text(progressEmoji, style: TextStyle(fontSize: 24.sp)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(FormSection section) {
    final isComplete = section.isComplete;

    return GestureDetector(
      onTap: isComplete ? null : onTapIncomplete,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isComplete ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isComplete ? Colors.green.shade300 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (!isComplete)
              BoxShadow(
                color: section.color.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  section.icon,
                  color: isComplete ? Colors.green : section.color,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    section.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isComplete ? Colors.green.shade900 : Colors.black87,
                    ),
                  ),
                ),
                if (isComplete)
                  Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: section.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${section.progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: section.color,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10.h),

            // Progress bar
            if (!isComplete) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: section.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(section.color),
                  minHeight: 6.h,
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // Field counts
            Row(
              children: [
                // Required fields
                _buildFieldBadge(
                  icon: Icons.star,
                  label: 'مطلوب',
                  count: section.completedRequiredFields,
                  total: section.requiredFields,
                  color: Colors.red,
                ),

                SizedBox(width: 12.w),

                // Optional fields
                if (section.optionalFields > 0)
                  _buildFieldBadge(
                    icon: Icons.star_border,
                    label: 'اختياري',
                    count: section.completedOptionalFields,
                    total: section.optionalFields,
                    color: Colors.grey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldBadge({
    required IconData icon,
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        Text(
          '$count/$total',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: count >= total ? Colors.green : color,
          ),
        ),
      ],
    );
  }
}

/// Progress indicator badge (for app bar)
class ProgressBadge extends StatelessWidget {
  final double progress;
  final VoidCallback? onTap;

  const ProgressBadge({super.key, required this.progress, this.onTap});

  Color get color {
    if (progress >= 100) return Colors.green;
    if (progress >= 75) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
