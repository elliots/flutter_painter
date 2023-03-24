import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Represents settings used to create and draw text.
@immutable
class TextSettings {
  /// The text style to be used for new or edited text drawables.
  final TextDrawableSettings style;

  /// Focus node used to edit text.
  /// This focus node will be listened to by the UI to determine user input.
  ///
  /// If a node is not provided, one will be used by default.
  /// However, you won't be able to listen to changes in user input focus.
  final FocusNode? focusNode;

  final List<String> fontFamilyOptions;
  final List<String> fontFamilyOptionsNames;

  /// Creates a [TextSettings] with the given [textStyle] and [focusNode].
  const TextSettings({
    this.style = defaultTextDrawableSettings,
    this.focusNode,
    this.fontFamilyOptions = const [],
    this.fontFamilyOptionsNames = const [],
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  TextSettings copyWith({TextDrawableSettings? style, FocusNode? focusNode}) {
    return TextSettings(
      style: style ?? this.style,
      focusNode: focusNode ?? this.focusNode,
      fontFamilyOptions: fontFamilyOptions,
      fontFamilyOptionsNames: fontFamilyOptionsNames,
    );
  }
}
