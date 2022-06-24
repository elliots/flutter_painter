import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_painter/flutter_painter.dart';

import '../../drawable.dart';
import 'dart:ui' as UI;
import 'dart:ui' as ui;

/// Free-style Drawable (hand scribble).
class PictureBrushDrawable extends PathDrawable {
  static UI.Image? brushImage1;
  static UI.Image? brushImage2;
  static UI.Image? brushImage3;
  static UI.Image? brushImage4;

  /// Preload brush images
  static void preLoadBrushImages() {
    for (int brushNum = 1; brushNum < 5; brushNum++) {
      rootBundle.load("packages/flutter_painter/assets/brush" + brushNum.toString() + ".png").then((data) {
        decodeImageFromList(Uint8List.view(data.buffer)).then((value) {
          switch (brushNum) {
            case 1:
              brushImage1 = value;
              break;
            case 2:
              brushImage2 = value;
              break;
            case 3:
              brushImage3 = value;
              break;
            case 4:
              brushImage4 = value;
              break;
          }
        });
      });
    }
  }

  /// The color the path will be drawn with.
  final Color color;

  final int brushNum;
  final double maxSpacing;
  final double maxOpacity;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  PictureBrushDrawable({
    required this.brushNum,
    required List<Offset> path,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
    this.maxSpacing = 1, // Divide stroke width by value
    this.maxOpacity = 0.24, // Multiple color opacity by value
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0, 'The stroke width cannot be less than or equal to 0'),
        super(path: path, strokeWidth: strokeWidth, hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  PictureBrushDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
    int? brushNum,
  }) {
    return PictureBrushDrawable(
      brushNum: brushNum ?? this.brushNum,
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
      maxSpacing: maxSpacing,
      maxOpacity: maxOpacity,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..strokeWidth = strokeWidth;

  bool captureNotStarted = true;
  ui.Image? myBackground;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    if (myBackground == null && captureNotStarted) {
      print("Capturing image brush drawable");
      captureNotStarted = true;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      var dpr = ui.window.devicePixelRatio;
      canvas.scale(dpr);
      // Create a UI path to draw
      final path = Path();

      drawImages(canvas, size);

      // Draw the path on the canvas
      canvas.drawPath(path, paint);
      recorder.endRecording().toImage((size.width * dpr).floor(), (size.height * dpr).floor()).then((value) => myBackground = value);
    } else if (myBackground != null) {
      canvas.drawImageRect(myBackground!, Rect.fromPoints(Offset.zero, Offset(myBackground!.width.toDouble(), myBackground!.height.toDouble())),
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), Paint());
      return;
    }
    // Draw a line between each point on the free path
    drawImages(canvas, size);
  }

  void drawImages(Canvas canvas, Size size) {
    // Create a UI path to draw
    final path = Path();
    var image = brushNum == 1
        ? brushImage1
        : brushNum == 2
            ? brushImage2
            : brushNum == 3
                ? brushImage3
                : brushImage4;

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
      int pointsToAdd = maxDistance ~/ maxSpacing;
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
          rect: Rect.fromLTWH(point.dx - width / 2, point.dy - width / 2, width, width),
          image: image,
          colorFilter: ColorFilter.mode(paint.color.withOpacity(maxOpacity * (paint.color.alpha / 255)),
              BlendMode.srcIn), //multiply (no opacity)//modulate(opacity)//srcIn (mask) (opacity)
        );
      }
    }
  }
}
