import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Represents settings used to create and draw text.
@immutable
class TextSettings {
  /// The text style to be used.
  final TextStyle textStyle;

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
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.focusNode,
    this.fontFamilyOptions = const [],
    this.fontFamilyOptionsNames = const [],
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  TextSettings copyWith({TextStyle? textStyle, FocusNode? focusNode}) {
    return TextSettings(
      textStyle: textStyle ?? this.textStyle,
      focusNode: focusNode ?? this.focusNode,
      fontFamilyOptions: fontFamilyOptions,
      fontFamilyOptionsNames: fontFamilyOptionsNames,
    );
  }
}
