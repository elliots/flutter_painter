import 'dart:ui';

import '../../views/painters/painter.dart';
import 'drawable.dart';
import 'dart:ui' as ui;

class GroupedDrawable extends Drawable {
  /// The list of drawables in this group.
  final List<Drawable> drawables;

  /// The renderedImage as background.
  ui.Image? myBackground;

  /// Creates a new [GroupedDrawable] with the list of [drawables].
  GroupedDrawable({
    required List<Drawable> drawables,
    bool hidden = false,
  })  : drawables = List.unmodifiable(drawables),
        super(hidden: hidden);

  bool captureNotStarted = true;
  /// Draw all the drawables in the group on [canvas] of [size].
  @override
  void draw(Canvas canvas, Size size) {
    if (myBackground == null && captureNotStarted) {
      captureNotStarted = true;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = Painter(
        drawables: drawables,
      );
      painter.paint(canvas, size);
      recorder.endRecording().toImage(size.width.floor(), size.height.floor()).then((value) => myBackground = value);
    } else {
      canvas.drawImage(myBackground!, Offset.zero, Paint());
    }

    if (myBackground == null) {
      for (final drawable in drawables) {
        drawable.draw(canvas, size);
      }
    }
  }

  /// Compares two [GroupedDrawable]s for equality.
// @override
// bool operator ==(Object other) {
//   return other is GroupedDrawable &&
//       super == other &&
//       ListEquality().equals(drawables, other.drawables);
// }
//
// @override
// int get hashCode => hashValues(hidden, hashList(drawables));
}
