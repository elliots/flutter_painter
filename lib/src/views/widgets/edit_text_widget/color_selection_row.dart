import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/views/widgets/edit_text_widget/bouncing_click_listener.dart';

List<Color> colorOptions = const [
  Color(0xFFFFFFFF),
  Color(0xFF000000),
  Color(0xFFEA4141),
  Color(0xFFFF933D),
  Color(0xFFF2CD44),
  Color(0xFF78C35E),
  Color(0xFF76C9A6),
  Color(0xFF3696F1),
  Color(0xFF2544B1),
  Color(0xFF5756D4),
  Color(0xFFAB47BC),
  Color(0xFFE91E63),
  Color(0xFFF9D7EA),
  Color(0xFF31688D),
  Color(0xFF607D8B),
  Color(0xFF33523D),
  Color(0xFFA4895B),
  Color(0xFF92969E),
];

List<Color> contrastColors = colorOptions.map((e) => e.getContrastColor()).toList();

extension ContrastColor on Color {
  Color getContrastColor() {
    final double relativeLuminance = computeLuminance();

    const double kThreshold = 0.15;
    if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
      // Brightness.light;
      return Colors.black;
    }
    // Brightness.dark;
    return Colors.white;
  }
}

class ColorSelectionRow extends StatelessWidget {
  const ColorSelectionRow({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        child: Row(
          children: colorOptions
              .mapIndexed((i, color) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    child: BouncingClickListener(
                      onTap: () => controller.textStyle = controller.textStyle.copyWith(
                        color: color,
                        contrastColor: contrastColors[i],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Material(
                            color: color,
                            borderRadius: BorderRadius.circular(24),
                            child: const SizedBox(
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
