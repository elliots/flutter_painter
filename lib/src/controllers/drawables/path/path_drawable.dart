import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../drawable.dart';
import 'dart:ui' as UI;

ByteData? data;
UI.Image? image;

/// Free-style Drawable (hand scribble).
abstract class PathDrawable extends Drawable {
  /// List of points representing the path to draw.
  final List<Offset> path;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// Creates a [PathDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [strokeWidth] if provided.
  PathDrawable({
    required this.path,
    this.strokeWidth = 1,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0, 'The stroke width cannot be less than or equal to 0'),
        super(hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  PathDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
  });

  @protected
  Paint get paint;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) async {
    // Create a UI path to draw
    final path = Path();/*
    if (data == null) {
      rootBundle.load("packages/flutter_painter/assets/brush.png").then((value) => data = value);
    }
    if (image == null && data != null) {
      decodeImageFromList(Uint8List.view(data!.buffer)).then((value) => image = value);
    }
*/
    // Start path from the first point
    path.moveTo(this.path[0].dx, this.path[0].dy);
    path.lineTo(this.path[0].dx, this.path[0].dy);

    // Draw a line between each point on the free path
    Offset lastPoint = this.path[0];
/*
    List<Offset> points = [];
    for (int i = 0; i < this.path.length - 1; i++) {
      var point1 = this.path[i];
      var point2 = this.path[i + 1];
      points.add(point1);

      if (image != null) {
        //canvas.drawImage(image!, point1, paint);
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(point1.dx - 10, point1.dy - 10, 20, 20),
          image: image!,
          colorFilter: ColorFilter.mode(paint.color.withOpacity(0.1), BlendMode.srcIn),
        );
      }
      double distanceX = point2.dx - point1.dx;
      double distanceY = point2.dy - point1.dy;
      double maxDistance = max(distanceX.abs(), distanceY.abs());
      int pointsToAdd = maxDistance ~/ 1;
      for (int p = 0; p < pointsToAdd; p++) {
        points.add(
          Offset(
            point1.dx + (distanceX / pointsToAdd) * p,
            point1.dy + (distanceY / pointsToAdd) * p,
          ),
        );
      }
    }*/
    this.path.sublist(1).forEach((point) {
      path.lineTo(point.dx, point.dy);/*
      Paint paint = this.paint;
      paint.color = paint.color.withOpacity(0.6);
      paint.strokeCap = StrokeCap.square;
      canvas.drawLine(lastPoint, point, paint);
      //canvas.drawLine(lastPoint.translate(1, 1), point.translate(1, 1), paint);
      //canvas.drawLine(lastPoint.translate(0, -1), point.translate(0, -1), paint);
      //canvas.drawLine(lastPoint.translate(0.5, 0.5), point.translate(0.5, 0.5), paint);
      //canvas.drawLine(lastPoint.translate(2, 2), point.translate(2, 2), paint);
      lastPoint = point;*/
    });

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }
}
