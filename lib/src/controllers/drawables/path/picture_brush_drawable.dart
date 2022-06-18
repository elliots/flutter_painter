import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_painter/flutter_painter.dart';

import '../drawable.dart';
import 'dart:ui' as UI;

ByteData? data;
UI.Image? image;

/// Free-style Drawable (hand scribble).
class PictureBrushDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  PictureBrushDrawable({
    required List<Offset> path,
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
  PictureBrushDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
  }) {
    return PictureBrushDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6)
    ..strokeWidth = strokeWidth;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) async {
    // Create a UI path to draw
    final path = Path();
    if (data == null) {
      rootBundle.load("packages/flutter_painter/assets/brush4.png").then((value) => data = value);
    }
    if (image == null && data != null) {
      decodeImageFromList(Uint8List.view(data!.buffer)).then((value) => image = value);
    }

    // Start path from the first point
    path.moveTo(this.path[0].dx, this.path[0].dy);
    path.lineTo(this.path[0].dx, this.path[0].dy);

    // Draw a line between each point on the free path
    Offset lastPoint = this.path[0];

    List<Offset> points = [];
    for (int i = 0; i < this.path.length - 1; i++) {
      var point1 = this.path[i];
      var point2 = this.path[i + 1];
      points.add(point1);

      double distanceX = point2.dx - point1.dx;
      double distanceY = point2.dy - point1.dy;
      double maxDistance = max(distanceX.abs(), distanceY.abs());
      int pointsToAdd = maxDistance ~/ (strokeWidth/6);
      for (int p = 0; p < pointsToAdd; p++) {
        points.add(
          Offset(
            point1.dx + (distanceX / pointsToAdd) * p,
            point1.dy + (distanceY / pointsToAdd) * p,
          ),
        );
      }
    }

    for (var point in points) {
      if (image != null) {
        double width = strokeWidth;
        width += 10;
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(point.dx - width/2, point.dy - width/2, width, width),
          image: image!,
          colorFilter: ColorFilter.mode(paint.color.withOpacity(0.12), BlendMode.srcIn),//multiply (no opacity)//modulate(opacity)//srcIn (mask) (opacity)
        );
      }
    }

  }
}
