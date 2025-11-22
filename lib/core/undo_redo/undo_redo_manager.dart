import 'package:flutter/material.dart';
import '../utils/feedback_utils.dart';

/// ↩️ Undo/Redo Manager - إدارة التراجع والإعادة
class UndoRedoManager<T> {
  final List<UndoableAction<T>> _undoStack = [];
  final List<UndoableAction<T>> _redoStack = [];
  final int maxStackSize;

  UndoRedoManager({this.maxStackSize = 50});

  /// تنفيذ إجراء قابل للتراجع
  Future<void> execute(UndoableAction<T> action) async {
    await action.execute();
    _undoStack.add(action);
    _redoStack.clear(); // مسح Redo عند إجراء جديد

    // الحفاظ على حجم Stack
    if (_undoStack.length > maxStackSize) {
      _undoStack.removeAt(0);
    }
  }

  /// التراجع
  Future<bool> undo() async {
    if (!canUndo) return false;

    final action = _undoStack.removeLast();
    await action.undo();
    _redoStack.add(action);

    return true;
  }

  /// الإعادة
  Future<bool> redo() async {
    if (!canRedo) return false;

    final action = _redoStack.removeLast();
    await action.execute();
    _undoStack.add(action);

    return true;
  }

  /// هل يمكن التراجع؟
  bool get canUndo => _undoStack.isNotEmpty;

  /// هل يمكن الإعادة؟
  bool get canRedo => _redoStack.isNotEmpty;

  /// آخر إجراء
  UndoableAction<T>? get lastAction =>
      _undoStack.isNotEmpty ? _undoStack.last : null;

  /// مسح السجل
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// عدد الإجراءات القابلة للتراجع
  int get undoCount => _undoStack.length;

  /// عدد الإجراءات القابلة للإعادة
  int get redoCount => _redoStack.length;
}

/// 📝 Undoable Action - إجراء قابل للتراجع
abstract class UndoableAction<T> {
  final String description;

  UndoableAction(this.description);

  /// تنفيذ الإجراء
  Future<void> execute();

  /// التراجع عن الإجراء
  Future<void> undo();

  @override
  String toString() => description;
}

/// 🗑️ Delete Action - إجراء حذف قابل للتراجع
class DeleteAction<T> extends UndoableAction<T> {
  final T item;
  final Future<void> Function(T) onDelete;
  final Future<void> Function(T) onRestore;

  DeleteAction({
    required this.item,
    required this.onDelete,
    required this.onRestore,
    String? description,
  }) : super(description ?? 'حذف عنصر');

  @override
  Future<void> execute() async {
    await onDelete(item);
  }

  @override
  Future<void> undo() async {
    await onRestore(item);
  }
}

/// ✏️ Edit Action - إجراء تعديل قابل للتراجع
class EditAction<T> extends UndoableAction<T> {
  final T oldValue;
  final T newValue;
  final Future<void> Function(T) onUpdate;

  EditAction({
    required this.oldValue,
    required this.newValue,
    required this.onUpdate,
    String? description,
  }) : super(description ?? 'تعديل عنصر');

  @override
  Future<void> execute() async {
    await onUpdate(newValue);
  }

  @override
  Future<void> undo() async {
    await onUpdate(oldValue);
  }
}

/// ➕ Create Action - إجراء إضافة قابل للتراجع
class CreateAction<T> extends UndoableAction<T> {
  final T item;
  final Future<void> Function(T) onCreate;
  final Future<void> Function(T) onDelete;

  CreateAction({
    required this.item,
    required this.onCreate,
    required this.onDelete,
    String? description,
  }) : super(description ?? 'إضافة عنصر');

  @override
  Future<void> execute() async {
    await onCreate(item);
  }

  @override
  Future<void> undo() async {
    await onDelete(item);
  }
}

/// 🎨 Undo/Redo Floating Action Buttons
class UndoRedoButtons extends StatelessWidget {
  final UndoRedoManager manager;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const UndoRedoButtons({
    super.key,
    required this.manager,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Undo Button
        FloatingActionButton.small(
          heroTag: 'undo',
          onPressed: manager.canUndo
              ? () async {
                  HapticPatterns.light();
                  final success = await manager.undo();
                  if (success && context.mounted) {
                    VisualFeedback.showInfo(
                      context,
                      'تم التراجع: ${manager.lastAction?.description ?? ""}',
                    );
                    onUndo?.call();
                  }
                }
              : null,
          tooltip: 'تراجع',
          child: Icon(Icons.undo, color: manager.canUndo ? null : Colors.grey),
        ),

        const SizedBox(width: 8),

        // Redo Button
        FloatingActionButton.small(
          heroTag: 'redo',
          onPressed: manager.canRedo
              ? () async {
                  HapticPatterns.light();
                  final success = await manager.redo();
                  if (success && context.mounted) {
                    VisualFeedback.showInfo(context, 'تم الإعادة');
                    onRedo?.call();
                  }
                }
              : null,
          tooltip: 'إعادة',
          child: Icon(Icons.redo, color: manager.canRedo ? null : Colors.grey),
        ),
      ],
    );
  }
}

/// 📜 History Viewer - عارض السجل
class ActionHistoryViewer extends StatelessWidget {
  final UndoRedoManager manager;

  const ActionHistoryViewer({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'سجل الإجراءات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            // Statistics
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('تراجع', manager.undoCount, Colors.blue),
                  _buildStat('إعادة', manager.redoCount, Colors.green),
                ],
              ),
            ),

            const Divider(),

            // Actions List
            Expanded(
              child: manager.undoCount == 0 && manager.redoCount == 0
                  ? const Center(
                      child: Text(
                        'لا توجد إجراءات',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      children: [
                        if (manager.undoCount > 0) ...[
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'إجراءات قابلة للتراجع:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // عرض من الأحدث للأقدم
                          ..._buildActionsList(
                            manager._undoStack.reversed.toList(),
                            Icons.undo,
                            Colors.blue,
                          ),
                        ],
                        if (manager.redoCount > 0) ...[
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'إجراءات قابلة للإعادة:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ..._buildActionsList(
                            manager._redoStack.reversed.toList(),
                            Icons.redo,
                            Colors.green,
                          ),
                        ],
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Clear Button
            if (manager.undoCount > 0 || manager.redoCount > 0)
              OutlinedButton.icon(
                onPressed: () {
                  manager.clear();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('مسح السجل'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  List<Widget> _buildActionsList(
    List<UndoableAction> actions,
    IconData icon,
    Color color,
  ) {
    return actions.map((action) {
      return ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(action.description),
        dense: true,
      );
    }).toList();
  }
}
