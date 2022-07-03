import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';
import 'add_drawables_action.dart';
import 'insert_drawables_action.dart';

/// An action of removing a drawable from the [PainterController].
class RemoveDrawableAction extends ControllerAction<bool, bool> {
  /// The drawable to be removed.
  final Drawable drawable;

  /// If the drawable is a paint level drawable.
  final bool isPaintLevel;

  /// The index of the removed drawable.
  ///
  /// This value is initially `null`, and is updated once the action is performed.
  /// It is used by [unperform$] to re-insert the [drawable] at the index it was removed from.
  int? _removedIndex;


  /// Creates a [RemoveDrawableAction] with the [drawable] to be removed.
  RemoveDrawableAction(this.drawable, this.isPaintLevel);

  /// Performs the action.
  ///
  /// Removes [drawable] from the drawables in [controller.value] and
  /// saves its index in [_removedIndex].
  ///
  /// Returns `true` [drawable] was found and removed, and `false` otherwise.
  ///
  /// If the removed drawable is the selected object drawable from [controller.value],
  /// it sets it to `null`.
  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(isPaintLevel ? value.paintLevelDrawables : value.topLevelDrawables);
    final index = currentDrawables.indexOf(drawable);
    if (index < 0) return false;
    final selectedObject = controller.value.selectedObjectDrawable;
    final isSelectedObject = currentDrawables[index] == selectedObject;
    currentDrawables.removeAt(index);
    _removedIndex = index;
    if (isPaintLevel) {
      controller.value = value.copyWith(
        paintLevelDrawables: currentDrawables,
      );
    } else {
      controller.value = value.copyWith(
        topLevelDrawables: currentDrawables,
      );
    }
    if (isSelectedObject) controller.deselectObjectDrawable(isRemoved: true);
    return true;
  }

  /// Un-performs the action.
  ///
  /// Returns `false` if [drawable] wasn't removed in [perform$], and `true` otherwise.
  ///
  /// Inserts the removed [drawable] back in the drawables in [controller.value]
  /// at [_removedIndex], and sets [_removedIndex] back to `null`.
  @protected
  @override
  bool unperform$(PainterController controller) {
    final removedIndex = _removedIndex;
    if (removedIndex == null) return false;
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(isPaintLevel ? value.paintLevelDrawables : value.topLevelDrawables);
    currentDrawables.insert(removedIndex, drawable);
    if (isPaintLevel) {
      controller.value = value.copyWith(paintLevelDrawables: currentDrawables);
    } else {
      controller.value = value.copyWith(topLevelDrawables: currentDrawables);
    }
    _removedIndex = null;
    return true;
  }

  /// Merges [this] action and the [previousAction] into one action.
  /// Returns the result of the merge.
  ///
  /// If [previousAction] is an add or insert action that adds or inserts this [drawable], merging them
  /// cancels their effects, so `null` is returned. Otherwise, the default behavior is used.
  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction) {
    if (isPaintLevel) {
      if (previousAction is AddDrawablesAction &&
          previousAction.paintLevelDrawables.length == 1 &&
          previousAction.paintLevelDrawables.first == drawable) return null;
      if (previousAction is InsertDrawablesAction &&
          previousAction.paintLevelDrawables.length == 1 &&
          previousAction.paintLevelDrawables.first == drawable) return null;
    } else {
      if (previousAction is AddDrawablesAction &&
          previousAction.topLevelDrawables.length == 1 &&
          previousAction.topLevelDrawables.first == drawable) return null;
      if (previousAction is InsertDrawablesAction &&
          previousAction.topLevelDrawables.length == 1 &&
          previousAction.topLevelDrawables.first == drawable) return null;
    }
    return super.merge$(previousAction);
  }
}
