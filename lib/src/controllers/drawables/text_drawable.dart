import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

import 'object_drawable.dart';

const TEXT_EDITOR_HORIZONTAL_PADDING = 32;

enum TextDrawableMode {
  blurBackground,
  solidBackground,
  justText,
  textWithBorder,
}

const defaultTextDrawableSettings = TextDrawableSettings(
  fontSize: 18,
  color: Colors.black,
  alignment: TextAlign.center,
  direction: TextDirection.ltr,
  mode: TextDrawableMode.blurBackground,
  contrastColor: Colors.white,
);

class TextDrawableSettings {
  /// The mode for the text drawable
  final TextDrawableMode mode;

  /// The font family
  final String? fontFamily;

  /// The font size
  final double fontSize;

  /// The color used to theme the text
  final Color color;

  /// The color used to contrast the theme color
  final Color contrastColor;

  /// The direction of the text to be drawn.
  final TextAlign alignment;

  /// The direction of the text to be drawn.
  final TextDirection direction;

  /// Returns the text style with the font size and text color applied
  TextStyle toTextStyle() {
    switch (mode) {
      case TextDrawableMode.blurBackground:
        return TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          color: Colors.white,
        );
      case TextDrawableMode.solidBackground:
        if (color == Colors.white) {
          // If background is too bright black text
          return TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: Colors.black,
          );
        } else {
          // Otherwise white text
          return TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: Colors.white,
          );
        }
      case TextDrawableMode.justText:
        return TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          color: color,
        );
      case TextDrawableMode.textWithBorder:
        return TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          color: color,
        );
    }
  }

  const TextDrawableSettings({
    required this.mode,
    this.fontFamily,
    required this.fontSize,
    required this.color,
    required this.contrastColor,
    required this.alignment,
    required this.direction,
  });

  TextDrawableSettings copyWith({
    TextDrawableMode? mode,
    String? fontFamily,
    double? fontSize,
    Color? color,
    Color? contrastColor,
    TextAlign? alignment,
    TextDirection? direction,
  }) {
    return TextDrawableSettings(
      mode: mode ?? this.mode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      contrastColor: contrastColor ?? this.contrastColor,
      alignment: alignment ?? this.alignment,
      direction: direction ?? this.direction,
    );
  }
}

/// Text Drawable
class TextDrawable extends ObjectDrawable {
  /// The text to be drawn.
  final String text;

  /// The style the text will be drawn with.
  final TextDrawableSettings style;

  /// A text painter which will paint the text on the canvas.
  final TextPainter textPainter;

  final Key key;

  /// Creates a [TextDrawable] to draw [text].
  ///
  /// The path will be drawn with the passed [style] if provided.
  TextDrawable({
    required this.key,
    required this.text,
    required Offset position,
    double rotation = 0,
    double scale = 1,
    this.style = defaultTextDrawableSettings,
    bool locked = false,
    bool hidden = false,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
  })  : textPainter = TextPainter(
          text: TextSpan(text: text, style: style.toTextStyle()),
          textAlign: TextAlign.center,
          textScaleFactor: scale,
          textDirection: style.direction,
        ),
        super(
            position: position,
            rotationAngle: rotation,
            scale: scale,
            assists: assists,
            locked: locked,
            hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  TextDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    String? text,
    Offset? position,
    double? rotation,
    double? scale,
    TextDrawableSettings? style,
    bool? locked,
    TextDirection? direction,
  }) {
    return TextDrawable(
      key: key,
      text: text ?? this.text,
      position: position ?? this.position,
      rotation: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      style: style ?? this.style,
      assists: assists ?? this.assists,
      hidden: hidden ?? this.hidden,
      locked: locked ?? this.locked,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    // Generate the text as a visual layout
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth * scale - TEXT_EDITOR_HORIZONTAL_PADDING * scale);
    return textPainter.size;
  }

  Widget buildStackEntry({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = getSize(minWidth: minWidth, maxWidth: maxWidth);
    return Positioned(
      top: position.dy - size.height / 2,
      left: position.dx - size.width / 2,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Transform.scale(
          scale: 1,
          child: IgnorePointer(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Container(
                //color: Colors.black.withOpacity(0.5),
                child: Builder(builder: (context) {
                  switch (style.mode) {
                    case TextDrawableMode.blurBackground:
                      return RoundedBackgroundText(
                        text,
                        style: style.toTextStyle(),
                        textAlign: style.alignment,
                        textDirection: style.direction,
                        backgroundColor: style.color.withOpacity(0.4),
                        textScaleFactor: scale,
                        blurX: 8,
                        blurY: 8,
                      );
                    case TextDrawableMode.solidBackground:
                      return RoundedBackgroundText(
                        text,
                        style: style.toTextStyle(),
                        textAlign: style.alignment,
                        textDirection: style.direction,
                        backgroundColor: style.color.withOpacity(1),
                        textScaleFactor: scale,
                        blurX: 0.0,
                        blurY: 0.0,
                      );
                    case TextDrawableMode.justText:
                      return Text(
                        text,
                        textAlign: style.alignment,
                        style: TextStyle(
                          fontSize: style.fontSize,
                          color: style.color,
                        ),
                      );
                    case TextDrawableMode.textWithBorder:
                      return Stack(
                        children: <Widget>[
                          // Stroke outline text
                          Text(
                            text,
                            textAlign: style.alignment,
                            style: style.toTextStyle().copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = style.fontSize / 12.0
                                    ..color = style.contrastColor,
                                ),
                          ),
                          // Solid text to fill
                          Text(
                            text,
                            textAlign: style.alignment,
                            style: style.toTextStyle(),
                          ),
                        ],
                      );
                  }
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Compares two [TextDrawable]s for equality.
// @override
// bool operator ==(Object other) {
//   return other is TextDrawable &&
//       super == other &&
//       other.text == text &&
//       other.style == style &&
//       other.direction == direction;
// }
//
// @override
// int get hashCode => hashValues(
//     hidden,
//     hashList(assists),
//     hashList(assistPaints.entries),
//     position,
//     rotationAngle,
//     scale,
//     style,
//     direction);

  /// Draws the text on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    // No longer painting text to the canvas
    return;
    // Render the text according to the size of the canvas taking the scale in mind
    textPainter.layout(maxWidth: size.width * scale - TEXT_EDITOR_HORIZONTAL_PADDING * scale);

    // Background fill color
    TextPainter textPainterBackground = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              backgroundColor: style.color,
              color: Colors.transparent,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily)),
      textAlign: TextAlign.center,
      textScaleFactor: scale,
      textDirection: style.direction,
    );
    textPainterBackground.layout(maxWidth: size.width * scale - TEXT_EDITOR_HORIZONTAL_PADDING * scale);
    textPainterBackground.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));

    // Paint the text on the canvas
    // It is shifted back by half of its width and height to be drawn in the center
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }
}
