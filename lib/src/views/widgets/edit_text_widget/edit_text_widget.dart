import 'package:flutter/material.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/edit_text_widget_ui.dart';

import '../../../../flutter_painter.dart';
import '../../../controllers/notifications/drawable_created_notification.dart';
import '../../../controllers/notifications/drawable_deleted_notification.dart';

/// A dialog-like widget to edit text drawables in.
class EditTextWidget extends StatefulWidget {
  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// The text drawable currently being edited.
  final TextDrawable drawable;

  /// If the text drawable being edited is new or not.
  /// If it is new, the update action is not marked as a new action, so it is merged with
  /// the previous action.
  final bool isNew;

  const EditTextWidget({
    Key? key,
    required this.controller,
    required this.drawable,
    this.isNew = false,
  }) : super(key: key);

  @override
  EditTextWidgetState createState() => EditTextWidgetState();
}

class EditTextWidgetState extends State<EditTextWidget> with WidgetsBindingObserver {
  /// Text editing controller for the [TextField].
  TextEditingController textEditingController = TextEditingController();

  /// The focus node of the [TextField].
  ///
  /// The node provided from the [TextSettings] will be used if provided
  /// Otherwise, it will be initialized to an inner [FocusNode].
  late FocusNode textFieldNode;

  /// The current bottom view insets (the keyboard size on mobile).
  ///
  /// This is used to detect when the keyboard starts closing.
  double bottomViewInsets = 0;

  /// Getter for [TextSettings] from `widget.controller.value` to make code more readable.
  TextSettings get settings => widget.controller.value.settings.text;

  bool disposed = false;

  @override
  void initState() {
    super.initState();

    // Initialize the focus node
    textFieldNode = settings.focusNode ?? FocusNode();
    textFieldNode.addListener(focusListener);

    // Requests focus for the focus node after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      textFieldNode.requestFocus();
    });

    // Initialize the text in the [TextField] to the drawable text
    textEditingController.text = widget.drawable.text;

    // Add this object as an observer for widget bindings
    //
    // This is used to check the bottom view insets (the keyboard size on mobile)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove this object from being an observer
    WidgetsBinding.instance?.removeObserver(this);

    // Stop listening to the focus node
    textFieldNode.removeListener(focusListener);

    // If the focus node was an inner node (not from [TextSettings]), dispose of it
    if (settings.focusNode == null) textFieldNode.dispose();

    // Dispose of the text editing controller
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height, keyboard height, widget height and position
    //
    // This is used to add padding to the text editing widget so that the keyboard
    // doesn't block it
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final renderBox = widget.controller.painterKey.currentContext?.findRenderObject() as RenderBox?;
    final y = renderBox?.localToGlobal(Offset.zero).dy ?? 0;
    final height = renderBox?.size.height ?? screenHeight;

    return EditTextWidgetUI(
      controller: widget.controller,
      drawable: widget.drawable,
      textFieldNode: textFieldNode,
      textEditingController: textEditingController,
      onEditingComplete: onEditingComplete,
      buildEmptyCounter: buildEmptyCounter,
    );
  }

  /// Listener to metrics.
  ///
  /// Used to check bottom insets and lose focus of the focus node if the
  /// mobile keyboard starts closing.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance.window.viewInsets.bottom;

    // If the previous value of bottom view insets is larger than the current value,
    // the keyboard is closing, so lose focus from the focus node
    if ((value ?? bottomViewInsets) < bottomViewInsets && textFieldNode.hasFocus) {
      textFieldNode.unfocus();
    }

    // Update the bottom view insets for next check
    bottomViewInsets = value ?? 0;
  }

  /// Listener to focus events for [textFieldNode]
  void focusListener() {
    if (!mounted) return;
    if (!textFieldNode.hasFocus) {
      onEditingComplete();
    }
  }

  /// Saves the changes to the [widget.drawable] text and closes the editor.
  ///
  /// If the text is empty, it will remove the drawable from the controller.
  void onEditingComplete() {
    if (textEditingController.text.trim().isEmpty) {
      widget.controller.removeDrawable(widget.drawable, false);
      if (!widget.isNew) {
        DrawableDeletedNotification(widget.drawable).dispatch(context);
      }
    } else {
      final drawable = widget.drawable.copyWith(
        text: textEditingController.text.trim(),
        style: settings.textStyle,
        hidden: false,
      );
      updateDrawable(widget.drawable, drawable);
      if (widget.isNew) DrawableCreatedNotification(drawable).dispatch(context);
    }
    if (mounted && !disposed) {
      setState(() {
        disposed = true;
      });

      Navigator.pop(context);
    }
  }

  /// Updates the drawable in the painter controller.
  void updateDrawable(TextDrawable oldDrawable, TextDrawable newDrawable) {
    widget.controller.addDrawables(paintLevelDrawables: [], topLevelDrawables: [newDrawable], newAction: widget.isNew);
  }

  /// Builds a null widget for the [TextField] counter.
  ///
  /// By default, [TextField] shows a character counter if the maxLength attribute
  /// is used. This is to override the counter and display nothing.
  Widget? buildEmptyCounter(BuildContext context,
          {required int currentLength, int? maxLength, required bool isFocused}) =>
      null;
}
