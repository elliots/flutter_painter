import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/generic_dot_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/ink_freehand_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/pencil_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/picture_brush_drawable.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class BrushPreview extends StatelessWidget {
  const BrushPreview({
    Key? key,
    this.height = 20,
    this.width = 200,
    required this.brushSize,
    required this.mode,
    required this.brushColor,
  }) : super(key: key);

  final double height;
  final double width;
  final double brushSize;
  final PainterMode mode;
  final Color brushColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CustomPaint(
        painter: FaceOutlinePainter(brushSize, mode, brushColor),
      ),
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  final double brushSize;
  final PainterMode mode;
  final Color brushColor;

  FaceOutlinePainter(this.brushSize, this.mode, this.brushColor);

  //(sin(6x)/12 +x/8)*6.8
  double calcY(double x) {
    return (sin(6 * x) / 12 + (x / 6)) * 6.8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = brushColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushSize;


    Path path = Path();
    path.moveTo(0.1 * size.width, size.height - calcY(0.1) * size.height);
    double incrementBy = 0.001;

    List<Offset> offsets = [];
    List<Offset> pencilOffsets = [];
    List<double> pencilOpacities = [];
    for (double x = 0.1; x < 1; x += incrementBy) {
      path.lineTo(x * size.width, size.height - calcY(x) * size.height);
      incrementBy *= 1.1;
      Offset offset = Offset(x * size.width, size.height - calcY(x) * size.height);
      offsets.add(offset);

      Set<Object> noise = PencilDrawable.generateNoise(offset, brushSize);
      pencilOffsets.addAll(noise.first as List<Offset>);
      pencilOpacities.addAll(noise.last as List<double>);
    }

    if (mode == PainterMode.erase) {
      FreeStyleDrawable(
        path: offsets,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    } else if (mode == PainterMode.pen) {
      FreeStyleDrawable(
        path: offsets,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    } else if (mode == PainterMode.pencil) {
      PencilDrawable(
        path: pencilOffsets,
        opacities: pencilOpacities,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    } else if (mode == PainterMode.inkFreehand) {
      InkFreehandDrawable(
        path: offsets,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    } else if (mode == PainterMode.pictureBrush1) {
      PictureBrushDrawable(
        path: offsets,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    } else if (mode == PainterMode.dots) {
      GenericDotDrawable(
        path: offsets,
        strokeWidth: brushSize,
        color: brushColor,
      ).draw(canvas, size);
    }

  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}
