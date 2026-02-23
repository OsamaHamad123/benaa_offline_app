import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔄 Undo/Redo System for Form Changes
class UndoRedoManager<T> extends ChangeNotifier {
  final List<T> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;

  UndoRedoManager({this.maxHistorySize = 50});

  /// Add new state to history
  void addState(T state) {
    // Remove all states after current index (if we've undone)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Add new state
    _history.add(state);
    _currentIndex++;

    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }

    notifyListeners();
  }

  /// Undo to previous state
  T? undo() {
    if (!canUndo) return null;

    _currentIndex--;
    notifyListeners();
    return _history[_currentIndex];
  }

  /// Redo to next state
  T? redo() {
    if (!canRedo) return null;

    _currentIndex++;
    notifyListeners();
    return _history[_currentIndex];
  }

  /// Get current state
  T? get currentState {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// Can undo?
  bool get canUndo => _currentIndex > 0;

  /// Can redo?
  bool get canRedo => _currentIndex < _history.length - 1;

  /// Clear history
  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    _history.clear();
    super.dispose();
  }
}

/// 🔘 Undo/Redo Buttons Widget
class UndoRedoButtons extends StatelessWidget {
  final UndoRedoManager undoRedoManager;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const UndoRedoButtons({
    required this.undoRedoManager, required this.onUndo, required this.onRedo, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: undoRedoManager,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Undo Button
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              onPressed: undoRedoManager.canUndo ? onUndo : null,
              tooltip: 'تراجع (Ctrl+Z)',
              iconSize: 20.sp,
            ),
            SizedBox(width: 4.w),
            // Redo Button
            IconButton(
              icon: const Icon(Icons.redo_rounded),
              onPressed: undoRedoManager.canRedo ? onRedo : null,
              tooltip: 'إعادة (Ctrl+Y)',
              iconSize: 20.sp,
            ),
          ],
        );
      },
    );
  }
}
