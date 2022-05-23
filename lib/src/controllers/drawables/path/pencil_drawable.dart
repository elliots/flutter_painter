import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'path_drawable.dart';

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

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
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
/// Compares two [FreeStyleDrawable]s for equality.
// @override
// bool operator ==(Object other) {
//   return other is FreeStyleDrawable &&
//       super == other &&
//       other.color == color &&
//       other.strokeWidth == strokeWidth &&
//       ListEquality().equals(other.path, path);
// }
//
// @override
// int get hashCode => hashValues(hidden, hashList(path), color, strokeWidth);
}
