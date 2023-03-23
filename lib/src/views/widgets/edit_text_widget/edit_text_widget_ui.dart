import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/triangle_slider_painter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../flutter_painter.dart';
import 'color_selection_row.dart';

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

  @override
  void initState() {
    super.initState();
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
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.black.withOpacity(0.25),
              ],
            ),
          ),
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
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0), // Fade top edge
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1), // Middle weight 8
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(0), // Fade bottom edge
                                ],
                              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.dstIn,
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
                            colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0)])),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          buildBottom(),
                          SizedBox(height: 12),
                          ColorSelectionRow(
                            onColorChange: (color) => widget.controller.textStyle = textStyle.copyWith(color: color),
                          ),
                        ],
                      ),
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
                    focusNode: widget.textFieldNode,
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
              child: buildFontFamilyOptions(),
            ),
          ),
        ]),
      ],
    );
  }

  Row buildFontFamilyOptions() {
    List<Widget> fontFamilyOptions = [];
    for (int i = 0; i < widget.controller.settings.text.fontFamilyOptions.length; i++) {
      fontFamilyOptions.add(buildFontFamilyOption(
          widget.controller.settings.text.fontFamilyOptionsNames[i],
          widget.controller.settings.text.fontFamilyOptions[i],
          () => setTextFontFamily(widget.controller.settings.text.fontFamilyOptions[i])));
    }
    if (fontFamilyOptions.isEmpty) {
      fontFamilyOptions.add(buildFontFamilyOption(GoogleFonts.roboto().fontFamily!, GoogleFonts.roboto().fontFamily!,
          () => setTextFontFamily(GoogleFonts.roboto().fontFamily!)));
    }
    return Row(children: fontFamilyOptions);
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
