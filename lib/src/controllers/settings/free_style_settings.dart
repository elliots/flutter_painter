import 'package:flutter/material.dart';

/// Represents settings used to create and draw free-style drawables.
@immutable
class FreeStyleSettings {

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth] and [mode] values.
  const FreeStyleSettings({
    this.color = Colors.black,
    this.strokeWidth = 1,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith({Color? color, double? strokeWidth}) {
    return FreeStyleSettings(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}


