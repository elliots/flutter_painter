import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of adding a list of drawables to the [PainterController].
class AddDrawablesAction extends ControllerAction<void, void> {
  /// The list of paint level drawables to be added to the controller.
  final List<Drawable> paintLevelDrawables;

  /// The list of top level drawables to be added to the controller.
  final List<Drawable> topLevelDrawables;

  /// Creates a [AddDrawablesAction].
  ///
  /// [paintLevelDrawables] is the list of paint level drawables to be added to the controller.
  /// [topLevelDrawables] is the list of top level drawables to be added to the controller.
  AddDrawablesAction(this.paintLevelDrawables, this.topLevelDrawables);

  /// Performs the action.
  ///
  /// Adds [drawables] to the end of the drawables in [controller.value].
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentPaintLevelDrawables = List<Drawable>.from(value.paintLevelDrawables);
    final currentTopLevelDrawables = List<Drawable>.from(value.topLevelDrawables);
    currentPaintLevelDrawables.addAll(paintLevelDrawables);
    currentTopLevelDrawables.addAll(topLevelDrawables);
    controller.value = value.copyWith(
      paintLevelDrawables: currentPaintLevelDrawables,
      topLevelDrawables: currentTopLevelDrawables,
    );
  }

  /// Un-performs the action.
  ///
  /// Removes the added [drawables] from the end of the drawables in [controller.value].
  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentPaintLevelDrawables = List<Drawable>.from(value.paintLevelDrawables);
    for (final drawable in paintLevelDrawables.reversed) {
      final index = currentPaintLevelDrawables.lastIndexOf(drawable);
      currentPaintLevelDrawables.removeAt(index);
    }
    final currentTopLevelDrawables = List<Drawable>.from(value.topLevelDrawables);
    for (final drawable in topLevelDrawables.reversed) {
      final index = currentTopLevelDrawables.lastIndexOf(drawable);
      currentTopLevelDrawables.removeAt(index);
    }
    controller.value = value.copyWith(
      paintLevelDrawables: currentPaintLevelDrawables,
      topLevelDrawables: currentTopLevelDrawables,
    );
  }
}
