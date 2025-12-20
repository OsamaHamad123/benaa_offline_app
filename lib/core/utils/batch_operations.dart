import 'dart:async';
import 'package:flutter/foundation.dart';

/// 📦 مدير العمليات الجماعية - Batch Operations
class BatchOperationManager {
  static final Map<String, _BatchQueue> _queues = {};

  /// تنفيذ عملية دفعية
  static Future<List<T>> executeBatch<T>(
    String queueName,
    List<Future<T> Function()> operations, {
    int batchSize = 10,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final results = <T>[];

    for (var i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize);
      final batchResults = await Future.wait(batch.map((op) => op()));
      results.addAll(batchResults);

      // تأخير بين الدفعات لتجنب حمل زائد
      if (i + batchSize < operations.length) {
        await Future.delayed(delay);
      }
    }

    return results;
  }

  /// إضافة عملية للطابور
  static void enqueue<T>(
    String queueName,
    Future<T> Function() operation, {
    int batchSize = 10,
    Duration maxWait = const Duration(seconds: 5),
  }) {
    if (!_queues.containsKey(queueName)) {
      _queues[queueName] = _BatchQueue(batchSize: batchSize, maxWait: maxWait);
    }

    _queues[queueName]!.enqueue(operation);
  }

  /// معالجة كل الطوابير
  static Future<void> flush() async {
    final futures = _queues.values.map((queue) => queue.flush());
    await Future.wait(futures);
  }

  /// مسح طابور محدد
  static Future<void> flushQueue(String queueName) async {
    final queue = _queues[queueName];
    if (queue != null) {
      await queue.flush();
    }
  }

  /// إحصائيات
  static Map<String, QueueStats> getStats() {
    return _queues.map((name, queue) => MapEntry(name, queue.stats));
  }

  /// تقرير
  static String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📦 Batch Operations Report');
    buffer.writeln('=' * 50);

    _queues.forEach((name, queue) {
      buffer.writeln('Queue: $name');
      buffer.writeln('  Pending: ${queue.stats.pendingOperations}');
      buffer.writeln('  Processed: ${queue.stats.processedBatches}');
      buffer.writeln();
    });

    return buffer.toString();
  }
}

/// طابور الدفعات
class _BatchQueue {
  final int batchSize;
  final Duration maxWait;
  final List<Future Function()> _operations = [];
  Timer? _timer;
  int _processedBatches = 0;

  _BatchQueue({required this.batchSize, required this.maxWait});

  void enqueue(Future Function() operation) {
    _operations.add(operation);

    // بدء Timer إذا لم يكن موجود
    _timer ??= Timer(maxWait, () => flush());

    // معالجة فورية إذا وصلنا للحد
    if (_operations.length >= batchSize) {
      flush();
    }
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;

    if (_operations.isEmpty) return;

    // تنفيذ كل العمليات
    final batch = List<Future Function()>.from(_operations);
    _operations.clear();

    try {
      await Future.wait(batch.map((op) => op()));
      _processedBatches++;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Batch operation failed: $e');
      }
    }
  }

  QueueStats get stats => QueueStats(
        pendingOperations: _operations.length,
        processedBatches: _processedBatches,
      );
}

/// إحصائيات الطابور
class QueueStats {
  final int pendingOperations;
  final int processedBatches;

  const QueueStats({
    required this.pendingOperations,
    required this.processedBatches,
  });

  @override
  String toString() {
    return 'QueueStats(pending: $pendingOperations, processed: $processedBatches)';
  }
}

/// مساعد لعمليات Database الجماعية
class BatchDatabaseHelper {
  /// إدخال جماعي
  static Future<void> batchInsert<T>(
    List<T> items,
    Future<void> Function(T item) insertFunction, {
    int batchSize = 50,
  }) async {
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(insertFunction));
    }
  }

  /// تحديث جماعي
  static Future<void> batchUpdate<T>(
    List<T> items,
    Future<void> Function(T item) updateFunction, {
    int batchSize = 50,
  }) async {
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(updateFunction));
    }
  }

  /// حذف جماعي
  static Future<void> batchDelete(
    List<int> ids,
    Future<void> Function(int id) deleteFunction, {
    int batchSize = 100,
  }) async {
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.skip(i).take(batchSize);
      await Future.wait(batch.map(deleteFunction));
    }
  }
}
