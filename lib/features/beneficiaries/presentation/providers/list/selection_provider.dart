import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'beneficiaries_list_state.dart';
import 'selection_persistence.dart';

/// ☑️ Selection Provider
final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>(
      (ref) => SelectionNotifier(),
    );

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(const SelectionState());

  /// تفعيل/إلغاء وضع التحديد
  void toggleSelectionMode() {
    if (state.isSelectionMode) {
      // إلغاء الوضع = مسح كل التحديدات
      state = const SelectionState();
    } else {
      // تفعيل الوضع
      state = state.copyWith(isSelectionMode: true);
    }
  }

  /// تحديد عنصر واحد
  void toggleItem(int id) {
    final newSelectedIds = Set<int>.from(state.selectedIds);

    if (newSelectedIds.contains(id)) {
      newSelectedIds.remove(id);
    } else {
      newSelectedIds.add(id);
    }

    // Ensure selection mode is enabled when there are selected items,
    // and disabled when selection becomes empty.
    state = state.copyWith(
      selectedIds: newSelectedIds,
      isSelectionMode: newSelectedIds.isNotEmpty,
    );

    SelectionPersistence.saveSelection(newSelectedIds);
  }

  /// تحديد الكل
  void selectAll(List<int> allIds) {
    state = state.copyWith(
      isSelectionMode: true,
      selectedIds: Set<int>.from(allIds),
    );
    SelectionPersistence.saveSelection(state.selectedIds);
  }

  /// إلغاء تحديد الكل
  void deselectAll() {
    state = const SelectionState();
    SelectionPersistence.clearSavedSelection();
  }

  /// مسح التحديدات فقط مع بقاء الوضع نشط
  void clearSelections() {
    state = state.copyWith(selectedIds: {});
  }

  /// بدء التحديد من عنصر معين
  void startSelectionWith(int id) {
    state = SelectionState(isSelectionMode: true, selectedIds: {id});
  }

  /// 🔄 Restore saved selection
  void restoreSelection() {
    final saved = SelectionPersistence.restoreSelection();
    if (saved != null && saved.isNotEmpty) {
      state = state.copyWith(isSelectionMode: true, selectedIds: saved);
    }
  }
}
