export 'free_style_settings.dart';

import 'package:flutter/material.dart';
import 'scale_settings.dart';
import 'shape_settings.dart';
import 'object_settings.dart';
import 'settings.dart';

/// Enum representing different states that painting can be.
enum PainterMode {
  select,

  zoom,

  /// Free-style painting is enabled in drawing mode; used to draw scribbles.
  pen,

  /// Free-style painting is enabled in pencil mode; used to create pencil drawings.
  pencil,

  /// Free-style painting is enabled in ink freehand mode; used to create drawings.
  inkFreehand,

  /// Free-style painting is enabled in erasing mode; used to erase drawings.
  erase,

}

extension PainterModeExtension on PainterMode {
  bool get isAFreestyleMode {
    switch (this) {
      case PainterMode.pen:
        return true;
      case PainterMode.pencil:
        return true;
      case PainterMode.inkFreehand:
        return true;
      case PainterMode.erase:
        return true;
      default:
        return false;
    }
  }
}

/// Represents all the settings used to create and draw drawables.
@immutable
class PainterSettings {
  /// CurrentPainterMode
  final PainterMode painterMode;

  /// Settings for free-style drawables.
  final FreeStyleSettings freeStyle;

  /// Settings for object drawables.
  final ObjectSettings object;

  /// Settings for text drawables.
  final TextSettings text;

  /// Settings for shape drawables.
  final ShapeSettings shape;

  /// Settings for canvas scaling.
  final ScaleSettings scale;

  /// Creates a [PainterSettings] with the given settings for [freeStyle], [object]
  /// and [text].
  const PainterSettings({
    this.painterMode = PainterMode.zoom,
    this.freeStyle = const FreeStyleSettings(),
    this.object = const ObjectSettings(),
    this.text = const TextSettings(),
    this.shape = const ShapeSettings(),
    this.scale = const ScaleSettings(),
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  PainterSettings copyWith({
    PainterMode? painterMode,
    FreeStyleSettings? freeStyle,
    ObjectSettings? object,
    TextSettings? text,
    ShapeSettings? shape,
    ScaleSettings? scale,
  }) {
    return PainterSettings(
      painterMode: painterMode ?? this.painterMode,
      text: text ?? this.text,
      object: object ?? this.object,
      freeStyle: freeStyle ?? this.freeStyle,
      shape: shape ?? this.shape,
      scale: scale ?? this.scale,
    );
  }
}
