import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🔄 Undo/Redo Stack for Form History
class FormHistory<T> extends ChangeNotifier {
  final List<T> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;

  FormHistory({this.maxHistorySize = 50});

  /// Add a new state to history
  void push(T state) {
    // Remove all states after current index (clear redo history)
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
    if (canUndo) {
      _currentIndex--;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  /// Redo to next state
  T? redo() {
    if (canRedo) {
      _currentIndex++;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  /// Check if undo is possible
  bool get canUndo => _currentIndex > 0;

  /// Check if redo is possible
  bool get canRedo => _currentIndex < _history.length - 1;

  /// Get current state
  T? get current => _currentIndex >= 0 && _currentIndex < _history.length
      ? _history[_currentIndex]
      : null;

  /// Clear all history
  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  /// Get history size
  int get size => _history.length;

  @override
  void dispose() {
    _history.clear();
    super.dispose();
  }
}

/// 📦 Form State Snapshot for History
class FormStateSnapshot {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String description;

  FormStateSnapshot({
    required this.data,
    DateTime? timestamp,
    this.description = '',
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create from controllers
  factory FormStateSnapshot.fromControllers(
    Map<String, dynamic> controllers, {
    String description = '',
  }) {
    final data = <String, dynamic>{};

    controllers.forEach((key, value) {
      if (value is TextEditingController) {
        data[key] = value.text;
      } else {
        data[key] = value;
      }
    });

    return FormStateSnapshot(data: data, description: description);
  }

  /// Apply to controllers
  void applyTo(Map<String, dynamic> controllers) {
    data.forEach((key, value) {
      if (controllers.containsKey(key)) {
        final controller = controllers[key];
        if (controller is TextEditingController && value is String) {
          controller.text = value;
        } else {
          controllers[key] = value;
        }
      }
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormStateSnapshot &&
          runtimeType == other.runtimeType &&
          mapEquals(data, other.data);

  @override
  int get hashCode => data.hashCode;
}
