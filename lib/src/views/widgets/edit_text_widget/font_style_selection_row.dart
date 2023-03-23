import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:google_fonts/google_fonts.dart';

class FontStyleSelectionRow extends StatelessWidget {
  const FontStyleSelectionRow({
    Key? key,
    required this.controller,
    required this.changeStyle,
  }) : super(key: key);

  final PainterController controller;
  final void Function() changeStyle;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 16),
      ChangeStyleButton(changeStyle: changeStyle),
      SizedBox(width: 8),
      ChangeFontSizeButton(controller: controller),
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
    ]);
  }

  Row buildFontFamilyOptions() {
    List<Widget> fontFamilyOptions = [];
    for (int i = 0; i < controller.settings.text.fontFamilyOptions.length; i++) {
      fontFamilyOptions.add(FontFamilyButton(
          name: controller.settings.text.fontFamilyOptionsNames[i],
          fontFamily: controller.settings.text.fontFamilyOptions[i],
          onTap: () {
            controller.textStyle =
                controller.textStyle.copyWith(fontFamily: controller.settings.text.fontFamilyOptions[i]);
          }));
    }
    if (fontFamilyOptions.isEmpty) {
      fontFamilyOptions.add(FontFamilyButton(
          name: GoogleFonts.roboto().fontFamily!,
          fontFamily: GoogleFonts.roboto().fontFamily!,
          onTap: () {
            controller.textStyle = controller.textStyle.copyWith(fontFamily: GoogleFonts.roboto().fontFamily!);
          }));
    }
    return Row(children: fontFamilyOptions);
  }
}

class ChangeStyleButton extends StatelessWidget {
  const ChangeStyleButton({
    Key? key,
    required this.changeStyle,
  }) : super(key: key);

  final void Function() changeStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: changeStyle,
        child: Container(
          height: 32,
          width: 32,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
          child: Center(
              child: Text(
            "A",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          )),
        ),
      ),
    );
  }
}

class ChangeFontSizeButton extends StatelessWidget {
  const ChangeFontSizeButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          double size = ((controller.textStyle.fontSize ?? 12) + 12);
          if (size > 72) size = 12;
          controller.textStyle = controller.textStyle.copyWith(fontSize: size);
        },
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Center(
            child: Icon(
              Icons.format_size_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class FontFamilyButton extends StatelessWidget {
  const FontFamilyButton({
    Key? key,
    required this.name,
    required this.fontFamily,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final String fontFamily;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
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
}
