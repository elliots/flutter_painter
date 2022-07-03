import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of inserting a list of drawables to the [PainterController] at
/// a specific index.
class InsertDrawablesAction extends ControllerAction<void, void> {
  /// The list of paint level drawables to be inserted into the controller.
  final List<Drawable> paintLevelDrawables;

  /// The list of top level drawables to be inserted into the controller.
  final List<Drawable> topLevelDrawables;

  /// The index at which the drawables are be inserted.
  final int index;

  /// Creates an [InsertDrawablesAction] with the [index] to insert the [drawables] at.
  InsertDrawablesAction(this.index, this.paintLevelDrawables, this.topLevelDrawables);

  /// Performs the action.
  ///
  /// Inserts [drawables] into the list of drawables in [controller.value] at [index].
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentPaintLevelDrawables = List<Drawable>.from(value.paintLevelDrawables);
    currentPaintLevelDrawables.insertAll(index, paintLevelDrawables);
    final currentTopLevelDrawables = List<Drawable>.from(value.topLevelDrawables);
    currentTopLevelDrawables.insertAll(index, topLevelDrawables);
    controller.value = value.copyWith(
      paintLevelDrawables: currentPaintLevelDrawables,
      topLevelDrawables: currentTopLevelDrawables,
    );
  }

  /// Un-performs the action.
  ///
  /// Removes drawables from the list of drawables in [controller.value]
  /// starting from [index] and at the length of [drawables].
  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentPaintLevelDrawables = List<Drawable>.from(value.paintLevelDrawables);
    currentPaintLevelDrawables.removeRange(index, index + paintLevelDrawables.length);
    final currentTopLevelDrawables = List<Drawable>.from(value.topLevelDrawables);
    currentTopLevelDrawables.removeRange(index, index + topLevelDrawables.length);
    controller.value = value.copyWith(
      paintLevelDrawables: currentPaintLevelDrawables,
      topLevelDrawables: currentTopLevelDrawables,
    );
  }
}
