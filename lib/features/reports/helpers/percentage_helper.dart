/// Helper functions for calculating percentages and formatting report data
class PercentageHelper {
  /// Calculate percentage from count and total
  static double calculatePercentage(int count, int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  /// Format percentage with decimal places
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return percentage.toStringAsFixed(decimals);
  }

  /// Calculate and format percentage in one call
  static String getFormattedPercentage(
    int count,
    int total, {
    int decimals = 1,
  }) {
    final percentage = calculatePercentage(count, total);
    return formatPercentage(percentage, decimals: decimals);
  }

  /// Get percentage display text with % symbol
  static String getPercentageText(int count, int total, {int decimals = 1}) {
    if (total == 0) return '0%';
    final percentage = calculatePercentage(count, total);
    return '${formatPercentage(percentage, decimals: decimals)}%';
  }

  /// Get count with percentage in parentheses
  static String getCountWithPercentage(
    int count,
    int total, {
    int decimals = 1,
  }) {
    final percentageText = getPercentageText(count, total, decimals: decimals);
    return '$count ($percentageText)';
  }
}
