import 'package:flutter/material.dart';

import '../../../flutter_painter.dart';
import '../drawables/path/dot_brushes/jagged_brush_drawable.dart';
import '../drawables/path/dot_brushes/pencil_drawable.dart';
import '../drawables/path/ink_freehand_drawable.dart';
import '../drawables/path/picture_brushes/generic_picture_brush_drawable.dart';

enum PaintBrushStyle {
  pen,
  ink,
  pencil,
  pictureBrush1,
  pictureBrush2,
  pictureBrush3,
  pictureBrush4,
  jagged,
}

extension PaintBrushStyleExtension on PaintBrushStyle {
  PathDrawable getDrawable(List<Offset> offsets, double brushSize, Color brushColor) {
    switch (this) {
      case PaintBrushStyle.pen:
        return FreeStyleDrawable(
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
        );
      case PaintBrushStyle.ink:
        return InkFreehandDrawable(
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
        );
      case PaintBrushStyle.pencil:
        return PencilDrawable(
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
        );
      case PaintBrushStyle.jagged:
        return JaggedDrawable(
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
        );
      case PaintBrushStyle.pictureBrush1:
        return PictureBrushDrawable(
          brushNum: 1,
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
          maxOpacity: 0.04,
        );
      case PaintBrushStyle.pictureBrush2:
        return PictureBrushDrawable(
          brushNum: 2,
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
          maxOpacity: 0.08,
        );
      case PaintBrushStyle.pictureBrush3:
        return PictureBrushDrawable(
          brushNum: 3,
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
        );
      case PaintBrushStyle.pictureBrush4:
        return PictureBrushDrawable(
          brushNum: 4,
          path: offsets,
          strokeWidth: brushSize,
          color: brushColor,
          maxSpacing: 0.6
        );
    }
  }
}

/// Represents settings used to create and draw free-style drawables.
@immutable
class FreeStyleSettings {

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// The paint brush style the path will be drawn with.
  final PaintBrushStyle paintBrushStyle;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth] and [mode] values.
  const FreeStyleSettings({
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.paintBrushStyle = PaintBrushStyle.pen,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith({Color? color, double? strokeWidth, PaintBrushStyle? paintBrushStyle}) {
    return FreeStyleSettings(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      paintBrushStyle: paintBrushStyle ?? this.paintBrushStyle,
    );
  }
}


