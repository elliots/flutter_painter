part of 'flutter_painter.dart';

class _TextDrawableOverlayWidget extends StatelessWidget {
  const _TextDrawableOverlayWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          ...PainterController.of(context)
              .value
              .topLevelDrawables
              .whereType<TextDrawable>()
              .toList()
              .map((e) => e.buildStackEntry(maxWidth: constraints.maxWidth)),
        ],
      );
    });
  }
}
