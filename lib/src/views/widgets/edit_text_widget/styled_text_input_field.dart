import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class StyledTextInputField extends StatelessWidget {
  const StyledTextInputField(
      {Key? key, required this.textEditingController, required this.focusNode, required this.controller})
      : super(key: key);

  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    final style = controller.textStyle;
    switch (controller.textStyle.mode) {
      case TextDrawableMode.blurBackground:
        return RoundedBackgroundTextField(
          clipBehavior: Clip.none,
          cursorColor: style.contrastColor,
          controller: textEditingController,
          focusNode: focusNode,
          style: style.toTextStyle(),
          textAlign: style.alignment,
          backgroundColor: style.color.withOpacity(0.4),
          blurY: 8,
          blurX: 8,
        );
      case TextDrawableMode.solidBackground:
        return RoundedBackgroundTextField(
          clipBehavior: Clip.none,
          cursorColor: style.contrastColor,
          controller: textEditingController,
          focusNode: focusNode,
          style: style.toTextStyle(),
          textAlign: style.alignment,
          backgroundColor: style.color.withOpacity(1),
          blurY: 0.0,
          blurX: 0.0,
        );
      case TextDrawableMode.justText:
        return EditableText(
          maxLines: null,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          cursorColor: style.contrastColor,
          backgroundCursorColor: style.contrastColor,
          controller: textEditingController,
          focusNode: focusNode,
          style: style.toTextStyle(),
          textAlign: style.alignment,
        );
      case TextDrawableMode.textWithBorder:
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Stroke outline text
            EditableText(
              maxLines: null,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              cursorColor: style.contrastColor,
              backgroundCursorColor: style.contrastColor,
              controller: textEditingController,
              focusNode: focusNode,
              textAlign: style.alignment,
              style: style.toTextStyle().copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = style.fontSize / 12.0
                      ..color = style.contrastColor,
                  ),
            ),
            // Solid text to fill
            EditableText(
              maxLines: null,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              cursorColor: style.contrastColor,
              backgroundCursorColor: style.contrastColor,
              controller: textEditingController,
              focusNode: focusNode,
              style: style.toTextStyle(),
              textAlign: style.alignment,
            ),
          ],
        );
    }
    return const Text("Error");
  }
}
