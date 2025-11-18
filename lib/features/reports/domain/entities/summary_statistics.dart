/// Summary statistics entity
/// Clean Architecture - Domain Layer

class SummaryStatistics {
  final int total;
  final int orphans;
  final int poor;
  final int pending;

  const SummaryStatistics({
    required this.total,
    required this.orphans,
    required this.poor,
    required this.pending,
  });

  /// Get synced count
  int get synced => total - pending;

  /// Get percentage of orphans
  double get orphansPercentage {
    if (total == 0) return 0.0;
    return (orphans / total) * 100;
  }

  /// Get percentage of poor
  double get poorPercentage {
    if (total == 0) return 0.0;
    return (poor / total) * 100;
  }

  /// Get percentage of pending
  double get pendingPercentage {
    if (total == 0) return 0.0;
    return (pending / total) * 100;
  }

  /// Get percentage of synced
  double get syncedPercentage {
    if (total == 0) return 0.0;
    return (synced / total) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummaryStatistics &&
        other.total == total &&
        other.orphans == orphans &&
        other.poor == poor &&
        other.pending == pending;
  }

  @override
  int get hashCode {
    return total.hashCode ^ orphans.hashCode ^ poor.hashCode ^ pending.hashCode;
  }

  @override
  String toString() {
    return 'SummaryStatistics(total: $total, orphans: $orphans, poor: $poor, pending: $pending)';
  }
}
