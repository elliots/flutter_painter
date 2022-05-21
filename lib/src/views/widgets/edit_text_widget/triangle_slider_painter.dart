import 'dart:math';

import 'package:flutter/material.dart';

class TriangleSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Based on https://www.youtube.com/watch?v=Wl4F5V6BoJw
  /// Create a slider track that draws two rectangles with rounded outer edges.
  final double size;

  const TriangleSliderTrackShape({this.size = 14});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    Path getTrianglePath(double x, double y, double startOffset) {
      final width = size * y / 4 + 4;
      return Path()
        ..moveTo(startOffset, y)
        ..lineTo(x, y - width)
        ..lineTo(x, y + width)
        ..lineTo(startOffset, y);
    }

    Paint paint = Paint()..color = Colors.white.withOpacity(0.6);
    context.canvas.drawPath(getTrianglePath(trackRect.width + trackRect.left, thumbCenter.dy, trackRect.left), paint);
  }
}
