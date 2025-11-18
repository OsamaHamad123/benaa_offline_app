import 'package:flutter/material.dart';
import '../../../core/constants/report_styles.dart';

/// Report Card Widget - كارد التقرير القابل لإعادة الاستخدام
class ReportCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final LinearGradient? gradient;

  const ReportCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ReportStyles.cardMargin),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: ReportStyles.cardBorderRadius,
        boxShadow: ReportStyles.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ReportStyles.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(ReportStyles.cardPadding),
            child: Stack(
              children: [
                // Decorative circle in background
                _buildBackgroundDecoration(),
                // Main content
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      right: -20,
      top: -20,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        // Icon Container with Hero animation
        _buildIconContainer(),
        const SizedBox(width: 16),
        // Text Content
        Expanded(child: _buildTextContent()),
        // Arrow Button
        _buildArrowButton(),
      ],
    );
  }

  Widget _buildIconContainer() {
    return Hero(
      tag: title,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: ReportStyles.cardIconSize),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.85),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoBadge(),
      ],
    );
  }

  Widget _buildInfoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 12, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            'عرض التفاصيل',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
    );
  }
}
