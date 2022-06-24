import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/noise_generator.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

import '../../../../views/painters/painter.dart';
import '../path_drawable.dart';
import 'dart:ui' as ui;

/// Pencil Drawable (pencil scribble).
class PencilDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  late final List<DotPoint> dots;

  /// Creates a [PencilDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  PencilDrawable({
    required List<Offset> path,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  }) : super(path: path, strokeWidth: strokeWidth, hidden: hidden) {
    assert(path.isNotEmpty, 'The path cannot be an empty list');
    assert(strokeWidth > 0, 'The stroke width cannot be less than or equal to 0');

    dots = NoiseGenerator.pathPointsToPencilPoints(path, strokeWidth, true, 1);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  PencilDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
  }) {
    return PencilDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.fill
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..strokeWidth = 0.8;

  bool captureNotStarted = true;
  ui.Image? myBackground;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    if (myBackground == null && captureNotStarted) {
      captureNotStarted = true;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      var dpr = ui.window.devicePixelRatio;
      canvas.scale(dpr);
      // Create a UI path to draw
      final path = Path();

      // Start path from the first point
      path.moveTo(dots[0].position.dx, dots[0].position.dy);
      path.lineTo(dots[0].position.dx, dots[0].position.dy);

      // Draw a line between each point on the free path
      dots.sublist(1).forEach((dot) {
        Paint newPaint = paint;
        newPaint.color = color.withOpacity(dot.opacity * (color.alpha / 255));
        canvas.drawCircle(Offset(dot.position.dx, dot.position.dy), strokeWidth / 6 * dot.opacity, newPaint);
      });

      // Draw the path on the canvas
      canvas.drawPath(path, paint);
      recorder.endRecording().toImage((size.width * dpr).floor(), (size.height * dpr).floor()).then((value) => myBackground = value);
    } else if (myBackground != null) {
      canvas.drawImageRect(myBackground!, Rect.fromPoints(Offset.zero, Offset(myBackground!.width.toDouble(), myBackground!.height.toDouble())),
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), Paint());
      return;
    }
    // Draw a line between each point on the free path
    dots.sublist(1).forEach((dot) {
      Paint newPaint = paint;
      newPaint.color = color.withOpacity(dot.opacity * (color.alpha / 255));
      canvas.drawCircle(Offset(dot.position.dx, dot.position.dy), strokeWidth / 6 * dot.opacity, newPaint);
    });
  }
}
