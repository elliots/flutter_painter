import 'package:flutter/foundation.dart';

import '../drawables/object_drawable.dart';
import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';
import 'add_drawables_action.dart';
import 'insert_drawables_action.dart';

/// An action of replacing a drawable with another in the [PainterController].
class ReplaceDrawableAction extends ControllerAction<bool, bool> {
  /// The drawable to be replaced with [newDrawable].
  final Drawable oldDrawable;

  /// The drawable to replace [oldDrawable].
  final Drawable newDrawable;

  /// If the drawables are on the paint drawable level.
  final bool isPaintLevel;

  /// Creates a [ReplaceDrawableAction] with [oldDrawable] and [newDrawable].
  ReplaceDrawableAction(this.oldDrawable, this.newDrawable, this.isPaintLevel);

  /// Performs the action.
  ///
  /// Replaces [oldDrawable] in the drawables in [controller.value] with [newDrawable].
  ///
  /// Returns `true` if [oldDrawable] is found and replaced by [newDrawable], and `false` otherwise.
  ///
  /// If [oldDrawable] was the selected object drawable the selected object drawable is set to [newDrawable]
  /// if [newDrawable] is an [ObjectDrawable], `null` otherwise.
  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final oldDrawableIndex =
        isPaintLevel ? value.paintLevelDrawables.indexOf(oldDrawable) : value.topLevelDrawables.indexOf(oldDrawable);
    if (oldDrawableIndex < 0) {
      return false;
    }

    final currentDrawables = List<Drawable>.from(isPaintLevel ? value.paintLevelDrawables : value.topLevelDrawables);
    final selectedObject = controller.value.selectedObjectDrawable;
    final isSelectedObject = oldDrawable == selectedObject;
    currentDrawables.setRange(oldDrawableIndex, oldDrawableIndex + 1, [newDrawable]);
    if (isPaintLevel) {
      controller.value = value.copyWith(
        paintLevelDrawables: currentDrawables,
        selectedObjectDrawable: isSelectedObject
            ? newDrawable is ObjectDrawable
                ? (newDrawable as ObjectDrawable)
                : selectedObject
            : null,
      );
    } else {
      controller.value = value.copyWith(
        topLevelDrawables: currentDrawables,
        selectedObjectDrawable: isSelectedObject
            ? newDrawable is ObjectDrawable
                ? (newDrawable as ObjectDrawable)
                : selectedObject
            : null,
      );
    }
    if (isSelectedObject && newDrawable is! ObjectDrawable) {
      controller.deselectObjectDrawable(isRemoved: true);
    }
    return true;
  }

  /// Un-performs the action.
  ///
  /// Replaces [newDrawable] back with [oldDrawable] in the drawables in [controller.value].
  ///
  /// Returns `true` if [newDrawable] is found and replaced by [oldDrawable], and `false` otherwise.
  @protected
  @override
  bool unperform$(PainterController controller) {
    final value = controller.value;
    final newDrawableIndex = isPaintLevel ? value.paintLevelDrawables.indexOf(newDrawable) : value.topLevelDrawables.indexOf(newDrawable);
    if (newDrawableIndex < 0) {
      return false;
    }

    final currentDrawables = List<Drawable>.from(isPaintLevel ? value.paintLevelDrawables : value.topLevelDrawables);
    final selectedObject = controller.value.selectedObjectDrawable;
    final isSelectedObject = newDrawable == selectedObject;
    currentDrawables.setRange(newDrawableIndex, newDrawableIndex + 1, [oldDrawable]);
    if (isPaintLevel) {
      controller.value = value.copyWith(
        paintLevelDrawables: currentDrawables,
        selectedObjectDrawable: isSelectedObject
            ? oldDrawable is ObjectDrawable
            ? (oldDrawable as ObjectDrawable)
            : selectedObject
            : null,
      );
    } else {
      controller.value = value.copyWith(
        topLevelDrawables: currentDrawables,
        selectedObjectDrawable: isSelectedObject
            ? oldDrawable is ObjectDrawable
            ? (oldDrawable as ObjectDrawable)
            : selectedObject
            : null,
      );
    }
    if (isSelectedObject && oldDrawable is! ObjectDrawable) {
      controller.deselectObjectDrawable(isRemoved: true);
    }
    return true;
  }

  /// Merges [this] action and the [previousAction] into one action.
  /// Returns the result of the merge.
  ///
  /// If [previousAction] is an add, insert or replace action that acts on [oldDrawable], merging
  /// their effects is like performing [previousAction] on its own but with [newDrawable].
  /// Otherwise, the default behavior is used.
  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction) {
    if (isPaintLevel) {
      if (previousAction is AddDrawablesAction && previousAction.paintLevelDrawables.last == oldDrawable) {
        return AddDrawablesAction([...previousAction.paintLevelDrawables]
          ..removeLast()
          ..add(newDrawable), []);
      }
      if (previousAction is InsertDrawablesAction && previousAction.paintLevelDrawables.last == oldDrawable) {
        return InsertDrawablesAction(
            previousAction.index,
            [...previousAction.paintLevelDrawables]
              ..removeLast()
              ..add(newDrawable), []);
      }
    } else {
      if (previousAction is AddDrawablesAction && previousAction.topLevelDrawables.last == oldDrawable) {
        return AddDrawablesAction([], [...previousAction.topLevelDrawables]
          ..removeLast()
          ..add(newDrawable));
      }
      if (previousAction is InsertDrawablesAction && previousAction.topLevelDrawables.last == oldDrawable) {
        return InsertDrawablesAction(
            previousAction.index, [],
            [...previousAction.topLevelDrawables]
              ..removeLast()
              ..add(newDrawable));
      }
    }
    if (previousAction is ReplaceDrawableAction && previousAction.newDrawable == oldDrawable) {
      return ReplaceDrawableAction(previousAction.oldDrawable, newDrawable, isPaintLevel);
    }
    return super.merge$(previousAction);
  }
}
