import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/bouncing_click_listener.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/styled_text_input_field.dart';

import '../../../../flutter_painter.dart';
import 'color_selection_row.dart';
import 'font_style_selection_row.dart';

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
  TextDrawableSettings get textStyle => widget.controller.textStyle;

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
          color: Colors.black.withOpacity(0.25),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Use an offstage widget to keep keyboard focus when switching between
                  // the different style modes and input fields
                  Offstage(
                    child: TextField(
                      controller: widget.textEditingController,
                      focusNode: widget.textFieldNode,
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      clipBehavior: Clip.hardEdge,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {}, // Don't un-focus when tapping the text area
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: StyledTextInputField(
                                textEditingController: widget.textEditingController,
                                focusNode: widget.textFieldNode,
                                controller: widget.controller,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  buildDoneRow(),
                  GestureDetector(
                    onTap: () {}, // Don't un-focus when tapping the bottom area
                    behavior: HitTestBehavior.opaque, // Process clicks even though the background is transparent
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        FontStyleSelectionRow(
                          controller: widget.controller,
                        ),
                        const SizedBox(height: 12),
                        ColorSelectionRow(
                          controller: widget.controller,
                        ),
                        const SizedBox(height: 12),
                      ],
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

  Widget buildDoneRow() {
    return Row(
      children: [
        Expanded(
          child: Container(),
        ),
        BouncingClickListener(
          onTap: () => widget.textFieldNode.unfocus(),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 1.6,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8.0, 16, 8),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Paint? getTextStyleBackground() {
    return Paint()
      ..color = (textStyle.color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
      ..strokeWidth = (/*textStyle.height*/ null ?? 1) * (textStyle.fontSize ?? 20) * 1.45
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }
}
