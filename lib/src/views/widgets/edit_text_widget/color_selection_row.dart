import 'package:flutter/material.dart';

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
  Color(0xFFF9D7EA),
  Color(0xFFA4895B),
  Color(0xFF33523D),
  Color(0xFF31688D),
  Color(0xFF92969E),
  Color(0xFF333333),
];

class ColorSelectionRow extends StatelessWidget {
  const ColorSelectionRow({
    Key? key,
    required this.onColorChange,
  }) : super(key: key);

  final void Function(Color) onColorChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        child: Row(
          children: colorOptions
              .map((color) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Material(
                            color: color,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              onTap: () => onColorChange(color),
                              borderRadius: BorderRadius.circular(24),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                              ),
                            )),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
