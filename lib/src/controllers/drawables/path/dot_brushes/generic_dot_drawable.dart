import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/noise_generator.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

import '../../../../views/painters/painter.dart';
import '../path_drawable.dart';
import 'dart:ui' as ui;

/// Pencil Drawable (pencil scribble).
class GenericDotDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  late final List<double> opacities;
  late final List<Offset> points;
  /// Creates a [GenericDotDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  GenericDotDrawable({
    required List<Offset> path,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  }) : super(path: path, strokeWidth: strokeWidth, hidden: hidden) {
    assert(path.isNotEmpty, 'The path cannot be an empty list');
    assert(strokeWidth > 0, 'The stroke width cannot be less than or equal to 0');

    var result = NoiseGenerator.pathPointsToPencilPoints(path, strokeWidth);
    points = result.first as List<Offset>;
    opacities = result.last as List<double>;
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  GenericDotDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
  }) {
    return GenericDotDrawable(
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
      // Create a UI path to draw
      final path = Path();

      // Start path from the first point
      path.moveTo(points[0].dx, points[0].dy);
      path.lineTo(points[0].dx, points[0].dy);

      // Draw a line between each point on the free path
      int index = 1;
      this.path.sublist(1).forEach((point) {
        Paint newPaint = paint;
        newPaint.color = color.withOpacity(opacities[index]);


        Shapes shapes = Shapes(canvas: canvas, radius: 1, paint: paint, center: Offset(point.dx, point.dy), angle: 0);
        shapes.drawPolygon(3);
        //canvas.drawCircle(Offset(point.dx, point.dy), strokeWidth / 6 * opacities[index], newPaint);
        index++;
      });

      // Draw the path on the canvas
      canvas.drawPath(path, paint);
      recorder.endRecording().toImage(size.width.floor(), size.height.floor()).then((value) => myBackground = value);
    } else {
      canvas.drawImage(myBackground!, Offset.zero, Paint());
      return;
    }

    // Draw a line between each point on the free path
    int index = 1;
    points.sublist(1).forEach((point) {
      Paint newPaint = paint;
      newPaint.color = color.withOpacity(opacities[index]);
      Shapes shapes = Shapes(canvas: canvas, radius: strokeWidth / 2 * opacities[index], paint: paint, center: Offset(point.dx, point.dy), angle: 0);
      shapes.drawPolygon(5, initialAngle: point.dx);
      //canvas.drawCircle(Offset(point.dx, point.dy), strokeWidth / 6 * opacities[index], newPaint);
      index++;
    });
  }
}
