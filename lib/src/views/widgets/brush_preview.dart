import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/jagged_brush_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/ink_freehand_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/pencil_drawable.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class BrushPreview extends StatelessWidget {
  const BrushPreview({
    Key? key,
    this.height = 20,
    this.width = 200,
    required this.brushSize,
    required this.paintBrushStyle,
    required this.brushColor,
  }) : super(key: key);

  final double height;
  final double width;
  final double brushSize;
  final PaintBrushStyle paintBrushStyle;
  final Color brushColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CustomPaint(
        painter: FaceOutlinePainter(brushSize, paintBrushStyle, brushColor),
      ),
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  final double brushSize;
  final PaintBrushStyle paintBrushStyle;
  final Color brushColor;

  FaceOutlinePainter(this.brushSize, this.paintBrushStyle, this.brushColor);

  //(sin(6x)/12 +x/8)*6.8
  double calcY(double x) {
    return (sin(6 * x) / 12 + (x / 6)) * 6.8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.1 * size.width, size.height - calcY(0.1) * size.height);
    double incrementBy = 0.001;

    List<Offset> offsets = [];
    for (double x = 0.1; x < 1; x += incrementBy) {
      path.lineTo(x * size.width, size.height - calcY(x) * size.height);
      incrementBy *= 1.1;
      Offset offset = Offset(x * size.width, size.height - calcY(x) * size.height);
      offsets.add(offset);
    }

    paintBrushStyle.getDrawable(offsets, brushSize, brushColor).draw(canvas, size);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
}
