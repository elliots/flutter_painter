import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../views/painters/painter.dart';
import 'path_drawable.dart';
import 'dart:ui' as ui;

/// Pencil Drawable (pencil scribble).
class PencilDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  final List<double> opacities;

  /// Creates a [PencilDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  PencilDrawable({
    required List<Offset> path,
    required this.opacities,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  })  :
  // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

  // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
        'The stroke width cannot be less than or equal to 0'),
        super(path: path, strokeWidth: strokeWidth, hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  PencilDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    List<double>? opacities,
    Color? color,
    double? strokeWidth,
  }) {
    return PencilDrawable(
      path: path ?? this.path,
      opacities: opacities ?? this.opacities,
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
      path.moveTo(this.path[0].dx, this.path[0].dy);
      path.lineTo(this.path[0].dx, this.path[0].dy);

      // Draw a line between each point on the free path
      int index = 1;
      this.path.sublist(1).forEach((point) {
        Paint newPaint = paint;
        newPaint.color = color.withOpacity(opacities[index]);
        canvas.drawCircle(Offset(point.dx, point.dy), strokeWidth/6*opacities[index], newPaint);
        index++;
      });

      // Draw the path on the canvas
      canvas.drawPath(path, paint);
      recorder.endRecording().toImage(size.width.floor(), size.height.floor()).then((value) => myBackground = value);
    } else {
      canvas.drawImage(myBackground!, Offset.zero, Paint());
      return;
    }

    // Create a UI path to draw
    final path = Path();

    // Start path from the first point
    path.moveTo(this.path[0].dx, this.path[0].dy);
    path.lineTo(this.path[0].dx, this.path[0].dy);

    // Draw a line between each point on the free path
    int index = 1;
    this.path.sublist(1).forEach((point) {
      Paint newPaint = paint;
      newPaint.color = color.withOpacity(opacities[index]);
      canvas.drawCircle(Offset(point.dx, point.dy), strokeWidth/6*opacities[index], newPaint);
      index++;
    });

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }


  static Set<Object> generateNoise(Offset initialOffset, double range) {
    List<Offset> points = [];
    List<double> opacities = [];
    for (int i = 0; i < 10; i++) {
      var percentOfRange1 = getPercentOfRange(range);
      var percentOfRange2 = getPercentOfRange(range);
      double opacity = 1 - max(percentOfRange1, percentOfRange2) * 0.5;
      points.add(Offset(addVariance(initialOffset.dx, percentOfRange1, range),
          addVariance(initialOffset.dy, percentOfRange2, range)));
      opacities.add(opacity);
    }
    return {points, opacities};
  }

  static double getPercentOfRange(double range) {
    double percentOfRange = Random().nextInt(10000) / 10000;
    // convert uniform distribution to quadratic, more values close to 0
    percentOfRange = percentOfRange;// * percentOfRange;
    return percentOfRange;
  }

  static double addVariance(double source, double percentOfRange, double range) {
    // Plus or minus
    if (Random().nextBool()) {
      return source + percentOfRange * range;
    } else {
      return source - percentOfRange * range;
    }
  }
}
