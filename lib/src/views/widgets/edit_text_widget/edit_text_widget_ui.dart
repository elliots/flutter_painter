import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/slider_colors.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/slider_painter.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/triangle_slider_painter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../flutter_painter.dart';
import '../../../controllers/notifications/drawable_created_notification.dart';
import '../../../controllers/notifications/drawable_deleted_notification.dart';

/// A dialog-like widget to edit text drawables in.
class EditTextWidgetUI extends StatefulWidget {
  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// The text drawable currently being edited.
  final TextDrawable drawable;

  /// Text editing controller for the [TextField].
  final TextEditingController textEditingController;

  /// The focus node of the [TextField].
  ///
  /// The node provided from the [TextSettings] will be used if provided
  /// Otherwise, it will be initialized to an inner [FocusNode].
  final FocusNode textFieldNode;

  /// If the text drawable being edited is new or not.
  /// If it is new, the update action is not marked as a new action, so it is merged with
  /// the previous action.
  final bool isNew;

  final Widget? Function(BuildContext, {required int currentLength, required bool isFocused, required int? maxLength})?
      buildEmptyCounter;

  final void Function()? onEditingComplete;

  const EditTextWidgetUI({
    Key? key,
    required this.controller,
    required this.drawable,
    required this.textFieldNode,
    required this.textEditingController,
    this.isNew = false,
    this.buildEmptyCounter,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  EditTextWidgetUIState createState() => EditTextWidgetUIState();
}

class EditTextWidgetUIState extends State<EditTextWidgetUI> with WidgetsBindingObserver {
  TextStyle get textStyle => widget.controller.textStyle;

  double textColorSliderValue = 0;

  @override
  void initState() {
    super.initState();
    if (textStyle.color == Colors.black) {
      textColorSliderValue = 0;
    } else if (textStyle.color == Colors.white) {
      textColorSliderValue = 355;
    } else if (textStyle.color == null) {
      textColorSliderValue = 0;
    } else {
      textColorSliderValue = HSVColor.fromColor(textStyle.color!).hue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // If the background is tapped, un-focus the text field
      onTap: () => widget.textFieldNode.unfocus(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.transparent, Colors.transparent])),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  buildTop(),
                  Expanded(
                    child: Row(
                      children: [
                        buildSide(),
                        Expanded(
                          child: Center(
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              cursorColor: Colors.white,
                              buildCounter: widget.buildEmptyCounter,
                              maxLength: 1000,
                              minLines: 1,
                              maxLines: 10,
                              controller: widget.textEditingController,
                              focusNode: widget.textFieldNode,
                              style: widget.controller.textStyle,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              onEditingComplete: widget.onEditingComplete,
                            ),
                          ),
                        ),
                        Container(
                          width: 52,
                          height: double.infinity,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.5), Colors.transparent])),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: buildBottom(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: [
        const SizedBox(width: 76),
        Expanded(
          child: Center(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 256,
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: TriangleSliderTrackShape(size: (textStyle.fontSize ?? 14) / 96),
                ),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Slider(
                    min: 8,
                    max: 96,
                    value: textStyle.fontSize ?? 14,
                    thumbColor: Colors.white,
                    onChanged: setTextFontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTop() {
    return Row(
      children: [
        Expanded(
          child: Container(),
        ),
        TextButton(
          onPressed: () => widget.textFieldNode.unfocus(),
          child: const Text(
            "Done",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget buildBottom() {
    return Column(
      children: [
        Row(children: [
          SizedBox(width: 16),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                print("Change background color");
                updateTextBackgroundColor(true);
                setState(() {});
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
                child: Center(
                    child: Text(
                  "A",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                )),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            color: Colors.white,
            height: 16,
            width: 1,
          ),
          SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Row(children: [
                buildFontFamilyOption(
                    "Classic",
                    GoogleFonts.roboto().fontFamily!,
                    () => setTextFontFamily(
                          GoogleFonts.roboto().fontFamily!,
                        )),
                buildFontFamilyOption(
                    "Serif",
                    GoogleFonts.playfairDisplay().fontFamily!,
                    () => setTextFontFamily(
                          GoogleFonts.playfairDisplay().fontFamily!,
                        )),
                buildFontFamilyOption(
                    "Bold",
                    GoogleFonts.permanentMarker().fontFamily!,
                    () => setTextFontFamily(
                          GoogleFonts.permanentMarker().fontFamily!,
                        )),
                buildFontFamilyOption(
                    "Cursive",
                    GoogleFonts.cookie().fontFamily!,
                    () => setTextFontFamily(
                          GoogleFonts.cookie().fontFamily!,
                        )),
              ]),
            ),
          ),
        ]),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: GradientRectSliderTrackShape(gradient: colorSliderGradient, darkenInactive: false),
                ),
                child: Slider(
                    min: 0,
                    max: 359.99,
                    value: textColorSliderValue,
                    thumbColor: widget.controller.textStyle.color,
                    onChanged: setTextColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFontFamilyOption(String name, String fontFamily, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style:
                    TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: fontFamily),
              ),
            )),
          ),
        ),
      ),
    );
  }

  void setTextColor(double hue) {
    setState(() {
      widget.controller.textStyle = textStyle.copyWith(color: HSVColor.fromAHSV(1, hue, 1, 1).toColor());
      textColorSliderValue = hue;
      if (hue <= 1) {
        widget.controller.textStyle = textStyle.copyWith(color: Colors.black);
      } else if (hue >= 355) {
        widget.controller.textStyle = textStyle.copyWith(color: Colors.white);
      }
      updateTextBackgroundColor(false);
    });
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      widget.controller.textStyle = textStyle.copyWith(fontSize: size);
    });
    updateTextBackgroundColor(false);
  }

  void setTextFontFamily(String family) {
    setState(() {
      widget.controller.textStyle = textStyle.copyWith(fontFamily: family);
    });
  }

  void updateTextBackgroundColor(bool swap) {
    if (swap) {
      if (textStyle.background == null || textStyle.background?.color == Colors.transparent) {
        widget.controller.textStyle = textStyle.copyWith(background: getTextStyleBackground());
      } else {
        widget.controller.textStyle = textStyle.copyWith(background: Paint()..color = Colors.transparent);
      }
    } else {
      if (textStyle.background == null || textStyle.background?.color == Colors.transparent) {
        return;
      }
      widget.controller.textStyle = textStyle.copyWith(background: getTextStyleBackground());
    }
  }

  Paint? getTextStyleBackground() {
    return Paint()
      ..color = (textStyle.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
      ..strokeWidth = (textStyle.height ?? 1) * (textStyle.fontSize ?? 20) * 1.45
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }
}
