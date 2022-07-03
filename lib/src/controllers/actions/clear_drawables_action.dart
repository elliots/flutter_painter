import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of clearing all drawables in the [PainterController].
class ClearDrawablesAction extends ControllerAction<void, void> {
  /// A list of all the removed drawables.
  ///
  /// This list is initially `null`, and is updated once the action is performed.
  /// It is used by [unperform$] to retrieve the removed drawables.
  List<Drawable>? _removedPaintLevelDrawables;
  List<Drawable>? _removedTopLevelDrawables;

  /// Creates a [ClearDrawablesAction].
  ClearDrawablesAction();

  /// Performs the action.
  ///
  /// Removes all drawables from [controller.value], and saves them in [_removedDrawables].
  ///
  /// Also sets the selected object drawable to `null` since the selected object drawable would
  /// be removed.
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    _removedPaintLevelDrawables = List<Drawable>.from(value.paintLevelDrawables);
    _removedTopLevelDrawables = List<Drawable>.from(value.topLevelDrawables);
    controller.value = value.copyWith(
      paintLevelDrawables: const <Drawable>[],
      topLevelDrawables: const <Drawable>[],
    );
    controller.deselectObjectDrawable(isRemoved: true);
  }

  /// Un-performs the action.
  ///
  /// Restores the drawables from [_removedDrawables] back to [controller.value],
  /// and sets [_removedDrawables] to `null`.
  @protected
  @override
  void unperform$(PainterController controller) {
    final removedPaintLevelDrawables = _removedPaintLevelDrawables;
    final removedTopLevelDrawables = _removedTopLevelDrawables;
    if (removedPaintLevelDrawables != null) {
      final value = controller.value;
      controller.value = value.copyWith(paintLevelDrawables: removedPaintLevelDrawables);
    }
    if (removedTopLevelDrawables != null) {
      final value = controller.value;
      controller.value = value.copyWith(topLevelDrawables: removedTopLevelDrawables);
    }
    _removedPaintLevelDrawables = null;
    _removedTopLevelDrawables = null;
  }

  /// Merges [this] action and the [previousAction] into one action.
  /// Returns the result of the merge.
  ///
  /// [previousAction] is ignored and `this` is returned, since the previous action won't matter
  /// when all drawables are cleared.
  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction) {
    return this;
  }
}
