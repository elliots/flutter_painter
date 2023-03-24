import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/bouncing_click_listener.dart';
import 'package:google_fonts/google_fonts.dart';

class FontStyleSelectionRow extends StatelessWidget {
  const FontStyleSelectionRow({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 16),
      ChangeStyleButton(controller: controller),
      const SizedBox(width: 8),
      ChangeTextAlignmentButton(controller: controller),
      const SizedBox(width: 8),
      ChangeFontSizeButton(controller: controller),
      const SizedBox(width: 8),
      Container(
        color: Colors.white,
        height: 16,
        width: 1,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0, 0.05],
              colors: [
                Colors.white.withOpacity(0), // Fade left edge
                Colors.white.withOpacity(1),
              ],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.srcIn,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.only(left: 4),
            child: buildFontFamilyOptions(),
          ),
        ),
      ),
    ]);
  }

  Row buildFontFamilyOptions() {
    var options = controller.settings.text.fontFamilyOptions;
    var names = controller.settings.text.fontFamilyOptionsNames;
    if (options.isEmpty) {
      options = [
        GoogleFonts.roboto().fontFamily!,
        GoogleFonts.varelaRound().fontFamily!,
      ].whereType<String>().toList();
      names = options.map((e) => e.toString()).toList();
    }
    List<Widget> fontFamilyOptions = [];
    for (int i = 0; i < options.length; i++) {
      fontFamilyOptions.add(FontFamilyButton(
          name: names[i],
          fontFamily: options[i],
          onTap: () {
            controller.textStyle = controller.textStyle.copyWith(fontFamily: options[i]);
          }));
    }
    return Row(children: fontFamilyOptions);
  }
}

class ChangeStyleButton extends StatelessWidget {
  const ChangeStyleButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return BouncingClickListener(
      onTap: () {
        final currentIndex = TextDrawableMode.values.indexOf(controller.textStyle.mode);
        final nextMode = TextDrawableMode.values[(currentIndex + 1) % TextDrawableMode.values.length];
        controller.textStyle = controller.textStyle.copyWith(mode: nextMode);
      },
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
    );
  }
}

class ChangeTextAlignmentButton extends StatelessWidget {
  const ChangeTextAlignmentButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: BouncingClickListener(
        onTap: () {
          var newAlignment = TextAlign.center;
          switch (controller.textStyle.alignment) {
            case TextAlign.left:
              newAlignment = TextAlign.center;
              break;
            case TextAlign.center:
              newAlignment = TextAlign.right;
              break;
            case TextAlign.right:
              newAlignment = TextAlign.left;
              break;
            default:
              break;
          }
          controller.textStyle = controller.textStyle.copyWith(alignment: newAlignment);
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Builder(
              builder: (context) {
                switch (controller.textStyle.alignment) {
                  case TextAlign.left:
                    return const Icon(
                      Icons.format_align_left_rounded,
                      color: Colors.white,
                    );
                  case TextAlign.right:
                    return const Icon(
                      Icons.format_align_right_rounded,
                      color: Colors.white,
                    );
                  default:
                    return const Icon(
                      Icons.format_align_center_rounded,
                      color: Colors.white,
                    );
                }
              },
            ),
          ),
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
      child: BouncingClickListener(
        onTap: () {
          double size = (controller.textStyle.fontSize * 1.5);
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
      child: BouncingClickListener(
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
            ),
          ),
        ),
      ),
    );
  }
}
